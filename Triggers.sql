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
