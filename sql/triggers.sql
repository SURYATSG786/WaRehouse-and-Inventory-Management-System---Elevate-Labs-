USE warehouse_db;

DELIMITER $$

CREATE TRIGGER trg_after_insert_transaction
AFTER INSERT ON stock_transactions
FOR EACH ROW
BEGIN
    DECLARE delta INT;

    IF NEW.transaction_type IN ('IN', 'TRANSFER_IN') THEN
        SET delta = NEW.quantity;
    ELSE
        SET delta = -NEW.quantity;
    END IF;

    INSERT INTO stock (product_id, warehouse_id, quantity)
    VALUES (NEW.product_id, NEW.warehouse_id, GREATEST(delta, 0))
    ON DUPLICATE KEY UPDATE
        quantity = quantity + delta;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_prevent_negative_stock
BEFORE UPDATE ON stock
FOR EACH ROW
BEGIN
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot go below zero for this product/warehouse.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_low_stock_alert
AFTER UPDATE ON stock
FOR EACH ROW
BEGIN
    DECLARE v_reorder_level INT;
    DECLARE v_open_alert_count INT;

    SELECT reorder_level INTO v_reorder_level
    FROM products WHERE product_id = NEW.product_id;

    IF NEW.quantity <= v_reorder_level THEN
        SELECT COUNT(*) INTO v_open_alert_count
        FROM low_stock_alerts
        WHERE product_id = NEW.product_id
          AND warehouse_id = NEW.warehouse_id
          AND status = 'OPEN';

        IF v_open_alert_count = 0 THEN
            INSERT INTO low_stock_alerts (product_id, warehouse_id, quantity_at_alert, reorder_level)
            VALUES (NEW.product_id, NEW.warehouse_id, NEW.quantity, v_reorder_level);
        END IF;

    ELSEIF NEW.quantity > v_reorder_level THEN
        UPDATE low_stock_alerts
        SET status = 'RESOLVED', resolved_at = NOW()
        WHERE product_id = NEW.product_id
          AND warehouse_id = NEW.warehouse_id
          AND status = 'OPEN';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_low_stock_alert_on_insert
AFTER INSERT ON stock
FOR EACH ROW
BEGIN
    DECLARE v_reorder_level INT;

    SELECT reorder_level INTO v_reorder_level
    FROM products WHERE product_id = NEW.product_id;

    IF NEW.quantity <= v_reorder_level THEN
        INSERT INTO low_stock_alerts (product_id, warehouse_id, quantity_at_alert, reorder_level)
        VALUES (NEW.product_id, NEW.warehouse_id, NEW.quantity, v_reorder_level);
    END IF;
END$$

DELIMITER ;
