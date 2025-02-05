------------------- CIERRE DE CAJA
------------COBROS
--1. PAGOS RECIBIDOS DE CONTADO
select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T0."DocTotal", T3."DocNum", '0' ,'3' DocType , 'PAGOS RECIBIDOS DE CONTADO', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,T0."CashSum",T0."CreditSum", T0."CheckSum", T0."TrsfrSum", T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T0."VatSum"

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry"

        left join NNM1 T4 on T3."Series"=T4."Series"

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T0."UserSign"='{?CodUser}' and T0."Canceled" = 'N'

UNION ALL
--2. COBROS DE CREDITO

select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T0."DocTotal",  T3."DocNum", '0' ,'3' DocType , 'COBROS DE CREDITO', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,T0."CashSum",T0."CreditSum", T0."CheckSum", T0."TrsfrSum",T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T0."VatSum"

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry" -- este no

        left join NNM1 T4 on T3."Series"=T4."Series" -- este no

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T0."UserSign"='{?CodUser}' and T3."GroupNum" IN (1,2,4,5,6,7,8)

UNION ALL
--3. ANTICIPOS DE CLIENTES RECIBIDOS
select  T0."DocEntry", T0."CardCode", T3."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
         T0."DocTotal",  T3."DocNum", '0' ,'3' DocType , 'COBROS DE CREDITO', T3."GroupNum", T4."SeriesName",T0."UserSign"   
        ,T0."CashSum",T0."CreditSum", T0."CheckSum", T0."TrsfrSum",T5."U_NAME", CASE WHEN SUBSTRING(T4."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T4."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T4."SeriesName",5,2) END Sucursal, '0', '0', T0."VatSum"

from ORCT  T0               

        left join RCT2 T1 on T0."DocEntry"=T1."DocNum"

        left join oinv T3 on T1."DocEntry"=T3."DocEntry" -- este no

        left join NNM1 T4 on T3."Series"=T4."Series" -- este no

        LEFT JOIN "OUSR" T5 ON T0."UserSign" = T5."USERID"   

where T0."DocDate"={?fechaCierre} and T0."UserSign"='{?CodUser}' and T0."PayNoDoc" = 'Y'

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
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum"
from OINV T0 

        left join NNM1 T1 on T0."Series"=T1."Series"  

where T0."DocDate"={?fechaCierre} -- and T0."GroupNum" not in ('3')
and T0."UserSign"='{?CodUser}'

UNION ALL
--2. ANULACIONES/INVALIDACIONES

select T0."DocEntry", T0."CardCode", T0."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate", 
        case when T0."CANCELED" = 'Y' THEN T0."DocTotal" ELSE T0."DocTotal" END as DocTotal,
        T0."DocNum",T0."U_NControlFE",'5' Doctype   ,'ANULACIONES-INVALIDACIONES', T0."GroupNum", T1."SeriesName" , T0."UserSign"                   
        ,'0','0','0','0', 'UNAME', CASE WHEN SUBSTRING(T1."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T1."SeriesName",5,2) END Sucursal,
        CASE WHEN T0."GroupNum" IN (1,2,4,5,6,7,8) THEN T0."DocTotal" ELSE 0 END Credito,
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum"
from OINV T0 

        left join NNM1 T1 on T0."Series"=T1."Series"  

where T0."DocDate"={?fechaCierre} -- and T0."GroupNum" not in ('3')
and T0."UserSign"='{?CodUser}' AND T0."CANCELED" ='Y' 


UNION ALL
--3. NOTAS DE CREDITO

select T0."DocEntry",  T0."CardCode", T0."NumAtCard", T0."CardName", T0."DocDate", T0."TaxDate",
        case when T0."CANCELED" = 'Y' THEN T0."DocTotal" ELSE T0."DocTotal" END as DocTotal, 
        T0."DocNum",T0."U_NControlFE",'2' Doctype, 'NOTAS DE CREDITO' Comentarios, T0."GroupNum", T1."SeriesName",T0."UserSign"   

        ,'0','0','0','0','UNAME', CASE WHEN SUBSTRING(T1."SeriesName",5,2) = 'JP' THEN 'JUAN PABLO'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'ML' THEN 'MERLIOT'
        WHEN SUBSTRING(T1."SeriesName",5,2) = 'SM' THEN 'SAN MIGUEL' ELSE SUBSTRING(T1."SeriesName",5,2) END Sucursal,
        CASE WHEN T0."GroupNum" IN (1,2,4,5,6,7,8) THEN T0."DocTotal" ELSE 0 END Credito,
        CASE WHEN T0."GroupNum" IN (3) THEN T0."DocTotal" ELSE 0 END Contado, T0."VatSum"

from ORIN  T0 

        left join NNM1 T1 on T0."Series"=T1."Series"                 

where T0."DocDate"={?fechaCierre} and T0."UserSign"='{?CodUser}'
