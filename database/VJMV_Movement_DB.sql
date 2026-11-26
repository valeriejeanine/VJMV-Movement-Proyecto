  /***************************************************************************************************
        PROYECTO INTEGRADOR: VJMV MOVEMENT ("BUILT TO MOVE")
        ASIGNATURAS: Desarrollo de Software IV (Backend/BD) y Desarrollo de Software V (Frontend)
        DESCRIPCIÓN: Script integral de creación de Base de Datos, Tablas, Restricciones,
                     Catálogo Inicial Femenino estilo AYBL y Procedimientos Almacenados (CRUD + Auth).
        AUTORA: Valeria
        FECHA: Noviembre 2026
    ***************************************************************************************************/

    -- =================================================================================================
    -- SECCIÓN 1: CREACIÓN Y PUESTA EN USO DE LA BASE DE DATOS
    -- =================================================================================================
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'VJMV_Movement_DB')
    BEGIN
        CREATE DATABASE VJMV_Movement_DB;
        PRINT '>> Base de datos VJMV_Movement_DB creada correctamente.';
    END
    ELSE
    BEGIN
        PRINT '>> La base de datos VJMV_Movement_DB ya existe. Utilizando instancia existente.';
    END
    GO

    USE VJMV_Movement_DB;
    GO

    -- =================================================================================================
    -- SECCIÓN 2: LIMPIEZA PREVENTIVA DE TABLAS (PARA EJECUCIÓN REPETIBLE Y LIMPIA)
    -- =================================================================================================
    IF OBJECT_ID(N'dbo.Productos', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.Productos;
        PRINT '>> Tabla Productos anterior eliminada.';
    END
    GO

    IF OBJECT_ID(N'dbo.Usuarios', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.Usuarios;
        PRINT '>> Tabla Usuarios anterior eliminada.';
    END
    GO

    -- =================================================================================================
    -- SECCIÓN 3: TABLA DE USUARIOS (Módulo de Autenticación / Login Administrativo)
    -- =================================================================================================
    CREATE TABLE dbo.Usuarios
    (
        Id             INT IDENTITY(1,1) NOT NULL,
        NombreCompleto NVARCHAR(100)     NOT NULL,
        Correo         NVARCHAR(120)     NOT NULL,
        Clave          NVARCHAR(255)     NOT NULL,
        Rol            NVARCHAR(30)      NOT NULL DEFAULT N'Administrador',
        Activo         BIT               NOT NULL DEFAULT 1,
        FechaCreacion  DATETIME2         NOT NULL DEFAULT SYSDATETIME(),

        -- Restricciones de integridad
        CONSTRAINT PK_Usuarios PRIMARY KEY (Id),
        CONSTRAINT UQ_Usuarios_Correo UNIQUE (Correo),
        CONSTRAINT CK_Usuarios_Rol CHECK (Rol IN (N'Administrador', N'Gestor', N'Cliente'))
    );
    GO

    -- Índice no agrupado sobre Correo: Acelera las búsquedas en el procedimiento de Login
    CREATE NONCLUSTERED INDEX IX_Usuarios_Correo ON dbo.Usuarios (Correo);
    GO

    -- =================================================================================================
    -- SECCIÓN 4: TABLA DE PRODUCTOS (Catálogo Femenino Deportivo - Estilo AYBL)
    -- =================================================================================================
    CREATE TABLE dbo.Productos
    (
        Id             INT IDENTITY(1,1) NOT NULL,
        Nombre         NVARCHAR(120)     NOT NULL,
        Descripcion    NVARCHAR(400)     NULL,
        Categoria      NVARCHAR(50)      NOT NULL, -- 'Leggings', 'Tops', 'Conjuntos', 'Mochilas', 'Medias', 'Shorts'
        Genero         NVARCHAR(20)      NOT NULL DEFAULT N'Mujer',
        Talla          NVARCHAR(10)      NOT NULL, -- 'XS', 'S', 'M', 'L', 'XL', 'Unica'
        Color          NVARCHAR(40)      NOT NULL,
        Precio         DECIMAL(10,2)     NOT NULL,
        Stock          INT               NOT NULL,
        ImagenUrl      NVARCHAR(500)     NOT NULL, -- Enlace directo a CDN oficial de AYBL
        Activo         BIT               NOT NULL DEFAULT 1, -- Borrado lógico (Soft Delete)
        FechaCreacion  DATETIME2         NOT NULL DEFAULT SYSDATETIME(),

        -- Restricciones de integridad
        CONSTRAINT PK_Productos PRIMARY KEY (Id),
        CONSTRAINT CK_Productos_Precio CHECK (Precio > 0.00),
        CONSTRAINT CK_Productos_Stock CHECK (Stock >= 0),
        CONSTRAINT CK_Productos_Genero CHECK (Genero IN (N'Mujer', N'Unisex'))
    );
    GO

    -- Índices para optimizar el filtrado de productos por categoría y estado activo
    CREATE NONCLUSTERED INDEX IX_Productos_Categoria ON dbo.Productos (Categoria);
    CREATE NONCLUSTERED INDEX IX_Productos_Activo ON dbo.Productos (Activo);
    GO

    -- =================================================================================================
    -- SECCIÓN 5: CARGA INICIAL DE DATOS (SEEDS)
    -- =================================================================================================

    -- 1. Usuario Administrador para acceso al Dashboard y gestión del CRUD
    INSERT INTO dbo.Usuarios (NombreCompleto, Correo, Clave, Rol, Activo)
    VALUES
    (N'Valeria Administradora', N'admin@vjmvmovement.com', N'Admin2026*', N'Administrador', 1);
    GO

    -- 2. Los 6 Productos Femeninos Oficiales (Inspirados en la estética limpia de AYBL)
    INSERT INTO dbo.Productos
    (Nombre, Descripcion, Categoria, Genero, Talla, Color, Precio, Stock, ImagenUrl, Activo)
    VALUES
    -- Producto 1: Leggings
    (
        N'Balance V2 Seamless Leggings',
        N'Diseñados con nuestro tejido elástico sin costuras que moldea y esculpe la figura. Cintura alta acanalada
        que se mantiene en su lugar durante sentadillas o sprints.',
        N'Leggings',
        N'Mujer',
        N'M',
        N'Speckle Black',
        42.00,
        35,
        N'https://www.aybl.com/cdn/shop/products/AYBL_2-11-23_BALANCEV2_SPECKLEBLACK_3470.jpg?v=1699292948&width=800'
        ,
        1
    ),
    -- Producto 2: Tops Deportivos (Sports Bra)
    (
        N'Empower Seamless Sports Bra',
        N'Top deportivo de compresión media confeccionado en punto transpirable. Escote favorecedor, almohadillas
        extraíbles y tirantes anatómicos.',
        N'Tops',
        N'Mujer',
        N'S',
        N'Black Onix',
        32.00,
        40,
        N'https://www.aybl.com/cdn/shop/files/08.05.2025_Womens5021.jpg?v=1753892468&width=800',
        1
    ),
    -- Producto 3: Conjuntos Deportivos
    (
        N'Balance V2 Seamless Set (Top + Leggings)',
        N'Conjunto coordinado de dos piezas en tono rubí. Máximo confort térmico y soporte muscular para
        entrenamientos de fuerza o yoga dinámico.',
        N'Conjuntos',
        N'Mujer',
        N'M',
        N'Rumba Red',
        68.00,
        20,
        N'https://www.aybl.com/cdn/shop/products/AYBL_2-11-23_RUMBAREDBRAANDLEGGINGS_5781.jpg?v=1699292910&width=800'
        ,
        1
    ),
    -- Producto 4: Mochila / Maletín Deportivo
    (
        N'Everyday Matte Gym Bag',
        N'Mochila y maletín deportivo multifuncional con acabado mate impermeable. Incluye compartimento ventilado
        para calzado y múltiples bolsillos para bandas y botella.',
        N'Mochilas',
        N'Unisex',
        N'Unica',
        N'Matte Black',
        45.00,
        25,
        N'https://www.aybl.com/cdn/shop/files/AYBL_31_08_23.jpg?v=1728587805&width=800',
        1
    ),
    -- Producto 5: Medias Deportivas
    (
        N'Everyday Crew Socks (Pack x3)',
        N'Pack de 3 pares de medias deportivas de media caña. Banda elástica en el arco plantar para evitar
        deslizamientos y suela con tejido afelpado.',
        N'Medias',
        N'Mujer',
        N'Unica',
        N'Pure White',
        15.00,
        60,
        N'https://www.aybl.com/cdn/shop/products/trio-image-comp_f6564003-1a60-41c6-8d0a-67d8bf6ca5af.jpg?v=169158518
        5&width=800',
        1
    ),
    -- Producto 6: Shorts Deportivos
    (
        N'Balance V2 Seamless Shorts',
        N'Shorts de compresión sin costuras con tiro alto y longitud ergonómica media pierna. Tejido opaco a prueba
        de sentadillas y tecnología anti-fricción.',
        N'Shorts',
        N'Mujer',
        N'S',
        N'Black Onix',
        30.00,
        45,
        N'https://www.aybl.com/cdn/shop/products/AYBL_2-11-23_BLACK-BALANCE-SHORTS_4745.jpg?v=1699293157&width=800',
        1
    );
    GO

    -- =================================================================================================
    -- SECCIÓN 6: PROCEDIMIENTOS ALMACENADOS (STORED PROCEDURES)
    -- =================================================================================================

    -- -------------------------------------------------------------------------------------------------
    -- SP 1: sp_ValidarLogin
    -- Descripción: Autentica credenciales en el inicio de sesión.
    -- Retorna: Información de la cuenta si el correo y la contraseña coinciden y el usuario está activo.
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_ValidarLogin
        @Correo NVARCHAR(120),
        @Clave  NVARCHAR(255)
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT
            Id,
            NombreCompleto,
            Correo,
            Rol,
            FechaCreacion
        FROM dbo.Usuarios
        WHERE Correo = LTRIM(RTRIM(@Correo))
          AND Clave = @Clave
          AND Activo = 1;
    END;
    GO

    -- -------------------------------------------------------------------------------------------------
    -- SP 2: sp_ListarProductos
    -- Descripción: Devuelve el catálogo completo de productos disponibles y activos.
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_ListarProductos
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT
            Id,
            Nombre,
            Descripcion,
            Categoria,
            Genero,
            Talla,
            Color,
            Precio,
            Stock,
            ImagenUrl,
            Activo,
            FechaCreacion
        FROM dbo.Productos
        WHERE Activo = 1
        ORDER BY Id DESC;
    END;
    GO

    -- -------------------------------------------------------------------------------------------------
    -- SP 3: sp_ObtenerProductoPorId
    -- Descripción: Consulta la información detallada de un producto individual por su ID.
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_ObtenerProductoPorId
        @Id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT
            Id,
            Nombre,
            Descripcion,
            Categoria,
            Genero,
            Talla,
            Color,
            Precio,
            Stock,
            ImagenUrl,
            Activo,
            FechaCreacion
        FROM dbo.Productos
        WHERE Id = @Id;
    END;
    GO

    -- -------------------------------------------------------------------------------------------------
    -- SP 4: sp_InsertarProducto
    -- Descripción: Registra un nuevo producto validando sus campos numéricos y de texto.
    -- Retorna: El registro recién creado con su ID generado mediante SCOPE_IDENTITY().
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_InsertarProducto
        @Nombre      NVARCHAR(120),
        @Descripcion NVARCHAR(400),
        @Categoria   NVARCHAR(50),
        @Genero      NVARCHAR(20),
        @Talla       NVARCHAR(10),
        @Color       NVARCHAR(40),
        @Precio      DECIMAL(10,2),
        @Stock       INT,
        @ImagenUrl   NVARCHAR(500)
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Validaciones de integridad en la capa de datos
        IF (LEN(LTRIM(RTRIM(@Nombre))) = 0)
        BEGIN
            RAISERROR(N'El nombre del producto no puede estar vacío.', 16, 1);
            RETURN;
        END;

        IF (@Precio <= 0.00)
        BEGIN
            RAISERROR(N'El precio debe ser un valor positivo mayor a 0.00.', 16, 1);
            RETURN;
        END;

        IF (@Stock < 0)
        BEGIN
            RAISERROR(N'El stock no puede ser un valor negativo.', 16, 1);
            RETURN;
        END;

        INSERT INTO dbo.Productos
        (
            Nombre, Descripcion, Categoria, Genero, Talla, Color,
            Precio, Stock, ImagenUrl, Activo, FechaCreacion
        )
        VALUES
        (
            LTRIM(RTRIM(@Nombre)),
            LTRIM(RTRIM(@Descripcion)),
            LTRIM(RTRIM(@Categoria)),
            LTRIM(RTRIM(@Genero)),
            LTRIM(RTRIM(@Talla)),
            LTRIM(RTRIM(@Color)),
            @Precio,
            @Stock,
            LTRIM(RTRIM(@ImagenUrl)),
            1,
            SYSDATETIME()
        );

        -- Capturamos el Id autonumérico recién insertado
        DECLARE @NuevoId INT = SCOPE_IDENTITY();

        -- Devolvemos la entidad completa creada
        EXEC dbo.sp_ObtenerProductoPorId @Id = @NuevoId;
    END;
    GO

    -- -------------------------------------------------------------------------------------------------
    -- SP 5: sp_ActualizarProducto
    -- Descripción: Modifica un producto existente tras verificar su existencia.
    -- Retorna: La entidad con los valores actualizados.
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_ActualizarProducto
        @Id          INT,
        @Nombre      NVARCHAR(120),
        @Descripcion NVARCHAR(400),
        @Categoria   NVARCHAR(50),
        @Genero      NVARCHAR(20),
        @Talla       NVARCHAR(10),
        @Color       NVARCHAR(40),
        @Precio      DECIMAL(10,2),
        @Stock       INT,
        @ImagenUrl   NVARCHAR(500)
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Verificar existencia previa
        IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE Id = @Id)
        BEGIN
            RAISERROR(N'El producto especificado no existe.', 16, 1);
            RETURN;
        END;

        IF (@Precio <= 0.00)
        BEGIN
            RAISERROR(N'El precio debe ser mayor a 0.00.', 16, 1);
            RETURN;
        END;

        IF (@Stock < 0)
        BEGIN
            RAISERROR(N'El inventario (stock) no puede ser inferior a 0.', 16, 1);
            RETURN;
        END;

        UPDATE dbo.Productos
        SET
            Nombre      = LTRIM(RTRIM(@Nombre)),
            Descripcion = LTRIM(RTRIM(@Descripcion)),
            Categoria   = LTRIM(RTRIM(@Categoria)),
            Genero      = LTRIM(RTRIM(@Genero)),
            Talla       = LTRIM(RTRIM(@Talla)),
            Color       = LTRIM(RTRIM(@Color)),
            Precio      = @Precio,
            Stock       = @Stock,
            ImagenUrl   = LTRIM(RTRIM(@ImagenUrl))
        WHERE Id = @Id;

        -- Devolvemos el registro con sus modificaciones
        EXEC dbo.sp_ObtenerProductoPorId @Id = @Id;
    END;
    GO

    -- -------------------------------------------------------------------------------------------------
    -- SP 6: sp_EliminarProducto
    -- Descripción: Aplica eliminación lógica (Soft Delete) cambiando Activo a 0.
    -- Retorna: Cantidad de filas afectadas.
    -- -------------------------------------------------------------------------------------------------
    CREATE OR ALTER PROCEDURE dbo.sp_EliminarProducto
        @Id INT
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE Id = @Id)
        BEGIN
            RAISERROR(N'El producto que intenta eliminar no existe en la base de datos.', 16, 1);
            RETURN;
        END;

        UPDATE dbo.Productos
        SET Activo = 0
        WHERE Id = @Id;

        SELECT @@ROWCOUNT AS FilasAfectadas;
    END;
    GO

 -- =================================================================================================
    -- SECCIÓN 7: COMPROBACIÓN INMEDIATA DEL SCRIPT (CONSULTAS DE PRUEBA)
    -- =================================================================================================
    PRINT '>> Comprobando catálogo cargado:';
    EXEC dbo.sp_ListarProductos;

    PRINT '>> Comprobando login con credenciales del Administrador:';
    EXEC dbo.sp_ValidarLogin @Correo = N'admin@vjmvmovement.com', @Clave = N'Admin2026*';
    GO