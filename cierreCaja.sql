------------------- CIERRE DE CAJA
------------COBROS
--1. PAGOS RECIBIDOS DE CONTADO
select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T3."DocTotal", T3."DocNum", '0' ,'3' DocType , 'PAGOS RECIBIDOS DE CONTADO', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,(case when T0."Canceled"='Y' THEN 0 
            when T1."SumApplied" != T0."CashSum" AND T0."CashSum"> 0  THEN T1."SumApplied" 
            else T0."CashSum" end)  Efectivo,(case when T0."Canceled"='Y' then '0'
            when T1."SumApplied" != T0."CreditSum" AND T0."CreditSum" > 0  THEN T1."SumApplied" 
             else T0."CreditSum" end)  Tarjeta, (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."CheckSum" AND T0."CheckSum" > 0  THEN T1."SumApplied" 
            else T0."CheckSum" end)  Cheque,  (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."TrsfrSum" AND T0."TrsfrSum" > 0  THEN T1."SumApplied" 
            else T0."TrsfrSum" end)  Transferencia, T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T3."VatSum", 'A'

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry"

        left join NNM1 T4 on T3."Series"=T4."Series"

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}' and T0."Canceled" = 'N' and T3."GroupNum" IN (3) 

UNION ALL
--2. COBROS DE CREDITO

select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T3."DocTotal",  T3."DocNum", '0' ,'3' DocType , 'COBROS DE CREDITO', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,(case when T0."Canceled"='Y' THEN 0 
            when T1."SumApplied" != T0."CashSum" AND T0."CashSum"> 0  THEN T1."SumApplied" 
            else T0."CashSum" end)  Efectivo,(case when T0."Canceled"='Y' then '0'
            when T1."SumApplied" != T0."CreditSum" AND T0."CreditSum" > 0  THEN T1."SumApplied" 
             else T0."CreditSum" end)  Tarjeta, (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."CheckSum" AND T0."CheckSum" > 0  THEN T1."SumApplied" 
            else T0."CheckSum" end)  Cheque,  (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."TrsfrSum" AND T0."TrsfrSum" > 0  THEN T1."SumApplied" 
            else T0."TrsfrSum" end)  Transferencia,T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T3."VatSum", 'B'

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry" -- este no

        left join NNM1 T4 on T3."Series"=T4."Series" -- este no

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}' and T3."GroupNum" IN (1,2,4,5,6,7,8) and T0."Canceled" = 'N'

UNION ALL
--3. ANTICIPOS DE CLIENTES RECIBIDOS
select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T3."DocTotal",  T3."DocNum", '0' ,'3' DocType , 'ANTICIPOS DE CLIENTES RECIBIDOS', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,(case when T0."Canceled"='Y' THEN 0 
            when T1."SumApplied" != T0."CashSum" AND T0."CashSum"> 0  THEN T1."SumApplied" 
            else T0."CashSum" end)  Efectivo,
        (case when T0."Canceled"='Y' then '0'
            when T1."SumApplied" != T0."CreditSum" AND T0."CreditSum" > 0  THEN T1."SumApplied" 
             else T0."CreditSum" end)  Tarjeta, (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."CheckSum" AND T0."CheckSum" > 0  THEN T1."SumApplied" 
            else T0."CheckSum" end)  Cheque,  (case when T0."Canceled"='Y' then '0' 
            when T1."SumApplied" != T0."TrsfrSum" AND T0."TrsfrSum" > 0  THEN T1."SumApplied" 
            else T0."TrsfrSum" end)  Transferencia,T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T3."VatSum", 'C'

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry" -- este no

        left join NNM1 T4 on T3."Series"=T4."Series" -- este no

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}' and T0."PayNoDoc" = 'Y' and T0."Canceled" = 'N'

------------FACTURACION

UNION ALL

--1. DOCUMENTOS EMITIDOS DEL DIA

select T0."DocEntry", T0."CardCode", T0."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
        case when T0."CANCELED" = 'Y' THEN T0."DocTotal" ELSE T0."DocTotal" END as DocTotal,
        T0."DocNum",T0."U_NControlFE",'5' Doctype   ,'DOCUMENTOS EMITIDOS DEL DIA', T0."GroupNum", T1."SeriesName" , T0."UserSign"                   
        ,'0','0','0','0', 'UNAME', CASE WHEN SUBSTRING(T1."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T1."SeriesName",5,2) END Sucursal,
        CASE WHEN T0."GroupNum" IN (1,2,4,5,6,7,8) THEN T0."DocTotal" ELSE 0 END Credito,
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum", 'D'
from OINV T0 

        left join NNM1 T1 on T0."Series"=T1."Series"
        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"     

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}' -- and T0."GroupNum" not in ('3')
--and T0."UserSign"='{?CodUser}'

UNION ALL
--2. ANULACIONES/INVALIDACIONES

select T0."DocEntry", T0."CardCode", T0."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
        case when T0."CANCELED" = 'Y' THEN T0."DocTotal" ELSE T0."DocTotal" END as DocTotal,
        T0."DocNum",T0."U_NControlFE",'5' Doctype   ,'ANULACIONES-INVALIDACIONES', T0."GroupNum", T1."SeriesName" , T0."UserSign"                   
        ,'0','0','0','0', 'UNAME', CASE WHEN SUBSTRING(T1."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T1."SeriesName",5,2) END Sucursal,
        CASE WHEN T0."GroupNum" IN (1,2,4,5,6,7,8) THEN T0."DocTotal" ELSE 0 END Credito,
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum", 'E'
from OINV T0 

        left join NNM1 T1 on T0."Series"=T1."Series"
        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"     

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}'-- and T0."GroupNum" not in ('3')
--and T0."UserSign"='{?CodUser}' 
AND T0."CANCELED" ='Y' 


UNION ALL
--3. NOTAS DE CREDITO

select T0."DocEntry",  T0."CardCode", T0."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate",
        case when T0."CANCELED" = 'Y' THEN T0."DocTotal" ELSE T0."DocTotal" END as DocTotal, 
        T0."DocNum",T0."U_NControlFE",'2' Doctype, 'NOTAS DE CREDITO' Comentarios, T0."GroupNum", T1."SeriesName",T0."UserSign"   

        ,'0','0','0','0','UNAME', CASE WHEN SUBSTRING(T1."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T1."SeriesName",5,2) END Sucursal,
        CASE WHEN T0."GroupNum" IN (1,2,4,5,6,7,8) THEN T0."DocTotal" ELSE 0 END Credito,
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum", 'F'

from ORIN  T0 

        left join NNM1 T1 on T0."Series"=T1."Series" 
        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"                

where T0."DocDate"={?fechaCierre} and T5."U_NAME"='{?CodUser}'--and T0."UserSign"='{?CodUser}'