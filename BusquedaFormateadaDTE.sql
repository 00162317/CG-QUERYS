--VENDEDOR RUTAS
SELECT T1."SlpName"
FROM OINV T0
INNER JOIN OSLP T1 ON T1."SlpCode" = T0."SlpCode"
where $["OINV"."SlpCode"] = T1."SlpCode" 


SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]



----------------- OINV
--Vendedor
SELECT DISTINCT T2."SlpName"
FROM OCRD T0
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
where $["OINV"."SlpCode"] = T2."SlpCode" 


-- Condicion de Pago
SELECT DISTINCT T2."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
where $["OINV"."GroupNum"] = T2."GroupNum" 


--NRC 
SELECT T0."AddID" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"] and T0."CardCode" = $[ORDR."CardCode"]


--NOMBRE CLIENTE
SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]


--NIT 
SELECT T0."LicTradNum" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

--DUI
SELECT T0."U_DUI" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]


-- Codigo departamento. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodDepartamento" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]


-- Codigo municipio. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodMunicipio" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

-- Codigo PAIS FE. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_PaisFE" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

--Codigo Sucursal FEL. HAY QUE CREAR ESTE CAMPO EN OUSR
SELECT T0."U_Cod_Sucursal_FEL"
FROM OUSR T0  INNER JOIN OINV T1 ON T0."USERID" = T1."UserSign"
WHERE $["OINV"."UserSign"] = T0."USERID"

-- Codigo Actividad FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodigoActividad" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

-- Tipo Identificacion FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Identificacion" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

--Correo
SELECT T0."E_Mail" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

--Actividad Eco. FE
SELECT T0."U_D_Act_FE" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]

-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[OINV."CardCode"]


---------------------------------------------------------------------------------------------------------------------------

----------------- ORDR
--Vendedor
SELECT DISTINCT T2."SlpName"
FROM OCRD T0
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
where $["ORDR"."SlpCode"] = T2."SlpCode" 


-- Condicion de Pago
SELECT DISTINCT T2."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
where $["ORDR"."GroupNum"] = T2."GroupNum" 


--NRC 
SELECT T0."AddID" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]  


--NOMBRE CLIENTE
SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]


--NIT 
SELECT T0."LicTradNum" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

--DUI
SELECT T0."U_DUI" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]


-- Codigo departamento. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodDepartamento" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]



-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]


-- Codigo municipio. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodMunicipio" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

-- Codigo PAIS FE. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_PaisFE" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

--Codigo Sucursal FEL. HAY QUE CREAR ESTE CAMPO EN OUSR
SELECT T0."U_Cod_Sucursal_FEL"
FROM OUSR T0  INNER JOIN ORDR T1 ON T0."USERID" = T1."UserSign"
WHERE $["ORDR"."UserSign"] = T0."USERID"


--Correo
SELECT T0."E_Mail" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]


-- Codigo Actividad FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodigoActividad" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

-- Tipo Identificacion FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Identificacion" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]


--Actividad Eco. FE
SELECT T0."U_D_Act_FE" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

--05
-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[ORDR."CardCode"]

---------------------------------------------------------------------------------------------------------------------------


----------------- OQUT
--Vendedor
SELECT DISTINCT T2."SlpName"
FROM OCRD T0
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
where $["OQUT"."SlpCode"] = T2."SlpCode" 


-- Condicion de Pago
SELECT DISTINCT T2."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
where $["OQUT"."GroupNum"] = T2."GroupNum" 


--NRC 
SELECT T0."AddID" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]  


--NOMBRE CLIENTE
SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]


--NIT 
SELECT T0."LicTradNum" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

--DUI
SELECT T0."U_DUI" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]


-- Codigo departamento. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodDepartamento" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]


-- Codigo municipio. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodMunicipio" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

-- Codigo PAIS FE. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_PaisFE" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

--Codigo Sucursal FEL. HAY QUE CREAR ESTE CAMPO EN OUSR
SELECT T0."U_Cod_Sucursal_FEL"
FROM OUSR T0  INNER JOIN OQUT T1 ON T0."USERID" = T1."UserSign"
WHERE $["OQUT"."UserSign"] = T0."USERID"


--Correo
SELECT T0."E_Mail" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]


-- Codigo Actividad FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodigoActividad" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

-- Tipo Identificacion FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Identificacion" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]


--Actividad Eco. FE
SELECT T0."U_D_Act_FE" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

--06
-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[OQUT."CardCode"]

-----------------Entrega

--Vendedor
SELECT DISTINCT T2."SlpName"
FROM OCRD T0
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
where $["ODLN"."SlpCode"] = T2."SlpCode" 


-- Condicion de Pago
SELECT DISTINCT T2."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
where $["ODLN"."GroupNum"] = T2."GroupNum" 


--NRC 
SELECT T0."AddID" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]  


--NOMBRE CLIENTE
SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


--NIT 
SELECT T0."LicTradNum" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]

--DUI
SELECT T0."U_DUI" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


-- Codigo departamento. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodDepartamento" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


-- Codigo municipio. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodMunicipio" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]

-- Codigo PAIS FE. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_PaisFE" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]

--Codigo Sucursal FEL. HAY QUE CREAR ESTE CAMPO EN OUSR
SELECT T0."U_Cod_Sucursal_FEL"
FROM OUSR T0  INNER JOIN ODLN T1 ON T0."USERID" = T1."UserSign"
WHERE $["ODLN"."UserSign"] = T0."USERID"


--Correo
SELECT T0."E_Mail" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


-- Codigo Actividad FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodigoActividad" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]

-- Tipo Identificacion FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Identificacion" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


--Actividad Eco. FE
SELECT T0."U_D_Act_FE" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]

--07
-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[ODLN."CardCode"]


-----------------Sujeto excluido (factura proveedor)
--Vendedor
SELECT DISTINCT T2."SlpName"
FROM OCRD T0
INNER JOIN OSLP T2 ON T0."SlpCode" = T2."SlpCode"
where $["OPCH"."SlpCode"] = T2."SlpCode" 


-- Condicion de Pago
SELECT DISTINCT T2."PymntGroup"
FROM OCRD T0
INNER JOIN OCTG T2 ON T0."GroupNum" = T2."GroupNum"
where $["OPCH"."GroupNum"] = T2."GroupNum" 


SELECT DISTINCT T1."U_Cod_Sucursal_FEL"
FROM OPCH T0
INNER JOIN OUSR T1 ON T0."UserSign" = T1."UserSign"
WHERE $["OPCH"."UserSign"] = T1."UserSign"

SELECT T0."U_Cod_Sucursal_FEL" UserSign
FROM OPCH T0 WHERE T0."UserSign" = $[OPCH."CardCode"]



--NRC 
SELECT T0."AddID" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]  


--NOMBRE CLIENTE
SELECT T0."CardName" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]


--NIT 
SELECT T0."LicTradNum" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]

--DUI
SELECT T0."U_DUI" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]


-- Codigo departamento. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodDepartamento" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]


-- Codigo municipio. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodMunicipio" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]

-- Codigo PAIS FE. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_PaisFE" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]

--Codigo Sucursal FEL. HAY QUE CREAR ESTE CAMPO EN OUSR
SELECT T0."U_Cod_Sucursal_FEL" UserSign
FROM OPCH T0 WHERE T0."UserSign" = $[OPCH."CardCode"]


--Correo
SELECT T0."E_Mail" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]


-- Codigo Actividad FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_CodigoActividad" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]

-- Tipo Identificacion FEL. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Identificacion" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]


--Actividad Eco. FE
SELECT T0."U_D_Act_FE" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]
--08
-- Condicion Pago. HAY QUE CREAR ESTE CAMPO EN OCRD
SELECT T0."U_Cond_Pago" FROM OCRD T0 WHERE T0."CardCode" = $[OPCH."CardCode"]