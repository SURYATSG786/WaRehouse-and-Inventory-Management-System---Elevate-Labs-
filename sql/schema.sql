CREATE DATABASE IF NOT EXISTS warehouse_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE warehouse_db;

CREATE TABLE suppliers (
    supplier_id     INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name   VARCHAR(100)  NOT NULL,
    contact_person  VARCHAR(100),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    city            VARCHAR(50),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE warehouses (
    warehouse_id    INT AUTO_INCREMENT PRIMARY KEY,
    warehouse_name  VARCHAR(100) NOT NULL,
    city            VARCHAR(50)  NOT NULL,
    capacity_units  INT NOT NULL DEFAULT 10000,
    manager_name    VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id       INT AUTO_INCREMENT PRIMARY KEY,
    sku              VARCHAR(30)  NOT NULL UNIQUE,
    product_name     VARCHAR(150) NOT NULL,
    category_id      INT,
    supplier_id      INT,
    unit_price       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    reorder_level    INT NOT NULL DEFAULT 20,
    reorder_quantity INT NOT NULL DEFAULT 50,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_products_reference_categories FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_products_reference_suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE stock (
    stock_id        INT AUTO_INCREMENT PRIMARY KEY,
    product_id      INT NOT NULL,
    warehouse_id    INT NOT NULL,
    quantity        INT NOT NULL DEFAULT 0,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_stock_references_products FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_stock_references_warehouses FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_one_stock_row_per_product_per_warehouse UNIQUE (product_id, warehouse_id),
    CONSTRAINT chk_stock_quantity_cannot_be_negative CHECK (quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE stock_transactions (
    transaction_id      INT AUTO_INCREMENT PRIMARY KEY,
    product_id          INT NOT NULL,
    warehouse_id        INT NOT NULL,
    transaction_type     ENUM('IN','OUT','TRANSFER_IN','TRANSFER_OUT','ADJUSTMENT') NOT NULL,
    quantity            INT NOT NULL,
    related_warehouse_id INT NULL,
    reference_note       VARCHAR(200),
    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_reference_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_transactions_reference_warehouses FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT fk_transactions_reference_related_warehouse FOREIGN KEY (related_warehouse_id) REFERENCES warehouses(warehouse_id),
    CONSTRAINT chk_transaction_quantity_must_be_positive CHECK (quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE low_stock_alerts (
    alert_id        INT AUTO_INCREMENT PRIMARY KEY,
    product_id      INT NOT NULL,
    warehouse_id    INT NOT NULL,
    quantity_at_alert INT NOT NULL,
    reorder_level   INT NOT NULL,
    status          ENUM('OPEN','RESOLVED') NOT NULL DEFAULT 'OPEN',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at     TIMESTAMP NULL,
    CONSTRAINT fk_alerts_reference_products FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_alerts_reference_warehouses FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE purchase_orders (
    po_id           INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id     INT NOT NULL,
    warehouse_id    INT NOT NULL,
    order_date      DATE NOT NULL DEFAULT (CURRENT_DATE),
    expected_date   DATE,
    status          ENUM('PENDING','RECEIVED','CANCELLED') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_purchase_orders_reference_suppliers FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_purchase_orders_reference_warehouses FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE purchase_order_items (
    po_item_id       INT AUTO_INCREMENT PRIMARY KEY,
    po_id            INT NOT NULL,
    product_id       INT NOT NULL,
    quantity_ordered INT NOT NULL,
    unit_cost        DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_order_items_reference_purchase_orders FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_items_reference_products FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE INDEX idx_transactions_by_product_and_date   ON stock_transactions(product_id, created_at);
CREATE INDEX idx_transactions_by_warehouse_and_date ON stock_transactions(warehouse_id, created_at);
CREATE INDEX idx_stock_by_quantity     ON stock(quantity);
CREATE INDEX idx_products_by_category  ON products(category_id);
