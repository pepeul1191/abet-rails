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
      abet_resp = AbetService.generate_evidences(params)
      resp = TastService.create(params, abet_resp)

      if resp[:success]
        #@user = resp[:data]
        redirect_to '/teachers/abet'
      else
        flash[:alert] = resp[:message]
        redirect_to '/teachers/abet/groups/new'
      end
    end
  end
end

