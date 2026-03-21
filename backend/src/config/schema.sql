-- ============================================================
-- Food App Database Schema
-- Server: (LocalDB)\MSSQLLocalDB  (Windows Authentication)
-- ============================================================

USE master;
GO

-- Tạo database nếu chưa tồn tại
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FoodAppDB')
BEGIN
    CREATE DATABASE FoodAppDB;
    PRINT 'Database FoodAppDB created.';
END
GO

USE FoodAppDB;
GO

-- ============================================================
-- DROP tables theo thứ tự reverse dependency
-- ============================================================
IF OBJECT_ID('dbo.OrderItems',   'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID('dbo.Orders',       'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.MenuItems',    'U') IS NOT NULL DROP TABLE dbo.MenuItems;
IF OBJECT_ID('dbo.Addresses',    'U') IS NOT NULL DROP TABLE dbo.Addresses;
IF OBJECT_ID('dbo.Restaurants',  'U') IS NOT NULL DROP TABLE dbo.Restaurants;
IF OBJECT_ID('dbo.Categories',   'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Users',        'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- ============================================================
-- 1. Users
-- ============================================================
CREATE TABLE dbo.Users (
    id          INT            IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100)  NOT NULL,
    email       NVARCHAR(150)  NOT NULL UNIQUE,
    phone       NVARCHAR(20)   NULL,
    password    NVARCHAR(255)  NOT NULL,
    avatar_url  NVARCHAR(500)  NULL,
    address     NVARCHAR(300)  NULL,
    role        NVARCHAR(20)   NOT NULL DEFAULT 'customer',   -- customer | admin
    is_active   BIT            NOT NULL DEFAULT 1,
    created_at  DATETIME2      NOT NULL DEFAULT GETDATE(),
    updated_at  DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 2. Categories
-- ============================================================
CREATE TABLE dbo.Categories (
    id          INT            IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100)  NOT NULL UNIQUE,
    icon        NVARCHAR(10)   NULL,        -- emoji icon
    sort_order  INT            NOT NULL DEFAULT 0,
    is_active   BIT            NOT NULL DEFAULT 1,
    created_at  DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. Restaurants
-- ============================================================
CREATE TABLE dbo.Restaurants (
    id            INT            IDENTITY(1,1) PRIMARY KEY,
    category_id   INT            NOT NULL REFERENCES dbo.Categories(id),
    name          NVARCHAR(200)  NOT NULL,
    description   NVARCHAR(MAX)  NULL,
    address       NVARCHAR(300)  NULL,
    phone         NVARCHAR(20)   NULL,
    image_url     NVARCHAR(500)  NULL,
    latitude      FLOAT          NULL,
    longitude     FLOAT          NULL,
    rating        DECIMAL(3,1)   NOT NULL DEFAULT 0.0,
    review_count  INT            NOT NULL DEFAULT 0,
    delivery_time INT            NOT NULL DEFAULT 30,    -- phút
    delivery_fee  DECIMAL(10,0)  NOT NULL DEFAULT 15000, -- VND
    min_order     DECIMAL(10,0)  NOT NULL DEFAULT 50000, -- VND
    is_open       BIT            NOT NULL DEFAULT 1,
    is_active     BIT            NOT NULL DEFAULT 1,
    created_at    DATETIME2      NOT NULL DEFAULT GETDATE(),
    updated_at    DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 4. MenuItems
-- ============================================================
CREATE TABLE dbo.MenuItems (
    id             INT            IDENTITY(1,1) PRIMARY KEY,
    restaurant_id  INT            NOT NULL REFERENCES dbo.Restaurants(id),
    name           NVARCHAR(200)  NOT NULL,
    description    NVARCHAR(MAX)  NULL,
    price          DECIMAL(10,0)  NOT NULL,              -- VND
    image_url      NVARCHAR(500)  NULL,
    emoji          NVARCHAR(10)   NULL,
    category       NVARCHAR(100)  NULL,                  -- nhóm menu trong nhà hàng
    sort_order     INT            NOT NULL DEFAULT 0,
    is_available   BIT            NOT NULL DEFAULT 1,
    is_best_seller BIT            NOT NULL DEFAULT 0,
    created_at     DATETIME2      NOT NULL DEFAULT GETDATE(),
    updated_at     DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 5. Addresses  (địa chỉ lưu của người dùng)
-- ============================================================
CREATE TABLE dbo.Addresses (
    id         INT            IDENTITY(1,1) PRIMARY KEY,
    user_id    INT            NOT NULL REFERENCES dbo.Users(id) ON DELETE CASCADE,
    label      NVARCHAR(50)   NOT NULL DEFAULT 'Nhà',  -- Nhà | Văn phòng | Khác
    address    NVARCHAR(300)  NOT NULL,
    latitude   FLOAT          NULL,
    longitude  FLOAT          NULL,
    is_default BIT            NOT NULL DEFAULT 0,
    created_at DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 6. Orders
-- ============================================================
CREATE TABLE dbo.Orders (
    id               INT            IDENTITY(1,1) PRIMARY KEY,
    user_id          INT            NOT NULL REFERENCES dbo.Users(id),
    restaurant_id    INT            NOT NULL REFERENCES dbo.Restaurants(id),
    status           NVARCHAR(30)   NOT NULL DEFAULT 'pending',
        -- pending | confirmed | preparing | delivering | delivered | cancelled
    subtotal         DECIMAL(12,0)  NOT NULL DEFAULT 0,
    delivery_fee     DECIMAL(10,0)  NOT NULL DEFAULT 0,
    total            DECIMAL(12,0)  NOT NULL DEFAULT 0,
    delivery_address NVARCHAR(300)  NULL,
    delivery_lat     FLOAT          NULL,
    delivery_lng     FLOAT          NULL,
    note             NVARCHAR(500)  NULL,
    payment_method   NVARCHAR(30)   NOT NULL DEFAULT 'cod',  -- cod | momo | vnpay
    payment_status   NVARCHAR(20)   NOT NULL DEFAULT 'unpaid', -- unpaid | paid
    created_at       DATETIME2      NOT NULL DEFAULT GETDATE(),
    updated_at       DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 7. OrderItems
-- ============================================================
CREATE TABLE dbo.OrderItems (
    id           INT            IDENTITY(1,1) PRIMARY KEY,
    order_id     INT            NOT NULL REFERENCES dbo.Orders(id) ON DELETE CASCADE,
    menu_item_id INT            NULL REFERENCES dbo.MenuItems(id) ON DELETE SET NULL,
    item_name    NVARCHAR(200)  NOT NULL,   -- snapshot tên tại thời điểm đặt
    item_price   DECIMAL(10,0)  NOT NULL,   -- snapshot giá
    quantity     INT            NOT NULL DEFAULT 1,
    subtotal     DECIMAL(12,0)  NOT NULL DEFAULT 0,
    note         NVARCHAR(300)  NULL,
    created_at   DATETIME2      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- Indexes
-- ============================================================
CREATE INDEX IX_Restaurants_category ON dbo.Restaurants(category_id);
CREATE INDEX IX_MenuItems_restaurant  ON dbo.MenuItems(restaurant_id);
CREATE INDEX IX_Orders_user           ON dbo.Orders(user_id);
CREATE INDEX IX_Orders_restaurant     ON dbo.Orders(restaurant_id);
CREATE INDEX IX_OrderItems_order      ON dbo.OrderItems(order_id);
CREATE INDEX IX_Addresses_user        ON dbo.Addresses(user_id);
GO

PRINT '✅ Schema created successfully!';
GO
