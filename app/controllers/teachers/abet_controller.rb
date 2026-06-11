# app/controllers/teachers/abet_controller.rb
require "csv"

module Teachers
  class AbetController < ApplicationController
    layout "dashboard"

    def industry_params
      params.permit(:name, :page, :per_page)
    end

    # Agrega aquí la lógica de tu controlador
    def index
      @title = "ABET - Rubricas y Folders"
      @nav_link = "abet"
      @abet_options = [
        {
          title: "Carpetas de alumnos",
          description: "Generación de carpetas con los nombres de los alumnos.",
          image: "/img/abet-colaborative.png",
          url: "/teachers/abet/folders",
          button_class: "btn-primary",
          icon: "fa-folder",
          tags: [
            "PDF evaluaciones",
            "CSV alumnos"
          ]
        },
        {
          title: "Folder con Evidencias",
          description: "Generación de folders con evidencias.",
          image: "/img/abet-colaborative.png",
          url: "/teachers/abet/folders-evidences",
          button_class: "btn-primary",
          icon: "fa-folder-open",
          tags: [
            "Rúbrica Word",
            "CSV alumnos"
          ]
        },
        {
          title: "Partir PDF",
          description: "Generación de pdfs por alumno a partir de PDF consolidado.",
          image: "/img/abet-colaborative.png",
          url: "/teachers/abet/split-pdf",
          button_class: "btn-primary",
          icon: "fa-folder-open",
          tags: [
            "PDF consolidado",
            "CSV alumnos"
          ]
        }
      ]

      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:name]

      task_type_id = params[:task_type_id]
      start_date = params[:start_date]
      end_date = params[:end_date]

      page = 1 if page < 1
      per_page = 10 if per_page < 1

      user_id = session["user"]["id"]

      result = TaskService.fetch_all(
        user_id: user_id,
        page: page,
        per_page: per_page,
        search_query: search_query,
        task_type_id: task_type_id,
        start_date: start_date,
        end_date: end_date
      )

      if result[:success]
        @tasks = result[:data][:tasks]
        @pagination = result[:data][:pagination]
        @search_query = search_query
        @task_type_id = task_type_id
        @start_date = start_date
        @end_date = end_date
      else
        @tasks = []
        @pagination = { page: page, per_page: per_page, total_tasks: 0, total_pages: 0, start_record: 0, end_record: 0 }
        flash.now[:alert] = result[:message]
      end

      @task_types = TaskType.all
      render "teachers/abet/index"
    end

    def folders_evidences
      @title = "Evidencias ABET - Rubricas y Folders"
      @nav_link = "abet"
      @periods = PeriodService.fetch_all
      @task_types = TaskType.all.order(name: :asc)
      render "teachers/abet/folders-evidences"
    end

    def folders_evidences_generate
      @title = "Generar Evidencias ABET"
      @nav_link = "abet"
      abet_resp = AbetService.generate_evidences(params)
      resp = TaskService.create(params, abet_resp, session)

      if resp[:success]
        task = resp[:data]
        redirect_to "/teachers/abet/tasks/#{task.id}"
      else
        @nav_link = "abet"
        @periods = PeriodService.fetch_all
        @task_types = TaskType.all.order(name: :asc)
        flash[:alert] = resp[:message]
        render "teachers/abet/folders-evidences"
      end
    end

    def show_task
      @title = "Tareas ABET Ejecutadas"
      @nav_link = "abet"
      
      # Obtener el ID del usuario de la sesión
      user_id = session[:user]&.dig('id')
      
      # Llamar al servicio para buscar la tarea
      result = TaskService.find_task_by_id_for_user(params[:id], user_id)
      
      if result[:success]
        @task = result[:data]
        render "teachers/abet/task"
      elsif result[:message].include?("no encontrada")
        render "errors/not_found", layout: "blank", status: :not_found
      else
        @error_message = result[:message]
        @error_return_link = "/teachers/abet"
        render "errors/error", layout: "blank", status: :not_found
      end
    end

    def download_evidences
      @nav_link = "abet"
      task = Task.includes(:user, :task_type, :period).find_by(id: params[:id])

      if task && File.exist?(task.zip_path)
        send_file task.zip_path, filename: File.basename(task.zip_path), type: "application/zip"
      else
        flash[:alert] = "Archivo no encontrado"
        redirect_to "/teachers/abet/tasks/#{params[:id]}"
      end
    end

    def folders
      @nav_link = "abet"
      @title = "Crear Folder de Alumnos"
      @periods = PeriodService.fetch_all
      @task_types = TaskType.all.order(name: :asc)
      render "teachers/abet/folders"
    end

    def folders_generate
      @nav_link = "abet"
      abet_resp = AbetService.generate_folders(params)
      resp = TaskService.create(params, abet_resp, session)

      if resp[:success]
        task = resp[:data]
        redirect_to "/teachers/abet/tasks/#{task.id}"
      else
        @nav_link = "abet"
        @periods = PeriodService.fetch_all
        @task_types = TaskType.all.order(name: :asc)
        flash[:alert] = resp[:message]
        render "teachers/abet/folders"
      end
    end

    def delete
      resp = TaskService.delete(params[:id])

      if resp[:success]
        redirect_to "/teachers/abet", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/teachers/abet"
      end
    end

    def split_pdf
      @nav_link = "abet"
      @title = "Partir PDF de Evidencias"
      @periods = PeriodService.fetch_all
      @task_types = TaskType.all.order(name: :asc)
      render "teachers/abet/split_pdf"
    end

    def split_pdf_generate
      @nav_link = "abet"
      abet_resp = AbetService.generate_split_pdf(params)
      resp = TaskService.create(params, abet_resp, session)

      if resp[:success]
        task = resp[:data]
        redirect_to "/teachers/abet/tasks/#{task.id}"
      else
        @nav_link = "abet"
        @periods = PeriodService.fetch_all
        @task_types = TaskType.all.order(name: :asc)
        flash[:alert] = resp[:message]
        render "teachers/abet/split_pdf"
      end
    end
  end
end
