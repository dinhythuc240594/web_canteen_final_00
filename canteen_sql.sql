-- Tạo database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS canteen_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Sử dụng database
USE canteen_db;

-- Bảng users
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    photo BLOB,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    role ENUM('admin', 'stall', 'customer') DEFAULT 'customer', -- admin = quản trị, staff = quầy, customer = khách
    status BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stalls (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_user_id INT UNIQUE NOT NULL, -- ID của tài khoản Quầy (Liên kết 1-1 với users)
    is_open BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (manager_user_id) REFERENCES users(id)
);

-- Bảng food_categories
CREATE TABLE IF NOT EXISTS food_categories (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Đổi 'id' thành 'category_id' để thống nhất
    name VARCHAR(255) NOT NULL UNIQUE,
	description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Bảng foods
CREATE TABLE IF NOT EXISTS foods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    image BLOB,
    name VARCHAR(100) NOT NULL,
    price DOUBLE NOT NULL DEFAULT 0.0,
    inventory INT NOT NULL DEFAULT 0,
    stall_id INT NOT NULL,
    description TEXT,
    is_available BOOLEAN DEFAULT TRUE, -- Trạng thái còn/hết hàng
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (stall_id) REFERENCES stalls(id),
    FOREIGN KEY (category_id) REFERENCES food_categories(id),

    CHECK (price >= 0),
    CHECK (inventory >= 0)
);

-- Bảng orders
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    stall_id INT NOT NULL, -- Quầy cung cấp món
    total_price DOUBLE NOT NULL DEFAULT 0.0,
    status ENUM('new_order', 'confirmed', 'in_delivery', 'delivered') DEFAULT 'new_order',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_location VARCHAR(255),
    payment_method VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (stall_id) REFERENCES stalls(id)
);

-- Bảng order_foods (dùng để lưu list<Food> trong Order)
CREATE TABLE IF NOT EXISTS order_foods (
	id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    food_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_order DOUBLE NOT NULL DEFAULT 0.0,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (food_id) REFERENCES foods(id),
    CHECK (quantity > 0)
);

-- Bảng statistics (dùng để thống kê đơn hàng)
CREATE TABLE IF NOT EXISTS statistics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stat_date DATE NOT NULL,
    stall_id INT,
    food_id INT,
    orders_count INT DEFAULT 0,
    revenue DOUBLE DEFAULT 0.0,
    quantity_sold INT DEFAULT 0,
    UNIQUE(stat_date, stall_id, food_id), 
   	FOREIGN KEY (stall_id) REFERENCES stalls(id),
    FOREIGN KEY (food_id) REFERENCES foods(id)
);

CREATE INDEX idx_orders_user_status ON orders (user_id, status);
CREATE INDEX idx_orders_stall_date ON orders (stall_id, created_at);
CREATE INDEX idx_foods_stall_available ON foods (stall_id, is_available);

ALTER TABLE foods ADD COLUMN promotion DECIMAL(5, 2) DEFAULT 0.00 COMMENT 'Phần trăm giảm giá (0.00 đến 99.99)';