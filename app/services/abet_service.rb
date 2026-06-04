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
      
      # IMPORTANTE: Probar diferentes codificaciones
      csv_text = nil
      
      # Intentar con UTF-8 primero
      begin
        csv_text = csv_content.force_encoding('UTF-8')
        csv_text = csv_text.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      rescue
        # Si falla, intentar con Windows-1252
        begin
          csv_text = csv_content.force_encoding('Windows-1252').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        rescue
          # Último recurso: limpiar caracteres inválidos
          csv_text = csv_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        end
      end
      
      # Asegurarse de que los acentos se corrijan
      # Reemplazar secuencias mal decodificadas
      accent_fixes = {
        'Ã' => 'Á',
        'Ã©' => 'é',
        'Ã­' => 'í',
        'Ã³' => 'ó',
        'Ãº' => 'ú',
        'Ã±' => 'ñ',
        'Ã‘' => 'Ñ',
        'Ã‰' => 'É',
        'Ã“' => 'Ó',
        'Ãš' => 'Ú',
        'Ã' => 'Í',
        'Â' => '',
        'Ã' => 'Í'  # Caso específico para Í
      }
      
      accent_fixes.each do |wrong, correct|
        csv_text.gsub!(wrong, correct)
      end
      
      # Usar símbolos como headers
      csv = CSV.parse(csv_text, headers: true, header_converters: :symbol)
      students = csv.map(&:to_h)
    end

    # =========================
    # 3. Guardar documento en /tmp/abet/{timestamp}/
    # =========================
    document_file = params[:document]
    document_path = nil
    timestamp_dir = nil
    pdf_final_name = nil

    if document_file.present?
      timestamp_dir = Rails.root.join("tmp", "abet", Time.now.to_i.to_s)
      FileUtils.mkdir_p(timestamp_dir)

      original_name = document_file.original_filename
      pdf_final_name = File.basename(original_name, '.*')
      full_path = timestamp_dir.join(original_name)

      File.open(full_path, "wb") do |file|
        file.write(document_file.read)
      end

      document_path = full_path.to_s
    end

    result = nil
    case task_type_id.to_i
    when 1
      result = groups_pdfs(students, document_path, timestamp_dir, pdf_final_name)
    else
      result = build_response(success: false, message: "Tipo de tarea no soportado")
    end
    
    result
  rescue => e
    handle_error("Error al generar las evidencias: #{e.message}", e.backtrace)
  end

  private

  def self.groups_pdfs(students, document_path, timestamp_dir, pdf_final_name)
    main_folder = timestamp_dir
    
    puts "\n🚀 Iniciando generación de PDFs"
    puts "📁 Carpeta principal: #{main_folder}"
    puts "=" * 60

    temp_word_folder = File.join(main_folder, 'temp_word_files')
    FileUtils.mkdir_p(temp_word_folder)

    successful = 0
    failed = 0

    students.each do |student|
      # Obtener y limpiar el nombre del estudiante
      alumno_name_raw = student[:alumno].to_s.strip
      
      # Limpiar caracteres mal decodificados
      alumno_name = fix_encoding(alumno_name_raw)
      
      next if alumno_name.empty?

      folder_name = sanitize_filename(alumno_name)
      
      puts "\n📄 Procesando: #{alumno_name}"
      puts "   📁 Nombre de carpeta: #{folder_name}"
      
      student_folder = File.join(main_folder, folder_name)
      FileUtils.mkdir_p(student_folder)
      
      temp_docx = File.join(temp_word_folder, "#{folder_name}_#{pdf_final_name}.docx")
      pdf_path = File.join(student_folder, "#{folder_name} - #{pdf_final_name}.pdf")
      
      # Preparar reemplazos con valores limpios
      reemplazos = {}
      student.each do |key, value|
        key_clean = fix_encoding(key.to_s)
        value_clean = fix_encoding(value.to_s)
        reemplazos[key_clean] = value_clean
      end
      
      begin
        reemplazar_en_docx(document_path, temp_docx, reemplazos)
        
        system("libreoffice --headless --convert-to pdf --outdir \"#{student_folder}\" \"#{temp_docx}\"")
        
        generated_pdf = File.join(student_folder, "#{folder_name}_#{pdf_final_name}.pdf")
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
    
    # Limpiar carpeta temporal
    begin
      Dir.rmdir(temp_word_folder) if Dir.exist?(temp_word_folder) && Dir.empty?(temp_word_folder)
    rescue
    end
    
    puts "\n" + "=" * 60
    puts "✨ Proceso completado!"
    puts "📊 Resumen:"
    puts "   ✅ Exitosos: #{successful}"
    puts "   ❌ Fallidos: #{failed}"
    puts "📁 Ubicación: #{main_folder}"
    puts "=" * 60
    
    # Comprimir
    puts "\n🗜️  Comprimiendo carpeta..."
    zip_path = File.join(main_folder, "rubricas.zip")
    
    begin
      zip_folder(main_folder, zip_path)
      
      puts "\n" + "=" * 60
      puts "✅ ¡PROCESO COMPLETADO!"
      puts "📦 Archivo ZIP generado: #{zip_path}"
      puts "📏 Tamaño: #{File.size(zip_path)} bytes"
      puts "=" * 60
      
      build_response(
        success: true,
        message: "Evidencias generadas correctamente",
        data: {
          zip_path: zip_path,
          folder: main_folder.to_s,
          total: students.count,
          students: students
        }
      )
    rescue => e
      puts "❌ Error al comprimir: #{e.message}"
      
      build_response(
        success: false,
        message: "Error al comprimir: #{e.message}",
        data: nil
      )
    end
  end

  # =========================
  # FUNCIÓN CRÍTICA: Corregir codificación
  # =========================
  
  def self.fix_encoding(text)
    return '' if text.nil? || text.empty?
    
    result = text.dup
    
    # Mapeo de caracteres mal codificados a correctos
    replacements = {
      'Ã' => 'Í',
      'Ã©' => 'é',
      'Ã­' => 'í', 
      'Ã³' => 'ó',
      'Ãº' => 'ú',
      'Ã±' => 'ñ',
      'Ã‘' => 'Ñ',
      'Ã‰' => 'É',
      'Ã“' => 'Ó',
      'Ãš' => 'Ú',
      'Ã' => 'Í',
      'Ã¡' => 'á',
      'Ã?' => 'í', # Caso genérico
      'BENÃTEZ' => 'BENÍTEZ',
      'ADRIÃN' => 'ADRIÁN',
      'JULIÃN' => 'JULIÁN'
    }
    
    replacements.each do |wrong, correct|
      result.gsub!(wrong, correct)
    end
    
    # Si todavía hay Ã, reemplazar por Í (caso común)
    result.gsub!('Ã', 'Í') if result.include?('Ã')
    
    result
  end

  def self.sanitize_filename(name)
    # Primero limpiar la codificación
    clean_name = fix_encoding(name)
    
    # Reemplazar la coma por espacio (no por _)
    clean_name = clean_name.gsub(',', ' ')
    
    # Reemplazar cualquier otro caracter problemático por _
    clean_name = clean_name.gsub(/[\/\\:*?"<>|]/, '_')
    
    # Reemplazar cualquier secuencia de espacios y/o guiones bajos por un SOLO espacio
    clean_name = clean_name.gsub(/[\s_]+/, ' ')
    
    # Recortar espacios al inicio y final
    clean_name = clean_name.strip
    
    clean_name
  end

  def self.reemplazar_en_docx(input_path, output_path, reemplazos)
    temp_file = Tempfile.new(['temp', '.docx'], binmode: true)

    Zip::File.open(input_path) do |zip_file|
      Zip::OutputStream.open(temp_file.path) do |output_zip|
        zip_file.each do |entry|
          contenido = entry.get_input_stream.read
          
          if entry.name.end_with?('.xml', '.rels')
            begin
              contenido_utf8 = contenido.dup.force_encoding('UTF-8')
              unless contenido_utf8.valid_encoding?
                contenido_utf8 = contenido_utf8.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
              end
              
              reemplazos.each do |clave, valor|
                placeholder = "{{#{clave}}}"
                valor_limpio = fix_encoding(valor.to_s)
                contenido_utf8.gsub!(placeholder, valor_limpio)
              end
              
              output_zip.put_next_entry(entry.name)
              output_zip.write(contenido_utf8.force_encoding('ASCII-8BIT'))
            rescue => e
              output_zip.put_next_entry(entry.name)
              output_zip.write(contenido)
            end
          else
            output_zip.put_next_entry(entry.name)
            output_zip.write(contenido)
          end
        end
      end
    end

    temp_file.close
    FileUtils.cp(temp_file.path, output_path)
    temp_file.unlink
  end

  def self.zip_folder(folder_path, zip_path)
    puts "   📦 Comprimiendo carpeta: #{File.basename(folder_path)}"
    
    entries = Dir.glob(File.join(folder_path, '**', '*'))
    
    Zip::File.open(zip_path, create: true) do |zipfile|
      entries.each do |file|
        next if File.directory?(file)
        
        relative_path = file.sub("#{folder_path}/", '')
        zipfile.add(relative_path, file)
      end
    end
    
    puts "   ✅ ZIP creado: #{File.basename(zip_path)}"
    puts "   📦 Tamaño: #{File.size(zip_path)} bytes"
  end
end