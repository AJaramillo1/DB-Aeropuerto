
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- Generación de Datos Aleatorios 
-- SELECT i, 'CATEGORIA',md5(random() :: text),
-- FROM   generate_series(1, 10) s(i);
--
-- https://generatedata.com  -- OK

-- https://pgxn.org/dist/postgresql_anonymizer/0.6.0/NEWS.html  
-- https://shusson.info/post/generating-test-data-in-postgres
-- https://www.todopostgresql.com/generar-datos-masivos-con-generate_series/
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- Caso de Estudio: Aeropuerto
----------------------------------------------------------------------------------------------------------------------------------------
-- La administración de un aeropuerto necesita una Base de Datos para almacenar los datos de su operación, que describa 
-- los siguientes hechos:
-- 
-- a) Cada aeronave administrada está identificada por un número de matrícula.  Las aeronaves son propiedad de una EMPRESA o de un PARTICULAR; 
--    y en ambos casos se debe conocer el nombre, la dirección y el teléfono del propietario, así como la fecha de compra del avión;
-- b) Cada avión es de un tipo determinado, caracterizándose éste por su nombre (Por ejemplo Boing 747, Airbus a380, ...), 
--    el nombre del fabricante, la potencia del motor y el número de asientos;
-- c) El  mantenimiento de las aeronaves lo realizan los mecánicos del aeropuerto. Por seguridad, las intervenciones son siempre realizadas 
--    por dos mecánicos (uno repara, el otro comprueba). El mismo mecánico puede, según las intervenciones, realizar la reparación o la revisión. 
--    Para cualquier intervención realizada, se conserva el objeto de la intervención, la fecha y la duración;
-- d) De cada mecánico conocemos su nombre, su dirección, su número de teléfono y los tipos de aeronaves en los que está autorizado a intervenir;
-- e) Varios pilotos están registrados en el aeropuerto. De cada piloto conocemos su nombre, su dirección, su número de teléfono, 
--    su número de licencia de piloto y los tipos de aeronaves que está autorizado a volar con el total de horas de vuelo que ha realizado en cada 
--    uno de estos tipos de aeronaves.
-- f) Las siguientes preguntas son algunos de los consultas típicas típicas que la Base de Datos debe poder responder:
--      - lista de aviones de la EMPRESA "AeroCharter";
--      - lista de aeronaves propiedad de PARTICULARes;
--      - Duración total de las intervenciones realizadas por el mecánico Rocha en el mes de enero; 
--      - Lista de tipos de aeronaves con más de 4 asientos, junto con la lista de pilotos autorizados para ese tipo de aeronave;
--      - lista de intervenciones (asunto, fecha) realizadas en la aeronave número 3242XZY78K3.
----------------------------------------------------------------------------------------------------------------------------------------
DROP SCHEMA IF EXISTS aeropuerto_sch CASCADE;
CREATE SCHEMA aeropuerto_sch AUTHORIZATION postgres;                 -- Se crea el esquema 
--SET search_path = aeropuerto_sch, "$user", public;                      -- For current session only
ALTER ROLE postgres SET search_path = aeropuerto_sch, "$user", public;  -- Persistent, for role
SHOW search_path;                                                       -- Se verifica que esquema sea el correcto

-- Eliminar tablas
DROP TABLE IF EXISTS propietarios CASCADE;
DROP TABLE IF EXISTS pilotos CASCADE;
DROP TABLE IF EXISTS tipos_avion CASCADE;
DROP TABLE IF EXISTS habilitaciones_Pilotos CASCADE;
DROP TABLE IF EXISTS aviones CASCADE;
DROP TABLE IF EXISTS mecanicos CASCADE;
DROP TABLE IF EXISTS habilitaciones_mecanicos CASCADE;
DROP TABLE IF EXISTS mantenimientos CASCADE;

-- Eliminar secuencias
DROP SEQUENCE IF EXISTS seq_propietarios;
DROP SEQUENCE IF EXISTS seq_pilotos;
DROP SEQUENCE IF EXISTS seq_tipos_avion;
DROP SEQUENCE IF EXISTS seq_mecanicos;
DROP SEQUENCE IF EXISTS seq_mantenimiento;

CREATE SEQUENCE seq_propietarios
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE seq_pilotos
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE seq_tipos_avion
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE seq_mecanicos
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;

CREATE SEQUENCE seq_mantenimiento
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
  

CREATE TABLE propietarios(
  id          INT PRIMARY KEY DEFAULT nextval('seq_propietarios')
  ,nombre     VARCHAR(50) NOT NULL
  ,ap_pat     VARCHAR(50)
  ,ap_mat     VARCHAR(50)
  ,calle      TEXT NOT NULL
  ,colonia    TEXT NOT NULL
  ,estado     TEXT NOT NULL
  ,ciudad     TEXT
  ,cp         INT
  ,telefono   VARCHAR(20) CONSTRAINT prop_tel_ck UNIQUE
  ,categoria  VARCHAR(20) CONSTRAINT prop_categ_ck CHECK (categoria IN ('EMPRESA','PARTICULAR'))
);
ALTER TABLE propietarios ADD CONSTRAINT prop_cp_ck CHECK (cp > 9999 AND cp < 99999);

CREATE TABLE pilotos(
  id        INT PRIMARY KEY DEFAULT nextval('seq_Pilotos')
  ,nombre   VARCHAR(50) NOT NULL
  ,ap_pat   VARCHAR(50)
  ,ap_mat   VARCHAR(50)
  ,calle    TEXT NOT NULL
  ,colonia  TEXT NOT NULL
  ,estado   TEXT NOT NULL
  ,ciudad   TEXT NOT NULL
  ,cp       INT
  ,telefono VARCHAR(20) CONSTRAINT piloto_tel_UK UNIQUE
  ,licencia VARCHAR(50) CONSTRAINT piloto_lic_UK UNIQUE
);

CREATE TABLE tipos_avion(
  id            INT PRIMARY KEY DEFAULT nextval('seq_tipos_avion')
  ,nombre       VARCHAR(50) NOT NULL
  ,constructor  VARCHAR(50)
  ,potencia     VARCHAR(20) 
  ,asientos     INT 
);
ALTER TABLE tipos_avion ADD CONSTRAINT tipos_avion_asientos_ck CHECK(asientos  > 0 AND asientos <500);


CREATE TABLE habilitaciones_pilotos(
   piloto_id          INT 
  ,tipo_avion_id      INT
  ,no_hrs_vuelo       INT 
  ,CONSTRAINT hab_pilotos_pk             PRIMARY KEY(piloto_id, tipo_avion_id)  
  ,CONSTRAINT hab_pilotos_pilotos_fk     FOREIGN KEY(piloto_id) REFERENCES pilotos(id)
  ,CONSTRAINT hab_pilotos_tipos_avion_fk  FOREIGN KEY(tipo_avion_id) REFERENCES tipos_avion(id)
);

 
CREATE TABLE aviones(
  id                INT PRIMARY KEY
  ,propietario_id   INT
  ,tipo_avion_id    INT
  ,matricula        VARCHAR(50) CONSTRAINT aviones_matricula_uk UNIQUE NOT NULL
  ,fecha_compra     DATE NOT NULL
  ,CONSTRAINT aviones_propietario_fk FOREIGN KEY (propietario_id)  REFERENCES propietarios(id)
  ,CONSTRAINT aviones_tipos_avion_fk  FOREIGN KEY (tipo_avion_id)  REFERENCES tipos_avion(id) 
);


CREATE TABLE mecanicos(
  id        INT PRIMARY KEY DEFAULT nextval('seq_mecanicos')
  ,nombre   VARCHAR(50) NOT NULL
  ,ap_pat   VARCHAR(50)
  ,ap_mat   VARCHAR(50)
  ,calle    TEXT
  ,colonia  TEXT
  ,estado   TEXT 
  ,ciudad   TEXT
  ,cp       INT
  ,telefono VARCHAR(20) CONSTRAINT meca_tel_UK UNIQUE
);
ALTER TABLE mecanicos ADD CONSTRAINT mecanicos_cp_ck CHECK (cp > 9999 AND cp < 99999);


CREATE TABLE habilitaciones_mecanicos (
   mecanico_id      INT
  ,tipo_avion_id    INT
  ,CONSTRAINT hab_mecan_pk            PRIMARY KEY(mecanico_id, tipo_avion_id)  
  ,CONSTRAINT hab_mecan_mecan_fk      FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id)
  ,CONSTRAINT hab_mecan_tipos_avion_fk FOREIGN KEY (tipo_avion_id) REFERENCES tipos_avion(id)
);


CREATE TABLE mantenimientos(
   id           INT PRIMARY KEY DEFAULT nextval('seq_mantenimiento')
  ,avion_id     INT 
  ,repara_id    INT
  ,verifica_id  INT
  ,objeto       TEXT
  ,duracion     NUMERIC 
  ,fecha        DATE
  ,CONSTRAINT mantenimientos_avion_fk     FOREIGN KEY (avion_id)  REFERENCES aviones(id)
  ,CONSTRAINT mantenimientos_repara_id_fk FOREIGN KEY (repara_id) REFERENCES mecanicos(id)  
  ,CONSTRAINT mantenimientos_vefica_id_fk FOREIGN KEY (verifica_id) REFERENCES mecanicos(id)  
);
ALTER TABLE mantenimientos ADD CONSTRAINT mantenimientos_duracion_ck CHECK(duracion > 0);



--INSERTS PROPIETARIOS
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('INTERJET','Av. Revolución No. 252','Lazaro cardenas','Edo.Mexico','Toluca',50180,7221853100,'EMPRESA');
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('VIVA AEROBUS','Manuel Altamirano #11','Lauro Villar','Chihuahua','Juarez',50090,7121591255,'EMPRESA');
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('AEROMEXICO','Gomez Farias # 212','Nicolas Romero','Edo.Mexico','Texcoco',50100,7226209639,'EMPRESA');
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('AEROMEXICO','Calle Francisco Villa No. 121','Tule','Baja California','La paz',50123,7224075965,'EMPRESA');
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('IBERIA','Lago Gatun #61','Patzcuaro','Guerrero','Acapulco',50260,7226475308,'EMPRESA');
INSERT INTO propietarios(nombre,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('DELTA','Av. Inst. Tecnológico S/N','San Felipe','Edo.Mexico','Metepec',51679,7226824549,'EMPRESA');
INSERT INTO propietarios(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('Juan','Sanchez','Colin','Luis Colosio No. 34','Centro','Michoacan','Uruapan',50110,7221234567,'PARTICULAR');
INSERT INTO propietarios(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('José','Manuel','Altamirano','Lauro Villar No 6652','Moctezuma','Chihuahua','Cd. Juarez',50090,7121591258,'PARTICULAR');
INSERT INTO propietarios(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('Alejandra','Villa','Negrete','Av. Central No. 212','Tule','Baja California','La paz',50123,7224077964,'PARTICULAR');
INSERT INTO propietarios(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,categoria) VALUES('Juan','Alvarez','López','Insurgentes Norte No.23','Nacosari','Queretaro','San JUuan del Río',51246,7222340705,'PARTICULAR');


--INSERTS PILOTOS
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Victoria','Castillo','Vicente','Miguel Barragán No. 2','Lazaro Cardenas','Edo.Mexico','Toluca',50180,7293689663,'VMCV-0107');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Neri','Castillo','Vicente','Libano #134','Zaragoza','Guanajuato','Puerto Vallarta',54120,7225719198,'NCV-01216');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Oscar','Castillo','Anaya','Leonardo DaVinci #31','Tollocan','Edo.Mexico','Cuahtitlan',51801,5540337746,'OCA-0975');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Irma','Vicente','Francisco','Cipres #551','Antonio Alvarez','Puebla','Miramar',50375,7131210941,'IVF-07206');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Sergio','Castillo','Perez','Ignacio Lopez Rayon #51','Venustiano Carranza','Oaxaca','Orizaba',50032,7151182177,'SCP-0202');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Antonio','Castillo','Bernal','Constituyentes #51','Zuñiga','Puebla','Manzanillo',50591,7221330915,'ACB-7997');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Guadalupe','Rivera','Romero','Manuel Correa #551','Martires','Nuevo León','Cuernavaca',52509,3121194879,'GRR-1233');
INSERT INTO pilotos(nombre,ap_pat,ap_mat,calle,colonia,estado,ciudad,cp,telefono,licencia) VALUES ('Angeles','Gonzales','Reyes','Libertad No. 212','Plan de Ayala','Yucatan','Chetumal',50495,7773095529,'AGR-8808');


--INSERTS TIPO DE AVION
INSERT INTO tipos_avion(nombre,constructor,potencia,asientos) VALUES('Airbus380','AIRBUS','5565 CV',480);
INSERT INTO tipos_avion(nombre,constructor,potencia,asientos) VALUES('Airbus340','AIRBUS','4565 CV',480);
INSERT INTO tipos_avion(nombre,constructor,potencia,asientos) VALUES('Airbus320','AIRBUS','3565 CV',480);
INSERT INTO tipos_avion(nombre,constructor,potencia,asientos) VALUES('Boeing747','BOEING','4500 CV',390);
INSERT INTO tipos_avion(nombre,constructor,potencia,asientos) VALUES('Boeing Dreamliner 787-9','BOEING','4769 cv',460);


--INSERTS HABILITACIONES PILOTOS
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (1,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (1,2,200);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (1,3,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (1,4,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (1,5,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (2,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (2,2,200);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (3,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (3,2,200);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (3,3,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (3,4,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (3,5,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (5,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (5,2,200);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (5,3,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (5,5,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (6,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (6,3,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (6,4,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (6,5,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (7,1,100);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (7,2,200);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (7,3,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (7,4,500);
INSERT INTO habilitaciones_pilotos(piloto_id, tipo_avion_id, no_hrs_vuelo) VALUES (7,5,100);



--INSERTS DE AVIONES
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (1,1,1,'1345-z','2020/02/19');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (2,1,5,'3285-WW','2002/12/16');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (3,1,5,'3469-UY','2001/07/30');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (4,2,5,'1890-QT','1972/01/06');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (5,2,4,'1250-LS','1975/09/05');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (6,3,3,'502-E','2004/08/14');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (7,3,3,'2345-IU','2007/02/12');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (8,3,3,'117-PO','2008/10/10');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (9,3,4,'2801-F','1990/11/11');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (10,4,2,'8167-G','1997/07/09');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (11,4,2,'1895-F','2005/01/24');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (12,4,2,'0756-C','2000/09/28');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (13,4,1,'2019-BN','2003/05/25');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (14,4,1,'431-AW','2001/12/27');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (15,5,1,'228-N','1995/03/04');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (16,5,2,'194-I','1991/04/17');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (17,6,3,'1975-O','2010/10/03');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (18,7,4,'2001-VM','2005/01/19');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (19,7,5,'2002-N','2006/03/17');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (20,8,5,'220-I','1997/08/15');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (21,8,5,'1876-M','2017/01/26');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (22,8,4,'901-V','2010/02/16');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (23,8,4,'502-MN','2014/12/01');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (24,8,4,'2345-ER','2009/02/03');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (25,8,4,'100-AS','2005/01/10');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (26,8,3,'2022-S','2011/05/07');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (27,8,3,'1856-RT','2009/12/20');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (28,9,4,'2340-SE','2001/01/25');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (29,10,4,'3102-C','2016/01/27');
INSERT INTO aviones(id,propietario_id,tipo_avion_id,matricula,fecha_compra) VALUES (30,10,1,'1980-VO','2012/12/12');


--INSERTS DE MECANICOS
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Tomura','Di Angelo',NUll,'Miguel Barragán #51','Lazaro cardenas','Edo.Mexico','Toluca',50180,7228297031); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Monica','Lopez','Calderon','Zempoala #23','La fragua','Quintana Roo','Cancun',50321,8129393916); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Carina','Sanchez','Robles','Juan Alvarez #53','Nacosari','Queretaro','Iguala',51246,7291758820); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Josafat','Hernandez','Rojas','Fernando Quiroz  #67','Morelos','Jalisco','Los cabos',51946,7227895462); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Marian','Castillo','Saldivar','Nicolas Bravo #872','Pucareli','Coahuila','Saltillo',50732,7227787872); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Gabriela','Cruz',NUll,'Buena Aventura  #3','San Javier','Queretaro','Cordoba',50093,7227081374); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Paulina','Pulido','Lara','Cedro #87','Alberto Garcia','Guerrero','Pachuca',52113,7226405160); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Merari','Flores','Moreno','Fernando Quiroz  #6673','Morelos','Jalisco','Los cabos',51946,7226355137); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Roberto','Moreno','Sarate','Ramon Rayon  #773','Aquiles Cerdan','Chihuahua','Ensenada',50332,7225329158); 
INSERT INTO mecanicos(nombre,ap_pat,ap_mat,calle,colonia,ciudad,estado,cp,telefono) VALUES ('Eduardo','Farfan','Mendoza','Libertad #773','Plan de Ayala','Yucatan','Chetumal',50495,7225128288); 


--INSERTS DE HABILITACIONES MECANICOS
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(1,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(1,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(1,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(1,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(1,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(2,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(2,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(2,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(2,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(2,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(3,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(3,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(3,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(3,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(3,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(4,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(4,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(4,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(4,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(4,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(5,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(5,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(5,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(5,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(5,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(7,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(7,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(7,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(7,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(7,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(8,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(8,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(8,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(8,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(8,5);

INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(9,1);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(9,2);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(9,3);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(9,4);
INSERT INTO habilitaciones_mecanicos(mecanico_id,tipo_avion_id) VALUES(9,5);
SELECT * FROM habilitaciones_mecanicos;



--INSERTS DE MANTENIMIENTOS
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (1,1,10,'Turboreactor',        12,'2021/12/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (2,2,9,'Estabilizador',       24,'2005/03/24');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (3,3,9,'Bodega de equipaje',  40,'2009/10/12');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (4,4,8,'Ala',                 19,'2007/09/14');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (5,5,7,'Tanque de gasolina',  20,'2022/07/30');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (1,6,6,'Luz de navegación',   8,'2022/12/16');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (7,7,5,'Timón',               5,'2022/09/05');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (8,8,4,'Estabilizador',       15,'2022/01/06');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (2,9,3,'Cabina de mando',     21,'2021/06/18');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (10,10,2,'Flap de aterrizaje', 25,'2020/03/20');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (11,8,1,'Turboreactor',       10,'2019/08/13');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (12,7,2,'Tanque de gasolina', 3,'2019/06/03');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (3,6,6,'Timón',              6,'2017/09/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (14,5,7,'Cabina de mando',    18,'2018/05/01');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (3,4,6,'Estabilizador',      8,'2020/01/05');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (16,3,8,'Turboreactor',       9,'2020/09/09');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (3,2,9,'Tanque de gasolina', 2,'2021/10/12');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (1,1,9,'Timón',              4,'2022/11/23');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (19,7,5,'Flap de aterrizaje', 23,'2022/12/24');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (20,6,4,'Ala',                10,'2021/01/30');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (4,5,2,'Luz de navegación',  2,'2020/02/02');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (22,4,6,'Turboreactor',       15,'2020/03/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (23,3,4,'Estabilizador',      17,'2021/04/17');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (24,4,2,'Tanque de gasolina', 5,'2022/05/26');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (7,8,3,'Luz de navegación',  1,'2022/06/13');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (26,2,7,'Tanque de gasolina', 4,'2020/07/29');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (27,3,7,'Cabina de mando',    22,'2019/08/31');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (8,2,8,'Flap de aterrizaje', 20,'2017/09/07');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (29,1,9,'Turboreactor',       16,'2018/10/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (30,1,10,'Estabilizador',      13,'2021/11/07');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (9,1,10,'Turboreactor',       16,'2018/01/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (30,5,10,'Estabilizador',      13,'2021/01/07');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (10,6,2,'Tanque de Gasolina',  16,'2018/10/10');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (30,7,3,'Estabilizador',       13,'2021/11/07');
INSERT INTO mantenimientos(avion_id,repara_id,verifica_id,objeto,duracion,fecha) VALUES (11,8,5,'TCabina de control',  16,'2018/01/10');






