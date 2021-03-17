--Base de datos de 10 GB a partir de 2010:
https://downloads.brentozar.com/StackOverflow2010.7z
--Esquema de los datos
https://i.stack.imgur.com/AyIkW.png
-- Más BBDD de StackOverFlow
https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/

-- Descarga fichero:
https://github.com/gallardo-rivilla/SQL-TIPS.git

------------------------------------------------
-- 1. SINTAXIS y OPERADORES 
------------------------------------------------

/*
SELECT columna1, columna2, ...
FROM nombre_tabla
WHERE condicion
-- Recuperar registros pero sólo los que cumplan con ciertas condiciones indicadas en la cláusula "where"
-- La cláusula WHERE no sólo se utiliza en las declaraciones SELECT, 
-- sino que también se utiliza en UPDATE, DELETE, etc!

Operadores de comparación SQL
-----------------------------
=	Equal to	
>	Greater than	
<	Less than	
>=	Greater than or equal to	
<=	Less than or equal to	
<>	Not equal to

Operadores lógicos SQL
-------------------------
ALL		
AND	
ANY		
BETWEEN	
EXISTS	 -- no busca valores, sino que verifica la existencia de filas.
IN	  -- se utiliza normalmente para filtrar una columna para una determinada lista de valores. También puede utilizar el operador IN para buscar los valores en el conjunto de resultados de una subconsulta
LIKE  -- realizar comparaciones exclusivamente de cadenas. El signo de porcentaje (%) representa cero, uno o varios caracteres. El signo de subrayado (_) representa un solo carácter		
NOT		
OR		
SOME	
*/
-- Usamos BBDD de StackOverFlow

USE [StackOverflow2010]
GO

------------------------------------------------
--2. Uso básico de la clásula WHERE
------------------------------------------------

-- 2.1 Ejemplo: Se nos pide mostrar el texto de los comentarios con un score igual o superior a 500

SELECT TOP 10 [Id], [CreationDate], [PostId], [Score], [Text], [UserId] FROM [dbo].[Comments] --Visualizamos los primeros 10 registros
SELECT DISTINCT score FROM [dbo].[Comments] -- Comprobamos los distintos valores del campo score

SELECT [Text] 
FROM [dbo].[Comments]
WHERE Score >= 500 -- Importante poner el = en último lugar

-- 2.2 Ejemplo: Se nos pide mostrar la ID de los usuarios que tengan un score inferior a 300 para el mes de Febrero 
SELECT [UserId] 
FROM  [dbo].[Comments]
WHERE Score < 300 and MONTH([CreationDate]) = MONTH(2)

-- 2.3 Ejemplo: Se nos pide mostrar el nombre de los usuarios creados en el ultimo año (2010)
SELECT  [DisplayName], CreationDate 
FROM [dbo].[Users]
WHERE YEAR([CreationDate]) = 2010

-- 2.4 Ejemplo: Se nos pide mostrar de los usuarios anteriores solo los que sean de la ciudad de New York
SELECT  [DisplayName], [CreationDate], [Location]
FROM [dbo].[Users]
WHERE YEAR([CreationDate]) = 2010 
AND [Location] ='New York'

-- 2.5 Ejemplo: Se nos pide mostrar de los usuarios anteriores los que su nombre comienze por la letra A.
SELECT  [DisplayName], [CreationDate], [Location]
FROM [dbo].[Users]
WHERE YEAR([CreationDate]) = 2010 
AND [Location] ='New York'
AND DisplayName LIKE 'A%'

------------------------------------------------
-- 3. WHERE SUBQUERY
------------------------------------------------
-- Podemos usar en la condición del where una consulta independiente

--3.1 Ejemplo: Se nos pide mostrar los nombres de los usuarios que tengan post creados con un más de 80.000 visitas

-- Primero buscamos los id de los usuarios que tengan post con más de 80.000 vistas
SELECT [OwnerUserId]
FROM [dbo].[Posts] 
WHERE [ViewCount] > 80000

--- Segundo realizamos una nueva consulta con la tabla usuarios y luego incluimos la consulta anterior.
SELECT [DisplayName]
FROM [dbo].[Users]
WHERE [Id] IN (SELECT [OwnerUserId]
			   FROM [dbo].[Posts] 
               WHERE [ViewCount] > 80000
			   )

--3.2 Ejemplo: Se nos pide mostrar el total de post por usuario.
SELECT [DisplayName], 
[TOTAL_POST] = (SELECT COUNT(p.[Id])
			   FROM [dbo].[Posts] p
               WHERE p.[OwnerUserId]= u.[Id]
			   ) 
FROM [dbo].[Users] u
------------------------------------------------
--4. WHERE IN y NOT IN 
------------------------------------------------

-- 4.1 Ejemplo: Se nos pide el titulo de los post que tengan 10 o 20 comentarios

SELECT [Title], [CommentCount]
FROM [dbo].[Posts]
WHERE [CommentCount] IN (10,20)


-- 4.2 Ejemplo: Se nos pide mostrar los post cuyos votos no sean de tipo Spam (12) y Close (6)
SELECT [PostId], [VoteTypeId]
FROM [dbo].[Votes]
WHERE [VoteTypeId] NOT IN (12,6)

------------------------------------------------
--5. WHERE EXIST Y NOT EXISTS
------------------------------------------------
-- Se emplean para determinar si hay o no datos en una lista de valores.
-- Estos operadores retornan "true" (si las subconsultas retornan registros) o "false" (si las subconsultas no retornan registros).

-- 5.1 EXIST Ejemplo:Se nos pide mostrar los post que tengan votos de tipo  UpMod(2)
SELECT [Title], [Id]
FROM [dbo].[Posts] p
WHERE EXISTS (
				SELECT [PostId]
				FROM [dbo].[Votes] v
				WHERE v.VoteTypeId=2
				AND p.[Id]=v.[PostId]
				
                  ) AND p.[Title] is not null

-- 5.2 NOT EXISTS Ejemplo: Se nos pide los usuarios que no tengan más de 50 post creados

SELECT [Id], [DisplayName]
FROM [dbo].[Users] u
WHERE NOT EXISTS ( 
					--Subquery con los usuarios con mas de 50 post
					SELECT [OwnerUserId], COUNT(ID) AS TOTAL_POST
					FROM [dbo].[Posts] p
					GROUP BY [OwnerUserId]
					HAVING COUNT(ID) > 50 AND p.[OwnerUserId]= u.[Id]
					)
-- Comprobacion de los resultados:

  SELECT [OwnerUserId], COUNT(ID) AS TOTAL_POST
  FROM [dbo].[Posts]
  GROUP BY [OwnerUserId]
  HAVING  [OwnerUserId] = 140
  ORDER BY COUNT(ID)  

------------------------------------------------
-- 6. WHERE BETWEEN Y NOT BETWEEN
------------------------------------------------
-- El operador BETWEEN selecciona valores dentro de un rango determinado. 
-- Los valores pueden ser números, texto o fechas.
-- Es inclusivo: se incluyen los valores inicial y final. 
--  BETWEEN valor1 AND valor2

-- 6.1 BETWEEN Ejemplo: Se nos pide mostrar los últimos 10 post editados  entre el Q1 del año 2018
SELECT [Title], [LastEditDate]
FROM [dbo].[Posts]
WHERE [LastEditDate] BETWEEN '20180101' AND  '20180630'
AND [Title] is not null

 -- TIPS HORAS,SEGUNDOS..ETC
 -- BETWEEN convierte el rango en '2018-01-01 00:00:00' Y '2018-06-30 00:00:00'
 -- Faltarán todos los valores de fecha y hora para ese último día (excepto aquellos, si los hay, que especifican exactamente la medianoche).
 -- En este caso no aparecen, por lo que son los mismos resultados:
 SELECT [Title], [LastEditDate]
FROM [dbo].[Posts]
WHERE [LastEditDate] >='20180101' AND [LastEditDate] <= '20180630'
AND [Title] is not null


-- 6.2 NOT BETWEEN Ejemplo: Se nos pide mostrar los post cuyos comentarios no esten entre 0 y 10, y el título no se sea NULL
 SELECT [Title], [CommentCount] as Comentarios
FROM [dbo].[Posts]
WHERE [CommentCount] NOT BETWEEN '0' AND '10'
AND [Title] is not null


------------------------------------------------
-- 7. WHERE ANY
------------------------------------------------
--  ANY devuelve un valor booleano como resultado. devuelve VERDADERO si CUALQUIERA de los valores de la subconsulta cumple la condición

-- 7.1 ANY Ejemplo: Se nos pide mostrar los post que tengan votos de tipo  UpMod(2)

-- Igual que el ejemplo 5.1 con EXISTS

SELECT [Title], [PostTypeId]
FROM [dbo].[Posts] p
WHERE [Id] = ANY (
				SELECT [PostId]
				FROM [dbo].[Votes] v
				WHERE v.VoteTypeId=2
				AND p.[Id]=v.[PostId]
				
                  ) AND p.[Title] is not null