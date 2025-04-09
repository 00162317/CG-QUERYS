--ESTE ES PARA VENTAS
SELECT
    T0."DocEntry" AS "Número Interno SAP",
    T0."DocDate" AS "Fecha Documento", 
    CASE 
        WHEN T1."U_tcontribuye" = '1' THEN 'N' -- Persona Natural
        WHEN T1."U_tcontribuye" = '2' THEN 'J' -- Persona Jurídica
        ELSE 'P' -- Extranjero
    END AS "Tipo Persona",
    T1."LicTradNum" AS "RUC del Cliente",
    CASE 
        WHEN T1."U_tcontribuye" IN ('3') THEN '0' -- Pasaporte o identificación tributaria extranjera
        ELSE T1."AddID" -- Últimos 2 caracteres como DV
    END AS "DV",
    T1."CardName" AS "Nombre o Razón Social",
    CASE 
        WHEN T0."DocSubType" = 'DN' THEN CONCAT('ND-', T0."DocNum") -- Notas de Débito
        WHEN T0."DocSubType" = 'CN' THEN CONCAT('NC-', T0."DocNum") -- Notas de Crédito
        ELSE T0."DocNum" -- Facturas
    END AS "N° Factura/Documento",
    CASE 
        WHEN T0."DocSubType" = 'CN' THEN T0."BaseAmnt" * -1 -- Valor negativo para NC
        ELSE T0."BaseAmnt"
    END AS "Monto Gravado ITBMS",
    CASE 
        WHEN T0."DocSubType" = 'CN' THEN T0."VatSum" * -1 -- Valor negativo para NC
        ELSE T0."VatSum"
    END AS "ITBMS Causado",
    CASE 
        WHEN T1."U_co_dgi_ret" = '1' THEN 'Pago por Servicio Profesional al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '2' THEN 'Pago por Venta de Bienes / Servicios al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '3' THEN 'Pago o Acreditación no Domiciliados o Empresa en el Exterior 100%'
        WHEN T1."U_co_dgi_ret" = '4' THEN 'Pago o Acreditación por Compra de Bienes / Servicios 50%'
        WHEN T1."U_co_dgi_ret" = '5' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD 50%'
        WHEN T1."U_co_dgi_ret" = '6' THEN 'Pago por Venta de Bienes / Servicios al Estado – otro %'
        WHEN T1."U_co_dgi_ret" = '7' THEN 'Pago o Acreditación por Compra de Bienes / Servicios – otro %'
        WHEN T1."U_co_dgi_ret" = '8' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD %'
        ELSE 'Sin objeto de retención definido'
    END AS "Objeto de la Retención"
FROM 
    OINV T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1] -- Rango de fechas
    AND T0."VatSum" > 0 -- Solo facturas con ITBMS aplicado
    AND T0."DocType" = 'I'; -- Solo facturas


-- COMPRAS

SELECT
    CASE 
        WHEN T1."U_co_dgi_ret" = '1' THEN 'Pago por Servicio Profesional al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '2' THEN 'Pago por Venta de Bienes / Servicios al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '3' THEN 'Pago o Acreditación no Domiciliados o Empresa en el Exterior 100%'
        WHEN T1."U_co_dgi_ret" = '4' THEN 'Pago o Acreditación por Compra de Bienes / Servicios 50%'
        WHEN T1."U_co_dgi_ret" = '5' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD 50%'
        WHEN T1."U_co_dgi_ret" = '6' THEN 'Pago por Venta de Bienes / Servicios al Estado – otro %'
        WHEN T1."U_co_dgi_ret" = '7' THEN 'Pago o Acreditación por Compra de Bienes / Servicios – otro %'
        WHEN T1."U_co_dgi_ret" = '8' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD %'
        ELSE 'Sin objeto de retención definido'
    END AS "Tipo de Retención",
    T0."DocNum" AS "N° Factura",
    T1."CardName" AS "Nombre",
    T1."LicTradNum" AS "RUC",
    CASE 
        WHEN T1."U_tcontribuye" IN ('3') THEN '0' -- Pasaporte o identificación tributaria extranjera
        ELSE T1."AddID" -- Últimos 2 caracteres como DV
    END AS "DV",
    T0."DocDate" AS "Fecha Pago",
    T0."DocTotal" AS "Monto Pagado", -- Total pagado por la factura
    T0."VatSum" AS "Monto ITBMS", -- ITBMS aplicado en la factura
    CASE 
        WHEN T1."U_co_dgi_ret" IN ('1', '2', '4', '5') THEN T0."VatSum" * 0.5 -- Retención del 50%
        WHEN T1."U_co_dgi_ret" = '3' THEN T0."VatSum" -- Retención del 100%
        ELSE 0 -- Sin retención
    END AS "ITBMS Retenido",
    T0."DocTotal" - T0."VatSum" AS "Monto Factura" -- Monto sin ITBMS
FROM 
    OPCH T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocDate" BETWEEN [%0] AND [%1] -- Rango de fechas
    --AND T0."VatSum" > 0; -- Solo facturas con ITBMS



-- COMPRAS

SELECT
    CASE 
        WHEN T1."U_co_dgi_ret" = '1' THEN 'Pago por Servicio Profesional al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '2' THEN 'Pago por Venta de Bienes / Servicios al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '3' THEN 'Pago o Acreditación no Domiciliados o Empresa en el Exterior 100%'
        WHEN T1."U_co_dgi_ret" = '4' THEN 'Pago o Acreditación por Compra de Bienes / Servicios 50%'
        WHEN T1."U_co_dgi_ret" = '5' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD 50%'
        WHEN T1."U_co_dgi_ret" = '6' THEN 'Pago por Venta de Bienes / Servicios al Estado – otro %'
        WHEN T1."U_co_dgi_ret" = '7' THEN 'Pago o Acreditación por Compra de Bienes / Servicios – otro %'
        WHEN T1."U_co_dgi_ret" = '8' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD %'
        ELSE 'Sin objeto de retención definido'
    END AS "Tipo de Retención",
    T0."DocNum" AS "N° Factura",
    T1."CardName" AS "Nombre",
    T1."LicTradNum" AS "RUC", T1."CardCode",
    CASE 
        WHEN T1."U_tcontribuye" IN ('3') THEN '0' -- Pasaporte o identificación tributaria extranjera
        ELSE T1."AddID" -- Últimos 2 caracteres como DV
    END AS "DV",
    T0."DocDate" AS "Fecha Pago",
    T0."DocTotal" AS "Monto Pagado", -- Total pagado por la factura
    T0."VatSum" AS "Monto ITBMS", -- ITBMS aplicado en la factura
    CASE 
        WHEN T1."U_co_dgi_ret" IN ('1', '2', '4', '5') THEN T0."VatSum" * 0.5 -- Retención del 50%
        WHEN T1."U_co_dgi_ret" = '3' THEN T0."VatSum" -- Retención del 100%
        ELSE 0 -- Sin retención
    END AS "ITBMS Retenido",
    T0."DocTotal" - T0."VatSum" AS "Monto Factura" -- Monto sin ITBMS
FROM 
    OPCH T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocDate" BETWEEN {?FechaInicio} AND {?FechaFin}-- Rango de fechas
    --AND T0."VatSum" > 0; -- Solo facturas con ITBMS
AND T1."CardCode" = '{?CardCode}' AND T1."U_Recep_1027" != 0



------ COMPRAS pero con las NDC en cuenta


-- COMPRAS
SELECT
    CASE 
        WHEN T1."U_co_dgi_ret" = '1' THEN 'Pago por Servicio Profesional al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '2' THEN 'Pago por Venta de Bienes / Servicios al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '3' THEN 'Pago o Acreditación no Domiciliados o Empresa en el Exterior 100%'
        WHEN T1."U_co_dgi_ret" = '4' THEN 'Pago o Acreditación por Compra de Bienes / Servicios 50%'
        WHEN T1."U_co_dgi_ret" = '5' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD 50%'
        WHEN T1."U_co_dgi_ret" = '6' THEN 'Pago por Venta de Bienes / Servicios al Estado – otro %'
        WHEN T1."U_co_dgi_ret" = '7' THEN 'Pago o Acreditación por Compra de Bienes / Servicios – otro %'
        WHEN T1."U_co_dgi_ret" = '8' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD %'
        ELSE 'Sin objeto de retención definido'
    END AS "Tipo de Retención",
    T0."DocNum" AS "N° Factura",
    T1."CardName" AS "Nombre",
    T1."LicTradNum" AS "RUC", T1."CardCode",
    CASE 
        WHEN T1."U_tcontribuye" IN ('3') THEN '0' -- Pasaporte o identificación tributaria extranjera
        ELSE T1."AddID" -- Últimos 2 caracteres como DV
    END AS "DV",
    T0."DocDate" AS "Fecha Pago",
    T0."DocTotal" AS "Monto Pagado", -- Total pagado por la factura
    T0."VatSum" AS "Monto ITBMS", -- ITBMS aplicado en la factura
    CASE 
        WHEN T1."U_co_dgi_ret" IN ('1', '2', '4', '5') THEN T0."VatSum" * 0.5 -- Retención del 50%
        WHEN T1."U_co_dgi_ret" = '3' THEN T0."VatSum" -- Retención del 100%
        ELSE 0 -- Sin retención
    END AS "ITBMS Retenido",
    T0."DocTotal" - T0."VatSum" AS "Monto Factura" -- Monto sin ITBMS
,T0."NumAtCard"
FROM 
    OPCH T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocDate" BETWEEN {?FechaInicio} AND {?FechaFin}-- Rango de fechas
    --AND T0."VatSum" > 0; -- Solo facturas con ITBMS
AND T1."CardCode" = '{?CardCode}' AND T1."U_Recep_1027" != 0

UNION ALL 

SELECT
    CASE 
        WHEN T1."U_co_dgi_ret" = '1' THEN 'Pago por Servicio Profesional al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '2' THEN 'Pago por Venta de Bienes / Servicios al Estado 50%'
        WHEN T1."U_co_dgi_ret" = '3' THEN 'Pago o Acreditación no Domiciliados o Empresa en el Exterior 100%'
        WHEN T1."U_co_dgi_ret" = '4' THEN 'Pago o Acreditación por Compra de Bienes / Servicios 50%'
        WHEN T1."U_co_dgi_ret" = '5' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD 50%'
        WHEN T1."U_co_dgi_ret" = '6' THEN 'Pago por Venta de Bienes / Servicios al Estado – otro %'
        WHEN T1."U_co_dgi_ret" = '7' THEN 'Pago o Acreditación por Compra de Bienes / Servicios – otro %'
        WHEN T1."U_co_dgi_ret" = '8' THEN 'Pago a Comercio Afiliado a Sistema de TC/TD %'
        ELSE 'Sin objeto de retención definido'
    END AS "Tipo de Retención",
    T0."DocNum" AS "N° NDC",
    T1."CardName" AS "Nombre",
    T1."LicTradNum" AS "RUC", T1."CardCode",
    CASE 
        WHEN T1."U_tcontribuye" IN ('3') THEN '0' -- Pasaporte o identificación tributaria extranjera
        ELSE T1."AddID" -- Últimos 2 caracteres como DV
    END AS "DV",
    T0."DocDate" AS "Fecha Pago",
    T0."DocTotal"*-1 AS "Monto Pagado", -- Total pagado por la factura
    T0."VatSum"*-1 AS "Monto ITBMS", -- ITBMS aplicado en la factura
    CASE 
        WHEN T1."U_co_dgi_ret" IN ('1', '2', '4', '5') THEN (T0."VatSum" * 0.5)*-1 -- Retención del 50%
        WHEN T1."U_co_dgi_ret" = '3' THEN T0."VatSum"*-1 -- Retención del 100%
        ELSE 0 -- Sin retención
    END AS "ITBMS Retenido",
    (T0."DocTotal" - T0."VatSum")*-1 AS "Monto Factura" -- Monto sin ITBMS
,T0."NumAtCard"
FROM 
    ORPC T0
INNER JOIN 
    OCRD T1 ON T0."CardCode" = T1."CardCode"
WHERE 
    T0."DocDate" BETWEEN {?FechaInicio} AND {?FechaFin}-- Rango de fechas
    --AND T0."VatSum" > 0; -- Solo facturas con ITBMS
AND T1."CardCode" = '{?CardCode}' AND T1."U_Recep_1027" != 0