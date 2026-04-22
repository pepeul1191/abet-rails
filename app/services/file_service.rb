# app/services/file_service.rb
class FileService < ApplicationService
  def self.upload_user_image(file, user_id: nil)
    base_upload_dir = 'public/users'.freeze
    max_file_size = 5.megabytes
    allowed_types = %w[image/jpeg image/jpg image/png].freeze

    begin
      # Validar que exista el archivo
      unless file.present?
        return build_response(
          success: false,
          message: "No se proporcionó ningún archivo",
          status: :bad_request
        )
      end

      # Validar tipo de archivo
      unless allowed_types.include?(file.content_type)
        return build_response(
          success: false,
          message: "Formato no válido. Solo se permiten JPG, JPEG y PNG",
          status: :bad_request
        )
      end

      # Validar tamaño
      if file.size > max_file_size
        return build_response(
          success: false,
          message: "El archivo excede el tamaño máximo de 5MB",
          status: :bad_request
        )
      end

      # Crear directorio si no existe
      upload_dir = Rails.root.join(base_upload_dir)
      FileUtils.mkdir_p(upload_dir) unless Dir.exist?(upload_dir)

      # Generar nombre único para el archivo
      extension = File.extname(file.original_filename)
      unique_filename = "#{SecureRandom.hex(20)}#{extension}"
      file_path = upload_dir.join(unique_filename)

      # Guardar el archivo
      File.open(file_path, 'wb') do |f|
        f.write(file.read)
      end

      # Construir URL pública
      image_url = "/users/#{unique_filename}"

      # Actualizar usuario si se proporciona user_id
      if user_id.present? && user_id != 'null'
        user = User.find_by(id: user_id)
        if user
          # Eliminar imagen anterior si existe
          if user.image_url.present?
            old_image_path = Rails.root.join('public', user.image_url.gsub(/^\//, ''))
            File.delete(old_image_path) if File.exist?(old_image_path)
          end
          user.update(image_url: image_url)
        end
      end

      build_response(
        success: true,
        message: "Imagen subida correctamente",
        data: {
          image_url: image_url,
          filename: unique_filename,
          size: file.size
        }
      )
    rescue => e
      handle_error("Error al subir la imagen: #{e.message}", e.backtrace)
    end
  end

  private

  def self.build_response(success:, message:, data: nil, status: nil)
    response = { success: success, message: message }
    response[:data] = data if data
    response[:status] = status if status
    response
  end
end