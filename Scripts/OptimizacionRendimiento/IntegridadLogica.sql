USE Restaurante;

-- Integridad Lógica de Datos con Restricciones CHECK: asegura que los datos cumplan ciertas reglas de negocio.

-- Añadir una restricción CHECK a la tabla Plato: el precio debe ser positivo
ALTER TABLE Plato
ADD CONSTRAINT CK_Plato_PrecioPositivo CHECK (precio > 0);

-- Probar, esto debería fallar
PRINT 'Intentando insertar un plato con precio negativo (debería fallar)';
BEGIN TRY
    INSERT INTO Plato (nombre_plato, precio, id_categoria) VALUES ('Plato Negativo', -5.00, 1);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;
