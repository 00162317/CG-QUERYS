ALTER PROCEDURE SBO_SP_TransactionNotification
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
error_message nvarchar (200); 		-- Error string to be displayed

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES GLOBALES PROPOSITO GENERAL
-------------------------------------------------------------------------------------------------------------------------------------------------------------
DocEntry 					Int:=0;
CardCode 					NVarchar(15):='';
ItemCode 					NVarchar(20):='';
temporal1 					NVarchar(20):='';
comentarios  				NVarchar(200):='';
IEPS 						NVarchar(1);
CardType					NVarchar(3);
FatherCard					NVarchar(20);
contador 					Int:=0;
contador2					Int;
contador3 					Int;
empleado 					Int:=0;
Ref							NVARCHAR(50);
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES PARAMETROS SISTEMA (UDO)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
camposcontrol				NVarchar(1):='';
dbNoManejaFelVentas			NVarchar(1):='';
dbNoManejaFelCompras		NVarchar(1):='';
permitecancelar				NVarchar(1):='';
usaCompradorVendedor 		NVarchar(1):='';
usaProyectoEncabezado   	NVarchar(1):='';
usaProyectoDetalle			NVarchar(1):='';
validaNitDocVentas 			NVarchar(1):=''; -- Se va a utilizar en validación futura
validarNitDocCompras 		NVarchar(1):=''; -- Se va a utilizar en validación futura
validarUsuarioPorAlmacen	NVarchar(1):='';
validarNitSN				NVarchar(1):='';

begin
error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: OQUT - Oferta de ventas / Pk: DocEntry / Object Type: 23
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 If :object_type = '23' Then
	DocEntry := list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Obliga utilizar CAMPOS DE IMPORTACION
		/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			Select Count(1) Into contador
			From OQUT T0
			Where T0."DocEntry" = DocEntry AND T0."U_TIPO_VENTA" = 1 AND (T0."U_N_OC" IS NULL OR LENGTH(T0."U_N_OC") = 0) ;
			If contador > 0 Then
				error := 96006;
				error_message := 'Para este tipo de venta directa, debe de indicar un No Orden de compra';
			End If;
		End If;*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Valida Proyecto en Documento a nivel de encabezado
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------	
		-- 3. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el documento tiene Comentarios


	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OQUT T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;
	  	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: ORDR - Orden de venta / Pk: DocEntry / Object Type: 17
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If :object_type = '17' Then
	DocEntry := list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDR T0
			Join RDR1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 5. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDR T0
			Join RDR1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDR T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;			

	-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 9. Evalua si el documento tiene EMPLEADO DE VENTAS 	
		
	/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDR T0
			Where T0."DocEntry" = DocEntry AND T0."SlpCode" = -1;
			If contador > 0 Then
				error := 96009;
				error_message := 'Es necesario seleccionar EMPLEADO DE VENTAS';
			End If;
		End If;	*/
		
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: ODLN - Entrega / Pk: DocEntry / Object Type: 15
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If :object_type = '15' Then
	DocEntry := list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el documento debe de tener un documento origen	
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 			Select Count(1) Into contador
	            From DLN1 T0
				Join ODLN T1 On T1."DocEntry" = T0."DocEntry"
				Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" And T2."U_Clase"= T1."DocType" And T2."U_TipoBase"<> T0."BaseType"
	            Where T0."DocEntry" =DocEntry;
				If contador > 0 Then
		       		error:=915006;
					error_message:='Este Documento no tiene documento base';
				End If;
      	End If;

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 5. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ODLN T0
			Join DLN1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ODLN T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: ORDN - Devolución / Pk: DocEntry / Object Type: 16
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If :object_type = '16' Then
	DocEntry := list_of_cols_val_tab_del;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 7. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDN T0
			Join RDN1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORDN T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;		  	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: OINV - (Factura de deudores/deudor + pago/Reserva)/Nota de debito de clientes / Pk: DocEntry / Object Type: 13
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If :object_type = '13' Then
	DocEntry := list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Registrar campos de control en automático
		If camposcontrol='S' Then
			Update OINV Set
			--"U_Tienda"=(Select T1."U_Tienda" From OINV T0 Join OUSR T1 On T0."UserSign"=T1."USERID" Where T0."DocEntry"=DocEntry),
			"U_Usuario"=(Select Distinct T1."USER_CODE" From OINV T0 Join OUSR T1 On T0."UserSign"=T1."USERID" Where T0."DocEntry"=DocEntry)
			Where "DocEntry"=DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Escritura campos de usuario fiscales documento a nivel encabezado
		If dbNoManejaFelVentas='S' Then
			Update OINV Set 
			OINV."U_FacNum"=	To_Decimal(Substring(OINV."DocNum", 2, 7), 5 ,0),
			OINV."U_FacSerie"=	NNM1."SeriesName",
			OINV."U_FacFecha"=	OINV."DocDate"
			From OINV 
			Join NNM1 On OINV."Series" = NNM1."Series"
			Where OINV."DocEntry" =DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OINV T0
			Join INV1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From INV1 T0
			Join OINV T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
	        Where T0."DocEntry" =DocEntry And T1."Series" <> 81;
			If contador > 0 Then
		       	error:=913010;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;
     
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		/*-- 8. Evalua si el documento debe tener DPI o NIT 
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From INV1 T0
			Join OINV T1 On T1."DocEntry" = T0."DocEntry"
	        Where T0."DocEntry" =DocEntry And (T1."U_FacNit" Is Null Or T1."U_FacNit" Like 'C%%')  And T1."DocTotal" > 2500;
			If contador > 0 Then
		       	error:=913010;
				error_message:='Este Documento no tiene NIT o DPI';
			End If;
      	End If;*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 9. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OINV T0
			Join INV1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OINV T0
			Where T0."DocEntry" = DocEntry AND (T0."Comments" IS NULL OR T0."Comments" ='');
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VENTAS: ORIN - Nota de crédito de clientes / Pk: DocEntry / Object Type: 14
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If :object_type = '14' Then
	DocEntry := list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Registrar campos de control en automático
		If camposcontrol='S' Then
			Update ORIN Set
				"U_Usuario"=(Select Distinct T1."USER_CODE" From ORIN T0 Join OUSR T1 On T0."UserSign"=T1."USERID" Where T0."DocEntry"=DocEntry)
			Where "DocEntry"=DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Escritura campos de usuario fiscales documento a nivel encabezado
		If dbNoManejaFelVentas='S' Then
			Update ORIN Set 
				ORIN."U_FacFecha"=	ORIN."DocDate"
			From ORIN 
			Join NNM1 On ORIN."Series" = NNM1."Series"
			Where ORIN."DocEntry" =DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORIN T0
			Join RIN1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
 			Select Count(1) Into contador
            From RIN1 T0
			Join ORIN T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
            Where T0."DocEntry" =DocEntry;
			If contador > 0 Then
	       		error:=914008;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 8. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORIN T0
			Join RIN1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar los Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 9. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORIN T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
		
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: OPRQ - Solicitud de compra / Pk: DocEntry / Object Type: 1470000113
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '1470000113' Then
	DocEntry:=list_of_cols_val_tab_del;

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPRQ T0
			Join PRQ1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPRQ T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	

End If;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: OPQT - Oferta de compra / Pk: DocEntry / Object Type: 540000006
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '540000006' Then
	DocEntry:=list_of_cols_val_tab_del;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPQT T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: OPOR - Orden de compra / Pk: DocEntry / Object Type: 22
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '22' Then
	DocEntry:=list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
   		-- 1. Obliga a copmletar flete y costos importacion directa
	/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
		contador:=0;
		Select Count(1) Into contador
		From OPOR T0
		Where T0."DocEntry" = DocEntry AND T0."U_TIPO_VENTA" = 1 AND T0."U_FLETE" = 0.00 ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario Completar campo de flete y Costo de importacion';
			End If;
	End If;*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Valida Proyecto en Documento a nivel de encabezado
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPOR T0
			Join POR1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
	/*	-- 5. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPOR T0
			Join POR1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;*/
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
	-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPOR T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: OPDN - Entrada de mercancias / Pk: DocEntry / Object Type: 20
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '20' Then
	DocEntry:=list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
   		-- 1. Obliga utilizar (comprador/vendedor)	en documento a nivel de encabezado	
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Valida Proyecto en Documento a nivel de encabezado
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From PDN1 T0
			Join OPDN T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
	        Where T0."DocEntry" =DocEntry;
			If contador > 0 Then
		       	error:=920006;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;

		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 5. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPDN T0
			Join PDN1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPDN T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: ORPD - Devolución de mercancias / Pk: DocEntry / Object Type: 21
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '21' Then
	DocEntry:=list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Obliga utilizar (comprador/vendedor)	en documento a nivel de encabezado		
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Valida Proyecto en Documento a nivel de encabezado
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From RPD1 T0
			Join ORPD T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
	        Where T0."DocEntry" =DocEntry;
			If contador > 0 Then
		       	error:=921006;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;
      	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 5. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORPD T0
			Join RPD1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORPD T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: OPCH - (Factura de Proveedores/Reserva)/Nota de debito de proveedores / Pk: DocEntry / Object Type: 18
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '18' Then
	DocEntry:=list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Registrar campos de control en automático
		If camposcontrol='S' Then
			Update OPCH Set
			"U_Usuario"=(Select Distinct T1."USER_CODE" From OPCH T0 Join OUSR T1 On T0."UserSign"=T1."USERID" Where T0."DocEntry"=DocEntry)
			Where "DocEntry"=DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. Escritura campos de usuario fiscales documento a nivel encabezado
		If dbNoManejaFelCompras='S' Then
			Update OPCH Set 
			OPCH."U_FacFecha"=	OPCH."DocDate"
			From OPCH 
			Join NNM1 On OPCH."Series" = NNM1."Series"
			Where OPCH."DocEntry"=DocEntry;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. Obliga utilizar (comprador/vendedor)	en documento a nivel de encabezado		
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0
			Join PCH1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 5. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From PCH1 T0
			Join OPCH T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
			Join OCRD T3 On T1."CardCode"=T3."CardCode"
	        Where T0."DocEntry" =DocEntry And T3."QryGroup59"='N';
			If contador > 0 Then
		       	error:=918006;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;
 
 		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 7. Evalua si el documento tiene los 3 Centros de costos

	/*If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0
			Join PCH1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		*/
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0
			Where T0."DocEntry" = DocEntry AND (T0."Comments" = '' OR T0."Comments" IS NULL);
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
		
 	-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 7. Validaciones para el proceso de caja chica
		-----------------------------------------------------------------------------------------------------------------------------------------------------
			-- 7.1 Valida serie documento de proveedor caja chica
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			INNER Join OCRD T1 On T0."CardCode"=T1."CardCode"
			INNER JOIN PCH1 T2 ON T0."DocEntry" = T2."DocEntry"
			Where T1."QryGroup59"='Y'And T0."DocEntry" = DocEntry  And T2."U_FacSerie" IS NULL ;
			If contador > 0 Then
				error:=918009;
				error_message:='Coloque el Serie del documento en el campo de detalle >> Serie del Documento';
			End If;
		End If;	
			-------------------------------------------------------------------------------------------------------------------------------------------------
					
			-------------------------------------------------------------------------------------------------------------------------------------------------
			-- 7.3 Valida nombre documento de proveedor caja chica.
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			INNER Join OCRD T1 On T0."CardCode"=T1."CardCode"
			INNER JOIN PCH1 T2 ON T0."DocEntry" = T2."DocEntry"
			Where T1."QryGroup59"='Y'And T0."DocEntry" = DocEntry  And T2."U_FacNom" IS NULL ;
			If contador > 0 Then
				error:=918011;
				error_message:='Coloque el nombre del documento en el campo de detalle >> Nombre del Documento.';
			End If;
		End If;
			-------------------------------------------------------------------------------------------------------------------------------------------------
			-- 7.4 Valida numero documento de proveedor caja chica.
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			INNER Join OCRD T1 On T0."CardCode"=T1."CardCode"
			INNER JOIN PCH1 T2 ON T0."DocEntry" = T2."DocEntry"
			Where T1."QryGroup59"='Y'And T0."DocEntry" = DocEntry  And T2."U_FacNum" IS NULL ;
			If contador > 0 Then
				error:=918012;
				error_message:='Coloque el numero de la factura en el campo de detalle >> Numero del Documento.';
			End If;
		End If;
			-------------------------------------------------------------------------------------------------------------------------------------------------
			-- 7.5 Valida fecha documento de proveedor caja chica.
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			INNER Join OCRD T1 On T0."CardCode"=T1."CardCode"
			INNER JOIN PCH1 T2 ON T0."DocEntry" = T2."DocEntry"
			Where T1."QryGroup59"='Y'And T0."DocEntry" = DocEntry  And T2."U_FacFecha" IS NULL ;
			If contador > 0 Then
				error:=918012;
				error_message:='Coloque fecha del documento en el campo de detalle >> Fecha del Documento.';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 8. Valida serie documento de proveedor a nivel encabezado para proceso fuera de caja chica
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			Join OCRD T1 On T0."CardCode"=T1."CardCode"
			Where T1."QryGroup59"='N' And (T0."U_FacSerie" = '' OR T0."U_FacSerie" IS NULL ) And T0."DocEntry" = DocEntry;
			If contador > 0 Then
				error:=918013;
				error_message:='Coloque la serie de la factura en el campo Serie del Documento.';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 9. Valida numero de factura de proveedor a nivel encabezado para proceso fuera de caja chica
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			Join OCRD T1 On T0."CardCode"=T1."CardCode"
			Where T1."QryGroup59"='N' And (T0."U_FacNum" = '' OR T0."U_FacNum" IS NULL ) And T0."DocEntry" = DocEntry;
			If contador > 0 Then
				error:=918013;
				error_message:='Coloque el numero de la factura en el campo Numero del Documento.';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 10. Valida fecha de la factura de proveedor a nivel encabezado para proceso fuera de caja chica
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			Join OCRD T1 On T0."CardCode"=T1."CardCode"
			Where T1."QryGroup59"='N' And (T0."U_FacFecha" ='' OR T0."U_FacFecha" IS NULL) And T0."DocEntry" = DocEntry;
			If contador > 0 Then
				error:=918014;
				error_message:='Coloque la fecha de la factura en el campo Fecha del Documento.';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 12. Valida nombre de la factura de proveedor a nivel encabezado para proceso fuera de caja chica
		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From OPCH T0 
			Join OCRD T1 On T0."CardCode"=T1."CardCode"
			Where T1."QryGroup59"='N' And (T0."U_FacNom" ='' OR T0."U_FacNom" IS NULL) And T0."DocEntry" = DocEntry;
			If contador > 0 Then
				error:=918016;
				error_message:='Coloque el nombre de la factura en el campo Nombre.';
			End If;
		End If;
		
End If;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS: ORPC - Nota de Crédito proveedores / Pk: DocEntry / Object Type: 19
-------------------------------------------------------------------------------------------------------------------------------------------------------------
If object_type = '19' Then
	DocEntry:=list_of_cols_val_tab_del;
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 1. Registrar campos de control en automático
		If camposcontrol='S' Then
			Update ORPC Set
			"U_Usuario"=(Select Distinct T1."USER_CODE" From ORPC T0 Join OUSR T1 On T0."UserSign"=T1."USERID" Where T0."DocEntry"=DocEntry)
			Where "DocEntry"=DocEntry;
		End If;
		--------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. Obliga utilizar (comprador/vendedor)	en documento a nivel de encabezado		
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 4. Evalua si el proyecto esta asignado

		If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORPC T0
			Join RPC1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND (T1."Project" IS NULL or LENGTH(T1."Project") = 0) ;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Proyecto';
			End If;
		End If;
		-----------------------------------------------------------------------------------------------------------------------------------------------------	
		-- 5. Valida Proyecto en Documento a nivel de linea
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento debe de tener un documento origen
	  	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
	 		Select Count(1) Into contador
	        From RPC1 T0
			Join ORPC T1 On T1."DocEntry" = T0."DocEntry"
			Join "@DOCUMENTOBASE" T2 On T2."U_Tipo" = T1."ObjType" 
				And T2."U_Clase"= T1."DocType" 
				And	T2."U_TipoBase"<> T0."BaseType"
	        Where T0."DocEntry" =DocEntry;
			If contador > 0 Then
		       	error:=919006;
				error_message:='Este Documento no tiene documento base';
			End If;
      	End If;
      	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 7. Evalua si el documento tiene los 3 Centros de costos

	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORPC T0
			Join RPC1 T1 On T0."DocEntry" = T1."DocEntry"
			Where T0."DocEntry" = DocEntry AND T1."OcrCode" IS NULL;
			If contador > 0 Then
				error := 96005;
				error_message := 'Es necesario llenar el Centros de costo';
			End If;
		End If;
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- 6. Evalua si el documento tiene Comentarios
		
	If error = 0 And transaction_type = 'A' Or transaction_type = 'U' Then
			contador:=0;
			Select Count(1) Into contador
			From ORPC T0
			Where T0."DocEntry" = DocEntry AND T0."Comments" IS NULL;
			If contador > 0 Then
				error := 96006;
				error_message := 'Es necesario agregar Comentarios al documento';
			End If;
		End If;	
End If;

-- -----------------------------------------------------validacion item nuevo campo no puede estar vacio

--------------------CENTRO DE COSTO OBLIGATORIO

if object_type = '23' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM OQUT T0 inner join qut1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."Project" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Projecto obligatorio';
   end if;
end if;


--------------------proyecto obligatorio

if object_type = '23' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM OQUT T0 inner join qut1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."OcrCode" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Centro de Costo obligatorio';
   end if;
end if;

--------------------CENTRO DE COSTO OBLIGATORIO

if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ORDR T0 inner join RDR1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."Project" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Projecto obligatorio';
   end if;
end if;


--------------------proyecto obligatorio

if object_type = '17' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ORDR T0 inner join RDR1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."OcrCode" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Centro de Costo obligatorio';
   end if;
end if;


/*--------------------CENTRO DE COSTO OBLIGATORIO

if object_type = '15' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ODLN T0 inner join DLN1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."Project" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Projecto obligatorio';
   end if;
end if;


--------------------proyecto obligatorio

if object_type = '15' and  transaction_type in ('A','U')
   then 
      if  (SELECT  COUNT(T0."CardCode") 
FROM ODLN T0 inner join DLN1 T1 on T1."DocEntry"=T0."DocEntry"
WHERE T1."OcrCode" IS NULL AND T0."DocEntry"= list_of_cols_val_tab_del 
 ) >= 1
      then
      error = 1003;
      error_message := N'Centro de Costo obligatorio';
   end if;
end if;
*/



if object_type = '13' and transaction_type in ('A')

   THEN 

	if exists(	select 1 from oinv a 
		
	inner join inv1 b on a."DocEntry"=b."DocEntry"
		
	inner join oitm c on b."ItemCode"=c."ItemCode"
	  
	where  c."U_ItemCodeFel" is null and a."DocEntry"=list_of_cols_val_tab_del )   --- ><  > < > < >

then
 error=1;
 error_message= 'Codigo de Item auxiliar FEL vacio, llenarlo para continuar';

end if;
end if; 



if object_type = '23' and  transaction_type in ('A','U') --OFERTA DE VENTAS
   then 
      if ( SELECT  COUNT(T0."DocNum") FROM OQUT T0 INNER JOIN QUT1 T1 ON T0."DocEntry" = T1."DocEntry" 
      WHERE T1."DiscPrcnt" > 15 and 
      
       T0."U_aut_precio" = '-' and
      
       T0."DocEntry"= list_of_cols_val_tab_del  AND  T0."UserSign" IN ('11','14','24')--Mario M, Adriana Calles,Aura A
 ) >= 1
      then
      error = 1007;
      error_message := N'OQUT Este documento tiene descuento, para generarlo cambiar el campo: Pedir autorizacion de precio a Y  ';
   end if;
end if;


if object_type = '17' and  transaction_type in ('A','U')-- ORDEN DE VENTAS
   then 
      if ( SELECT  COUNT(T0."DocNum") FROM ORDR T0 INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry" 
      
      WHERE T1."DiscPrcnt" > 15 and T0."WddStatus"<> 'P' 
      
      and  T1."BaseEntry" is null
      
      AND  T0."DocEntry"= list_of_cols_val_tab_del  AND  T0."UserSign" IN ('11','14','24')--Mario M, Adriana Calles,Aura A 
 ) >= 1
      then
      error = 1007;
      error_message := N'ORDR Este documento tiene descuento, para generarlo cambiar el campo: Pedir autorizacion de precio a Y';
   end if;
end if;






--------------------------------------------------------------------------------------------------------------------------------

-- Select the return values
select :error, :error_message FROM dummy;

end;