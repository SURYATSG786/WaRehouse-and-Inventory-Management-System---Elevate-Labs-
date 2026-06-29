USE warehouse_db;

INSERT INTO suppliers (supplier_name, contact_person, phone, email, city) VALUES
('Crescent Electronics Pvt Ltd', 'Arjun Mehta',   '9840012345', 'sales@crescentelectronics.in', 'Chennai'),
('BrightTech Distributors',     'Sara Khan',      '9876543210', 'orders@brighttech.in',         'Bengaluru'),
('IronWorks Hardware Supply',   'Ravi Kumar',     '9123456780', 'contact@ironworks.in',          'Coimbatore'),
('Apex Office Essentials',      'Divya Rao',      '9988776655', 'support@apexoffice.in',          'Mumbai'),
('Northline Packaging Co.',     'Karthik S',      '9001122334', 'info@northlinepack.in',          'Hyderabad');

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Hardware Tools'), ('Office Supplies'), ('Packaging Materials'), ('Computer Accessories');

INSERT INTO warehouses (warehouse_name, city, capacity_units, manager_name) VALUES
('Chennai Central Warehouse',  'Chennai',    15000, 'Lakshmi Narayanan'),
('Bengaluru Tech Park Hub',    'Bengaluru',  12000, 'Pooja Reddy'),
('Mumbai Distribution Center', 'Mumbai',     18000, 'Imran Sheikh');

INSERT INTO products (sku, product_name, category_id, supplier_id, unit_price, reorder_level, reorder_quantity) VALUES
('ELE-1001', 'USB-C Charging Cable 1m',          1, 1, 149.00,  40, 100),
('ELE-1002', 'Wireless Mouse 2.4GHz',             1, 2, 599.00,  25,  60),
('ELE-1003', 'Bluetooth Speaker Mini',            1, 2, 1299.00, 15,  40),
('ELE-1004', 'Power Bank 10000mAh',               1, 1, 999.00,  20,  50),
('HRD-2001', 'Cordless Screwdriver Set',          2, 3, 1499.00, 10,  25),
('HRD-2002', 'Adjustable Wrench 10-inch',         2, 3, 349.00,  30,  60),
('HRD-2003', 'Measuring Tape 5m',                 2, 3, 199.00,  35,  70),
('OFF-3001', 'A4 Paper Ream (500 sheets)',        3, 4, 279.00,  50, 120),
('OFF-3002', 'Ballpoint Pen Box (50 pcs)',        3, 4, 199.00,  60, 150),
('OFF-3003', 'Sticky Notes Pack',                 3, 4, 89.00,   45,  90),
('PKG-4001', 'Corrugated Box Medium',             4, 5, 39.00,   100, 300),
('PKG-4002', 'Bubble Wrap Roll 50m',              4, 5, 599.00,  20,  50),
('CMP-5001', 'USB Flash Drive 64GB',              5, 2, 449.00,  30,  80),
('CMP-5002', 'HDMI Cable 2m',                     5, 1, 249.00,  25,  60),
('CMP-5003', 'Laptop Cooling Pad',                5, 2, 899.00,  15,  35);

INSERT INTO stock (product_id, warehouse_id, quantity) VALUES

(1, 1, 180), (2, 1, 90), (3, 1, 12), (4, 1, 75), (5, 1, 22),
(6, 1, 110), (7, 1, 140), (8, 1, 200), (9, 1, 18), (10, 1, 160),
(11, 1, 420), (12, 1, 65), (13, 1, 95), (14, 1, 70), (15, 1, 40),

(1, 2, 60), (2, 2, 14), (3, 2, 30), (4, 2, 55), (5, 2, 28),
(6, 2, 80), (7, 2, 30), (8, 2, 95), (9, 2, 130), (10, 2, 38),
(11, 2, 260), (12, 2, 18), (13, 2, 45), (14, 2, 60), (15, 2, 10),

(1, 3, 220), (2, 3, 110), (3, 3, 50), (4, 3, 8), (5, 3, 15),
(6, 3, 65), (7, 3, 90), (8, 3, 40), (9, 3, 75), (10, 3, 110),
(11, 3, 95), (12, 3, 70), (13, 3, 20), (14, 3, 15), (15, 3, 60);

INSERT INTO stock_transactions (product_id, warehouse_id, transaction_type, quantity, reference_note, created_at) VALUES
(1, 1, 'IN',  200, 'Initial stock receipt from Crescent Electronics', DATE_SUB(NOW(), INTERVAL 40 DAY)),
(1, 1, 'OUT',  20, 'Retail dispatch batch #112',                       DATE_SUB(NOW(), INTERVAL 35 DAY)),
(2, 1, 'OUT',  15, 'Online order fulfillment',                         DATE_SUB(NOW(), INTERVAL 30 DAY)),
(3, 1, 'OUT',  18, 'Bulk corporate order',                             DATE_SUB(NOW(), INTERVAL 28 DAY)),
(8, 1, 'IN',  100, 'Restock from Apex Office Essentials',              DATE_SUB(NOW(), INTERVAL 20 DAY)),
(9, 1, 'OUT',  42, 'Office supplies clearance',                       DATE_SUB(NOW(), INTERVAL 15 DAY)),
(4, 3, 'OUT',  30, 'Festive season sale',                              DATE_SUB(NOW(), INTERVAL 10 DAY)),
(12,2, 'OUT',  22, 'Corporate bulk order - HDMI/cooling pads',         DATE_SUB(NOW(), INTERVAL 9 DAY)),
(7, 1, 'OUT',  25, 'Hardware store resale order',                     DATE_SUB(NOW(), INTERVAL 5 DAY)),
(11,1, 'IN',  300, 'Packaging stock replenishment',                   DATE_SUB(NOW(), INTERVAL 3 DAY));

INSERT INTO purchase_orders (supplier_id, warehouse_id, order_date, expected_date, status) VALUES
(3, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'PENDING');

INSERT INTO purchase_order_items (po_id, product_id, quantity_ordered, unit_cost) VALUES
(1, 5, 25, 1450.00),
(1, 9, 60, 180.00);
