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

      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:name]

      task_type_id = params[:task_type_id]
      start_date = params[:start_date]
      end_date = params[:end_date]

      page = 1 if page < 1
      per_page = 10 if per_page < 1

      user_id = session[:user][:id]

      result = TaskService.fetch_all(
        user_id: user_id,
        page: page,
        per_page: per_page,
        search_query: search_query,
        task_type_id: task_type_id,
        start_date: start_date,
        end_date: end_date
      )

      puts '1 +++++++++++++++++++++++++++++++++++++++++++++++'
      puts result.inspect
      puts '2 +++++++++++++++++++++++++++++++++++++++++++++++'

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
      render 'teachers/abet/index'
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

