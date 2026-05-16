-- Izzamawy Pastry and Delicacies Database Schema

CREATE DATABASE IF NOT EXISTS izzamawy_pastry_shop;
USE izzamawy_pastry_shop;

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(255),
    display_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    image_url VARCHAR(255),
    additional_images TEXT,
    is_featured TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    weight VARCHAR(50),
    ingredients TEXT,
    allergens VARCHAR(255),
    shelf_life VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_category (category_id),
    INDEX idx_featured (is_featured),
    INDEX idx_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Customers Table
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(150) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    province VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20),
    subtotal DECIMAL(10, 2) NOT NULL,
    shipping_fee DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    order_status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
    INDEX idx_customer (customer_id),
    INDEX idx_status (order_status),
    INDEX idx_date (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT,
    product_name VARCHAR(200) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Product stock summary table: tracks current stock and restock flag per product
CREATE TABLE IF NOT EXISTS product_stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    stock_quantity INT DEFAULT 0,
    restock_threshold INT DEFAULT 10,
    restock_required TINYINT(1) DEFAULT 0,
    last_checked TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_stock_qty (stock_quantity),
    INDEX idx_restock (restock_required)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Populate `product_stock` from existing `products` table if empty
INSERT INTO product_stock (product_id, stock_quantity, restock_threshold, restock_required)
SELECT p.id, p.stock_quantity, 10 AS restock_threshold, (p.stock_quantity < 10) AS restock_required
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM product_stock ps WHERE ps.product_id = p.id);

-- Triggers to keep product_stock in sync with products
DELIMITER $$
CREATE TRIGGER trg_products_after_insert
AFTER INSERT ON products FOR EACH ROW
BEGIN
    INSERT INTO product_stock (product_id, stock_quantity, restock_threshold, restock_required, created_at)
    VALUES (NEW.id, NEW.stock_quantity, 10, (NEW.stock_quantity < 10), NOW())
    ON DUPLICATE KEY UPDATE stock_quantity = VALUES(stock_quantity), restock_required = VALUES(restock_required), last_checked = NOW();
END$$

CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON products FOR EACH ROW
BEGIN
    UPDATE product_stock
    SET stock_quantity = NEW.stock_quantity,
        restock_required = (NEW.stock_quantity < restock_threshold),
        last_checked = NOW()
    WHERE product_id = NEW.id;

    -- If no row exists (older installs), insert it
    IF (ROW_COUNT() = 0) THEN
        INSERT INTO product_stock (product_id, stock_quantity, restock_threshold, restock_required, created_at)
        VALUES (NEW.id, NEW.stock_quantity, 10, (NEW.stock_quantity < 10), NOW());
    END IF;
END$$

CREATE TRIGGER trg_products_after_delete
AFTER DELETE ON products FOR EACH ROW
BEGIN
    DELETE FROM product_stock WHERE product_id = OLD.id;
END$$
DELIMITER ;

-- Admin Users Table
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    role ENUM('admin', 'manager', 'staff') DEFAULT 'staff',
    is_active TINYINT(1) DEFAULT 1,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Sample Categories
INSERT INTO categories (name, description, image_url, display_order) VALUES
('Fish Crackers', 'Crispy and delicious fish crackers, perfect pasalubong', 'images/categories/fish-crackers.jpg', 1),
('Cookies', 'Homemade cookies with authentic Filipino flavors', 'images/categories/cookies.jpg', 2),
('Local Delicacies', 'Traditional Filipino treats and sweets', 'images/categories/delicacies.jpg', 3),
('Gift Boxes', 'Beautifully packaged gift boxes for special occasions', 'images/categories/gift-boxes.jpg', 4);

-- Insert Sample Products
INSERT INTO products (category_id, name, description, price, stock_quantity, image_url, is_featured, weight) VALUES
(1, 'Premium Fish Crackers', 'Authentic fish crackers made from fresh ingredients. Crispy and flavorful.', 150.00, 100, 'images/products/fish-crackers-1.jpg', 1, '250g'),
(1, 'Spicy Fish Crackers', 'Our signature fish crackers with a spicy kick. Perfect for those who love heat.', 165.00, 80, 'images/products/fish-crackers-2.jpg', 0, '250g'),
(2, 'Butter Cookies Classic', 'Melt-in-your-mouth butter cookies, a timeless favorite.', 120.00, 150, 'images/products/butter-cookies.jpg', 1, '300g'),
(2, 'Chocolate Chip Cookies', 'Loaded with chocolate chips, perfect with coffee or tea.', 135.00, 120, 'images/products/choco-chip.jpg', 1, '300g'),
(3, 'Polvoron Assorted', 'Traditional Filipino shortbread in assorted flavors: classic, ube, pinipig.', 180.00, 90, 'images/products/polvoron.jpg', 1, '400g'),
(3, 'Yema Candy', 'Sweet and creamy yema wrapped individually. A Filipino favorite.', 95.00, 110, 'images/products/yema.jpg', 0, '200g'),
(3, 'Pastillas de Leche', 'Soft milk candies that melt in your mouth. Authentic recipe.', 85.00, 130, 'images/products/pastillas.jpg', 0, '200g'),
(4, 'Deluxe Gift Box', 'Premium selection of our bestsellers, beautifully packaged.', 450.00, 50, 'images/products/gift-box-1.jpg', 1, '1kg'),
(4, 'Small Gift Pack', 'Perfect starter pack with a variety of our products.', 250.00, 75, 'images/products/gift-box-2.jpg', 0, '500g');

-- Insert Default Admin User (username: admin, password: admin123)
-- Password is hashed using PHP password_hash() with PASSWORD_DEFAULT
INSERT INTO admin_users (username, password_hash, full_name, email, role) VALUES
('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrator', 'admin@izzamawy.com', 'admin');

-- Users Table: stores credential records for site users (username + password)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    customer_id INT NULL,
    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_customer (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Remember tokens and login attempts (included here so schema.sql is self-contained)
CREATE TABLE IF NOT EXISTS remember_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    selector VARCHAR(32) NOT NULL UNIQUE,
    token_hash VARCHAR(255) NOT NULL,
    customer_id INT NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used DATETIME DEFAULT NULL,
    user_agent VARCHAR(255) DEFAULT NULL,
    ip_address VARCHAR(45) DEFAULT NULL,
    INDEX idx_remember_customer (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ip_address VARCHAR(45) NOT NULL,
    attempts INT DEFAULT 0,
    last_attempt DATETIME DEFAULT NULL,
    locked_until DATETIME DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_ip (ip_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
