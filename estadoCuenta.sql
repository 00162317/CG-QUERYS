SELECT 
    case when T4."CardCode" is null then T3."CardCode" else T4."CardCode" end "CardCode",
    case when T4."CardCode" is null then T3."CardName" else T4."CardName" end "CardName", T3."LicTradNum", T3."Phone1", T3."E_Mail",T3."Balance",
    T0."DocTotal", T0."DocNum", T0."DocEntry", T0."PaidToDate", T2."InsTotal", T2."DueDate",T0."TaxDate" as  DocDate, 
    T5."SlpName",T3."CreditLine", t6."PymntGroup", DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) AS "DIAS",

        --30DIAS
    --SUM(
        case when DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) between '0' and '30' then t2."InsTotal" - t2."PaidToDate" else 0 end "30Dias"--)
    ,
    --45DIAS
    --SUM(
        case when DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) between '31' and '45' then t2."InsTotal" - t2."PaidToDate" else 0 end "45Dias"--)
    ,
    --60DIAS
    --SUM(
        case when DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) between '46' and '60' then t2."InsTotal" - t2."PaidToDate" else 0 end "60Dias"--)
    --90DIAS
    --SUM(
    ,    case when DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) between '61' and '90' then t2."InsTotal" - t2."PaidToDate" else 0 end "60Dias"--)
    --120DIAS
    --SUM(
    ,    case when DAYS_BETWEEN(t2."DueDate",CURRENT_DATE) between '91' and '120' then t2."InsTotal" - t2."PaidToDate" else 0 end "60Dias"--)
    -- +120DIAS
    --SUM(
    ,   case when DAYS_BETWEEN(CURRENT_DATE,t2."DueDate") > '120' then t2."InsTotal" - t2."PaidToDate" else 0 end "120+"--)
FROM OINV    T0
    INNER JOIN INV6 T2 ON T2."DocEntry" = T0."DocEntry"
    INNER JOIN OCRD T3 ON T0."CardCode" = T3."CardCode"
    LEFT JOIN OCRD T4  ON T4."CardCode" = T3."FatherCard"
    INNER JOIN OSLP T5 ON T0."SlpCode" = T5."SlpCode"
    LEFT JOIN OCTG t6 on t3."GroupNum"=t6."GroupNum"

WHERE
    T0."CardCode" = [%0] 
    AND T0."PaidToDate" <> T0."DocTotal"
    AND T2."InsTotal" <> T2."PaidToDate"
ORDER BY case when T4."CardCode" is null then T3."CardName" else T4."CardName" end,
            T4."CardName",T0."TaxDate", T2."InstlmntID"  