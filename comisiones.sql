---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--COMISIONES RESUMIDO
SELECT 
    P1."Code", 
    P1."U_Vendedor", 
    P1."U_Comision" AS "Meta",
    SUM("LineTotal") AS "Venta",
    (SUM("LineTotal")/P1."U_Comision")*100 as "% ALCANZADO",
    (((SUM("LineTotal")/P1."U_Comision"))*SUM("LineTotal"))/100 AS "COMISION PAGADA"
    --'**'
FROM "10028_COPPER_ESV"."@COMISIONES" P0
INNER JOIN "10028_COPPER_ESV"."@COMI_LINEAS" P1 ON P0."Code" = P1."Code"
LEFT JOIN (
        Select 
                T0."Series", T0."DocNum", T1."ItemCode", T1."Quantity", T1."Dscription",
                case when T4."ItmsGrpCod"='102' then T1."LineTotal" else 0 end  LineTotal60,
                case when T4."ItmsGrpCod"!='102' then T1."LineTotal" else 0 end  LineTotal40,
                T1."LineTotal",
                case when T4."ItmsGrpCod"='102' then '60' else '40' end  Porcentaje_Familia,
                T4."ItmsGrpCod",T6."ItmsGrpNam", T0."DocDate", T0."SlpCode", T2."SlpName",
                T1."Price",T1."LineNum", T1."TotalSumSy", T0."CardCode", T0."CardName",  T1."WhsCode",
                T1."GrssProfit",T3."WhsName", T4."CardCode", T5."CardName", T7."County", T2."Memo",
                'Factura' TipoDocumento

        from    OINV T0
                inner join INV1 T1 on T0."DocEntry" = T1."DocEntry"
                inner join OSLP T2 on T0."SlpCode" = T2."SlpCode"
                left join OWHS T3 on T1."WhsCode"=T3."WhsCode"
                left join OITM T4 on T1."ItemCode"=T4."ItemCode"
                left join OCRD T5 on T4."CardCode"=T5."CardCode"
                left join OITB T6 on T4."ItmsGrpCod"=T6."ItmsGrpCod"
                left join OCRD T7 on T0."CardCode"=T7."CardCode"
        where   --T0."DocDate" between '20241201' and '20241231' and 
        T0."CANCELED"='N'  
        UNION ALL  
        Select 
                T0."Series", T0."DocNum", T1."ItemCode",T1."Quantity"*-1, T1."Dscription",
                case when T4."ItmsGrpCod"='102' then T1."LineTotal"*-1 else 0 end  LineTotal60,
                case when T4."ItmsGrpCod"!='102' then T1."LineTotal"*-1 else 0 end  LineTotal40,
                T1."LineTotal"*-1,
                case when T4."ItmsGrpCod"='102' then '60' else '40' end  Porcentaje_Familia,
                T4."ItmsGrpCod", T6."ItmsGrpNam", T0."DocDate",T0."SlpCode", T2."SlpName",
                T1."Price"*-1, T1."LineNum", T1."TotalSumSy"*-1, T0."CardCode", T0."CardName",  
                T1."WhsCode", T1."GrssProfit"*-1,T3."WhsName", T4."CardCode", T5."CardName",
                T7."County", T2."Memo",
                'Nota de Credito' TipoDocumento
        
        from    ORIN T0
                inner join RIN1 T1 on T0."DocEntry" = T1."DocEntry"
                inner join OSLP T2 on T0."SlpCode" = T2."SlpCode"
                left join OWHS T3 on T1."WhsCode"=T3."WhsCode"
                left join OITM T4 on T1."ItemCode"=T4."ItemCode"
                left join OCRD T5 on T4."CardCode"=T5."CardCode"
                left join OITB T6 on T4."ItmsGrpCod"=T6."ItmsGrpCod"
                left join OCRD T7 on T0."CardCode"=T7."CardCode"

        where   --T0."DocDate" between '20241201' and '20241231' and 
        T0."CANCELED"='N'

        ) VENTAS ON VENTAS."SlpName" = P1."U_Vendedor"
WHERE P0."Code" = [%0] AND "DocDate" = [%2]
GROUP BY P1."Code",P1."U_Vendedor",P1."U_Comision"
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--COMISIONES DETALLADO

SELECT
    P1."Code", 
    P1."U_Vendedor",
    P1."U_Comision" AS "Meta",
    
INNER JOIN "10028_COPPER_ESV"."@COMI_LINEAS" P1 ON P0."Code" = P1."Code"
LEFT JOIN (
        Select 
                T0."Series", T0."DocNum", T1."ItemCode", T1."Quantity", T1."Dscription",
                case when T4."ItmsGrpCod"='102' then T1."LineTotal" else 0 end  LineTotal60,
                case when T4."ItmsGrpCod"!='102' then T1."LineTotal" else 0 end  LineTotal40,
                T1."LineTotal",
                case when T4."ItmsGrpCod"='102' then '60' else '40' end  Porcentaje_Familia,
                T4."ItmsGrpCod",T6."ItmsGrpNam", T0."DocDate", T0."SlpCode", T2."SlpName",
                T1."Price",T1."LineNum", T1."TotalSumSy", T0."CardCode", T0."CardName",  T1."WhsCode",
                T1."GrssProfit",T3."WhsName", T4."CardCode",-- T5."CardName", 
                T5."County", T2."Memo",
                'Factura' TipoDocumento

        from    OINV T0
                inner join INV1 T1 on T0."DocEntry" = T1."DocEntry"
                inner join OSLP T2 on T0."SlpCode" = T2."SlpCode"
                left join OWHS T3 on T1."WhsCode"=T3."WhsCode"
                left join OITM T4 on T1."ItemCode"=T4."ItemCode"
                left join OCRD T5 on T4."CardCode"=T5."CardCode"
                left join OITB T6 on T4."ItmsGrpCod"=T6."ItmsGrpCod"
        where   --T0."DocDate" between '20241201' and '20241231' and 
        T0."CANCELED"='N'  
        UNION ALL  
        Select 
                T0."Series", T0."DocNum", T1."ItemCode",T1."Quantity"*-1, T1."Dscription",
                case when T4."ItmsGrpCod"='102' then T1."LineTotal"*-1 else 0 end  LineTotal60,
                case when T4."ItmsGrpCod"!='102' then T1."LineTotal"*-1 else 0 end  LineTotal40,
                T1."LineTotal"*-1,
                case when T4."ItmsGrpCod"='102' then '60' else '40' end  Porcentaje_Familia,
                T4."ItmsGrpCod", T6."ItmsGrpNam", T0."DocDate",T0."SlpCode", T2."SlpName",
                T1."Price"*-1, T1."LineNum", T1."TotalSumSy"*-1, T0."CardCode", T0."CardName",  
                T1."WhsCode", T1."GrssProfit"*-1,T3."WhsName", T4."CardCode", --T5."CardName",
                T5."County", T2."Memo",
                'Nota de Credito' TipoDocumento
        
        from    ORIN T0
                inner join RIN1 T1 on T0."DocEntry" = T1."DocEntry"
                inner join OSLP T2 on T0."SlpCode" = T2."SlpCode"
                left join OWHS T3 on T1."WhsCode"=T3."WhsCode"
                left join OITM T4 on T1."ItemCode"=T4."ItemCode"
                left join OCRD T5 on T4."CardCode"=T5."CardCode"
                left join OITB T6 on T4."ItmsGrpCod"=T6."ItmsGrpCod"

        where   --T0."DocDate" between '20241201' and '20241231' and 
        T0."CANCELED"='N' 

        ) VENTAS ON VENTAS."SlpName" = P1."U_Vendedor"

INNER JOIN (SELECT * FROM "10028_COPPER_ESV"."BASECOM1" T0 WHERE T0."FECHA_PAGO" between '20241201' and '20241231') 
PAGOS ON PAGOS."DocNum" = VENTAS."DocNum"
WHERE VENTAS."DocDate" >= [%0] AND VENTAS."DocDate" <= [%1]
--WHERE P0."Code" = [%0] and YEAR(VENTAS."DocDate") = P0."U_YEAR" and MONTH(VENTAS."DocDate") = P0."U_MONTH"

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
--VISTA

CREATE VIEW BASECOM1( "FECHA_PAGO",
     "DIAS",
     "RELATIVO",
     "DocEntry",
     "DocNum",
     "FECHA_CREACION" ) AS SELECT
     MAX(L0."FECHA_PAGO") FECHA_PAGO,
     MAX(L0."DIAS") DIAS,
     CASE WHEN SUM(L0."RELATIVO") >= 100 
THEN 100 
ELSE SUM(L0."RELATIVO") 
END RELATIVO,
     L0."DocEntry",
     L0."DocNum",
     MAX(L0."FECHA_CREACION") FECHA_CREACION 
FROM ( 
    SELECT * FROM COM1 

    UNION ALL 

    SELECT * FROM COM2 )L0 
GROUP BY L0."DocNum", L0."DocEntry" WITH READ ONLY

INNER JOIN "OSLP" T5 = T5."SlpCode" = T2."SlpCode"


        "FECHA_PAGO",
         "DocNum",
         "VENDEDOR",
         "DIAS",
         "RELATIVO",
         "DocEntry",
         "FECHA_CREACION" 




SELECT 
    P0."SlpName", P0."U_Comision" as "Meta", SUM(P1."VENTA") as "Venta", (SUM(P1."VENTA")/P0."U_Comision") as "% ALCANZADO", ((SUM(P1."VENTA")/P0."U_Comision")*P1."VENTA")/100 as "COMISION PAGADA" 

FROM COMISIONES P0

LEFT JOIN (SELECT "VENDEDOR", "FECHA", SUM("TOTAL") VENTA FROM VENTAS GROUP BY "VENDEDOR", "FECHA") 
        P1 ON P1."VENDEDOR" = P0."SlpName"

WHERE "SlpName" = 'Joaquin Portillo' and P1."FECHA">='20241201' and P1."FECHA" <= '20241231'
GROUP BY P0."SlpName", P0."U_Comision", P1."VENTA"






----------





SELECT  

        T0."DocDate"
        ,T0."GrosProfit"
        ,T0."SlpName"
        ,T0."CardCode"
        ,T0."CARDNAME"
        ,T0."DocNum"
        ,ROUND(t0."DIAS",0) AS "DIAS"
        ,CASE 
        WHEN T3."Pagado" = 0 and  T0."RELATIVO" != 100 THEN 100 
        ELSE T0."RELATIVO" END AS "RELATIVO"
        ,T0."DocEntry"
        ,T0."Memo"
        ,T0."MONTO_BRUTO"  FACTURADO
        ,T3."Pagado"
        ,CASE 
        WHEN T3."Pagado" =0 and  T0."RELATIVO" <=99 THEN MONTO_BRUTO 
        WHEN T0."RELATIVO" <=95 THEN 0
        WHEN T0."DIAS" > 30 THEN 0 
        ELSE  T0."MONTO_BRUTO" END MONTO_BRUTO

        ,CASE
        WHEN T3."Pagado" !=0 and  T0."RELATIVO" <=99 THEN MONTO_BRUTO  
        WHEN T0."RELATIVO" <=95 THEN 0 
        WHEN T0."DIAS" > 30 THEN T0."MONTO_BRUTO" 
        ELSE 0 END PERDIDA


        ,T0."U_Comision"
        , T1."FECHA_PAGO", T2."VENTA"


FROM  "10028_COPPER_ESV"."COMISIONES" T0 
        LEFT JOIN "10028_COPPER_ESV"."PAGOSSV"  T1 ON T0."DocEntry" = T1."DocEntry"
        LEFT JOIN (select "VENDEDOR", SUM("TOTAL") VENTA from "10028_COPPER_ESV"."VENTAS" 
                   WHERE "FECHA" >=  {?FechaIni} AND "FECHA"  <= {?Fechafin} 
                   GROUP BY  "VENDEDOR") 
                T2 ON T2."VENDEDOR" = T0."SlpName"
        LEFT JOIN (SELECT  T0."DocNum" , (T0."DocTotal" - T0."PaidToDate")  as "Pagado"
                        FROM "10028_COPPER_ESV"."OINV" T0 ) 
        T3 ON T0."DocNum" = T3."DocNum"
WHERE T1."FECHA_PAGO" >=  {?FechaIni} AND "FECHA_PAGO"<={?Fechafin} 





---- SE HA TOMADO ESTE

SELECT *, CASE WHEN T0."GRUPO"='Aire Acondicionado' THEN T0."PRECIO_UNITARIO" ELSE 0 END PRECIO_UNITARIO_60,
CASE WHEN T0."GRUPO"!='Aire Acondicionado' THEN T0."PRECIO_UNITARIO" ELSE 0 END PRECIO_UNITARIO_40
FROM VENTAS T0 
WHERE T0."FECHA" >= {?fechaInicio} and T0."FECHA"<={?fechaFin}










