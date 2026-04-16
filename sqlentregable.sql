CREATE SCHEMA `e-commerce`;

CREATE  TABLE `e-commerce`.categorys ( 
	category_id          INT UNSIGNED  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
	category_name        TINYTEXT   NOT NULL    ,
	CONSTRAINT unq_categorys UNIQUE ( category_name ) 
 ) engine=InnoDB;

ALTER TABLE `e-commerce`.categorys COMMENT 'Tabla de categorias de los productos';

ALTER TABLE `e-commerce`.categorys MODIFY category_id INT UNSIGNED  NOT NULL  AUTO_INCREMENT COMMENT 'ID unica de la categoria';

ALTER TABLE `e-commerce`.categorys MODIFY category_name TINYTEXT   NOT NULL   COMMENT 'nombre de la categoria';

CREATE  TABLE `e-commerce`.client_id ( 
	client_id            INT UNSIGNED  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
	name                 VARCHAR(24)   NOT NULL    ,
	age                  INT UNSIGNED      ,
	birth_date           DATE   NOT NULL    ,
	mail                 VARCHAR(255)   NOT NULL    ,
	dni                  VARCHAR(30)       ,
	gender               TINYTEXT   NOT NULL    ,
	created_at           DATETIME   NOT NULL DEFAULT (current_timestamp())   ,
	updated_at           DATETIME  ON UPDATE current_timestamp() NOT NULL DEFAULT (current_timestamp())   ,
	is_active            BOOLEAN   NOT NULL DEFAULT (true)   ,
	CONSTRAINT unq_clients_mail UNIQUE ( mail ) ,
	CONSTRAINT unq_clients_dni UNIQUE ( dni ) 
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `e-commerce`.client_id ADD CONSTRAINT mail CHECK ( `mail` regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$' );

ALTER TABLE `e-commerce`.client_id COMMENT 'Tabla de los clientes o Compradores en cuestion';

ALTER TABLE `e-commerce`.client_id MODIFY name VARCHAR(24)   NOT NULL   COMMENT 'nombre unico por usuario';

ALTER TABLE `e-commerce`.client_id MODIFY age INT UNSIGNED     COMMENT 'edad';

ALTER TABLE `e-commerce`.client_id MODIFY birth_date DATE   NOT NULL   COMMENT 'Fecha de cumpleanos del cliente';

ALTER TABLE `e-commerce`.client_id MODIFY mail VARCHAR(255)   NOT NULL   COMMENT 'Correo electronico del cliente (UNICO)';

ALTER TABLE `e-commerce`.client_id MODIFY dni VARCHAR(30)      COMMENT 'DNI-Numero de Documento de identidad UNICO por Cliente';

ALTER TABLE `e-commerce`.client_id MODIFY gender TINYTEXT   NOT NULL   COMMENT 'genero del cliente';

ALTER TABLE `e-commerce`.client_id MODIFY created_at DATETIME   NOT NULL DEFAULT (current_timestamp())  COMMENT 'Registro de Entrada o creacion por Fila de la tabla Clientes';

ALTER TABLE `e-commerce`.client_id MODIFY updated_at DATETIME  ON UPDATE current_timestamp() NOT NULL DEFAULT (current_timestamp())  COMMENT 'Registro de Actualizacion de la fila de la tabla';

ALTER TABLE `e-commerce`.client_id MODIFY is_active BOOLEAN   NOT NULL DEFAULT (true)  COMMENT 'registro de si esta activo o no el cliente';

CREATE  TABLE `e-commerce`.invoices ( 
	invoice_id           INT UNSIGNED  NOT NULL    PRIMARY KEY,
	client_id            INT UNSIGNED  NOT NULL    ,
	`date`               DATETIME   NOT NULL DEFAULT (current_timestamp())   ,
	created_at           DATETIME(6)    DEFAULT (current_timestamp(6))   ,
	total_sale           INT UNSIGNED  NOT NULL    
 ) engine=InnoDB;

CREATE INDEX idx_client ON `e-commerce`.invoices ( client_id );

ALTER TABLE `e-commerce`.invoices COMMENT 'Tabla de facturas.  1 factura puede estar en 1 cliente pero 1 cliente puede tener muchas facturas. 1 a M';

ALTER TABLE `e-commerce`.invoices MODIFY invoice_id INT UNSIGNED  NOT NULL   COMMENT 'id unica por factura';

ALTER TABLE `e-commerce`.invoices MODIFY `date` DATETIME   NOT NULL DEFAULT (current_timestamp())  COMMENT 'Fecha exacta en la que salio la factura';

CREATE  TABLE `e-commerce`.products ( 
	product_id           INT UNSIGNED  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
	category_id          INT UNSIGNED  NOT NULL    ,
	product_name         TEXT(100)   NOT NULL    ,
	product_price        DECIMAL(65,0) UNSIGNED  NOT NULL    ,
	product_stock        INT UNSIGNED      ,
	created_at           DATETIME(6)   NOT NULL DEFAULT (current_timestamp(6))   ,
	updated_at           DATETIME  ON UPDATE current_timestamp()  DEFAULT (current_timestamp())   ,
	is_active            BOOLEAN   NOT NULL DEFAULT (true)   ,
	CONSTRAINT unq_products UNIQUE ( product_name ) ,
	CONSTRAINT unq_products_product_price UNIQUE ( product_price ) ,
	CONSTRAINT unq_products_product_stock UNIQUE ( product_stock ) ,
	CONSTRAINT fk_category_product FOREIGN KEY ( category_id ) REFERENCES `e-commerce`.categorys( category_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
 ) engine=InnoDB;

CREATE INDEX unq_products_category_id ON `e-commerce`.products ( category_id );

ALTER TABLE `e-commerce`.products COMMENT 'Tabla de productos. un producto DEBE estar en una categoria';

ALTER TABLE `e-commerce`.products MODIFY product_id INT UNSIGNED  NOT NULL  AUTO_INCREMENT COMMENT 'ID unico del producto';

ALTER TABLE `e-commerce`.products MODIFY category_id INT UNSIGNED  NOT NULL   COMMENT 'ID unico de la categoria, es una llave foranea a la tabla Categorys';

ALTER TABLE `e-commerce`.products MODIFY product_name TEXT(100)   NOT NULL   COMMENT 'Nombre del producto';

ALTER TABLE `e-commerce`.products MODIFY product_price DECIMAL(65,0) UNSIGNED  NOT NULL   COMMENT 'Precio del producto';

ALTER TABLE `e-commerce`.products MODIFY product_stock INT UNSIGNED     COMMENT 'Numero de unidades en stock';

CREATE  TABLE `e-commerce`.invoices_products ( 
	aux_id               INT UNSIGNED  NOT NULL  AUTO_INCREMENT  PRIMARY KEY,
	invoice_id           INT UNSIGNED  NOT NULL    ,
	product_id           INT UNSIGNED  NOT NULL    ,
	product_price        DECIMAL(65,0) UNSIGNED  NOT NULL    ,
	quantity             INT UNSIGNED      ,
	CONSTRAINT fk_invoices_products_products FOREIGN KEY ( product_id ) REFERENCES `e-commerce`.products( product_id ) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT fk_invoices_products_invoices FOREIGN KEY ( invoice_id ) REFERENCES `e-commerce`.invoices( invoice_id ) ON DELETE NO ACTION ON UPDATE NO ACTION
 ) engine=InnoDB;

CREATE INDEX fk_invoices_products_products ON `e-commerce`.invoices_products ( product_id );

CREATE INDEX fk_invoices_products_invoices ON `e-commerce`.invoices_products ( invoice_id );

CREATE INDEX idx_invoices_products_price ON `e-commerce`.invoices_products ( product_price );

CREATE INDEX idx_invoices_products_stock ON `e-commerce`.invoices_products ( quantity );

ALTER TABLE `e-commerce`.invoices_products COMMENT 'tabla auxiliar de relacion muchos a muchos de facturas y productos';

ALTER TABLE `e-commerce`.invoices_products MODIFY aux_id INT UNSIGNED  NOT NULL  AUTO_INCREMENT COMMENT 'id de la tabla auxiliar para relaciones M a M. facturas a productos';

ALTER TABLE `e-commerce`.invoices_products MODIFY invoice_id INT UNSIGNED  NOT NULL   COMMENT 'Columna de relacion de facturas';

ALTER TABLE `e-commerce`.invoices_products MODIFY product_id INT UNSIGNED  NOT NULL   COMMENT 'relacion de productos';

ALTER TABLE `e-commerce`.invoices_products MODIFY quantity INT UNSIGNED     COMMENT 'cantidad en total.';

CREATE VIEW `e-commerce`.clients_age AS select `e-commerce`.`clients`.`id` AS `id`,`e-commerce`.`clients`.`name` AS `name`,`e-commerce`.`clients`.`birth_date` AS `birth_date`,`e-commerce`.`clients`.`gender` AS `gender`,timestampdiff(YEAR,`e-commerce`.`clients`.`birth_date`,curdate()) AS `age` from `e-commerce`.`clients`;

INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 1, 'Hogar');
INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 2, 'Electronica');
INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 3, 'Alimentos');
INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 4, 'Belleza');
INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 5, 'Ropa');
INSERT INTO `e-commerce`.categorys( category_id, category_name ) VALUES ( 6, 'Escolar');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 1, 'Santi', '2002-07-23', 'man', 23, '2026-04-10 03.17.35 p.m.', '2026-04-10 03.17.35 p.m.', 1, 'squevedomejias@gmail.com', '32.946.778');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 2, 'Maria', '1988-01-16', 'asexual', 38, '2026-04-10 03.17.35 p.m.', '2026-04-10 03.21.42 p.m.', 1, 'mariarivas@lexpin.online', '47.567.982');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 3, 'Bryan God', '2004-08-29', 'man', 21, '2026-04-10 03.17.35 p.m.', '2026-04-10 03.17.35 p.m.', 1, 'bryantffacen@gmail.com', '19.508.702');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 4, 'Mauricio', '2006-04-12', 'man', 19, '2026-04-10 03.17.35 p.m.', '2026-04-10 03.17.35 p.m.', 1, 'mauriciocotufa@gmail.com', '45.967.609');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 5, 'Angelica', '1988-01-16', 'pansexual', 38, '2026-04-10 03.17.35 p.m.', '2026-04-10 03.17.35 p.m.', 1, 'angirivas@lexpin.online', '48.567.982');
INSERT INTO `e-commerce`.client_id( client_id, name, birth_date, gender, age, created_at, updated_at, is_active, mail, dni ) VALUES ( 6, 'Dervis', '1978-05-24', 'man', 47, '2026-04-10 03.19.38 p.m.', '2026-04-10 03.19.38 p.m.', 1, 'delvissivira@lexpin.online', '51.598.465');
INSERT INTO `e-commerce`.invoices( invoice_id, `date`, created_at, client_id, total_sale ) VALUES ( 1, '2026-04-15 03.43.09 p.m.', '2026-04-15 03.43.09 p.m.', 2, 1200);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 1, 1, 'Cama Matrimonial', 600, 4, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 2, 2, 'Xbox Series X', 499, 872, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 3, 2, 'Bateria de Energia de Maria Angelica', 1799, 1, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 4, 4, 'Rubor', 27, 56, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 5, 6, 'Pega Loka', 13, 42, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 6, 5, 'Camisa Negra Timberland', 120, 9, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 7, 3, 'Excremento', 2, 2305, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.products( product_id, category_id, product_name, product_price, product_stock, created_at, updated_at, is_active ) VALUES ( 8, 3, 'Leche Casera', 9, 999, '2026-04-12 10.34.30 p.m.', '2026-04-12 10.34.30 p.m.', 1);
INSERT INTO `e-commerce`.invoices_products( aux_id, invoice_id, product_id, product_price, quantity ) VALUES ( 1, 1, 1, 600, 2);
