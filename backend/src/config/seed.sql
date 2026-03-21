-- ============================================================
-- Food App - Seed Data
-- Server: (LocalDB)\MSSQLLocalDB  (Windows Authentication)
-- ============================================================

USE FoodAppDB;
GO

-- ============================================================
-- 1. Categories (8 categories)
-- ============================================================
INSERT INTO dbo.Categories (name, icon, sort_order) VALUES
(N'Cơm',          N'🍚', 1),
(N'Bún - Phở',   N'🍜', 2),
(N'Bánh mì',     N'🥖', 3),
(N'Pizza',        N'🍕', 4),
(N'Burger',       N'🍔', 5),
(N'Chay',         N'🥗', 6),
(N'Lẩu',         N'🍲', 7),
(N'Đồ uống',     N'🧋', 8);
GO

-- ============================================================
-- 2. Restaurants (5 nhà hàng)
-- ============================================================
-- category_id: 1=Cơm, 2=Bún-Phở, 3=Bánh mì, 4=Pizza, 5=Burger, 6=Chay, 7=Lẩu, 8=Đồ uống

INSERT INTO dbo.Restaurants
  (category_id, name, description, address, phone, image_url, latitude, longitude,
   rating, review_count, delivery_time, delivery_fee, min_order, is_open)
VALUES
-- 1: Cơm tấm Sài Gòn
(1,
 N'Cơm Tấm Sài Gòn',
 N'Cơm tấm đặc sản Sài Gòn với sườn nướng thơm lừng, bì sợi giòn, chả trứng mềm mịn. Thực đơn phong phú hơn 20 món.',
 N'12 Nguyễn Trãi, Quận 1, TP.HCM',
 N'0901234567',
 N'https://images.unsplash.com/photo-1555126634-323283e090fa?w=400',
 10.7769, 106.6980, 4.7, 2340, 25, 15000, 50000, 1),

-- 2: Phở Hà Nội
(2,
 N'Phở Hà Nội Truyền Thống',
 N'Phở bò Hà Nội nấu từ xương bò hầm 12 tiếng, nước dùng trong và ngọt thanh. Bún bò Huế cay đúng vị.',
 N'45 Đinh Tiên Hoàng, Bình Thạnh, TP.HCM',
 N'0912345678',
 N'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
 10.8009, 106.7095, 4.8, 1876, 20, 10000, 60000, 1),

-- 3: Pizza 4P's
(4,
 N'Pizza House HCM',
 N'Pizza theo phong cách Ý chính gốc với nguyên liệu nhập khẩu. Vỏ bánh mỏng giòn, topping đa dạng.',
 N'8 Đống Đa, Tân Bình, TP.HCM',
 N'0923456789',
 N'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
 10.8021, 106.6538, 4.5, 987, 35, 20000, 100000, 1),

-- 4: Burger Bò Mỹ
(5,
 N'Burger Bò Mỹ Premium',
 N'Burger thịt bò Mỹ 100% xay thủ công, kết hợp sốt đặc biệt và rau tươi. Khoai tây chiên giòn đi kèm.',
 N'99 Cách Mạng Tháng 8, Quận 3, TP.HCM',
 N'0934567890',
 N'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
 10.7756, 106.6818, 4.6, 1432, 30, 15000, 80000, 1),

-- 5: Lẩu Thái
(7,
 N'Lẩu Thái Chua Cay',
 N'Lẩu Thái tom yum nước dùng đậm đà từ sả, lá chanh, ớt tươi. Hải sản tươi sống nhập hàng ngày.',
 N'234 Nguyễn Đình Chiểu, Quận 3, TP.HCM',
 N'0945678901',
 N'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
 10.7720, 106.6862, 4.4, 756, 40, 25000, 150000, 1);
GO

-- ============================================================
-- 3. MenuItems - Restaurant 1: Cơm Tấm Sài Gòn
-- ============================================================
INSERT INTO dbo.MenuItems (restaurant_id, name, description, price, emoji, category, sort_order, is_best_seller) VALUES
(1, N'Cơm tấm sườn bì chả',      N'Sườn nướng mật ong, bì sợi, chả trứng, dưa leo, cà chua',                 55000, N'🍚', N'Cơm tấm đặc biệt', 1,  1),
(1, N'Cơm tấm sườn nướng',       N'Sườn heo nướng than hoa vàng đều, thơm',                                   45000, N'🥩', N'Cơm tấm đặc biệt', 2,  0),
(1, N'Cơm tấm bì chả',           N'Bì sợi giòn + chả trứng mềm, cơm tấm dẻo',                                40000, N'🍳', N'Cơm tấm đặc biệt', 3,  0),
(1, N'Cơm tấm đặc biệt',         N'2 sườn + bì + chả + trứng ốp la, đầy đủ topping',                         75000, N'⭐', N'Cơm tấm đặc biệt', 4,  1),
(1, N'Cơm chiên dương châu',      N'Cơm chiên trứng, xúc xích, hành lá thơm',                                 45000, N'🍳', N'Cơm khác', 5,          0),
(1, N'Nước mắm cơm tấm',         N'Nước mắm pha đặc trưng cơm tấm Sài Gòn',                                  5000,  N'🫙', N'Thêm vào', 6,         0),
(1, N'Nước ngọt',                N'Pepsi / Coca / 7UP lon 330ml',                                              15000, N'🥤', N'Đồ uống', 7,          0);
GO

-- ============================================================
-- MenuItems - Restaurant 2: Phở Hà Nội
-- ============================================================
INSERT INTO dbo.MenuItems (restaurant_id, name, description, price, emoji, category, sort_order, is_best_seller) VALUES
(2, N'Phở bò tái chín',           N'Tái nạm gầu gân, nước dùng hầm 12h trong vắt, bánh phở dai',              65000, N'🍜', N'Phở bò', 1,           1),
(2, N'Phở bò đặc biệt',           N'Tái + chín + gầu + gân + sách, đầy đủ topping',                           85000, N'⭐', N'Phở bò', 2,           1),
(2, N'Phở bò tái',                N'Tái hồng, ăn kèm rau thơm, giá đỗ, chanh ớt',                             60000, N'🍜', N'Phở bò', 3,           0),
(2, N'Bún bò Huế',                N'Nước dùng cay đậm đà mắm ruốc, bò + giò heo',                             70000, N'🌶️', N'Bún', 4,             1),
(2, N'Bún riêu cua',              N'Riêu cua đồng, cà chua, đậu hũ chiên, bún sợi nhỏ',                       65000, N'🦀', N'Bún', 5,              0),
(2, N'Bánh cuốn nhân thịt',       N'Bánh cuốn hấp mềm, nhân thịt hành, ăn kèm chả lụa',                       55000, N'🫔', N'Bánh', 6,             0),
(2, N'Nước chanh',                N'Chanh tươi vắt, đá, đường',                                                15000, N'🍋', N'Đồ uống', 7,           0),
(2, N'Trà đá',                    N'Trà vỉa hè truyền thống',                                                  5000,  N'🍵', N'Đồ uống', 8,           0);
GO

-- ============================================================
-- MenuItems - Restaurant 3: Pizza House
-- ============================================================
INSERT INTO dbo.MenuItems (restaurant_id, name, description, price, emoji, category, sort_order, is_best_seller) VALUES
(3, N'Pizza Margherita',          N'Sốt cà chua, phô mai mozzarella, lá basil tươi, vỏ mỏng giòn',            125000, N'🍕', N'Pizza truyền thống', 1, 1),
(3, N'Pizza Pepperoni',           N'Xúc xích pepperoni Ý, phô mai kéo sợi, sốt cà chua đậm',                  145000, N'🍕', N'Pizza truyền thống', 2, 1),
(3, N'Pizza BBQ Chicken',         N'Gà nướng BBQ, hành tây, sốt BBQ ngọt khói',                               145000, N'🍗', N'Pizza gà', 3,          0),
(3, N'Pizza 4 Mùa',               N'Nấm, ô liu đen, ớt chuông, thịt nguội, phô mai 4 loại',                  165000, N'🏅', N'Pizza đặc biệt', 4,    0),
(3, N'Mì Ý Carbonara',            N'Mì spaghetti, kem tươi, thịt xông khói, trứng lòng đào',                  95000, N'🍝', N'Mì Ý', 5,              0),
(3, N'Salad Ý Caesar',            N'Xà lách romaine, vụn bánh mì, sốt Caesar, phô mai parmesan',               75000, N'🥗', N'Khai vị', 6,           0),
(3, N'Nước Ép Cam',               N'Cam tươi vắt 100%',                                                        35000, N'🍊', N'Đồ uống', 7,           0);
GO

-- ============================================================
-- MenuItems - Restaurant 4: Burger Bò Mỹ
-- ============================================================
INSERT INTO dbo.MenuItems (restaurant_id, name, description, price, emoji, category, sort_order, is_best_seller) VALUES
(4, N'Classic Beef Burger',       N'Thịt bò Mỹ 150g, phô mai cheddar, xà lách, cà chua, sốt đặc biệt',       89000, N'🍔', N'Burger', 1,            1),
(4, N'Double Smash Burger',       N'2 lớp thịt bò xay thủ công, phô mai chảy, dưa chua, hành caramel',        129000,N'🍔', N'Burger', 2,            1),
(4, N'Crispy Chicken Burger',     N'Gà chiên giòn vàng ươm, sốt mayo tỏi, bắp cải muối',                       79000, N'🐔', N'Burger', 3,            0),
(4, N'Mushroom Swiss Burger',     N'Nấm sauté, phô mai Swiss, thịt bò, sốt demi-glace',                        109000,N'🍄', N'Burger', 4,            0),
(4, N'Khoai tây chiên vừa',       N'Khoai tây cắt miếng to, chiên vàng giòn, muối, ớt bột',                    35000, N'🍟', N'Món phụ', 5,           0),
(4, N'Khoai tây chiên lớn',       N'Size lớn khoai tây chiên, dip sốt phô mai hoặc ranch',                     45000, N'🍟', N'Món phụ', 6,           0),
(4, N'Coca-Cola',                 N'Lon 330ml',                                                                 20000, N'🥤', N'Đồ uống', 7,           0),
(4, N'Nước suối',                 N'Chai 500ml',                                                                10000, N'💧', N'Đồ uống', 8,           0);
GO

-- ============================================================
-- MenuItems - Restaurant 5: Lẩu Thái
-- ============================================================
INSERT INTO dbo.MenuItems (restaurant_id, name, description, price, emoji, category, sort_order, is_best_seller) VALUES
(5, N'Lẩu Thái tom yum hải sản',  N'Nước dùng tom yum sả chanh, tôm cá mực tươi, nấm rơm',                    280000,N'🦐', N'Lẩu', 1,              1),
(5, N'Lẩu Thái gà',               N'Nước dùng Tom Kha Gai, gà ta, nấm, rau tươi',                              220000,N'🍗', N'Lẩu', 2,              0),
(5, N'Lẩu Thái hải sản đặc biệt', N'Tôm hùm baby, mực lá, ngao, cua, cá mú tươi sống',                       450000,N'🦞', N'Lẩu', 3,              1),
(5, N'Tôm sú nướng muối ớt',      N'Tôm sú size 30, nướng muối ớt thơm ngon',                                  150000,N'🍤', N'Hải sản', 4,          0),
(5, N'Mực chiên giòn',            N'Mực ống tươi cắt khoanh, tẩm bột chiên vàng giòn',                         95000, N'🦑', N'Hải sản', 5,          0),
(5, N'Rau ăn lẩu',                N'Đĩa rau tổng hợp: mồng tơi, rau muống, nấm kim châm...',                   35000, N'🥬', N'Thêm vào', 6,         0),
(5, N'Mì / Bún / Miến',           N'Lựa chọn tinh bột ăn kèm lẩu',                                             20000, N'🍝', N'Thêm vào', 7,         0),
(5, N'Bia Singha',                N'Bia Thái Lan lon 330ml',                                                    35000, N'🍺', N'Đồ uống', 8,           0);
GO

PRINT '✅ Seed data inserted successfully!';
PRINT '   - Categories: 8';
PRINT '   - Restaurants: 5';
PRINT '   - MenuItems: 38';
GO
