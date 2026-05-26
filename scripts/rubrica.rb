require 'csv'
require 'zip'
require 'tempfile'
require 'fileutils'
require 'libreconv'

def sanitize_filename(name)
  # Reemplazar caracteres problemáticos por guiones bajos
  name.gsub(/[,\/\\:*?"<>|]/, '_')
      .gsub(/\s+/, '_')  # Reemplazar espacios por _
      .gsub(/_+/, '_')   # Reemplazar múltiples _ por uno solo
      .strip
end

def reemplazar_en_docx(input_path, output_path, reemplazos)
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
              valor_limpio = valor.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
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

def get_students
  csv_data = CSV.read('alumnos.csv', headers: true, header_converters: :symbol)
  csv_data.map(&:to_h)
end

def zip_folder(folder_path, zip_path)
  puts "   📦 Comprimiendo carpeta: #{File.basename(folder_path)}"
  
  # Método correcto para rubyzip 3.3.0
  entries = Dir.glob(File.join(folder_path, '**', '*'))
  
  Zip::File.open(zip_path, create: true) do |zipfile|
    entries.each do |file|
      next if File.directory?(file)
      
      # Obtener la ruta relativa dentro de la carpeta
      relative_path = file.sub("#{folder_path}/", '')
      zipfile.add(relative_path, file)
    end
  end
  
  puts "   ✅ ZIP creado: #{File.basename(zip_path)}"
  puts "   📦 Tamaño: #{File.size(zip_path)} bytes"
end

def generate_pdfs
  pdf_final_name = 'MdD Proyecto Rubrica-2026-1'
  students = get_students()
  
  timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
  main_folder = File.join('tmp', "rubricas_#{timestamp}")
  FileUtils.mkdir_p(main_folder)
  
  puts "\n🚀 Iniciando generación de PDFs"
  puts "📁 Carpeta principal: #{main_folder}"
  puts "=" * 60

  temp_word_folder = File.join(main_folder, 'temp_word_files')
  FileUtils.mkdir_p(temp_word_folder)

  successful = 0
  failed = 0

  students.each do |student|
    alumno_name = student[:alumno].to_s.strip
    next if alumno_name.empty?

    folder_name = sanitize_filename(alumno_name)
    
    puts "\n📄 Procesando: #{alumno_name}"
    
    student_folder = File.join(main_folder, folder_name)
    FileUtils.mkdir_p(student_folder)
    
    temp_docx = File.join(temp_word_folder, "#{folder_name}_#{pdf_final_name}.docx")
    pdf_path = File.join(student_folder, "#{folder_name} - #{pdf_final_name}.pdf")
    
    reemplazos = {}
    student.each do |key, value|
      reemplazos[key.to_s] = value.to_s
    end
    
    begin
      reemplazar_en_docx('template.docx', temp_docx, reemplazos)
      
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
  
  # Comprimir la carpeta principal
  puts "\n🗜️  Comprimiendo carpeta..."
  zip_path = File.join('tmp', "rubricas_#{timestamp}.zip")
  
  begin
    zip_folder(main_folder, zip_path)
    
    puts "\n" + "=" * 60
    puts "✅ ¡PROCESO COMPLETADO!"
    puts "📦 Archivo ZIP generado: #{zip_path}"
    puts "📏 Tamaño: #{File.size(zip_path)} bytes"
    puts "=" * 60
  rescue => e
    puts "❌ Error al comprimir: #{e.message}"
    puts "   💡 La carpeta original se mantiene en: #{main_folder}"
  end
end

generate_pdfs