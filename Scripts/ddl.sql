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

-- C. ¡Listo! Agregamos la restricción de PRIMARY KEY de manera segura
ALTER TABLE dbo.Stg_BPD_Arrests 
ADD CONSTRAINT PK_Stg_BPD_Arrests PRIMARY KEY (Arrest);


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
SET [Location 1] = 'No Registrado'
WHERE [Location 1] IS NULL;

SELECT Age, COUNT(*) FROM dbo.Stg_BPD_Arrests 
WHERE Age < 0 OR Age > 100
GROUP BY Age;


select *
from Stg_BPD_Arrests