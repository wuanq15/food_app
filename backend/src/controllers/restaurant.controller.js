const { sql, getPool } = require('../config/database');

// ─── Haversine: tính khoảng cách (km) giữa 2 tọa độ ─────────
const haversine = (lat1, lng1, lat2, lng2) => {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
    Math.cos((lat2 * Math.PI) / 180) *
    Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
};

// ─── GET /api/restaurants ─────────────────────────────────────
const getRestaurants = async (req, res) => {
  const { category, search, lat, lng } = req.query;

  try {
    const pool = await getPool();
    let query = `
      SELECT r.id, r.name, r.description, r.address, r.image_url,
             r.latitude, r.longitude, r.rating, r.review_count,
             r.delivery_time, r.delivery_fee, r.min_order, r.is_open,
             c.name AS category_name, c.icon AS category_icon
      FROM Restaurants r
      JOIN Categories c ON r.category_id = c.id
      WHERE r.is_active = 1
    `;

    const request = pool.request();

    if (category) {
      query += ` AND c.name = @category`;
      request.input('category', sql.NVarChar, category);
    }

    if (search) {
      query += ` AND (r.name LIKE @search OR c.name LIKE @search)`;
      request.input('search', sql.NVarChar, `%${search}%`);
    }

    query += ` ORDER BY r.rating DESC, r.review_count DESC`;

    const result = await request.query(query);
    let restaurants = result.recordset;

    // Nếu có tọa độ → tính khoảng cách và sắp xếp theo gần nhất
    if (lat && lng) {
      const userLat = parseFloat(lat);
      const userLng = parseFloat(lng);
      restaurants = restaurants
        .map((r) => ({
          ...r,
          distance_km: r.latitude && r.longitude
            ? parseFloat(haversine(userLat, userLng, r.latitude, r.longitude).toFixed(1))
            : null,
        }))
        .sort((a, b) => (a.distance_km ?? 999) - (b.distance_km ?? 999));
    }

    return res.status(200).json({ success: true, data: restaurants });
  } catch (err) {
    console.error('GetRestaurants error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/restaurants/:id ─────────────────────────────────
const getRestaurantById = async (req, res) => {
  const { id } = req.params;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query(`
        SELECT r.id, r.name, r.description, r.address, r.phone,
               r.image_url, r.latitude, r.longitude,
               r.rating, r.review_count, r.delivery_time,
               r.delivery_fee, r.min_order, r.is_open,
               c.name AS category_name, c.icon AS category_icon
        FROM Restaurants r
        JOIN Categories c ON r.category_id = c.id
        WHERE r.id = @id AND r.is_active = 1
      `);

    const restaurant = result.recordset[0];
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy nhà hàng' });
    }

    return res.status(200).json({ success: true, data: restaurant });
  } catch (err) {
    console.error('GetRestaurantById error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/restaurants/:id/menu ───────────────────────────
const getRestaurantMenu = async (req, res) => {
  const { id } = req.params;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query(`
        SELECT id, restaurant_id, name, description, price,
               image_url, emoji, category, is_available, is_best_seller
        FROM MenuItems
        WHERE restaurant_id = @id AND is_available = 1
        ORDER BY category, sort_order, id
      `);

    // Group theo category
    const grouped = {};
    for (const item of result.recordset) {
      const cat = item.category || 'Khác';
      if (!grouped[cat]) grouped[cat] = [];
      grouped[cat].push(item);
    }

    return res.status(200).json({
      success: true,
      data: {
        items: result.recordset,
        grouped,
      },
    });
  } catch (err) {
    console.error('GetMenu error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/categories ─────────────────────────────────────
const getCategories = async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request()
      .query(`
        SELECT id, name, icon
        FROM Categories
        WHERE is_active = 1
        ORDER BY sort_order
      `);

    return res.status(200).json({ success: true, data: result.recordset });
  } catch (err) {
    console.error('GetCategories error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/recommend?lat=&lng= ────────────────────────────
// KNN đơn giản: lấy k nhà hàng gần nhất đang mở
const getRecommendations = async (req, res) => {
  const { lat, lng, k = 5 } = req.query;

  if (!lat || !lng) {
    return res.status(400).json({
      success: false,
      message: 'Cần cung cấp tọa độ lat và lng',
    });
  }

  try {
    const pool = await getPool();
    const result = await pool.request().query(`
      SELECT r.id, r.name, r.image_url, r.latitude, r.longitude,
             r.rating, r.delivery_time, r.delivery_fee, r.is_open,
             c.name AS category_name, c.icon AS category_icon
      FROM Restaurants r
      JOIN Categories c ON r.category_id = c.id
      WHERE r.is_active = 1 AND r.is_open = 1
        AND r.latitude IS NOT NULL AND r.longitude IS NOT NULL
    `);

    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const kInt = Math.min(parseInt(k), 20);

    const withDistance = result.recordset
      .map((r) => ({
        ...r,
        distance_km: parseFloat(haversine(userLat, userLng, r.latitude, r.longitude).toFixed(1)),
      }))
      .sort((a, b) => a.distance_km - b.distance_km)
      .slice(0, kInt);

    return res.status(200).json({ success: true, data: withDistance });
  } catch (err) {
    console.error('Recommend error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// ─── GET /api/menu/:id ───────────────────────────────────────
const getMenuItemById = async (req, res) => {
  const { id } = req.params;

  try {
    const pool = await getPool();
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query(`
        SELECT mi.id, mi.restaurant_id, mi.name, mi.description,
               mi.price, mi.image_url, mi.emoji, mi.category,
               mi.is_available, mi.is_best_seller,
               r.name AS restaurant_name
        FROM MenuItems mi
        JOIN Restaurants r ON mi.restaurant_id = r.id
        WHERE mi.id = @id AND mi.is_available = 1
      `);

    const item = result.recordset[0];
    if (!item) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy món ăn' });
    }

    return res.status(200).json({ success: true, data: item });
  } catch (err) {
    console.error('GetMenuItemById error:', err);
    return res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

module.exports = {
  getRestaurants,
  getRestaurantById,
  getRestaurantMenu,
  getMenuItemById,
  getCategories,
  getRecommendations,
};