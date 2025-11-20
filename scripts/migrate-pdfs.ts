/**
 * Script de migración de PDFs
 *
 * Este script migra PDFs almacenados como buffers en MongoDB
 * al nuevo sistema de almacenamiento (Cloudinary, Local, etc.)
 *
 * Uso:
 * ```bash
 * # Con ts-node
 * npx ts-node scripts/migrate-pdfs.ts
 *
 * # Compilado
 * npm run build && node dist/scripts/migrate-pdfs.js
 * ```
 *
 * Opciones de ambiente:
 * - DRY_RUN=true - Solo muestra lo que haría sin hacer cambios
 * - BATCH_SIZE=50 - Cantidad de PDFs a procesar por lote
 */

import mongoose from 'mongoose';
import InvoicePDF from '../src/models/InvoicePDF';
import { PDFStorageFactory } from '../src/services/storage';

interface MigrationStats {
  total: number;
  migrated: number;
  failed: number;
  skipped: number;
  errors: Array<{ claveAcceso: string; error: string }>;
}

/**
 * Conecta a la base de datos
 */
async function connectDB(): Promise<void> {
  const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/facturacion_sri';

  try {
    await mongoose.connect(mongoUri);
    console.log('✅ Conectado a MongoDB');
  } catch (error) {
    console.error('❌ Error conectando a MongoDB:', error);
    throw error;
  }
}

/**
 * Encuentra PDFs antiguos que necesitan migración
 */
async function findOldPDFs(limit: number = 0): Promise<any[]> {
  console.log('\n🔍 Buscando PDFs antiguos con buffer...');

  // Buscar documentos que tienen pdf_buffer pero no tienen pdf_url
  const query: any = {
    $or: [
      { pdf_buffer: { $exists: true, $ne: null } },
      { pdf_url: { $exists: false } },
      { pdf_url: '' },
    ],
  };

  const pdfs = limit > 0 ? await InvoicePDF.find(query).limit(limit) : await InvoicePDF.find(query);

  console.log(`📊 Encontrados ${pdfs.length} PDFs para migrar`);

  return pdfs;
}

/**
 * Migra un PDF individual
 */
async function migrateSinglePDF(pdf: any, storage: any, dryRun: boolean): Promise<boolean> {
  try {
    console.log(`\n📄 Procesando: ${pdf.claveAcceso}`);

    // Verificar que tenga buffer
    if (!pdf.pdf_buffer || pdf.pdf_buffer.length === 0) {
      console.log('  ⚠️  Sin buffer, buscando archivo local...');

      // Si tiene pdf_path, intentar leer el archivo
      if (pdf.pdf_path) {
        const fs = require('fs');
        if (fs.existsSync(pdf.pdf_path)) {
          pdf.pdf_buffer = fs.readFileSync(pdf.pdf_path);
          console.log(`  ✅ Archivo leído desde: ${pdf.pdf_path}`);
        } else {
          console.log(`  ❌ Archivo no encontrado: ${pdf.pdf_path}`);
          return false;
        }
      } else {
        console.log('  ⏭️  Saltando - sin buffer ni ruta');
        return false;
      }
    }

    console.log(`  📦 Tamaño del buffer: ${(pdf.pdf_buffer.length / 1024).toFixed(2)} KB`);

    if (dryRun) {
      console.log('  🏃 DRY RUN - No se realizarán cambios');
      return true;
    }

    // Generar nombre de archivo
    const filename = pdf.pdf_path
      ? pdf.pdf_path.split('/').pop()?.replace('.pdf', '') || `factura_${pdf.factura_id}`
      : `factura_${pdf.factura_id}`;

    // Subir al nuevo sistema
    console.log(`  ⬆️  Subiendo a ${storage.getProviderName()}...`);
    const result = await storage.upload(pdf.pdf_buffer, filename);

    console.log(`  ✅ Subido exitosamente`);
    console.log(`     URL: ${result.url}`);
    console.log(`     Provider: ${result.provider}`);
    console.log(`     Public ID: ${result.publicId}`);

    // Actualizar el documento en MongoDB
    pdf.pdf_url = result.url;
    pdf.pdf_public_id = result.publicId;
    pdf.pdf_provider = result.provider;

    // Eliminar el buffer para liberar espacio
    pdf.pdf_buffer = undefined;

    // Guardar cambios
    await pdf.save();

    console.log(`  💾 Actualizado en MongoDB`);

    return true;
  } catch (error) {
    console.error(`  ❌ Error migrando ${pdf.claveAcceso}:`, error);
    throw error;
  }
}

/**
 * Migra todos los PDFs
 */
async function migrateAllPDFs(): Promise<MigrationStats> {
  const stats: MigrationStats = {
    total: 0,
    migrated: 0,
    failed: 0,
    skipped: 0,
    errors: [],
  };

  const dryRun = process.env.DRY_RUN === 'true';
  const batchSize = parseInt(process.env.BATCH_SIZE || '50', 10);

  console.log('\n⚙️  Configuración:');
  console.log(`   Modo: ${dryRun ? 'DRY RUN (sin cambios)' : 'PRODUCCIÓN'}`);
  console.log(`   Tamaño de lote: ${batchSize}`);
  console.log(`   Proveedor: ${process.env.PDF_STORAGE_PROVIDER || 'local'}`);

  // Obtener el proveedor de almacenamiento
  const storage = PDFStorageFactory.create();
  console.log(`   ✅ Storage provider inicializado: ${storage.getProviderName()}`);

  // Buscar PDFs para migrar
  const pdfs = await findOldPDFs();
  stats.total = pdfs.length;

  if (stats.total === 0) {
    console.log('\n✅ No hay PDFs para migrar');
    return stats;
  }

  console.log('\n🚀 Iniciando migración...\n');

  // Procesar en lotes
  for (let i = 0; i < pdfs.length; i++) {
    const pdf = pdfs[i];

    try {
      const success = await migrateSinglePDF(pdf, storage, dryRun);

      if (success) {
        stats.migrated++;
      } else {
        stats.skipped++;
      }
    } catch (error) {
      stats.failed++;
      stats.errors.push({
        claveAcceso: pdf.claveAcceso,
        error: (error as Error).message,
      });
    }

    // Mostrar progreso
    if ((i + 1) % 10 === 0 || i === pdfs.length - 1) {
      console.log(
        `\n📊 Progreso: ${i + 1}/${pdfs.length} (${Math.round(((i + 1) / pdfs.length) * 100)}%)`,
      );
      console.log(`   ✅ Migrados: ${stats.migrated}`);
      console.log(`   ⏭️  Saltados: ${stats.skipped}`);
      console.log(`   ❌ Fallidos: ${stats.failed}`);
    }

    // Pausa entre lotes para no sobrecargar
    if ((i + 1) % batchSize === 0 && i < pdfs.length - 1) {
      console.log(`\n⏸️  Pausa de 2 segundos...`);
      await new Promise((resolve) => setTimeout(resolve, 2000));
    }
  }

  return stats;
}

/**
 * Muestra el resumen final
 */
function showSummary(stats: MigrationStats, startTime: number): void {
  const duration = ((Date.now() - startTime) / 1000).toFixed(2);

  console.log('\n' + '='.repeat(60));
  console.log('📊 RESUMEN DE MIGRACIÓN');
  console.log('='.repeat(60));
  console.log(`Total de PDFs encontrados: ${stats.total}`);
  console.log(`✅ Migrados exitosamente:  ${stats.migrated}`);
  console.log(`⏭️  Saltados:               ${stats.skipped}`);
  console.log(`❌ Fallidos:               ${stats.failed}`);
  console.log(`⏱️  Duración:               ${duration}s`);

  if (stats.errors.length > 0) {
    console.log('\n❌ ERRORES:');
    stats.errors.forEach((err, idx) => {
      console.log(`${idx + 1}. ${err.claveAcceso}: ${err.error}`);
    });
  }

  console.log('='.repeat(60));

  if (stats.failed > 0) {
    console.log('\n⚠️  La migración completó con errores');
    process.exit(1);
  } else if (stats.migrated === 0) {
    console.log('\n✅ No había PDFs para migrar');
    process.exit(0);
  } else {
    console.log('\n✅ Migración completada exitosamente');
    process.exit(0);
  }
}

/**
 * Main
 */
async function main() {
  console.log('🚀 SCRIPT DE MIGRACIÓN DE PDFs');
  console.log('================================\n');

  const startTime = Date.now();

  try {
    // Conectar a MongoDB
    await connectDB();

    // Ejecutar migración
    const stats = await migrateAllPDFs();

    // Mostrar resumen
    showSummary(stats, startTime);
  } catch (error) {
    console.error('\n❌ Error fatal en la migración:', error);
    process.exit(1);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Desconectado de MongoDB');
  }
}

// Ejecutar
if (require.main === module) {
  main();
}

export { migrateAllPDFs, migrateSinglePDF };
