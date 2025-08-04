USE Restaurante;

-- Integridad L�gica de Datos con Restricciones CHECK: asegura que los datos cumplan ciertas reglas de negocio.

-- A�adir una restricci�n CHECK a la tabla Plato: el precio debe ser positivo
ALTER TABLE Plato
ADD CONSTRAINT CK_Plato_PrecioPositivo CHECK (precio > 0);

-- Probar, esto deber�a fallar
PRINT 'Intentando insertar un plato con precio negativo (deber�a fallar)';
BEGIN TRY
    INSERT INTO Plato (nombre_plato, precio, id_categoria) VALUES ('Plato Negativo', -5.00, 1);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
