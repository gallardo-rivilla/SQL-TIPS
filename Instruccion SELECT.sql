--Base de datos de 10 GB a partir de 2010:
https://downloads.brentozar.com/StackOverflow2010.7z
--Esquema de los datos
https://i.stack.imgur.com/AyIkW.png
-- Más BBDD de StackOverFlow
https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/

-- Descarga fichero:
https://github.com/gallardo-rivilla/SQL-TIPS.git

/* INTRODUCCIÓN
Ejemplo de USO de la instrucción SELECT


 
Sintaxis de la instrucción SELECT de Transact-SQL
 -------------------------------------------------
SELECT statement> ::=    
    [ WITH { [ XMLNAMESPACES ,] [ <common_table_expression> [,...n] ] } ]  
    <query_expression>   
    [ ORDER BY { order_by_expression | column_position [ ASC | DESC ] }   
  [ ,...n ] ]   
    [ <FOR Clause>]   
    [ OPTION ( <query_hint> [ ,...n ] ) ]   
<query_expression> ::=   
    { <query_specification> | ( <query_expression> ) }   
    [  { UNION [ ALL ] | EXCEPT | INTERSECT }  
        <query_specification> | ( <query_expression> ) [...n ] ]   
<query_specification> ::=   
SELECT [ ALL | DISTINCT ]   
    [TOP ( expression ) [PERCENT] [ WITH TIES ] ]   
    < select_list >   
    [ INTO new_table ]   
    [ FROM { <table_source> } [ ,...n ] ]   
    [ WHERE <search_condition> ]   
    [ <GROUP BY> ]   
    [ HAVING < search_condition > ]

*/

--SELECT [TOP X] attributes & values
--FROM first_table
--INNER / LEFT / RIGHT JOIN second_table ON condition(s)
--... other joins if needed
--WHERE condition(s)
--GROUP BY set of attributes
--HAVING condition(s) for group by
--ORDER BY list attributes and order;


-- 1.Primeros pasos
-------------------------------------
SELECT 1 as numero;
SELECT 1+2 as suma;
SELECT 1+2 AS resultado;
SELECT 1+2 AS suma, 2*3 AS multi;
SELECT (CASE WHEN 1+2 > 2*3 THEN 'mayor' ELSE 'menor' END) AS comparacion;


-- Usamos BBDD de StackOverFlow

USE [StackOverflow2010]
GO

-- El * después de SELECT significa que seleccionaremos todas las columnas de esa tabla.
-- NO SE RECOMIENDA EL USO DEL * para optimizaciones solo usar las columnas necesarias.

SELECT * FROM [dbo].[Users]
SELECT * FROM [dbo].[Comments]
SELECT * FROM [dbo].[Badges]

-- 2.TIPS consultar tabla 
----------------------------------------------------
sp_help '[dbo].[Users]'
sp_help '[dbo].[Comments]'
sp_help '[dbo].[Badges]'


---2.1 TIPS mostrar todas las columnas
SELECT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments]





--3. Uso de funciones con select
-----------------------------------------------------
-- Evitar uso COUNT(*)
SELECT COUNT([Id]) FROM [dbo].[Users] -- Total registros tabla Users
SELECT COUNT([Id]) FROM [dbo].[Comments] -- Total registros tabla Comments
SELECT COUNT([Id]) FROM [dbo].[Badges] -- Total registros tabla Badges
SELECT MAX([Reputation]) FROM  [dbo].[Users] -- Maxima Reputacion
SELECT MIN([Views]) FROM  [dbo].[Users] -- Minimas vistas


-- 4.SQL TOP y TOP PERCENT
-------------------------------------------------------
-- Se utiliza para especificar el número de registros que se devolverán.
-- SELECT TOP number column_name FROM table_name WHERE condition;

SELECT TOP 10 [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments]
SELECT TOP 50 PERCENT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments] -- selecciona el primer 50% de los registros

-- 5.SELECT DISTINCT 
-----------------------------------------------------------
-- Selecciona solo los valores DISTINCT de la columna desada

SELECT  DISTINCT Name FROM [dbo].[Badges]


-- 6.SQL COUNT + DISTINCT
---------------------------------------------------------------------
-- Consulta para mostrar el total de diferentes Insignias.
SELECT DISTINCT Name FROM [dbo].[Badges]
SELECT COUNT(DISTINCT Name) FROM [dbo].[Badges]

-- 7. SELECT INTO
---------------------------------------------------------------------
-- Copia datos de una tabla a una tabla nueva
/*
SELECT columna1, columna2, columna3, ...
INTO nueva [IN externaldb]
FROM vieja
WHERE condicion;
*/
-- Vamos a copiar la tabla de coments de [StackOverflow2010] a [StackOverflow2010_backup]

SELECT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] INTO [StackOverflow2010_backup].[dbo].[Comments]
FROM [dbo].[Comments]

-- Comprobamos que se han insertado:
USE [StackOverflow2010_backup]
GO
-------------------------------------
SELECT COUNT([Id]) FROM [dbo].[Comments]

-- 8. TIPS Borramos la tabla creada para realizar otro insert.
USE [StackOverflow2010]
GO
drop table [dbo].[Comments] -- Eliminar tabla completa 
DELETE FROM [dbo].[Comments] -- Borrar registros

-- Realizamos una copia de los comentarios con un score superior a 8
SELECT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] INTO [StackOverflow2010_backup].[dbo].[Comments]
FROM [dbo].[Comments]
where score > 8

-- Comprobamos que se han insertado:
USE [StackOverflow2010_backup]
GO
SELECT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments]

-- 9. INTO SELECT
-- Copia datos de una tabla y los inserta en otra tabla
-- Requiere que los tipos de datos en las tablas de origen y destino coincidan.
/*
INSERT INTO destino (column1, column2, column3, ...)
SELECT column1, column2, column3, ...
FROM origen
WHERE condición;
*/
-- Borramos previamente los datos insertados en el Tip anterior 
USE [StackOverflow2010_backup]
GO
DELETE [dbo].[Comments]
--- Realizamos el INSERT INTO SELECT

 -- Importante habilitar IDENTITY_INSERT. Más info: https://docs.microsoft.com/es-es/sql/t-sql/statements/set-identity-insert-transact-sql?view=sql-server-ver15
 -- Solo una tabla de una sesión puede tener la propiedad IDENTITY_INSERT establecida en ON.
 -- Debes ser el propietario de la tabla o disponer del permiso ALTER en esta.

SET IDENTITY_INSERT [dbo].[Comments] ON

INSERT INTO [dbo].[Comments] ([Id], [CreationDate], [PostId], [Score], [Text], [UserId])
SELECT [Id], [CreationDate], [PostId], [Score], [Text], [UserId]
FROM [StackOverflow2010].[dbo].[Comments]

SET IDENTITY_INSERT [dbo].[Comments] OFF -- Volvemos a desactivarlo.