// Script de inicialización de MongoDB
// Este archivo se ejecuta automáticamente cuando se inicia el contenedor de MongoDB

db = db.getSiblingDB('admin');

// Crear la base de datos y usuario principal (ya creados por MONGO_INITDB)

// Cambiar a la base de datos f-sri
db = db.getSiblingDB('f-sri');

// Crear índices para optimización de consultas
print('Creando índices...');

// Índices para la colección de usuarios
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ ruc: 1 });

// Índices para la colección de empresas
db.issuingcompanies.createIndex({ ruc: 1 }, { unique: true });
db.issuingcompanies.createIndex({ userId: 1 });

// Índices para la colección de clientes
db.clients.createIndex({ ruc: 1 });
db.clients.createIndex({ email: 1 });
db.clients.createIndex({ companyId: 1 });

// Índices para la colección de productos
db.products.createIndex({ code: 1 });
db.products.createIndex({ companyId: 1 });

// Índices para la colección de facturas
db.invoices.createIndex({ numero: 1 });
db.invoices.createIndex({ companyId: 1 });
db.invoices.createIndex({ clientId: 1 });
db.invoices.createIndex({ estado: 1 });
db.invoices.createIndex({ fechaEmision: 1 });

// Índices para la colección de detalles de factura
db.invoicedetails.createIndex({ invoiceId: 1 });
db.invoicedetails.createIndex({ productId: 1 });

// Índices para la colección de PDFs
db.invoicepdfs.createIndex({ invoiceId: 1 }, { unique: true });
db.invoicepdfs.createIndex({ companyId: 1 });

// Índices para la colección de tipos de identificación
db.identificationtypes.createIndex({ code: 1 }, { unique: true });

print('✅ Base de datos inicializada correctamente');
print('✅ Índices creados exitosamente');
