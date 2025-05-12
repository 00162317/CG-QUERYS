CREATE PROCEDURE SBO_SP_TransactionNotification
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
error  int;				-- Result (0 for no error)
flag nvarchar(200);	
error_message nvarchar (200); 		-- Error string to be displayed
cont int;
DocEntry int;
begin

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------
--- AGREGAR TU CODIGO AQUI ---------
/*
--Debe de seleccionar el Forma de envío
IF object_type = '17' AND transaction_type IN ('A','U')  THEN 
  
flag = '';

	SELECT Count(*) into flag 
	FROM ORDR T0 
	WHERE T0."TrnspCode" = -1 AND 
	T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15)) ;
 		IF flag >= 1 THEN 
		 error='1111';
		 error_message = '***** Debe seleccionar Forma de Envío *****';
		END IF;	
END IF;*/

--No puede facturar de sucursales diferentes
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT(W0."WHSCODE")  FROM(
SELECT DISTINCT 
 T0."DocEntry" ,
 SUBSTRING(T1."WhsCode",0,2) WHSCODE
FROM ORDR T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" WHERE T0."DocEntry"= list_of_cols_val_tab_del 
)W0 ) > 1
      then
      error = 1001;
      error_message := N'No puede facturar de sucursales diferentes';
   end if;
end if;

--No puede facturar de sucursales diferentes
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT( T0."DocEntry") 
FROM ORDR T0 INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"  WHERE T1."GroupNum" in (-1,1) AND  T0."GroupNum" > 2 AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 1
      then
      error = 10011;
      error_message := N'No puede facturar de sucursales diferentes';
   end if;
end if;

--debe de seleccionar el tipo de Oferta
if object_type = '23' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM OQUT T0 
WHERE T0."U_TIPO" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Seleccione una opcion en Tipo';
   end if;
end if;


--No puede facturar productos sin  stock 
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T1."ItemCode") 
FROM RDR1 T1 
INNER JOIN OITM T2 ON T1."ItemCode" = T2."ItemCode"
WHERE T1."Price" = 0 AND T1."DocEntry"= list_of_cols_val_tab_del AND T2."TreeType" = 'N'
 ) >= 1
      then
      error = 1004;
      error_message := N'No puede crear este documento sin precio';
   end if;
end if;

/*
--No puede facturar productos sin  stock 
if object_type = '13' and  transaction_type in ('A','U')
   then 
      if  (SELECT  max(T1."LineNum")
FROM INV1 T1 
WHERE   T1."DocEntry"= list_of_cols_val_tab_del 
 ) > 19
      then
      error = 1005;
      error_message := N'No puede pasar de 19 lineas';
   end if;
end if;*/


--No puede pasar a un cliente de contado a credito
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if
		(SELECT  COUNT( T0."DocEntry") 
		FROM ORDR T0 
		INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"  
		WHERE T1."GroupNum" = 3  AND  T0."GroupNum" NOT IN ('3','7') AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1006;
      error_message := N'No puede cambiar la condicion a credito de un cliente de contado';
   end if;
end if;


--No puede facturar de sucursales diferentes
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT(T0."DocNum") FROM ORDR T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
      WHERE T1."DiscPrcnt" > 0 AND  T0."UserSign" IN ('23','24','25','26','30','31','32','33','35','36','21','57','58') AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1007;
      error_message := N'Este documento tiene descuento, para generarlo solicitar al encargaro de la tienda (Marcela, Walter o Christian) para que lo genere como pedido';
   end if;
end if;



--No puede facturar de sucursales diferentes
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT(T0."DocNum") FROM ORDR T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
      LEFT JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
      WHERE T0."CardName" != T2."CardName" AND T0."CardCode" NOT IN ('CFJP','CFMR','CFSM') AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1008;
      error_message := N'El nombre del socio de negocio no corresponde al asignado en el dato maestro.';
   end if;
end if;


---VALIDA SI LA CEDULA YA ESTA REGISTRADA


if object_type = '2' and transaction_type in ('A') then

flag = '';

select  a."LicTradNum" into flag from OCRD a where a."CardCode" = list_of_cols_val_tab_del;

	if (select count (b."LicTradNum") from ocrd b where b."LicTradNum" IS NOT NULL and b."LicTradNum" = flag) >1 then

     error = 1;
     error_message = N'Numero de NIT ya existe';
    
     
	end if;
end if; 

if object_type = '2' and transaction_type in ('A') then

flag = '';

select  a."AddID" into flag from OCRD a where a."CardCode" = list_of_cols_val_tab_del;

	if (select count (b."AddID") from ocrd b where b."AddID" IS NOT NULL and b."AddID" = flag) >1 then

     error = 1;
     error_message = N'Numero de NRC ya existe';
    
     
	end if;
end if;

if object_type = '2' and transaction_type in ('A') then

flag = '';

select  a."U_DUI" into flag from OCRD a where a."CardCode" = list_of_cols_val_tab_del;

	if (select count (b."U_DUI") from ocrd b where b."U_DUI" IS NOT NULL and b."U_DUI" = flag) >1 then

     error = 1;
     error_message = N'Numero de DUI ya existe';
    
     
	end if;                                                                                                          
end if;

if object_type = '2' and transaction_type in ('A') then

flag = '';

select  a."VatIdUnCmp" into flag from OCRD a where a."CardCode" = list_of_cols_val_tab_del;

	if (select count (b."VatIdUnCmp") from ocrd b where b."VatIdUnCmp" IS NOT NULL and b."VatIdUnCmp" = flag) >1 then

     error = 1;
     error_message = N'Numero de Cedula ya existe !!!';
    
     
	end if;
end if;



--Los socios de los documentos no es igual al socio de datos maestros de negocio
if object_type = '13' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT(T0."DocNum") FROM OINV T0 INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
      LEFT JOIN "OCRD" T2 ON T0."CardCode" = T2."CardCode" 
      WHERE T0."CardName" != T2."CardName" AND T0."CardCode" NOT IN ('CFJP','CFMR','CFSM') AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1009;
      error_message := N'El nombre del socio de negocio no corresponde al asignado en el dato maestro.';
   end if;
end if;


if object_type = '24' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT(T0."CashAcct") FROM ORCT T0 
      WHERE (T0."CashAcct" = '1-1-02-010300' or T0."CheckAcct" = '1-1-02-010300' or T0."TrsfrAcct" = '1-1-02-010300')  AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 10010;
      error_message := N'No se puede generar el pago sobre la cuenta 1-1-02-010300 - Banco Agricola - 5110010654 .';

   end if;
end if;

/*
if object_type = '4' and  transaction_type in ('A')
   then 
      if  (SELECT  COUNT(T0."ItemCode")
FROM OITM T0
WHERE   T0."UserSign" NOT in ('46','47','17') and  T0."ItemCode"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1011;
      error_message := N'Los Arituclos solo se pueden crear desde Miami, comunicarse con Viviana Morales.';
   end if;
end if;
*/

if object_type = '17' and  transaction_type in ('A')
   then 
      if  (SELECT  COUNT(T0."DocEntry")
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OUSR T2 ON T0."UserSign" = T2."USERID"
WHERE  T2."DfltsGroup" != '0009' AND T1."ItemCode" in ('SERVICIO','SERVICIO 2','SERVICIO 3', 'SERVICIO 4') AND  T0."UserSign" = (1) AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1012;
      error_message := N'No puede facturar articulos de servicios';
   end if;
end if;


/*if object_type = '23' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."TrnspCode")
FROM OQUT T0
WHERE  T0."TrnspCode" ='-1' AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1013;
      error_message := N'Debe de definir una forma de envio';
   end if;
end if;*/


if object_type = '22' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT( T0."DocEntry") 
FROM OPOR T0   WHERE T0."U_OrdenMiami" IS NOT NULL AND T0."U_Provee_LLC" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1008;
      error_message := N'Debe de selecionar un proveedor LLC';
   end if;
end if;

if object_type = '22' and  transaction_type in ('A','U')
   then 
      if ( SELECT  COUNT( T0."DocEntry") 
FROM OPOR T0   WHERE LENGTH(T0."U_OrdenMiami") > 4   AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1008;
      error_message := N'El Consecutivo no es correcto en LLC';
   end if;
end if;

/*
-- Campo DUI

IF object_type = '2' AND transaction_type IN ('A','U')  THEN 
  
flag = '';

	SELECT Count(*) into flag 
	FROM OCRD T0 
	WHERE T0."U_DUI" IS NULL  AND T0."CardType" = 'C' AND 
	T0."CardCode" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15)) ;
 		IF flag>= '1' THEN 
		 error='1111';
		 error_message = '***** Debe de llenar el campo DUI en el Dato Maetro del Socio de Negicios  *****';
		END IF;

END IF;
*/

---BLOQUEO DE DOCUMENTOS POR ALMACEN------

--ORDEN DE VENTA

IF object_type in ('17') AND transaction_type IN ('A', 'U')  THEN 
flag = '';
	SELECT count(T1."UserSign") into flag 
	FROM ORDR T1 INNER JOIN RDR1 T2 on T1."DocEntry" = T2."DocEntry" 
	WHERE T1."UserSign" IN (23,24,25,26,27,30,31,32,33,34,35,36,60,61,41) 
	AND T2."WhsCode" in ('01','C05','D04-M','D04-JP','PR03-JP','PR03-M','REP06','SAFE','SIKA','TRANS','TRANSAP','SBFA-JP','SBFA-M')
	AND T1."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1010';
		 error_message = '***** ALMACEN NO PERMITIDO PARA CREAR ORDEN DE VENTA, CORREGIR EL AMACEN *****';
		END IF;	
END IF;

--OFERTA DE VENTA
IF object_type in ('23') AND transaction_type IN ('A', 'U')  THEN 
flag = '';
	SELECT count(T1."UserSign") into flag 
	FROM OQUT T1 INNER JOIN QUT1 T2 on T1."DocEntry" = T2."DocEntry" 
	WHERE T1."UserSign" IN (23,24,25,26,27,30,31,32,33,34,35,36,60,61,41) 
	AND T2."WhsCode" in ('01', 'C05', 'D04-M', 'D04-JP', 'PR03-JP', 'PR03-M', 'REP06', 'SAFE', 'SIKA', 'TRANS', 'TRANSAP', 'SBFA-JP', 'SBFA-M')
	AND T1."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1010';
		 error_message = '***** ALMACEN NO PERMITIDO PARA CREAR OFERTA DE VENTA, CORREGIR EL ALMACEN *****';
		END IF;	
END IF;

--BLOQUEO DE FACTURAS POR USUARIO Y ALMACEN.
/*BLOQUEO APLICA CAJA JUAN PABLO*/

IF object_type in ('13') AND transaction_type IN ('A', 'U')  THEN 
flag = '';
	SELECT count(T1."UserSign") into flag 
	FROM OINV T1 INNER JOIN INV1 T2 on T1."DocEntry" = T2."DocEntry" 
	WHERE T1."UserSign" IN (118) 
	AND T2."WhsCode" in ('01', 'C05', 'D04-JP', 'D04-M', 'PR03-JP', 'PR03-M', 'REP06', 'SAFE', 'SIKA', 'TRANS', 'TRANSAP', 'SBFA-JP', 'SBFA-M', 'BME1', 'BME2', 'SM1', 'SM2')
	AND T1."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1010';
		 error_message = '***** ALMACEN NO PERMITIDO PARA CREAR FACTURAS PARA ESTE USUARIO, CORREGIR EL ALMACEN *****';
		END IF;	
END IF;
/*BLOQUEO APLICA PARA CAJA MERLIOT*/


IF object_type in ('13') AND transaction_type IN ('A', 'U')  THEN 
flag = '';
	SELECT count(T1."UserSign") into flag 
	FROM OINV T1 INNER JOIN INV1 T2 on T1."DocEntry" = T2."DocEntry" 
	WHERE T1."UserSign" IN (117) 
	AND T2."WhsCode" in ('01', 'C05', 'D04-JP', 'D04-M', 'PR03-JP', 'PR03-M', 'REP06', 'SAFE', 'SIKA', 'TRANS', 'TRANSAP', 'SBFA-JP', 'SBFA-M', 'BJP1', 'BJP2', 'SM1', 'SM2')
	AND T1."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1010';
		 error_message = '***** ALMACEN NO PERMITIDO PARA CREAR FACTURAS PARA ESTE USUARIO, CORREGIR EL ALMACEN *****';
		END IF;	
END IF;


/*BLOQUEO APLICA PARA CAJA SAN MIGUEL*/


IF object_type in ('13') AND transaction_type IN ('A', 'U')  THEN 
flag = '';
	SELECT count(T1."UserSign") into flag 
	FROM OINV T1 INNER JOIN INV1 T2 on T1."DocEntry" = T2."DocEntry" 
	WHERE T1."UserSign" IN (57) 
	AND T2."WhsCode" in ('01', 'C05', 'D04-JP', 'D04-M', 'PR03-JP', 'PR03-M', 'REP06', 'SAFE', 'SIKA', 'TRANS', 'TRANSAP', 'SBFA-JP', 'SBFA-M','BJP1','BJP2','BME1','BME2','RO-JP')
	AND T1."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1010';
		 error_message = '***** ALMACEN NO PERMITIDO PARA CREAR FACTURAS PARA ESTE USUARIO, CORREGIR EL ALMACEN *****';
		END IF;	
END IF;


------------------BLOQUEO RETENCIONES----------------------

if object_type = '13' and  transaction_type in ('A')
   then 
      if  (SELECT  Count (*) 
FROM OINV T0
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
WHERE  T2."WTLiable" = 'Y'  AND T1."WtLiable" <> 'Y' AND (T0."DocTotal" - T0."VatSum" + T0."WTSum")  > 100 AND T0."DocEntry" =  CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1012;
      error_message := N'*****FACTURA DE MAS DE $100 Y EXISTE UNA LINEA SIN RETENCION*****';
   end if;
end if;

if object_type = '13' and  transaction_type in ('A')
   then 
      if  (SELECT  Count (*) 
FROM OINV T0
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
WHERE  T2."WTLiable" = 'Y'  AND T1."WtLiable" <> 'N' AND  (T0."DocTotal" - T0."VatSum" + T0."WTSum") < 100 AND T0."DocEntry" =   CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1013;
      error_message := N'*****FACTURA  DE MENOS DE $100 Y EXISTE UNA LINEA CON RETENCION*****';
   end if;
end if;

----Bloquea lineas duplicadas en el documento
/*
IF object_type = '1250000001' and transaction_type in ('A','U')and 
(Select Distinct 'True'  FROM WTQ1 T1 WHERE cast (T1."DocEntry" as nvarchar) = list_of_cols_val_tab_del
Group by T1."ItemCode" Having count (T1."LineNum") > 1) = 'True'
then
error='101';
		 error_message = ' ****No puede crear documento con codigos de articulos Repetido en las lineas****';
END IF;

IF object_type = '17' and transaction_type in ('A','U')and 
(Select Distinct 'True'  FROM RDR1 T1 WHERE cast (T1."DocEntry" as nvarchar) = list_of_cols_val_tab_del
Group by T1."ItemCode" Having count (T1."LineNum") > 1) = 'True'
then
error='101';
		 error_message = ' ****No puede crear documento con codigos de articulos Repetido en las lineas ****';
END IF;

*/
------------BLOQUEO COTIZACION DEBAJO DE LISTA DE PRECIO


/*
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(*)
FROM ORDR T0
INNER JOIN  RDR1 T1 ON T1."DocEntry" = T0."DocEntry" 
INNER JOIN OCRD T2 ON T2."CardCode" = T0."CardCode"
WHERE   T1."PriceBefDi" < (select T10."Price" from ITM1 T10 WHERE T10."PriceList" = T2."ListNum" AND T10."ItemCode" = T1."ItemCode") 
 and T0."U_aut_precio" = '-' and T0."WddStatus" = '-'   and  T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1005;
      error_message := N'***Precio por debajo al de la lista de precios del Socio de Negocios, Debe de indicar Si en Autorizacion *****';
   end if;
end if;
/*

------------BLOQUEO COTIZACION DEBAJO DE LISTA DE PRECIO


/*
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(*)
FROM ORDR T0
INNER JOIN  RDR1 T1 ON T1."DocEntry" = T0."DocEntry" 
INNER JOIN OCRD T2 ON T2."CardCode" = T0."CardCode"
WHERE   T1."PriceBefDi" < (select T10."Price" from ITM1 T10 WHERE T10."PriceList" = T2."ListNum" AND T10."ItemCode" = T1."ItemCode") 
 and T0."U_aut_precio" = '-' and T0."WddStatus"<> 'P'   and  T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1005;
      error_message := N'***"* El precio no coincide con la lista de precios asignada al cliente. Solicitar permiso a gerencia *"*****';
   end if;
end if;
*/

---BLOQUEO COMPROMETIDO

if object_type = '17' and  transaction_type in ('A', 'U')
   then 
      if  (SELECT  Count (*) 
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OITW T2 ON T1."ItemCode" = T2."ItemCode" and T1."WhsCode" = T2."WhsCode" 
WHERE  T1."Quantity" > ((T2."OnHand"-T2."IsCommited")+ T1."Quantity")  AND  T0."DocEntry" =   CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1013;
      error_message := N'** No puedes crear este documento ya que existe un articulo sin existencias disponibles por comprometido **';
   end if;
end if;

if object_type = '1250000001' and  transaction_type in ('A', 'U')
   then 
      if  (SELECT  Count (*)
FROM OWTQ T0
INNER JOIN WTQ1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OITW T2 ON T1."ItemCode" = T2."ItemCode"  and T1."FromWhsCod" = T2."WhsCode"
WHERE T1."Quantity" > ((T2."OnHand"-T2."IsCommited")+ T1."Quantity")  AND T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1013;
      error_message := N'** No puedes crear este documento ya que existe un articulo sin existencias disponibles por comprometido **';
   end if;
end if;




-----BLOQUEO DE TRASLADOS SIN SOLICITUD RELACIONADA


if object_type = '67' and  transaction_type in ('A', 'U')
   then 
      if  (SELECT  Count (*)
FROM OWTQ T0
INNER JOIN WTQ1 T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T1."BaseType" <> '1250000001' AND IFNULL(T0."U_pick_user",'0') = '0' AND T0."UserSign" <> 17
AND T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1013;
      error_message := N'** No se puede crear el documento sin tener una solicitud de traslado previa  **';
   end if;
end if;


/*
------------BLOQUEO FACTURAS Y ENTREGAS CON COSTOS ERRONEOS	



if object_type = '13' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(*)
FROM OINV T0
INNER JOIN  INV1 T1 ON T1."DocEntry" = T0."DocEntry" 
INNER JOIN OITM T2 ON T2."ItemCode" = T1."ItemCode"
WHERE      (T1."GrossBuyPr" * T1."Quantity") > (T2."AvgPrice" * T1."Quantity")
 and  T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1005;
      error_message := N'*** FACTURA CON ERROR DE COSTOS  *****';
   end if;
end if;


if object_type = '15' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(*)
FROM ODLN T0
INNER JOIN  DLN1 T1 ON T1."DocEntry" = T0."DocEntry" 
INNER JOIN OITM T2 ON T2."ItemCode" = T1."ItemCode"
WHERE      (T1."GrossBuyPr" * T1."Quantity") > (T2."AvgPrice" * T1."Quantity")
 and  T0."DocEntry"= list_of_cols_val_tab_del 
 ) > 0
      then
      error = 1005;
      error_message := N'*** ENTREGA CON ERROR DE COSTOS  *****';
   end if;
end if;

*/


-----Bloqueo de notas de credito si tipo de NC



if object_type = '14' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."U_TNC")
FROM ORIN T0
WHERE  T0."U_TNC" ='-' AND  T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1013;
      error_message := N'DEBE DE INDICAR EL TIPO DE NOTA DE CREDITO FISCAL O INTERNA';
   end if;
end if;


if object_type = '14' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."U_TNC")
FROM ORIN T0
WHERE  T0."U_TNC" ='1' AND T0."Series" <> 6  AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1013;
      error_message := N'ESTE TIPO DE NOTA DE CREDITO DEBE DE EFECTUARSE EN PRIMARIO';
   end if;
end if;

if object_type = '14' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."U_TNC")
FROM ORIN T0
WHERE  T0."U_TNC" ='2' AND T0."Series" = 6  AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1013;
      error_message := N'ESTE TIPO DE NOTA DE CREDITO DEBE DE EFECTUARSE EN NUMERACION FISCAL';
   end if;
end if;

------ BLOQUEO CREADO POR CARLOS ACEVEDO -----
/*ESTE BLOQUEO NO DEJA FACTURAR DOCUMENTO FISCAL DE TIPO CREDITO FISCAL SI EL SOCIO DE NEGOIO NO TIENE NRC*/ --NO APLICA POR FEL 01/03/2025
/*IF object_type = '13' AND  transaction_type IN ('A')
  THEN 
      IF
      	(SELECT  COUNT (*) FROM OINV T0
      	INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode"
      	INNER JOIN NNM1 T2 ON T0."Series" = T2."Series"
      	WHERE T1."AddID" IS NULL AND T0."Series" IN ('75', '76', '77', '88', '97') AND T0."DocEntry"= list_of_cols_val_tab_del) > 0
      	THEN
      	error = 1060;
      	error_message := N'No se puede facturar porque el socio de negocio no tiene NRC';
      END IF;
END IF;
*/
/*ESTE BLOQUEO NO DEJA CREAR NI ACTUALIZAR SOCIOS DE NEGOCIO CON LISTA DESCRITAS*/
IF object_type = '2' AND transaction_type IN ('A')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign") INTO flag 
	FROM OCRD T0 
	WHERE T0."UserSign" IN (--'55',--codigo coppersv34 (roberto)
	  --'74',--Joaquin Poritllo
	  '77',--Carlos Acosta
	  '75',--Walter Guardado
	  '66',--Cristian Ramirez
	  '70',--Ricardo Flores
	 -- '67',--Geovani Alvarado
	 -- '54',--Wilberto Urbina
	  '47',--Diana Rodriguez
	  '131',--Andres Lopez
	  '51',--Sandy Ramos
	  '68',--Gustavo Quezada
	  '129',--Donaldo
	  '76')--Shirley Trejo  
	AND T0."ListNum" IN ('1','2','6','7','3','8','13','14','17','19')
	AND T0."CardCode" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'No tiene autorizado asignar lista de precio 1, 2, 11, 22, Cree el SN con una lista diferente y solicite la asignacion a Marcela, Joaquin, Geovani, Wilberto, Christian';
		END IF;	
END IF;


IF object_type = '2' AND transaction_type IN ('U')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign2") INTO flag 
	FROM OCRD T0 
	WHERE T0."UserSign2" IN (--'55',--codigo coppersv34 (roberto)
	  --'74',--Joaquin Poritllo
	  '77',--Carlos Acosta
	  '75',--Walter Guardado
	  '66',--Cristian Ramirez
	  '70',--Ricardo Flores
	 -- '67',--Geovani Alvarado
	 -- '54',--Wilberto Urbina
	  '47',--Diana Rodriguez
	  '131',--Andres Lopez
	  '51',--Sandy Ramos
	  '68',--Gustavo Quezada
	  '129',--Donaldo
	  '76')--Shirley Trejo 
	AND T0."ListNum" IN ('1','2','6','7','3','8','13','14','17','19')
	AND T0."CardCode" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'No tiene autorizado asignar lista de precio 1, 2, 11, 22, Cree el SN con una lista diferente y solicite la asignacion a Marcela, Joaquin, Geovani, Wilberto, Christian';
		END IF;	
END IF;

--VALIDACION MAXIMO DESCUENTO POR LINEA PARA 

--validacion extrae valores de tabla de usuarios de famiula y subfamila con procentajes maximos para vendedores y jefes de sucursal 

IF object_type = '23' AND transaction_type IN ('U','A')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign") INTO flag 
	FROM OQUT T0 
	INNER JOIN QUT1 T1 on T0."DocEntry"=T1."DocEntry"
	INNER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode"
	INNER JOIN "@SUB_FAMILIAS" T3 on T2."U_SubFamilia"=T3."Code"
	WHERE  T0."UserSign2" IN (68, 66, 76, 54, 47, 65, 77, 70, 60, 129) AND (
	  T1."DiscPrcnt">(T3."U_permitidov"*100))
	AND T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'Maximo descuento permitido vendedor, pedir autorizacion a jefatura';
		END IF;	
END IF;

IF object_type = '23' AND transaction_type IN ('U','A')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign") INTO flag 
	FROM OQUT T0 
	INNER JOIN QUT1 T1 on T0."DocEntry"=T1."DocEntry"
	INNER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode"
	INNER JOIN "@SUB_FAMILIAS" T3 on T2."U_SubFamilia"=T3."Code"
	WHERE  T0."UserSign2" IN (74, 67, 56) and
	  T1."DiscPrcnt">(T3."U_permitidoj"*100)
	AND T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'Maximo de descuento permitido Jefatura';
		END IF;	
END IF;




IF object_type = '23' AND transaction_type IN ('U','A')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign") INTO flag 
	FROM OQUT T0 
	INNER JOIN QUT1 T1 on T0."DocEntry"=T1."DocEntry"
	INNER JOIN OITM T2 on T1."ItemCode"=T2."ItemCode"
	INNER JOIN "@SUB_FAMILIAS" T3 on T2."U_SubFamilia"=T3."Code"
	WHERE  T0."UserSign2" IN (51) and
	  T1."DiscPrcnt">20
	AND T0."DocEntry" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'Maximo de descuento permitido Sany Ramos';
		END IF;	
END IF;


 if object_type='1250000001' and transaction_type in ('A','U')

	then 

	if exists ( select 1 from OWTQ T0 

				inner join WTQ1 T1 on T0."DocEntry"=T1."DocEntry"

				where T0."Filler"<>T1."FromWhsCod" and T0."DocEntry"=list_of_cols_val_tab_del )
	then
	 error='1061';
	 error_message='Almacen origen diferente en detalle de productos';


  end if;
  end if;


 if object_type='1250000001' and transaction_type in ('A','U')

	then 

	if exists ( select 1 from OWTQ T0 

				inner join WTQ1 T1 on T0."DocEntry"=T1."DocEntry"

				where T0."ToWhsCode"<>T1."WhsCode" and T0."DocEntry"=list_of_cols_val_tab_del )
	then
	 error='1061';
	 error_message='Almacen destino diferente en detalle de productos';


  end if;
  end if;
  
 ---------------------VALIDACION DE CORRELATIVOS PARA LAS 3 SUCURSALES
/*


if object_type = '13' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from oinv a 

		 

		where a."Series"  in ('82','97','101') and a."UserSign"<>'117' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Numero de serie no valido para sucursal Merliot .. ';

end if;
end if;


*/
/*  SIN EFECTO, LOS USUARIOS VALIDOS PARA CREAR NOTA DE CREIDTO ANY, CESAR, SANDRA MECHADO 6-11-2024
if object_type = '14' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from ORIN  a 

		 

		where a."Series"  in ('85') and a."UserSign"<>'117' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Numero de serie no valido para NDC sucursal Merliot.. ';

end if;
end if;



if object_type = '14' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from ORIN  a 

		 

		where a."Series"  in ('86') and a."UserSign"<>'118' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Numero de serie no valido para NDC sucursal Juan Pablo.. ';

end if;
end if;


if object_type = '14' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from ORIN  a 

		 

		where a."Series"  in ('87') and a."UserSign"<>'57' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Numero de serie no valido para NDC sucursal San Miguel.. ';

end if;
end if;

*/
---------------------------validacion tipos de documento e iva
/*
if object_type = '13' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from oinv a 

		inner join inv1 b on a."DocEntry"=b."DocEntry"

	  where a."Series" in ('78','115','101') and b."TaxCode" not in ('IVACF','IVAEXE') and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Tipo de impuesto no valido IVAEXE/IVACF .. ';

end if;
end if;


*/
/*
if object_type = '13' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from oinv a 

		inner join inv1 b on a."DocEntry"=b."DocEntry"

	  where a."Series" in ('75','111','97') and b."TaxCode" not in ('IVACRF') and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Tipo de impuesto no valido IVACRF.. ';

end if;
end if;
*/
/*
if object_type = '13' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from oinv a 

		inner join inv1 b on a."DocEntry"=b."DocEntry"

	  where a."Series" in ('81','83','82') and b."TaxCode" not in ('IVAEXP') and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Tipo de impuesto no valido IVAEXP.. ';

end if;
end if; 
  
  */
 
 ----- INFORUM: VALIDACION DE DOCUMENTO BASE EN FACTURA DE PROVEEDORES ------
/*
if object_type = '18' and transaction_type in ('A') THEN 
DocEntry := list_of_cols_val_tab_del;
cont := 0;

SELECT COUNT(1) INTO cont 
FROM OPCH T0
INNER JOIN PCH1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
WHERE T0."DocEntry" = DocEntry AND T0."DocType" = 'S' AND T2."QryGroup60" = 'N' AND T1."BaseType" <> 22;
  --and  T2."QryGroup60" = 'Y' AND T0."DocEntry" = DocEntry ;

IF cont > 0 THEN 
	error=1;
 	error_message= 'Este documento requiere de un DOCUMENTO BASE - ORDEN DE COMPRA ';
 	END IF;

end if;
*/


--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------VALIDACION PARA FACTURA ELECTRONICA CAMPOS REQUERIDOS 
--validar que sea el mismo numero de serie en la base productiva 



--debe de seleccionar el tipo de orden venta
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ORDR T0 
WHERE T0."U_TIPO" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Seleccione una opcion en Tipo';
   end if;
end if;

--No se puede crear orden de venta si el cliente es tipo LEAD
if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ORDR T0
INNER JOIN OCRD T1 ON T0."CardCode" = T1."CardCode" 
WHERE T1."CardType" = 'L' AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'*** El socio de negocios esta como tipo LEAD ***';
   end if;
end if;

--ORDEN DE VENTA: CODIGO SUCURSAL
if object_type = '17' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from ORDR a 

      where
      (a."U_Cod_Sucursal_FEL" is null)
      and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

	then
	 error=1;
	 error_message= '(DTE) Falta seleccionar "CODIGO SUCURSAL FEL"';
	
	end if; 
end if;

--ORDEN DE VENTA: IVA RETENIDO
if object_type = '17' and transaction_type in ('A')

   THEN 
   	 if exists(  select 1 from ORDR a 
	  inner join OCRD b on a."CardCode" = b."CardCode"
      where 
      (b."WTLiable" = 'Y' and a."U_RetiIVAFE" is null) and (a."DocTotal" - a."VatSum" + a."WTSum")  > 100
      and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

	then
	 error=1;
	 error_message= '(DTE) Debe seleccionar IVA RETENIDO en Y';
	
	end if;

end if;


/*CODIGO DE EJEMPLO
if object_type = '13' and  transaction_type in ('A')
   then 
      if  (SELECT  Count (*) 
FROM OINV T0
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
WHERE  T2."WTLiable" = 'Y'  AND T1."WtLiable" <> 'Y' AND (T0."DocTotal" - T0."VatSum" + T0."WTSum")  > 100 AND T0."DocEntry" =  CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1012;
      error_message := N'*****FACTURA DE MAS DE $100 Y EXISTE UNA LINEA SIN RETENCION*****';
   end if;
end if;
*/

--ORDEN DE VENTA CCF
if object_type = '17' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from ORDR a 

      where a."U_TIPO"='CCF' AND 
      (a."U_CodDepartamento" is null or 
      a."U_CodMunicipio" is null or  
      a."U_FacNit" is null or
      a."U_CodigoActividad" is null or--Codigo Actividad FEL 
      a."U_FacNom" is null or--Nombre recepetor
      a."U_Correo" is null or 
      --a."U_Sistema_Caja" is null or -- Codigo sucursal FEL
      a."U_FacReg" is null or--NRC RECEPTOR
      a."U_Vendedor" is null or  
      a."U_Condicion_Pago" is null or 
      a."U_Identificacion" is null) -- Tipo identificacion
      and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Campos incompletos para creacion de CCF Electronica';

end if;
end if;


--ORDEN DE VENTA FCF
if object_type = '17' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from ORDR a 

      where a."U_TIPO"='FCF' AND 
      (a."U_CodDepartamento" is null or 
      a."U_CodMunicipio" is null or  
      a."U_DUI" is null or --DUI
      a."U_FacNom" is null or--Nombre receptor
      a."U_Correo" is null or --Email Receptor
      --a."U_Sistema_Caja" is null or -- Codigo Sucursal FEL
      --a."U_FacReg" is null or--NRC RECEPTOR
      a."U_Vendedor" is null or  
      a."U_Condicion_Pago" is null or 
      a."U_Identificacion" is null) --Tipo de identificacion
      and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Campos incompletos para creacion de FCF Electronica';

end if;
end if;


--ORDEN DE VENTA FEX
if object_type = '17' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from ORDR a 

      where a."U_TIPO"='FEX' AND 
      (a."U_Correo" is null or 
      a."U_FacNom" is null or-- Nombre receptor
      --a."U_Sistema_Caja" is null or -- Codigo Sucursal FEL
      a."U_TipoPersona" is null or 
      --a."U_TipoAExp" is null or --Tipo de exportacion
      a."U_IncotermFE" is null or 
      a."U_RecintoFiscal" is null or 
      a."U_Regimen" is null or
      a."U_D_Act_FE" is null or
      a."U_FacNit" is null or
      a."Address" is null or
      a."U_PaisFE" is null or                       
      a."U_Vendedor" is null or  
      --a."U_Condicion_Pago" is null or 
      --a."U_Sistema_Caja" is null or      
      a."U_Identificacion" is null) 
      and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Campos incompletos para creacion de FEX Electronica';

end if;
end if;

-- Bloqueo por Lead creacion

if object_type = '2' and transaction_type in ('A') THEN 
flag = '';
	select COUNT(a."UserSign") INTO flag 
	from ocrd a 
	  where a."CardType" != 'L' and a."UserSign" in (--'55',--codigo coppersv34 (roberto)
	 -- '74',--Joaquin Poritllo
	  '77',--Carlos Acosta
	  '75',--Walter Guardado
	  '66',--Cristian Ramirez
	  '70',--Ricardo Flores
	  --'67',--Geovani Alvarado
	 -- '54',--Wilberto Urbina
	  '47',--Diana Rodriguez
	  '131',--Andres Lopez
	  '51',--Sandy Ramos
	  '68',--Gustavo Quezada
	  '129',--Donaldo
	  '76')--Shirley Trejo 
	  and a."CardCode"=CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
	IF flag >= '1' THEN 
		 error='1061';
		error_message= 'NO PUEDES CREAR CLIENTES Y PROVEEDORES';
		END IF;	

end if;

-- Bloqueo por Lead modificacion
/*
if object_type = '2' and transaction_type in ('U') THEN 
flag = '';
	select COUNT(a."UserSign2") INTO flag 
	from ocrd a 
	  where a."CardType" != 'L' and a."UserSign2" in ('55',--codigo coppersv34 (roberto)
	  --'74',--Joaquin Poritllo
	  '77',--Carlos Acosta
	  '75',--Walter Guardado
	  '66',--Cristian Ramirez
	  '70',--Ricardo Flores
	 -- '67',--Geovani Alvarado
	 -- '54',--Wilberto Urbina
	  '47',--Diana Rodriguez
	  '131',--Andres Lopez
	  '51',--Sandy Ramos
	  '68',--Gustavo Quezada
	  '76')--Shirley Trejo 
	  and a."CardCode"=CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
	IF flag >= '1' THEN 
		 error='1061';
		error_message= 'NO PUEDES MODIFICAR CLIENTES Y PROVEEDORES';
		END IF;	

end if;
*/
-- Validacion FCF campos requeridos DTE

if object_type = '2' and transaction_type in ('A') THEN 

	IF EXISTS( select 1
	from ocrd a
    INNER JOIN CRD1 T1 ON a."CardCode" = T1."CardCode" 
	  where T1."TaxCode" = 'IVACF' AND 
	  (a."E_Mail" IS NULL OR a."CardName" IS NULL OR a."U_CodDepartamento" IS NULL OR a."U_CodMunicipio" 
	  IS NULL OR a."U_DUI" IS NULL OR a."U_Identificacion" IS NULL) 
	  AND a."CardCode"=list_of_cols_val_tab_del )   --- ><  > < > < >

	then
 	error=1;
	 error_message= 'Campos incompletos para creacion de FCF Electronica';	

end if;
end if;

-- Validacion CCF campos requeridos DTE

if object_type = '2' and transaction_type in ('A') THEN 

	IF EXISTS( select 1
	from ocrd a
    INNER JOIN CRD1 T1 ON a."CardCode" = T1."CardCode" 
	  where T1."TaxCode" = 'IVACRF' AND 
	  (a."E_Mail" IS NULL OR a."CardName" IS NULL OR a."U_CodDepartamento" IS NULL OR a."U_CodMunicipio" 
	  IS NULL OR a."U_Identificacion" IS NULL OR a."U_CodigoActividad" IS NULL OR a."AddID" IS NULL) AND a."CardCode"=list_of_cols_val_tab_del )   --- ><  > < > < >

	then
 	error=1;
	 error_message= 'Campos incompletos para creacion de CCF Electronica';	

end if;
end if;

-- Validacion FEX campos requeridos DTE

if object_type = '2' and transaction_type in ('A') THEN 

	IF EXISTS( select 1
	from ocrd a
    INNER JOIN CRD1 T1 ON a."CardCode" = T1."CardCode" 
	  where T1."TaxCode" = 'IVAEXP' AND 
	  (a."E_Mail" IS NULL OR a."CardName" IS NULL OR a."U_PaisFE" IS NULL OR a."U_D_Act_FE" 
	  IS NULL OR a."VatIdUnCmp" IS NULL OR a."U_Identificacion" IS NULL OR a."U_CodigoActividad" IS NULL OR a."U_IncotermFE" 
	  IS NULL OR a."U_Regimen" IS NULL OR a."U_TipoAExp" IS NULL) AND a."CardCode"=list_of_cols_val_tab_del )   --- ><  > < > < >

	then
 	error=1;
	 error_message= 'Campos incompletos para creacion de FEX Electronica';	

end if;
end if;

/*

--ESTE BLOQUEO NO DEJA CREAR NI ACTUALIZAR SOCIOS DE NEGOCIO CON LISTA DESCRITAS
IF object_type = '2' AND transaction_type IN ('A')  THEN 
flag = '';
	SELECT COUNT(T0."UserSign") INTO flag 
	FROM OCRD T0 
	WHERE T0."UserSign" IN (11, 12, 44, 45, 46, 47,  49, 51, 52, 53, 56, 57, 58, 60, 61, 62, 63, 64, 65, 66,
	68, 69, 70, 71, 72, 73, 75, 76, 77, 78, 79, 82, 84, 117, 118) 
	AND T0."ListNum" IN ('1','2','6', '7')
	AND T0."CardCode" = CAST(list_of_cols_val_tab_del AS NVARCHAR(15));
 		IF flag >= '1' THEN 
		 error='1061';
		 error_message = 'No tiene autorizado asignar lista de precio 1, 2, 11, 22, Cree el SN con una lista diferente y solicite la asignacion a Marcela, Joaquin, Geovani, Wilberto, Christian';
		END IF;	
END IF;

*/

if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where a."UserSign"='57' and a."U_Cod_Sucursal_FEL"<>'S002' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Codigo de sucursal incorrecto SM';

end if;
end if;

if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where a."UserSign"='117' and a."U_Cod_Sucursal_FEL"<>'S001' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Codigo de sucursal incorrecto ML';

end if;
end if;

if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where a."UserSign"='118' and a."U_Cod_Sucursal_FEL"<>'M001' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Codigo de sucursal incorrecto JP';

end if;
end if;


if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where   a."U_Cod_Sucursal_FEL" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Agregar codigo de sucursal M001,S001,S002';

end if;
end if;


if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where   a."DiscSum"<>0  and a."DocEntry"=list_of_cols_val_tab_del and a."UserSign" in ('57','117','118'))   --- ><  > < > < >

then
 error=1;
 error_message= 'Descuentos deben agregarse por linea, no por documento';

end if;
end if;

----------------validacion retencin al cliente debe llenar campo DTE
/*

if object_type = '13' and transaction_type in ('A')

   THEN 

    if exists(  select 1 from oinv a 

      where   a."WTSum"<>0  and a."DocEntry"=list_of_cols_val_tab_del and a."U_RetiIVAFE" is null )   --- ><  > < > < >

then
 error=1;
 error_message= 'Debe colocar el campo (DTE) IVA Retenido a YES';

end if;
end if;
*/
----------------campos minimos DTE CCF
/*
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND (a."U_CodDepartamento" is null or a."U_CodMunicipio" is null or  
      a."U_FacNit" is null or a."U_FacNom" is null 
      or a."U_Correo" is null or  a."U_FacReg" is null or a."U_Vendedor" is null or  
      a."U_Condicion_Pago" is null) and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'Campos incompletos para creacion de CCF Electronica';
end if;
end if;*/
-------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_CodDepartamento" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE)Codigo de departamento vacio';
end if;
end if;
-------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_CodMunicipio" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE) Codigo de Municipio vacio';
end if;
end if;
-------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_Correo" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE)Correo vacio';
end if;
end if;
-------------------------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_CodigoActividad" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE)Codigo de actividad economica vacio';
end if;
end if;
---------------------------------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_FacNom" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE) Nombre de receptor vacio ';
end if;
end if;
------------------------------------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_Identificacion" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE)Tipo identificacion cliente vacio NIT,DUI,OTRO';
end if;
end if;
------------------------------------------------------------
if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."Series"='129' AND  a."U_FacReg" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE)NRC Cliente vacio';
end if;
end if;


if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
      where a."U_Valido"='true' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'FAC Cambiar estado true a false para fiscalizar';
end if;
end if;

if object_type = '14' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from orin a 
      where a."U_Valido"='true' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'NC Cambiar estado true a false para fiscalizar';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   inner join inv1 b on a."DocEntry"=b."DocEntry"
   where a."Series"='129' and b."TaxCode"<>'IVACRF' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'CCF Tipo de impuesto no valido para Credito Fiscal Electronico';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   inner join inv1 b on a."DocEntry"=b."DocEntry"
   where a."Series"='128' and b."TaxCode" not in('IVACF','IVAEXE') and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'CF Tipo de impuesto no valido para Comsumidor Final Electronico';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   inner join inv1 b on a."DocEntry"=b."DocEntry"
   where a."Series"='130' and b."TaxCode" not in('IVAEXP') and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'EXP Tipo de impuesto no valido para Exportacion';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   inner join ocrd b on a."CardCode"=b."CardCode"
   where a."Series"='129' and b."WTLiable"='Y' AND (a."DocTotal" - a."VatSum" + a."WTSum")  > 100 and a."U_RetiIVAFE"<>'Y' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE IVA Retenido) debe ser valor Y';
end if;
end if;
/*
if object_type = '13' and  transaction_type in ('A')
   then 
      if  (SELECT  Count (*) 
FROM OINV T0
INNER JOIN INV1 T1 ON T0."DocEntry" = T1."DocEntry"
INNER JOIN OCRD T2 ON T0."CardCode" = T2."CardCode"
WHERE  T2."WTLiable" = 'Y'  AND T1."WtLiable" <> 'Y' AND (T0."DocTotal" - T0."VatSum" + T0."WTSum")  > 100 AND T0."DocEntry" =  CAST(list_of_cols_val_tab_del AS NVARCHAR(15))  
) >= 1
      then
      error = 1012;
      error_message := N'*****FACTURA DE MAS DE $100 Y EXISTE UNA LINEA SIN RETENCION*****';
   end if;
end if;
*/


if object_type = '14' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from orin a 
   inner join ocrd b on a."CardCode"=b."CardCode"
   where a."Series"='132' and b."WTLiable"='Y' and a."U_RetiIVAFE"<>'Y' and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE IVA Retenido) debe ser valor Y';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   where a."RoundDif">0.03  and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'Descuento maximo permitido';
end if;
end if;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   where a."RoundDif"<-0.03  and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= 'Descuento maximo permitido';
end if;
end if;

IF object_type = '13' and transaction_type in ('A')and 
(Select Distinct 'True'  FROM inv1 T1 WHERE cast (T1."DocEntry" as nvarchar) = list_of_cols_val_tab_del
Group by T1."ItemCode" Having count (T1."LineNum") > 1) = 'True'
then
error='101';
		 error_message = ' ****No puede crear documento con codigos de articulos Repetido en las lineas ****';
END IF;

if object_type = '13' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from oinv a 
   inner join inv1 b on a."DocEntry"=b."DocEntry"
   where a."Series"='128' and b."TaxCode"='IVAEXE' and b."U_TipoVentaFel"<>3 and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >
then
 error=1;
 error_message= '(DTE TipoVentaFel) Debe ser tipo venta Exenta 3';
end if;
end if;

--VALIDACION PARA NOTAS DE CREDITO PASEN POR SOLICITUD DE DEVOLUCION. NO APLICA PARA FACTURAS DE RESERVA
if object_type = '14' and transaction_type in ('A')
   THEN 
   if exists(  select 1 from  orin a 
		
			inner join rin1 b on a."DocEntry"=b."DocEntry"
			
			left join inv1 c on b."DocEntry"=c."TrgetEntry"
			
			left join oinv e on c."DocEntry"=e."DocEntry"
			
			left join rrr1 f on b."DocEntry"=f."TrgetEntry"
			
			where e."isIns"='N'  and b."BaseType"!='234000031' and a."DocEntry"=list_of_cols_val_tab_del )
then
 error=1;
 error_message= 'NCR no posee solicitud de devolucion asociada, corregir';
end if;
end if;



--------------------------------------------------------------------------------------------------------------------------------

-- Select the return values
select :error, :error_message FROM dummy;

end;