


--Lista de AVIONES

--Lista TIPOS DE AVIONES

--Lista de PROPIETARIOS

--Lista matrícula y constructor de todos los aviones

--Lista el número de aviones clasificados por constructor

--Lista el número de aviones construidos por BOEING

--Lista a los constructores en orden alfabéticios descendiente, que nos han vendido más de 12 aviones

--Lista matrícula, constructor y propietario (indicando si es un 'PARTICULAR' o una 'EMPRESA') de todos los aviones
          
--Listar el número de aviones que son propiedad de una 'EMPRESA'

--Listar el número de aviones clasificados por empresa y propietario

--Listar el número de aviones clasificados por empresa y constructor

-- Alteramos un poco los registros
            
-- Las sumas ya no dan los 35 mantenimientos
-- Se resulve aplicando LEFT o RIGHT OUTER JOIN


-- Muestre la lista completa de los aviones que han completado su proceso de mantenimiento indicando:
-- la matricula, modelo (nombre), constructor del avión, la falla, así como el nombre completo del mecánico que reparó y que revisó el mantenimeinto.

-- Mantenimiento JOIN --> Aviones + Mecanico Realiza + Mecánico Verifica

-- Mantenimiento JOIN --> (Aviones JOIN Tipos_Avion) + Mecanico Realiza + Mecánico Verifica


-- Cuantas horas (duración) ha trabajado el Mecánico 'Di Angelo', reparando y/o verificando aviones ?



--> Creación de vistas:  CREATE OR REPLACE VIEW _____ AS


-- Realizar una auditoría para detectar a los mecánicos que realizaron algún mantenimiento, y
-- NO cuentan con la habilitación correspondiente.



























































SELECT  a.*
FROM    aviones a;


SELECT   a.id, a.matricula, a.fecha_compra 
        ,CASE
      WHEN p.categoria LIKE 'EMPRESA' THEN
        p.nombre
      WHEN p.categoria LIKE 'PARTICULAR' THEN       
      p.nombre || ' '||P.ap_pat|| ' '||P.ap_mat
     END "propietario"
    ,p.categoria
FROM    aviones a JOIN propietarios p ON (a.propietario_id = p.id);


SELECT  a.*
FROM    aviones a;

SELECT  p.*
FROM    propietarios p;

SELECT  t.*
FROM    tipos_avion t;

SELECT  a.id, a.matricula, a.fecha_compra
       ,CASE
           WHEN p.categoria LIKE 'EMPRESA' THEN
             p.nombre
           WHEN p.categoria LIKE 'PARTICULAR' THEN       
             p.nombre ||' '||P.ap_pat|| ' '||P.ap_mat
        END "propietario"
     ,p.telefono, p.categoria
     ,t.constructor
FROM    aviones a JOIN propietarios p ON (a.propietario_id = p.id) JOIN tipos_avion t ON (a.tipo_avion_id = t.id)
WHERE   UPPER(t.constructor) LIKE 'AIRBUS%';



SELECT  hm.*
FROM    habilitaciones_pilotos hm;

SELECT  m.*
FROM    mecanicos m;

SELECT  t.*
FROM    tipos_avion t;

SELECT  p.id, p.nombre "piloto", COUNT(hp.tipo_avion_id)
FROM    habilitaciones_pilotos hp JOIN pilotos p ON (hp.piloto_id = p.id)
                                    JOIN tipos_avion t ON (hp.tipo_avion_id = t.id)
GROUP BY p.id, p.nombre
HAVING COUNT(hp.tipo_avion_id) > 2
ORDER BY p.id;
















