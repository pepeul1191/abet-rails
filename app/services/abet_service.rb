require "fileutils"

class AbetService
  def self.generate_pdfs(students, document_path, timestamp_dir)
    pdf_final_name = "MdD Proyecto Rubrica-2026-1"

    # =========================
    # TODO dentro de la misma carpeta
    # =========================
    main_folder = timestamp_dir
    FileUtils.mkdir_p(main_folder)

    puts "\n🚀 Iniciando generación de PDFs"
    puts "📁 Carpeta principal: #{main_folder}"
    puts "=" * 60

    successful = 0
    failed = 0

    puts students

    students.each do |student|
      puts '1 XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'
      puts student["alumno"]

      alumno_name = student["alumno"].to_s.strip
      next if alumno_name.empty?
      puts '2 XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'

      folder_name = sanitize_filename(alumno_name)

      puts "\n📄 Procesando: #{alumno_name}"

      student_folder = File.join(main_folder, folder_name)
      FileUtils.mkdir_p(student_folder)

      puts 'student_folder'
      puts '3 XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'

      temp_docx = File.join(
        main_folder,
        "#{folder_name}_#{pdf_final_name}.docx"
      )

      pdf_path = File.join(
        student_folder,
        "#{folder_name} - #{pdf_final_name}.pdf"
      )

      # 🔥 también aquí: string keys
      reemplazos = student.transform_keys(&:to_s)

      begin
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

    cleanup_temp_folder(main_folder)

    # =========================
    # ZIP TAMBIÉN DENTRO DEL TIMESTAMP
    # =========================
    zip_path = File.join(main_folder, "rubricas.zip")

    zip_folder(main_folder, zip_path)

    puts "\n📦 ZIP generado dentro del folder:"
    puts "   #{zip_path}"
    puts "📏 Tamaño: #{File.size(zip_path)} bytes"

    {
      success: true,
      zip_path: zip_path,
      folder: main_folder,
      successful: successful,
      failed: failed
    }

  rescue => e
    {
      success: false,
      error: e.message
    }
  end

  # =========================
  # HELPERS
  # =========================

  def self.cleanup_temp_folder(folder)
    Dir.rmdir(folder) if Dir.exist?(folder) && Dir.empty?(folder)
  rescue
  end

  def self.sanitize_filename(name)
    name.gsub(/[^0-9A-Za-z.\-]/, "_")
  end

  def self.reemplazar_en_docx(template, output, replacements)
    raise "reemplazar_en_docx no implementado"
  end

  def self.zip_folder(source, destination)
    system("zip -r \"#{destination}\" \"#{source}\"")
  end
end