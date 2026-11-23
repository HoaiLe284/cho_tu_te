DROP DATABASE IF EXISTS cho_tu_te;
CREATE DATABASE cho_tu_te CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cho_tu_te;

CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NULL,
  phone VARCHAR(20) NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','seller','buyer') NOT NULL DEFAULT 'buyer',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE products (
  id INT NOT NULL AUTO_INCREMENT,
  seller_id INT NOT NULL,
  name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 0,
  story TEXT NULL,
  donation_percent INT NOT NULL DEFAULT 10,
  video_url VARCHAR(255) NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_products_seller (seller_id),
  KEY idx_products_status (status),
  CONSTRAINT fk_products_seller FOREIGN KEY (seller_id) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE product_images (
  id INT NOT NULL AUTO_INCREMENT,
  product_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_images_product (product_id),
  CONSTRAINT fk_images_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE product_colors (
  id INT NOT NULL AUTO_INCREMENT,
  product_id INT NOT NULL,
  color_name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_color (product_id, color_name),
  CONSTRAINT fk_colors_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  color_id INT NULL,
  quantity INT NOT NULL DEFAULT 1,
  added_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_item (user_id, product_id, color_id),
  KEY idx_cart_product (product_id),
  KEY idx_cart_color (color_id),
  CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_color FOREIGN KEY (color_id) REFERENCES product_colors (id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
  id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  receiver_name VARCHAR(100) NOT NULL,
  receiver_phone VARCHAR(20) NOT NULL,
  shipping_address TEXT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expected_delivery_date DATE NULL,
  status ENUM('pending','confirmed','shipping','completed','cancelled') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (id),
  KEY idx_orders_customer (customer_id),
  KEY idx_orders_status (status),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES users (id)
) ENGINE=InnoDB;

CREATE TABLE order_details (
  id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  color_id INT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_details_order (order_id),
  KEY idx_details_product (product_id),
  KEY idx_details_color (color_id),
  CONSTRAINT fk_details_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
  CONSTRAINT fk_details_product FOREIGN KEY (product_id) REFERENCES products (id),
  CONSTRAINT fk_details_color FOREIGN KEY (color_id) REFERENCES product_colors (id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE donations (
  id INT NOT NULL AUTO_INCREMENT,
  order_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  donation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_donations_order (order_id),
  CONSTRAINT fk_donations_order FOREIGN KEY (order_id) REFERENCES orders (id)
) ENGINE=InnoDB;