import { v2 as cloudinary } from 'cloudinary';
import { Readable } from 'stream';
import { IPDFStorageProvider, PDFStorageResponse } from '../../interfaces/pdf-storage.interface';

/**
 * Implementación de almacenamiento de PDFs usando Cloudinary
 *
 * Cloudinary es un servicio de almacenamiento en la nube que permite
 * almacenar, transformar y entregar archivos multimedia.
 *
 * Configuración requerida:
 * - CLOUDINARY_CLOUD_NAME: Nombre de tu cloud en Cloudinary
 * - CLOUDINARY_API_KEY: API Key de Cloudinary
 * - CLOUDINARY_API_SECRET: API Secret de Cloudinary
 */
export class CloudinaryPDFStorage implements IPDFStorageProvider {
  private configured: boolean = false;

  constructor() {
    this.configure();
  }

  /**
   * Configura Cloudinary con las credenciales del entorno
   */
  private configure(): void {
    try {
      cloudinary.config({
        cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'dcksabaod',
        api_key: process.env.CLOUDINARY_API_KEY || '257726425151596',
        api_secret: process.env.CLOUDINARY_API_SECRET || 'z0oBiqSTNcEhVmbMnVD8wf8jrOc',
      });
      this.configured = true;
      console.log('✅ Cloudinary configurado correctamente');
    } catch (error) {
      console.error('❌ Error configurando Cloudinary:', error);
      this.configured = false;
    }
  }

  /**
   * Sube un PDF a Cloudinary
   */
  async upload(pdfBuffer: Buffer, filename: string): Promise<PDFStorageResponse> {
    if (!this.configured) {
      throw new Error('Cloudinary no está configurado correctamente');
    }

    try {
      console.log(`📤 Subiendo PDF a Cloudinary: ${filename}`);

      // Convertir buffer a stream
      const stream = Readable.from(pdfBuffer);

      // Configuración para la subida
      const uploadOptions = {
        resource_type: 'raw' as const,
        format: 'pdf',
        public_id: `facturas/${filename}`,
        folder: 'facturas-electronicas',
        use_filename: true,
        unique_filename: true,
      };

      // Subir a Cloudinary usando Promise
      const result: any = await new Promise((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(uploadOptions, (error, result) => {
          if (error) {
            console.error('❌ Error subiendo a Cloudinary:', error);
            reject(error);
          } else {
            console.log('✅ PDF subido exitosamente a Cloudinary:', result?.secure_url);
            resolve(result);
          }
        });

        stream.pipe(uploadStream);
      });

      return {
        url: result.secure_url,
        publicId: result.public_id,
        size: result.bytes,
        provider: 'cloudinary',
      };
    } catch (error) {
      console.error('❌ Error en CloudinaryPDFStorage.upload:', error);
      throw new Error(`Error subiendo PDF a Cloudinary: ${(error as Error).message}`);
    }
  }

  /**
   * Elimina un PDF de Cloudinary
   */
  async delete(publicId: string): Promise<boolean> {
    try {
      console.log(`🗑️  Eliminando PDF de Cloudinary: ${publicId}`);

      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: 'raw',
      });

      const success = result.result === 'ok';
      if (success) {
        console.log('✅ PDF eliminado de Cloudinary exitosamente');
      } else {
        console.log('⚠️  No se pudo eliminar el PDF de Cloudinary:', result);
      }

      return success;
    } catch (error) {
      console.error('❌ Error eliminando PDF de Cloudinary:', error);
      return false;
    }
  }

  /**
   * Obtiene la URL optimizada de un PDF en Cloudinary
   */
  getPublicUrl(publicId: string): string {
    return cloudinary.url(publicId, {
      resource_type: 'raw',
      format: 'pdf',
      secure: true,
    });
  }

  /**
   * Retorna el nombre del proveedor
   */
  getProviderName(): string {
    return 'cloudinary';
  }

  /**
   * Extrae el public_id de una URL de Cloudinary
   * Utilidad para casos donde solo se tiene la URL
   */
  static extractPublicIdFromUrl(cloudinaryUrl: string): string {
    try {
      const url = new URL(cloudinaryUrl);
      const pathParts = url.pathname.split('/');
      const uploadIndex = pathParts.findIndex((part) => part === 'upload');

      if (uploadIndex === -1 || uploadIndex + 2 >= pathParts.length) {
        throw new Error('URL de Cloudinary inválida');
      }

      // Extraer la parte después de upload/version/
      const publicIdParts = pathParts.slice(uploadIndex + 2);
      return publicIdParts.join('/').replace(/\.pdf$/, '');
    } catch (error) {
      console.error('Error extrayendo public_id de URL:', error);
      throw new Error('No se pudo extraer el public_id de la URL de Cloudinary');
    }
  }
}
