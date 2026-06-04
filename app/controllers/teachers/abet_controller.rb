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

    def folders_evidences
      @nav_link = 'abet'
      @periods = PeriodService.fetch_all
      @task_types = TaskType.all.order(name: :asc)
      render 'teachers/abet/folders-evidences'
    end

    def folders_evidences_generate
      @nav_link = 'abet'
      abet_resp = AbetService.generate_evidences(params)
      resp = TaskService.create(params, abet_resp, session)

      if resp[:success]
        task = resp[:data]
        redirect_to "/teachers/abet/tasks/#{task.id}"
      else
        flash[:alert] = resp[:message]
        render 'teachers/abet/folders-evidences'
      end
    end

    def show_task
      @nav_link = 'abet'
      @task = Task.find_by(id: params[:id])
      if @task
        render 'teachers/abet/task'
      else
        flash[:alert] = "Tarea no encontrada"
        redirect_to "/teachers/abet"
      end
    end

    def download_evidences
      @nav_link = 'abet'
      task = Task.includes(:user, :task_type, :period).find_by(id: params[:id])
      
      if task && File.exist?(task.zip_path)
        send_file task.zip_path, filename: File.basename(task.zip_path), type: 'application/zip'
      else
        flash[:alert] = "Archivo no encontrado"
        redirect_to "/teachers/abet/tasks/#{params[:id]}"
      end
    end
  end
end

