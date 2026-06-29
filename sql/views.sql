USE warehouse_db;

CREATE OR REPLACE VIEW vw_current_stock_levels AS
SELECT
    p.product_id,
    p.sku,
    p.product_name,
    c.category_name,
    w.warehouse_id,
    w.warehouse_name,
    s.quantity,
    p.reorder_level,
    p.unit_price,
    ROUND(s.quantity * p.unit_price, 2)            AS stock_value,
    CASE
        WHEN s.quantity = 0                  THEN 'OUT_OF_STOCK'
        WHEN s.quantity <= p.reorder_level    THEN 'LOW'
        WHEN s.quantity <= p.reorder_level * 2 THEN 'WARNING'
        ELSE 'HEALTHY'
    END AS stock_status,
    sup.supplier_name
FROM stock s
JOIN products p    ON p.product_id = s.product_id
JOIN warehouses w   ON w.warehouse_id = s.warehouse_id
LEFT JOIN categories c ON c.category_id = p.category_id
LEFT JOIN suppliers sup ON sup.supplier_id = p.supplier_id;

CREATE OR REPLACE VIEW vw_open_alerts AS
SELECT
    a.alert_id,
    p.sku,
    p.product_name,
    w.warehouse_name,
    a.quantity_at_alert,
    a.reorder_level,
    p.reorder_quantity AS suggested_order_qty,
    sup.supplier_name,
    sup.phone           AS supplier_phone,
    a.created_at
FROM low_stock_alerts a
JOIN products p    ON p.product_id = a.product_id
JOIN warehouses w   ON w.warehouse_id = a.warehouse_id
LEFT JOIN suppliers sup ON sup.supplier_id = p.supplier_id
WHERE a.status = 'OPEN';

CREATE OR REPLACE VIEW vw_warehouse_summary AS
SELECT
    w.warehouse_id,
    w.warehouse_name,
    w.city,
    COUNT(DISTINCT s.product_id)                AS distinct_skus,
    COALESCE(SUM(s.quantity), 0)                 AS total_units,
    ROUND(COALESCE(SUM(s.quantity * p.unit_price), 0), 2) AS total_stock_value,
    w.capacity_units,
    ROUND(COALESCE(SUM(s.quantity), 0) * 100.0 / w.capacity_units, 1) AS capacity_used_pct
FROM warehouses w
LEFT JOIN stock s     ON s.warehouse_id = w.warehouse_id
LEFT JOIN products p  ON p.product_id = s.product_id
GROUP BY w.warehouse_id, w.warehouse_name, w.city, w.capacity_units;
