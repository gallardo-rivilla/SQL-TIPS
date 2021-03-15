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
sp_help '[dbo].[Users]'
sp_help '[dbo].[Comments]'
sp_help '[dbo].[Badges]'
--- Uso de SELECT con campos seleccionados.


SET STATISTICS IO ON

SELECT [Id], [AboutMe], [Age], [CreationDate], [DisplayName], [DownVotes], [EmailHash], [LastAccessDate], [Location], [Reputation], [UpVotes], [Views], [WebsiteUrl], [AccountId]
FROM [dbo].[Users]

SELECT * FROM [dbo].[Users]

SET STATISTICS IO OFF 



---3. Uso de funciones con select
-- Evitar uso COUNT(*)
SELECT COUNT([Id]) FROM [dbo].[Users] -- Total registros tabla Users
SELECT COUNT([Id]) FROM [dbo].[Comments] -- Total registros tabla Comments
SELECT COUNT([Id]) FROM [dbo].[Badges] -- Total registros tabla Badges
SELECT MAX([Reputation]) FROM  [dbo].[Users] -- Maxima Reputacion
SELECT MIN([Views]) FROM  [dbo].[Users] -- Minimas vistas


-- 4.SQL TOP y TOP PERCENT
-- Se utiliza para especificar el número de registros que se devolverán.
-- SELECT TOP number column_name FROM table_name WHERE condition;

SELECT TOP 10 [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments]
SELECT TOP 50 PERCENT [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments] -- selecciona el primer 50% de los registros

-- 5.SELECT DISTINCT 
-- Selecciona solo los valores DISTINCT de la columna desada

SELECT  DISTINCT Name FROM [dbo].[Badges]


-- 6.SQL COUNT + DISTINCT
-- Consulta para mostrar el total de diferentes Insignias.

SELECT COUNT(DISTINCT Name) FROM [dbo].[Badges]

-- 7. SELECT INTO
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
-- Borramos la tabla creada para realizar otro insert.
drop table [dbo].[Comments]