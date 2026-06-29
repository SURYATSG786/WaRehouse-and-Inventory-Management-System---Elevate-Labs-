USE warehouse_db;

SELECT * FROM vw_current_stock_levels ORDER BY stock_status, stock_value DESC;

SELECT * FROM vw_open_alerts ORDER BY created_at DESC;

SELECT * FROM vw_warehouse_summary ORDER BY capacity_used_pct DESC;

SELECT
    ROUND(SUM(s.quantity * p.unit_price), 2) AS total_inventory_value,
    COUNT(DISTINCT p.product_id)             AS total_skus,
    SUM(s.quantity)                          AS total_units_on_hand
FROM stock s
JOIN products p ON p.product_id = s.product_id;

SELECT
    p.sku,
    p.product_name,
    SUM(t.quantity) AS units_dispatched_last_30_days
FROM stock_transactions t
JOIN products p ON p.product_id = t.product_id
WHERE t.transaction_type IN ('OUT', 'TRANSFER_OUT')
  AND t.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY units_dispatched_last_30_days DESC
LIMIT 5;

SELECT
    p.sku,
    p.product_name,
    SUM(s.quantity) AS total_units_idle
FROM products p
JOIN stock s ON s.product_id = p.product_id
WHERE p.product_id NOT IN (
    SELECT DISTINCT product_id
    FROM stock_transactions
    WHERE transaction_type IN ('OUT', 'TRANSFER_OUT')
      AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
)
GROUP BY p.product_id, p.sku, p.product_name
HAVING total_units_idle > 0
ORDER BY total_units_idle DESC;

SELECT
    sup.supplier_name,
    sup.city,
    COUNT(DISTINCT p.product_id)               AS skus_supplied,
    ROUND(SUM(s.quantity * p.unit_price), 2)    AS stock_value_supplied
FROM suppliers sup
JOIN products p ON p.supplier_id = sup.supplier_id
JOIN stock s    ON s.product_id = p.product_id
GROUP BY sup.supplier_id, sup.supplier_name, sup.city
ORDER BY stock_value_supplied DESC;

SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    transaction_type,
    SUM(quantity)                    AS total_quantity
FROM stock_transactions
GROUP BY month, transaction_type
ORDER BY month, transaction_type;

SELECT
    po.po_id,
    sup.supplier_name,
    w.warehouse_name,
    poi.po_item_id,
    p.product_name,
    poi.quantity_ordered,
    poi.unit_cost,
    po.order_date,
    po.expected_date,
    DATEDIFF(po.expected_date, CURDATE()) AS days_remaining,
    po.status
FROM purchase_orders po
JOIN purchase_order_items poi ON poi.po_id = po.po_id
JOIN suppliers sup ON sup.supplier_id = po.supplier_id
JOIN warehouses w   ON w.warehouse_id = po.warehouse_id
JOIN products p     ON p.product_id = poi.product_id
WHERE po.status = 'PENDING'
ORDER BY days_remaining ASC;

SELECT
    category_name,
    sku,
    product_name,
    warehouse_name,
    stock_value,
    RANK() OVER (PARTITION BY category_name ORDER BY stock_value DESC) AS value_rank_in_category
FROM vw_current_stock_levels
ORDER BY category_name, value_rank_in_category;
