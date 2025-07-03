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

-- 3. Registrar auditoría de cambios de precio (Trigger `AFTER UPDATE`).

DELIMITER $$
CREATE TRIGGER trg_after_update_precio
AFTER UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF OLD.precio <> NEW.precio THEN
        INSERT INTO auditoria_precio (
            producto_id,
            presentacion_id,
            precio_antiguo,
            precio_nuevo
        ) VALUES (
            NEW.producto_id,
            NEW.presentacion_id,
            OLD.precio,
            NEW.precio
        );
    END IF;
END $$
DELIMITER ;

UPDATE producto_presentacion SET precio = 4000 WHERE producto_id = 1 AND presentacion_id = 1;

SELECT * FROM auditoria_precio;

-- 4. Impedir precio cero o negativo (Trigger `BEFORE UPDATE`).

DELIMITER $$
CREATE TRIGGER trg_before_update_precio
BEFORE UPDATE ON producto_presentacion
FOR EACH ROW
BEGIN
    IF NEW.precio <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor a cero.';
    END IF;
END $$
DELIMITER ;
UPDATE producto_presentacion SET precio = 0 WHERE producto_id = 1 AND presentacion_id = 1;