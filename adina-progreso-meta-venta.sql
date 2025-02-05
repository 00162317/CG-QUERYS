--------------QUERYS ADINA 
--METAS ADINA

SELECT T1."U_Pais", T1."U_Responsable", T1."U_Meta_ZL", T1."U_Meta_FOB", 
        (T1."U_Meta_ZL"+T1."U_Meta_FOB") AS "Meta Total", 
FROM "@METAS_VENTAS" T0
INNER JOIN "@METAS_LINEA" T1 ON T1."DocEntry" = T0."DocEntry"
WHERE T1."DocEntry" = [%0] 

--PROGRESO META

SELECT
    T0."CardCode", T0."CardName", T2."Name", T0."DocNum", T0."DocDate", T0."DocTotal", ((T3."U_Meta_ZL"+T3."U_Meta_FOB")) AS "Meta por pais",
    SUM(((T3."U_Meta_ZL"+T3."U_Meta_FOB"))) as "Meta Global", (T0."DocTotal"/(((T3."U_Meta_ZL"+T3."U_Meta_FOB")))) as "% Meta / Pais",
    (T0."DocTotal"/(SUM(((T3."U_Meta_ZL"+T3."U_Meta_FOB"))))) as "% Meta Total"
FROM OINV T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
INNER JOIN OCRY T2 ON T1."Country" = T2."Code"
INNER JOIN "@METAS_LINEA" T3 ON T2."Name" = T3."U_Pais" 
WHERE T0."DocDate" >= [%0] and T0."DocDate" <= [%1]
GROUP BY T0."CardCode", T0."CardName", T2."Name", T0."DocNum", T0."DocDate", T0."DocTotal", T3."U_Meta_ZL", T3."U_Meta_FOB"



SELECT T0."CardCode", T0."CardName", T1."Country", T2."Name" 
FROM OCRD T0  
INNER JOIN CRD1 T1 ON T0."CardCode" = T1."CardCode" 
INNER JOIN OCRY T2 ON T0."Country" = T2."Code"


-- Progreso venta x mes x pais

SELECT T1."U_Pais", T1."U_Responsable", (T1."U_Meta_ZL"+T1."U_Meta_FOB") AS "Meta Total",
SUM("LineTotal") as "Venta / mes", (SUM("LineTotal")/(T1."U_Meta_ZL"+T1."U_Meta_FOB"))*100 as "Progreso %"
FROM "@METAS_VENTAS" T0
    INNER JOIN "@METAS_LINEA" T1 ON T1."DocEntry" = T0."DocEntry"
    LEFT JOIN(

        Select 
                T0."Series", T8."Name", T0."DocNum", T1."ItemCode", T1."Quantity", T1."Dscription",
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
                INNER JOIN OCRY T8 ON T7."Country" = T8."Code"
        where   YEAR(T0."DocDate") = YEAR(CURRENT_DATE) AND MONTH(T0."DocDate") = MONTH(CURRENT_DATE) 
        UNION ALL  
        Select 
                T0."Series", T8."Name", T0."DocNum", T1."ItemCode",T1."Quantity"*-1, T1."Dscription",
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
                INNER JOIN OCRY T8 ON T7."Country" = T8."Code"
        where   YEAR(T0."DocDate") = YEAR(CURRENT_DATE) AND MONTH(T0."DocDate") = MONTH(CURRENT_DATE) 

        ) VENTAS_MES ON VENTAS_MES."Name" = T1."U_Pais"
WHERE T1."DocEntry" = [%0]
GROUP BY T1."U_Pais", T1."U_Responsable", T1."U_Meta_ZL",T1."U_Meta_FOB"