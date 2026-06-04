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
  end
end

