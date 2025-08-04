USE Restaurante;

-- Monitoreo y Rendimiento: Evaluación de consultas, crecimiento de registros, uso de recursos.

-- 1. Evaluación del Rendimiento de Consultas (Top 10 Consultas más Costosas)
-- Esta consulta utiliza Dynamic Management Views (DMVs) para encontrar las consultas
-- que más recursos (CPU, I/O, tiempo de ejecución) han consumido desde la última vez que
-- se reinició el servicio de SQL Server o se limpió la caché de planes.
SELECT TOP 10
    qs.creation_time, -- Fecha y hora de compilación del plan de consulta
    qs.last_execution_time, -- Última fecha y hora de ejecución
    qs.execution_count, -- Número de veces que se ha ejecutado la consulta
    (qs.total_worker_time / 1000) AS total_cpu_time_ms, -- Tiempo total de CPU en milisegundos
    (qs.total_elapsed_time / 1000) AS total_elapsed_time_ms, -- Tiempo total transcurrido en milisegundos
    (qs.total_logical_reads + qs.total_physical_reads) AS total_reads, -- Total de lecturas lógicas y físicas
    (qs.total_logical_writes) AS total_writes, -- Total de escrituras lógicas
    SUBSTRING(st.text, (qs.statement_start_offset / 2) + 1,
              ((CASE qs.statement_end_offset
                  WHEN -1 THEN DATALENGTH(st.text)
                  ELSE qs.statement_end_offset
                END - qs.statement_start_offset) / 2) + 1) AS query_text -- Texto de la consulta
FROM
    sys.dm_exec_query_stats AS qs
CROSS APPLY
    sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY
    total_cpu_time_ms DESC; -- Ordena por el tiempo de CPU, puedes cambiar a total_elapsed_time_ms o total_reads
GO

-- 2. Crecimiento de Registros y Espacio en Disco por Tabla
-- Muestra el número de filas y el espacio en disco utilizado por cada tabla.
-- Útil para identificar tablas que crecen rápidamente y consumen mucho espacio.
SELECT
    t.name AS TableName,
    s.name AS SchemaName,
    p.rows AS RowCounts,
    SUM(a.total_pages) * 8 AS TotalSpaceKB,
    SUM(a.used_pages) * 8 AS UsedSpaceKB,
    (SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM
    sys.tables t
INNER JOIN
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN
    sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN
    sys.schemas s ON t.schema_id = s.schema_id
WHERE
    t.name NOT LIKE 'dt%' -- Excluye tablas del sistema
    AND t.is_ms_shipped = 0
    AND i.object_id > 255
GROUP BY
    t.name, s.name, p.rows
ORDER BY
    TotalSpaceKB DESC;
GO

-- Otra forma rápida de ver el espacio usado por una tabla específica (ej. 'Orden')
-- EXEC sp_spaceused N'Orden';
-- GO

-- 3. Uso de Recursos del Servidor (CPU, Memoria, I/O)
-- Estas DMVs proporcionan información sobre el uso general de recursos.

-- Uso de CPU (desde el último reinicio de SQL Server)
SELECT TOP 10
    SQLProcessUtilization AS SQL_CPU_Usage,
    SystemIdle AS System_Idle_CPU,
    OtherProcessUtilization AS Other_CPU_Usage,
    DATEADD(ms, - (ms_ticks - (SELECT ms_ticks FROM sys.dm_os_sys_info)) / 1000, GETDATE()) AS CaptureTime
FROM
    sys.dm_os_ring_buffers
WHERE
    ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
ORDER BY
    timestamp DESC;
GO

-- Uso de Memoria (Memoria asignada y en uso por SQL Server)
SELECT
    (physical_memory_in_use_kb / 1024) AS PhysicalMemoryInUseMB,
    (locked_page_allocations_kb / 1024) AS LockedPagesAllocatedMB,
    (total_virtual_address_space_kb / 1024) AS TotalVASMB,
    (available_physical_memory_kb / 1024) AS AvailablePhysicalMemoryMB,
    (total_page_file_kb / 1024) AS TotalPageFileMB,
    (available_page_file_kb / 1024) AS AvailablePageFileMB
FROM
    sys.dm_os_process_memory;
GO

-- Estadísticas de I/O por archivo de base de datos
SELECT
    DB_NAME(vfs.database_id) AS DatabaseName,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    vfs.io_stall_read_ms / (vfs.num_of_reads + 1) AS AvgReadStallMs,
    vfs.io_stall_write_ms / (vfs.num_of_writes + 1) AS AvgWriteStallMs,
    vfs.io_stall / (vfs.num_of_reads + vfs.num_of_writes + 1) AS AvgIOStallMs
FROM
    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN
    sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY
    AvgIOStallMs DESC;
GO