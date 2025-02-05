-- OPCION 1
SELECT DISTINCT 'TRUE'
FROM OPOR K0
WHERE (
            $[OPOR."DocTotal"] + 
            (SELECT COALESCE(SUM(K1."DocTotal"), 0) 
             FROM OPOR K1 
             WHERE YEAR(K1."DocDate") = YEAR(CURRENT_DATE)
               AND MONTH(K1."DocDate") = MONTH(CURRENT_DATE)
               AND K1."DocStatus" = 'O')
          ) > (
    SELECT 
        COALESCE(TL."U_Presupuesto",0)
    FROM 
        "@PRESUPUESTO_TABLA" TC
    INNER JOIN 
            "@PRESUPUESTO_LINEA" TL 
        ON TC."DocEntry" = TL."DocEntry"
    WHERE 
        TC."U_YEAR" = YEAR(CURRENT_DATE)
        AND TC."U_MES" = MONTH(CURRENT_DATE)
    )

-- VER LO DE COMPRAS LOCALES, VIVIANA Y IT (BACKUP). 
-- HACER UN REPORTE PARA VER CUANTO LLEVAN. 
----

-- OPCION 1
SELECT DISTINCT 'TRUE'
FROM OPOR K0
WHERE "CardCode" IN (
    SELECT T0."CardCode"
        FROM OCRD T0
        WHERE T0."GroupNum" != -1
          AND (
            "DocTotal" + 
            (SELECT COALESCE(SUM(K1."DocTotal"), 0) 
             FROM OPOR K1 
             WHERE K1."CardCode" = T0."CardCode"
               AND YEAR(K1."DocDate") = YEAR(CURRENT_DATE)
               AND MONTH(K1."DocDate") = MONTH(CURRENT_DATE)
               AND K1."DocStatus" = 'O')
          ) > (
    SELECT 
        TL."U_Presupuesto"
    FROM 
        "@PRESUPUESTO_TABLA" TC
    INNER JOIN 
            "@PRESUPUESTO_LINEA" TL 
        ON TC."DocEntry" = TL."DocEntry"
    WHERE 
        TC."U_YEAR" = YEAR(CURRENT_DATE)
        AND TC."U_MES" = MONTH(CURRENT_DATE)
)



-- opcione 2 sin iva


-- OPCION 1
SELECT DISTINCT 'TRUE'
FROM OPOR K0
WHERE (
            SUM($[POR1."LineTotal"]) + 
            (SELECT COALESCE(SUM(T2."LineTotal"), 0) 
             FROM OPOR K1 
             INNER JOIN POR1 T2 ON T2."DocEntry" = K0."DocEntry"
             WHERE YEAR(K1."DocDate") = YEAR(CURRENT_DATE)
               AND MONTH(K1."DocDate") = MONTH(CURRENT_DATE)
               AND K1."DocStatus" = 'O')
          ) > (
    SELECT 
        COALESCE(TL."U_Presupuesto",0)
    FROM 
        "@PRESUPUESTO_TABLA" TC
    INNER JOIN 
            "@PRESUPUESTO_LINEA" TL 
        ON TC."DocEntry" = TL."DocEntry"
    WHERE 
        TC."U_YEAR" = YEAR(CURRENT_DATE)
        AND TC."U_MES" = MONTH(CURRENT_DATE)
    )




Select Sum(T2."LineTotal") FROM OPOR K1 
INNER JOIN POR1 T2 ON T2."DocEntry" = K1."DocEntry"
WHERE YEAR(K1."DocDate") = YEAR(CURRENT_DATE)
               AND MONTH(K1."DocDate") = MONTH(CURRENT_DATE)
