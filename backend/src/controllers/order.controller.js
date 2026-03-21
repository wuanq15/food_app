const { sql, getPool } = require('../config/database');

// ─── POST /api/orders ─────────────────────────────────────────
const createOrder = async (req, res) => {
  const { restaurant_id, items, delivery_address, delivery_lat, delivery_lng, note } = req.body;
  const userId = req.user.id;

  // Validate
  if (!restaurant_id || !items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng chọn nhà hàng và ít nhất 1 món',
    });
  }

  if (!delivery_address) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng nhập địa chỉ giao hàng',
    });
  }

  try {
    const pool = await getPool();

    // Lấy thông tin món ăn từ DB để đảm bảo giá chính xác
    const itemIds = items.map((i) => i.menu_item_id);
    const menuResult = await pool.request()
      .input('restaurantId', sql.Int, restaurant_id)
      .query(`
        SELECT id, name, price FROM MenuItems
        WHERE restaurant_id = @restaurantId
          AND id IN (${itemIds.join(',')})
          AND is_available = 1
      `);

    const menuMap = {};
    for (const m of menuResult.recordset) {
      menuMap[m.id] = m;
    }

    // Tính tiền
    let subtotal = 0;
    const orderItems = [];

    for (const item of items) {
      const menuItem = menuMap[item.menu_item_id];
      if (!menuItem) {
        return res.status(400).json({
          success: false,
          message: `Món ID ${item.menu_item_id} không hợp lệ hoặc không có sẵn`,
        });
      }
      const qty = parseInt(item.quantity) || 1;
      const itemSubtotal = menuItem.price * qty;
      subtotal += itemSubtotal;
      orderItems.push({
        menu_item_id: menuItem.id,
        item_name: menuItem.name,
        item_price: menuItem.price,
        quantity: qty,
        subtotal: itemSubtotal,
      });
    }

    const deliveryFee = subtotal >= 150000 ? 0 : 15000;
    const total = subtotal + deliveryFee;

    // Insert Order
    const orderResult = await pool.request()
      .input('user_id',          sql.Int,      userId)
      .input('restaurant_id',    sql.Int,      restaurant_id)
      .input('subtotal',         sql.Decimal,  subtotal)
      .input('delivery_fee',     sql.Decimal,  deliveryFee)
      .input('total',            sql.Decimal,  total)
      .input('delivery_address', sql.NVarChar, delivery_address)
      .input('delivery_lat',     sql.Float,    delivery_lat || null)
      .input('delivery_lng',     sql.Float,    delivery_lng || null)
      .input('note',             sql.NVarChar, note || null)
      .query(`
        INSERT INTO Orders
          (user_id, restaurant_id, status, subtotal, delivery_fee, total,
           delivery_address, delivery_lat, delivery_lng, note)
        OUTPUT INSERTED.id, INSERTED.status, INSERTED.created_at
        VALUES
          (@user_id, @restaurant_id, 'pending', @subtotal, @delivery_fee, @total,
           @delivery_address, @delivery_lat, @delivery_lng, @note)
      `);

    const newOrder = orderResult.recordset[0];
    const orderId = newOrder.id;

    // Insert OrderItems
    for (const item of orderItems) {
      await pool.request()
        .input('order_id',     sql.Int,      orderId)
        .input('menu_item_id', sql.Int,      item.menu_item_id)
        .input('item_name',    sql.NVarChar, item.item_name)
        .input('item_price',   sql.Decimal,  item.item_price)
        .input('quantity',     sql.Int,      item.quantity)
        .input('subtotal',     sql.Decimal,  item.subtotal)
        .query(`
          INSERT INTO OrderItems (order_id, menu_item_id, item_name, item_price, quantity, subtotal)
          VALUES (@order_id, @menu_item_id, @item_name, @item_price, @quantity, @subtotal)
        `);
    }

    return res.status(201).json({
      success: true,
      message: 'Đặt hàng thành công!',
      data: {
        order_id: orderId,
        status: newOrder.status,
        subtotal,
        delivery_fee: deliveryFee,
        total,
        items_count: orderItems.length,
        created_at: newOrder.created_at,
      },
    });
  } catch (err) {
    console.error('CreateOrder error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/orders/history ──────────────────────────────────
const getOrderHistory = async (req, res) => {
  const userId = req.user.id;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('userId', sql.Int, userId)
      .query(`
        SELECT o.id, o.status, o.subtotal, o.delivery_fee, o.total,
               o.delivery_address, o.created_at, o.updated_at,
               r.name AS restaurant_name, r.image_url AS restaurant_image,
               (SELECT COUNT(*) FROM OrderItems oi WHERE oi.order_id = o.id) AS items_count
        FROM Orders o
        JOIN Restaurants r ON o.restaurant_id = r.id
        WHERE o.user_id = @userId
        ORDER BY o.created_at DESC
      `);

    return res.status(200).json({ success: true, data: result.recordset });
  } catch (err) {
    console.error('GetHistory error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/orders/:id ──────────────────────────────────────
const getOrderById = async (req, res) => {
  const { id } = req.params;
  const userId = req.user.id;

  try {
    const pool = await getPool();

    // Lấy thông tin đơn hàng
    const orderResult = await pool.request()
      .input('id',     sql.Int, id)
      .input('userId', sql.Int, userId)
      .query(`
        SELECT o.id, o.status, o.subtotal, o.delivery_fee, o.total,
               o.delivery_address, o.delivery_lat, o.delivery_lng,
               o.note, o.created_at, o.updated_at,
               r.id AS restaurant_id, r.name AS restaurant_name,
               r.image_url AS restaurant_image, r.phone AS restaurant_phone
        FROM Orders o
        JOIN Restaurants r ON o.restaurant_id = r.id
        WHERE o.id = @id AND o.user_id = @userId
      `);

    const order = orderResult.recordset[0];
    if (!order) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
    }

    // Lấy danh sách món
    const itemsResult = await pool.request()
      .input('orderId', sql.Int, id)
      .query(`
        SELECT oi.id, oi.menu_item_id, oi.item_name,
               oi.item_price, oi.quantity, oi.subtotal,
               mi.emoji
        FROM OrderItems oi
        LEFT JOIN MenuItems mi ON oi.menu_item_id = mi.id
        WHERE oi.order_id = @orderId
      `);

    return res.status(200).json({
      success: true,
      data: { ...order, items: itemsResult.recordset },
    });
  } catch (err) {
    console.error('GetOrderById error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

module.exports = { createOrder, getOrderHistory, getOrderById };