CREATE SCHEMA IF NOT EXISTS `e-commerce`;
USE `e-commerce`;


-- 1. ESTRUCTURA


CREATE TABLE categorys (
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE clients (
    client_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(24) NOT NULL,
    age INT UNSIGNED,
    birth_date DATE NOT NULL,
    mail VARCHAR(255) NOT NULL UNIQUE,
    dni VARCHAR(30) UNIQUE,
    gender TINYTEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_mail CHECK (mail REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    product_price DECIMAL(10,2) UNSIGNED NOT NULL,
    product_stock INT UNSIGNED,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_category_product FOREIGN KEY (category_id) REFERENCES categorys(category_id)
) ENGINE=InnoDB;

CREATE TABLE invoices (
    invoice_id INT UNSIGNED NOT NULL PRIMARY KEY,
    client_id INT UNSIGNED NOT NULL,
    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_sale DECIMAL(10,2) UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_invoices_clients FOREIGN KEY (client_id) REFERENCES clients(client_id)
) ENGINE=InnoDB;

CREATE TABLE invoices_products (
    aux_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    product_price DECIMAL(10,2) UNSIGNED NOT NULL,
    quantity INT UNSIGNED,
    CONSTRAINT fk_inv_prod_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_inv_prod_product FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- 2. Triger para completar el precio del producto en la tabla invoices_products

DELIMITER //
CREATE TRIGGER price_stock_complete
BEFORE INSERT ON invoices_products
FOR EACH ROW
BEGIN
    SET NEW.product_price = (SELECT product_price FROM products WHERE product_id = NEW.product_id);
END //
DELIMITER ;


-- 3. DATOS COMPLETOS


-- Categorías
INSERT INTO categorys (category_name) VALUES 
('Hogar'), ('Electronica'), ('Alimentos'), ('Belleza'), ('Ropa'), ('Escolar');

-- Clientes
INSERT INTO clients (name, birth_date, gender, age, mail, dni) VALUES 
('Santi', '2002-07-23', 'man', 23, 'squevedomejias@gmail.com', '32.946.778'),
('Maria', '1988-01-16', 'asexual', 38, 'mariarivas@lexpin.online', '47.567.982'),
('Bryan God', '2004-08-29', 'man', 21, 'bryantffacen@gmail.com', '19.508.702'),
('Mauricio', '2006-04-12', 'man', 19, 'mauriciocotufa@gmail.com', '45.967.609'),
('Angelica', '1988-01-16', 'pansexual', 38, 'angirivas@lexpin.online', '48.567.982'),
('Dervis', '1978-05-24', 'man', 47, 'delvissivira@lexpin.online', '51.598.465');

-- productos
INSERT INTO products (category_id, product_name, product_price, product_stock) VALUES 
(1, 'Cama Matrimonial', 599.99, 4),
(2, 'Xbox Series X', 499.45, 872),
(2, 'Bateria de Energia de Maria Angelica', 1799.13, 1),
(4, 'Rubor', 26.99, 56),
(6, 'Pega Loka', 12.99, 42),
(5, 'Camisa Negra Timberland', 119.99, 9),
(3, 'Excremento', 1.99, 2304),
(3, 'Leche Casera', 9.12, 999); -- 100% humana


INSERT INTO invoices (invoice_id, client_id, total_sale) VALUES (1, 2, 0); -- Cabezera de la factura


INSERT INTO invoices_products (invoice_id, product_id, quantity) VALUES (1, 1, 2); -- 2 Camas matrimoniales

-- total de la factura
UPDATE invoices 
SET total_sale = (SELECT SUM(product_price * quantity) FROM invoices_products WHERE invoice_id = 1) 
WHERE invoice_id = 1;

-- Reporte final
SELECT 
    i.invoice_id AS 'Factura',
    c.name AS 'Cliente',
    p.product_name AS 'Producto',
    ip.quantity AS 'Cant',
    ip.product_price AS 'Precio Unit',
    (ip.quantity * ip.product_price) AS 'Subtotal',
    i.total_sale AS 'Total Factura'
FROM invoices i
JOIN clients c ON i.client_id = c.client_id
JOIN invoices_products ip ON i.invoice_id = ip.invoice_id
JOIN products p ON ip.product_id = p.product_id;