CREATE DATABASE Arresto
use Arresto

IF OBJECT_ID('dbo.Stg_BPD_Arrests', 'U') IS NOT NULL
    DROP TABLE dbo.Stg_BPD_Arrests;
    
-- 2. Creamos la tabla corregida (sin PRIMARY KEY para que acepte filas vacías)
CREATE TABLE dbo.Stg_BPD_Arrests (
    Arrest NVARCHAR(50) NULL, 
    Age NVARCHAR(50) NULL,
    Sex NVARCHAR(10) NULL,
    Race NVARCHAR(10) NULL,
    ArrestDate NVARCHAR(20) NULL,
    ArrestTime NVARCHAR(20) NULL,
    ArrestLocation NVARCHAR(255) NULL,
    IncidentOffense NVARCHAR(255) NULL,
    IncidentLocation NVARCHAR(255) NULL,
    Charge NVARCHAR(50) NULL,
    ChargeDescription NVARCHAR(255) NULL,
    District NVARCHAR(100) NULL,
    Post NVARCHAR(20) NULL,
    Neighborhood NVARCHAR(255) NULL,
    [Location 1] NVARCHAR(100) NULL
);

-- 3. Importamos el archivo masivamente
BULK INSERT dbo.Stg_BPD_Arrests
FROM 'C:\Users\User\Desktop\CLASES ANALISIS DE DATOS DATA ACADEM Y\SQL CLASE JHON\Proyecto\SQL-SEVER-PROJECT-HR-ANALYTICS\SQL-SERVER-HR-ANALITYCS--3-EDICION\Data\Arrestos.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
-- -- -- -- -- -- --
-- DATA CLEANING --
-- -- -- -- -- -- --


-- A. Borramos las filas que no tienen número de arresto (las corruptas que rompían todo)
DELETE FROM dbo.Stg_BPD_Arrests 
WHERE Arrest IS NULL OR Arrest = '';

-- B. Cambiamos la columna para decirle a SQL que ya no se permiten vacíos
ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN Arrest NVARCHAR(50) NOT NULL;


-- Verificar valores duplicados en la tabla Stg_BPD_Arrests --

SELECT Arrest, COUNT(*) as Repeticiones
FROM dbo.Stg_BPD_Arrests
GROUP BY Arrest
HAVING COUNT(*) > 1;

-- 1. Convertir la Edad a un número entero (INT)
ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN Age INT NULL;

-- 2. Convertir Sexo y Raza a tipos de longitud fija óptimos
ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN Sex CHAR(1) NULL;

ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN Race CHAR(1) NULL;

-- 3. Convertir la hora al formato TIME real
UPDATE dbo.Stg_BPD_Arrests
SET ArrestTime = TRY_CAST(ArrestTime AS TIME);

ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN ArrestTime TIME NULL;

-- 4. Convertir el Post (Zona/Cuadrante) a un número entero (INT)
ALTER TABLE dbo.Stg_BPD_Arrests 
ALTER COLUMN Post INT NULL;

-- 5. Cambiamos los NULLs por un texto descriptivo 
UPDATE dbo.Stg_BPD_Arrests
SET ArrestLocation = 'No Registrado'
WHERE ArrestLocation IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET IncidentLocation = 'No Registrado'
WHERE IncidentLocation IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET District = 'No Registrado'
WHERE District IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET Post = 0
WHERE Post IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET Neighborhood = 'No Registrado'
WHERE Neighborhood IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET ChargeDescription = 'Sin Descripcion'
WHERE ChargeDescription IS NULL;

UPDATE dbo.Stg_BPD_Arrests
SET [Location 1] = 'No Registrado'
WHERE [Location 1] IS NULL;

SELECT Age, COUNT(*) FROM dbo.Stg_BPD_Arrests 
WHERE Age < 0 OR Age > 100
GROUP BY Age;


select *
from Stg_BPD_Arrests

-- Consulta de diagnóstico para detectar nulos en variables clave
-- Verificar valores nulos en los campos clave de la tabla Stg_BPD_Arrests
SELECT 
    COUNT(CASE WHEN Arrest IS NULL THEN 1 END) AS Nulos_ID_Arresto,
    COUNT(CASE WHEN Age IS NULL THEN 1 END) AS Nulos_Edad,
    COUNT(CASE WHEN Sex IS NULL THEN 1 END) AS Nulos_Sexo,
    COUNT(CASE WHEN District IS NULL THEN 1 END) AS Nulos_Distrito,
    COUNT(CASE WHEN ArrestDate IS NULL THEN 1 END) AS Nulos_Fecha,
    COUNT(CASE WHEN ChargeDescription IS NULL THEN 1 END) AS Nulos_Cargo
FROM dbo.Stg_BPD_Arrests;

select age
from Stg_BPD_Arrests
where age = 0

-- Ver las filas que tienen el ID de arresto repetido
SELECT * 
FROM dbo.Stg_BPD_Arrests
WHERE Arrest IN (
    SELECT Arrest 
    FROM dbo.Stg_BPD_Arrests
    GROUP BY Arrest
    HAVING COUNT(*) > 1
)
ORDER BY Arrest;


SELECT 
    District,
    COUNT(*) AS TotalArrestos
FROM dbo.Stg_BPD_Arrests
GROUP BY District
ORDER BY TotalArrestos DESC;

SELECT TOP 10
    Age,
    COUNT(*) AS CantidadCasos
FROM dbo.Stg_BPD_Arrests
WHERE Age IS NOT NULL
GROUP BY Age
ORDER BY CantidadCasos DESC;

SELECT 
    Sex,
    Race,
    COUNT(*) AS TotalArrestos
FROM dbo.Stg_BPD_Arrests
WHERE Sex IS NOT NULL AND Race IS NOT NULL
GROUP BY Sex, Race
ORDER BY TotalArrestos DESC;

SELECT 
    District,
    COUNT(*) AS TotalArrestos
FROM dbo.Stg_BPD_Arrests
GROUP BY District
HAVING COUNT(*) > 10000
ORDER BY TotalArrestos DESC;

SELECT 
    CASE 
        WHEN Age < 18 THEN 'Menores (<18)'
        WHEN Age BETWEEN 18 AND 29 THEN 'Jóvenes Adultos (18-29)'
        WHEN Age BETWEEN 30 AND 55 THEN 'Adultos (30-55)'
        ELSE 'Adultos Mayores (56+)' 
    END AS CategoriaEdad,
    COUNT(*) AS TotalArrestos
FROM dbo.Stg_BPD_Arrests
WHERE Age IS NOT NULL
GROUP BY 
    CASE 
        WHEN Age < 18 THEN 'Menores (<18)'
        WHEN Age BETWEEN 18 AND 29 THEN 'Jóvenes Adultos (18-29)'
        WHEN Age BETWEEN 30 AND 55 THEN 'Adultos (30-55)'
        ELSE 'Adultos Mayores (56+)' 
    END
ORDER BY TotalArrestos DESC;

-- Los 10 cargos criminales más comunes --
SELECT TOP 10 
    ChargeDescription AS Cargo_Criminal,
    COUNT(*) AS Total_Arrestos
FROM dbo.Stg_BPD_Arrests
WHERE ChargeDescription IS NOT NULL 
  AND ChargeDescription <> 'Unknown Charge'
GROUP BY ChargeDescription
ORDER BY Total_Arrestos DESC;

SELECT TOP 10
    ChargeDescription,
    COUNT(CASE WHEN Sex = 'M' THEN 1 END) AS Arrestos_Hombres,
    COUNT(CASE WHEN Sex = 'F' THEN 1 END) AS Arrestos_Mujeres
FROM dbo.Stg_BPD_Arrests
WHERE Sex IN ('M', 'F')
GROUP BY ChargeDescription
ORDER BY COUNT(*) DESC;

WITH RankingVecindarios AS (
    SELECT 
        District,
        Neighborhood,
        COUNT(*) AS TotalArrestos,
        DENSE_RANK() OVER (PARTITION BY District ORDER BY COUNT(*) DESC) AS Posicion
    FROM dbo.Stg_BPD_Arrests
    WHERE District <> 'No Registrado' AND Neighborhood <> 'No Registrado'
    GROUP BY District, Neighborhood
)
SELECT 
    District,
    Neighborhood,
    TotalArrestos
FROM RankingVecindarios
WHERE Posicion <= 3;

WITH HistorialArrestos AS (
    SELECT 
        Arrest,
        Post,
        ArrestDate,
        LAG(ArrestDate) OVER (PARTITION BY Post ORDER BY ArrestDate) AS FechaArrestoAnterior
    FROM dbo.Stg_BPD_Arrests
    WHERE Post <> 0 AND ArrestDate IS NOT NULL
)

-- Delitos donde el promedio de edad de los implicados es menor a 25 años
SELECT 
    ChargeDescription AS Delito,
    ROUND(AVG(CAST(Age AS FLOAT)), 2) AS Edad_Promedio
FROM dbo.Stg_BPD_Arrests
WHERE Age > 0 AND ChargeDescription <> 'Unknown Charge'
GROUP BY ChargeDescription
HAVING AVG(CAST(Age AS FLOAT)) < 25
ORDER BY Edad_Promedio ASC;

-- Segmentación estratégica de distritos basada en volumen y edad promedio
WITH CTE_MetricasDistrito AS (
    SELECT 
        District AS Distrito,
        COUNT(*) AS Total_Arrestos,
        AVG(CAST(Age AS FLOAT)) AS Edad_Promedio
    FROM dbo.Stg_BPD_Arrests
    WHERE District <> 'No Registrado' AND Age > 0
    GROUP BY District
)
SELECT 
    Distrito,
    Total_Arrestos,
    ROUND(Edad_Promedio, 2) AS Edad_Promedio,
    CASE 
        WHEN Total_Arrestos > 12000 AND Edad_Promedio < 30 THEN 'CRÍTICO: Delincuencia Juvenil Masiva'
        WHEN Total_Arrestos > 12000 AND Edad_Promedio >= 30 THEN 'CRÍTICO: Delincuencia Adulta Concentrada'
        WHEN Total_Arrestos BETWEEN 5000 AND 12000 THEN 'ALERTA: Actividad Moderada en Monitoreo'
        ELSE 'ESTABLE: Bajo Impacto Operativo'
    END AS Clasificacion_Estrategica
FROM CTE_MetricasDistrito
ORDER BY Total_Arrestos DESC;

-- Análisis de impacto y ranking demográfico acumulado
WITH CTE_PerfilDemografico AS (
    SELECT 
        Sex AS Sexo,
        Race AS Raza,
        COUNT(*) AS Total_Arrestos
    FROM dbo.Stg_BPD_Arrests
    WHERE Sex IN ('M', 'F') AND Race IS NOT NULL
    GROUP BY Sex, Race
)
SELECT 
    Sexo,
    Raza,
    Total_Arrestos,
    DENSE_RANK() OVER (ORDER BY Total_Arrestos DESC) AS Ranking_Impacto,
    ROUND((CAST(Total_Arrestos AS FLOAT) / SUM(Total_Arrestos) OVER()) * 100, 2) AS Porcentaje_Participacion
FROM CTE_PerfilDemografico
ORDER BY Total_Arrestos DESC;

-- Crear un ranking oficial de distritos por volumen operativo
WITH CTE_RankingDistritos AS (
    SELECT 
        District AS Distrito,
        COUNT(*) AS Total_Arrestos
    FROM dbo.Stg_BPD_Arrests
    WHERE District <> 'No Registrado'
    GROUP BY District
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY Total_Arrestos DESC) AS Puesto_Oficial,
    Distrito,
    Total_Arrestos
FROM CTE_RankingDistritos;

-- Distribución operativa y balance de género por distrito
SELECT 
    District AS Distrito,
    COUNT(*) AS Total_Arrestos,
    SUM(CASE WHEN Sex = 'M' THEN 1 ELSE 0 END) AS Arrestos_Hombres,
    SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS Arrestos_Mujeres,
    ROUND((CAST(SUM(CASE WHEN Sex = 'F' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100, 2) AS Porcentaje_Mujeres
FROM dbo.Stg_BPD_Arrests
WHERE District <> 'No Registrado' AND Sex IN ('M', 'F')
GROUP BY District
ORDER BY Total_Arrestos DESC;