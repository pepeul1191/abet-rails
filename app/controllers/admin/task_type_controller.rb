# app/controllers/admin/task_type_controller.rb
module Admin
  class TaskTypeController < ApplicationController
    layout "dashboard"

    # Solo permite el parámetro :name
    def task_type_params
      params.permit(:name)
    end

    # GET /admin/task_type
    def index
      @nav_link = 'master-data'
      
      # Parámetros de paginación
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:name]

      page = 1 if page < 1
      per_page = 10 if per_page < 1

      # Llamada al servicio
      result = TaskTypeService.fetch_all(
        page: page,
        per_page: per_page,
        search_query: search_query
      )

      if result[:success]
        @task_types = result[:data][:task_types]
        @pagination = result[:data][:pagination]
        @search_query = search_query
      else
        @task_types = []
        @pagination = {
          page: page,
          per_page: per_page,
          total_task_types: 0,
          total_pages: 0,
          start_record: 0,
          end_record: 0
        }
        @search_query = search_query
        flash.now[:alert] = result[:message]
      end

      render 'admin/task_type/index'
    end

    # GET /admin/task_type/new
    def new
      @nav_link = 'master-data'
      render 'admin/task_type/new'
    end

    # POST /admin/task_type
    def create
      resp = TaskTypeService.create(task_type_params)
      if resp[:success]
        redirect_to "/admin/task-type/#{resp[:data].id}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/task-type/new"
      end
    end

    # GET /admin/task_type/:id/edit
    def edit
      @nav_link = 'master-data'
      resp = TaskTypeService.fetch_one(params[:id])
      if resp[:success]
        @task_type = resp[:data]
        render 'admin/task_type/edit'
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/task-type/new"
      end
    end

    # PATCH/PUT /admin/task_type/:id
    def update
      resp = TaskTypeService.update(params[:id], task_type_params)
      if resp[:success]
        redirect_to "/admin/task-type/#{params[:id]}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/task-type/#{params[:id]}/edit"
      end
    end

    # DELETE /admin/task_type/:id
    def delete
      resp = TaskTypeService.delete(params[:id])
      if resp[:success]
        redirect_to "/admin/task-type", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/task-type"
      end
    end
  end
end