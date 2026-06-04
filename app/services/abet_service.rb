# app/services/abet_service.rb
require 'csv'
require 'zip'
require 'tempfile'
require 'fileutils'
require 'libreconv'

class AbetService < ApplicationService
  def self.generate_evidences(params)
    # =========================
    # 1. Leer parámetros básicos
    # =========================
    name = params[:name]
    description = params[:description]
    task_type_id = params[:task_type_id]
    period_id = params[:period_id]

    # =========================
    # 2. Leer archivo CSV
    # =========================
    csv_file = params[:data]
    students = []

    if csv_file.present?
      csv_content = csv_file.read
      
      # Intentar detectar y corregir codificación
      begin
        # Primero intentar como Windows-1252 (común en Excel)
        csv_text = csv_content.force_encoding('Windows-1252').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      rescue
        # Si falla, usar UTF-8 y limpiar caracteres inválidos
        csv_text = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end

      csv = CSV.parse(csv_text, headers: true)
      students = csv.map(&:to_h)
      
      # Limpiar codificación de todos los valores del CSV
      students.each do |student|
        student.each do |key, value|
          student[key] = normalize_encoding(value.to_s) if value.is_a?(String)
        end
      end
    end

    # =========================
    # 3. Guardar documento en /tmp/abet/{timestamp}/
    # =========================
    document_file = params[:document]
    document_path = nil
    timestamp_dir = nil

    if document_file.present?
      timestamp_dir = Rails.root.join("tmp", "abet", Time.now.to_i.to_s)
      FileUtils.mkdir_p(timestamp_dir)

      original_name = document_file.original_filename
      full_path = timestamp_dir.join(original_name)

      File.open(full_path, "wb") do |file|
        file.write(document_file.read)
      end

      document_path = full_path.to_s
    end

    case task_type_id.to_i
    when 1 # Trabajo Grupal
      return groups_pdfs(students, document_file, timestamp_dir, document_path)
    when "aprobado"
      puts "Aprobado"
    when "rechazado"
      puts "Rechazado"
    end
  rescue => e
    handle_error("Error al generar las evidencias: #{e.message}", e.backtrace)
  end

  private

  def self.groups_pdfs(students, document_file, timestamp_dir, document_path)
    pdf_final_name = document_file.original_filename
    
    # =========================
    # Carpeta principal dentro del timestamp
    # =========================
    main_folder = timestamp_dir
    
    puts "\n🚀 Iniciando generación de PDFs"
    puts "📁 Carpeta principal: #{main_folder}"
    puts "=" * 60

    successful = 0
    failed = 0

    students.each do |student|
      # Obtener nombre del estudiante y normalizarlo
      student_name_raw = student["alumno"]
      student_name = normalize_encoding(student_name_raw)
      
      puts "\n📝 Nombre original: #{student_name_raw}"
      puts "📝 Nombre normalizado: #{student_name}"
      
      next if student_name.empty?

      # Crear nombre de carpeta (reemplazar coma por espacio, CONSERVAR acentos)
      folder_name = create_folder_name(student_name)

      puts "📁 Nombre de carpeta: #{folder_name}"

      student_folder = File.join(main_folder, folder_name)
      FileUtils.mkdir_p(student_folder)

      temp_docx = File.join(
        main_folder,
        "#{folder_name}_#{pdf_final_name}.docx"
      )

      pdf_path = File.join(
        student_folder,
        "#{folder_name} - #{pdf_final_name}.pdf"
      )

      # Preparar reemplazos con codificación normalizada
      reemplazos = {}
      student.each do |key, value|
        reemplazos[normalize_encoding(key.to_s)] = normalize_encoding(value.to_s)
      end

      begin
        # Usar document_path en lugar de document_file.path
        reemplazar_en_docx(document_path, temp_docx, reemplazos)

        system(
          "libreoffice --headless --convert-to pdf --outdir \"#{student_folder}\" \"#{temp_docx}\""
        )

        generated_pdf = File.join(
          student_folder,
          "#{File.basename(temp_docx, '.docx')}.pdf"
        )

        if File.exist?(generated_pdf)
          File.rename(generated_pdf, pdf_path) if generated_pdf != pdf_path
          puts "   ✅ PDF generado exitosamente"
          successful += 1
        else
          puts "   ❌ No se generó el PDF"
          failed += 1
        end

        File.delete(temp_docx) if File.exist?(temp_docx)

      rescue => e
        puts "   ❌ Error: #{e.message}"
        failed += 1
      end
    end

    puts "\n📊 Resumen:"
    puts "   ✅ Exitosos: #{successful}"
    puts "   ❌ Fallidos: #{failed}"
    puts "   📁 Carpeta: #{main_folder}"

    # =========================
    # Generar ZIP dentro del mismo folder
    # =========================
    zip_path = File.join(main_folder, "rubricas.zip")
    zip_folder(main_folder, zip_path)

    puts "\n📦 ZIP generado:"
    puts "   📍 #{zip_path}"
    puts "   📏 Tamaño: #{File.size(zip_path)} bytes"
    
    build_response(
      success: true,
      message: "Evidencias generadas correctamente",
      data: {
        zip_path: zip_path,
        folder: main_folder,
        successful: successful,
        failed: failed
      }
    )
  rescue => e
    handle_error("Error al generar las evidencias: #{e.message}", e.backtrace)
  end

  # =========================
  # HELPERS DE CODIFICACIÓN
  # =========================

  def self.normalize_encoding(text)
    return '' if text.nil?
    
    begin
      # Forzar a UTF-8 limpiando bytes inválidos
      utf8_text = text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      
      # Corregir casos comunes de doble codificación
      # Específicamente para el caso de Í que se convierte en Ã
      if utf8_text.include?('Ã')
        utf8_text = utf8_text.gsub('Ã', 'Í')
      end
      
      utf8_text
    rescue => e
      # Si todo falla, devolver el texto original limpiado
      text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end
  end

  def self.create_folder_name(name)
    # Crear nombre de carpeta: CONSERVAR acentos, solo reemplazar coma por espacio
    return '' if name.nil? || name.empty?
    
    # Normalizar primero
    name = normalize_encoding(name)
    
    # Reemplazar coma por espacio
    name = name.gsub(',', ' ')
    
    # Reemplazar espacios múltiples por uno solo
    name = name.gsub(/\s+/, ' ')
    
    # Recortar espacios al inicio y final
    name = name.strip
    
    # Si el nombre está vacío después de limpiar, usar un default
    if name.empty?
      name = "estudiante_sin_nombre"
    end
    
    name
  end

  def self.sanitize_filename(name)
    # Solo para nombres de archivo, no para carpetas
    # Reemplazar caracteres problemáticos para sistemas de archivos
    name = name.gsub(/[\/\\:*?"<>|]/, '_')
    name = name.gsub(/\s+/, ' ')
    name.strip
  end

  # =========================
  # HELPERS DE DOCX
  # =========================

  def self.reemplazar_en_docx(input_path, output_path, reemplazos)
    temp_file = Tempfile.new(['temp', '.docx'], binmode: true)

    # Limpiar y normalizar todos los reemplazos antes de procesar
    reemplazos_limpios = {}
    reemplazos.each do |clave, valor|
      clave_limpia = normalize_encoding(clave.to_s)
      valor_limpio = normalize_encoding(valor.to_s)
      reemplazos_limpios[clave_limpia] = valor_limpio
    end

    Zip::File.open(input_path) do |zip_file|
      Zip::OutputStream.open(temp_file.path) do |output_zip|
        zip_file.each do |entry|
          contenido = entry.get_input_stream.read
          
          if entry.name.end_with?('.xml', '.rels')
            begin
              # Intentar procesar como UTF-8
              contenido_utf8 = contenido.dup.force_encoding('UTF-8')
              unless contenido_utf8.valid_encoding?
                contenido_utf8 = contenido_utf8.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
              end
              
              # Realizar todos los reemplazos
              reemplazos_limpios.each do |clave, valor|
                placeholder = "{{#{clave}}}"
                contenido_utf8.gsub!(placeholder, valor)
              end
              
              output_zip.put_next_entry(entry.name)
              output_zip.write(contenido_utf8.force_encoding('ASCII-8BIT'))
            rescue => e
              # Si falla, escribir el contenido original
              puts "   ⚠️ Error procesando #{entry.name}: #{e.message}"
              output_zip.put_next_entry(entry.name)
              output_zip.write(contenido)
            end
          else
            # Archivos no XML se copian tal cual
            output_zip.put_next_entry(entry.name)
            output_zip.write(contenido)
          end
        end
      end
    end

    temp_file.close
    FileUtils.cp(temp_file.path, output_path)
    temp_file.unlink
  rescue => e
    raise "Error al reemplazar en docx: #{e.message}"
  end

  # =========================
  # HELPERS DE ARCHIVOS
  # =========================

  def self.zip_folder(source, destination)
    # Verificar que la carpeta origen existe
    unless Dir.exist?(source)
      raise "La carpeta origen no existe: #{source}"
    end
    
    # Cambiar al directorio origen y crear el zip
    Dir.chdir(source) do
      # Usar el comando zip de sistema (más confiable)
      system("zip -r \"#{destination}\" . > /dev/null 2>&1")
      
      unless File.exist?(destination)
        # Fallback: usar RubyZip si el comando falla
        require 'zip'
        Zip::File.open(destination, Zip::File::CREATE) do |zipfile|
          Dir[File.join('.', '**', '**')].each do |file|
            next if File.directory?(file)
            zipfile.add(file, file)
          end
        end
      end
    end
  end

  def self.cleanup_temp_folder(folder)
    return unless Dir.exist?(folder)
    
    # Eliminar archivos temporales .docx
    Dir.glob(File.join(folder, "*.docx")).each do |temp_file|
      File.delete(temp_file) if File.exist?(temp_file)
    end
    
    # Eliminar carpetas vacías
    Dir.glob(File.join(folder, "*")).each do |subfolder|
      if File.directory?(subfolder) && Dir.empty?(subfolder)
        Dir.rmdir(subfolder)
      end
    end
    
    # Eliminar la carpeta principal si está vacía
    if Dir.exist?(folder) && Dir.empty?(folder)
      Dir.rmdir(folder)
    end
  rescue => e
    puts "   ⚠️ Error limpiando carpeta temporal: #{e.message}"
  end
end