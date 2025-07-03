-- 1. Validar stock antes de agregar detalle de producto (Trigger `BEFORE INSERT`).
DELIMITER $$
CREATE TRIGGER trg_before_insert_detalle
    BEFORE INSERT ON detalle_pedido
    FOR EACH ROW
BEGIN
    IF NEW.cantidad < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cantidad debe ser al menos 1';
    END IF;
END $$

DELIMITER ;

INSERT INTO detalle_pedido (pedido_id, cantidad)VALUES (1, 0);

-- 2. Descontar stock tras agregar ingredientes extra (Trigger `AFTER INSERT`).

DELIMITER $$
CREATE TRIGGER trg_after_insert_ingredientes_extra
AFTER INSERT ON ingredientes_extra
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;

    SELECT stock INTO stock_actual
    FROM ingrediente
    WHERE id = NEW.ingrediente_id;

    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para este ingrediente.';
    END IF;

    UPDATE ingrediente
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.ingrediente_id;
END $$
DELIMITER ;

INSERT INTO ingredientes_extra (detalle_id, ingrediente_id, cantidad)VALUES (1, 2, 1);