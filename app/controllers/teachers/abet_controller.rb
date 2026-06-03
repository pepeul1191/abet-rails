require "csv"

module Teachers
  class AbetController < ApplicationController
    layout "dashboard"

    def industry_params
      params.permit(:name, :page, :per_page)
    end

    # Agrega aquí la lógica de tu controlador
    def index
      @nav_link = 'abet'
    end

    def groups_new
      @nav_link = 'abet'
      @periods = PeriodService.fetch_all
      @task_types = TaskType.all.order(name: :asc)
      render 'teachers/abet/new-group'
    end

    def groups_generate
      @nav_link = 'abet'

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
        csv_text = csv_file.read

        csv = CSV.parse(csv_text, headers: true)

        students = csv.map do |row|
          row.to_h
        end
      end

      # =========================
      # 3. Guardar documento en /tmp/abet/timestamp/
      # =========================
      document_file = params[:document]
      document_path = nil

      if document_file.present?
        timestamp_dir = Rails.root.join("tmp", "abet", Time.now.to_i.to_s)

        FileUtils.mkdir_p(timestamp_dir)

        original_extension = File.extname(document_file.original_filename)
        random_name = "#{SecureRandom.hex(10)}#{original_extension}"

        full_path = timestamp_dir.join(random_name)

        File.open(full_path, "wb") do |file|
          file.write(document_file.read)
        end

        document_path = full_path.to_s
      end

      puts '1 +++++++++++++++++++++++++++++++++'
      puts timestamp_dir
      puts '2 +++++++++++++++++++++++++++++++++'

      AbetService.generate_pdfs(students, document_path, timestamp_dir)

      redirect_to '/teachers/abet/groups/new'
    end
  end
end

