USE warehouse_db;

DELIMITER $$

CREATE PROCEDURE sp_transfer_stock (
    IN p_product_id    INT,
    IN p_source_warehouse_id INT,
    IN p_destination_warehouse_id   INT,
    IN p_quantity       INT
)
BEGIN
    DECLARE v_available_quantity INT DEFAULT 0;

    IF p_source_warehouse_id = p_destination_warehouse_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination warehouse cannot be the same.';
    END IF;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer quantity must be greater than zero.';
    END IF;

    SELECT COALESCE(quantity, 0) INTO v_available_quantity
    FROM stock
    WHERE product_id = p_product_id AND warehouse_id = p_source_warehouse_id;

    IF v_available_quantity < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock at source warehouse for this transfer.';
    END IF;

    START TRANSACTION;

        INSERT INTO stock_transactions
            (product_id, warehouse_id, transaction_type, quantity, related_warehouse_id, reference_note)
        VALUES
            (p_product_id, p_source_warehouse_id, 'TRANSFER_OUT', p_quantity, p_destination_warehouse_id, 'Stock transfer out');

        INSERT INTO stock_transactions
            (product_id, warehouse_id, transaction_type, quantity, related_warehouse_id, reference_note)
        VALUES
            (p_product_id, p_destination_warehouse_id, 'TRANSFER_IN', p_quantity, p_source_warehouse_id, 'Stock transfer in');

    COMMIT;

    SELECT CONCAT('Transferred ', p_quantity, ' unit(s) of product #', p_product_id,
                  ' from warehouse #', p_source_warehouse_id, ' to warehouse #', p_destination_warehouse_id) AS result;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_receive_stock (
    IN p_product_id   INT,
    IN p_warehouse_id INT,
    IN p_quantity     INT,
    IN p_note         VARCHAR(200)
)
BEGIN
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Received quantity must be greater than zero.';
    END IF;

    INSERT INTO stock_transactions (product_id, warehouse_id, transaction_type, quantity, reference_note)
    VALUES (p_product_id, p_warehouse_id, 'IN', p_quantity, COALESCE(p_note, 'Stock received'));

    SELECT CONCAT('Received ', p_quantity, ' unit(s) of product #', p_product_id,
                  ' into warehouse #', p_warehouse_id) AS result;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_issue_stock (
    IN p_product_id   INT,
    IN p_warehouse_id INT,
    IN p_quantity     INT,
    IN p_note         VARCHAR(200)
)
BEGIN
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Issued quantity must be greater than zero.';
    END IF;

    INSERT INTO stock_transactions (product_id, warehouse_id, transaction_type, quantity, reference_note)
    VALUES (p_product_id, p_warehouse_id, 'OUT', p_quantity, COALESCE(p_note, 'Stock issued'));

    SELECT CONCAT('Issued ', p_quantity, ' unit(s) of product #', p_product_id,
                  ' from warehouse #', p_warehouse_id) AS result;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_reorder_report ()
BEGIN
    SELECT
        p.sku,
        p.product_name,
        w.warehouse_name,
        s.quantity              AS current_quantity,
        p.reorder_level,
        p.reorder_quantity      AS suggested_order_qty,
        sup.supplier_name,
        sup.phone               AS supplier_phone
    FROM stock s
    JOIN products p   ON p.product_id = s.product_id
    JOIN warehouses w ON w.warehouse_id = s.warehouse_id
    LEFT JOIN suppliers sup ON sup.supplier_id = p.supplier_id
    WHERE s.quantity <= p.reorder_level
    ORDER BY (s.quantity / p.reorder_level) ASC;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_create_purchase_order (
    IN p_supplier_id  INT,
    IN p_warehouse_id INT,
    IN p_product_id   INT,
    IN p_quantity     INT,
    IN p_unit_cost    DECIMAL(10,2),
    IN p_lead_days    INT
)
BEGIN
    DECLARE v_new_purchase_order_id INT;

    START TRANSACTION;

        INSERT INTO purchase_orders (supplier_id, warehouse_id, order_date, expected_date, status)
        VALUES (p_supplier_id, p_warehouse_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_lead_days DAY), 'PENDING');

        SET v_new_purchase_order_id = LAST_INSERT_ID();

        INSERT INTO purchase_order_items (po_id, product_id, quantity_ordered, unit_cost)
        VALUES (v_new_purchase_order_id, p_product_id, p_quantity, p_unit_cost);

    COMMIT;

    SELECT v_new_purchase_order_id AS new_po_id, 'Purchase order created' AS result;
END$$

DELIMITER ;
