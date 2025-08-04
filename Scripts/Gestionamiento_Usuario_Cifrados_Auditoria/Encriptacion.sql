-- 4. Encriptaci�n (Ejemplo de Always Encrypted para datos sensibles)
-- En nuestra base de datos, el dato sensible que encontramos fue el dato de c�dula de los empleados.

ALTER TABLE Empleado
ALTER COLUMN cedula
VARBINARY(256) ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = [CEK_Auto1],
ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA256');

-- tambi�n se puede hacer de forma manual