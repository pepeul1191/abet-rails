# app/controllers/admin/specialism_controller.rb
module Admin
  class SpecialismController < ApplicationController
    layout "dashboard"

    def specialism_params
      params.permit(:name)
    end
    # Agrega aquí la lógica de tu controlador
    def index2
      @nav_link = "master-data"
      result = SpecialismService.fetch_all

      if result[:success]
        @specialisms = result[:data]
      else
        @specialisms = []
        flash.now[:alert] = result[:message]
      end

      render "admin/specialism/index"
    end

    def index
      @nav_link = "master-data"

      # Obtener parámetros de la URL
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:name]

      # Validar que no sean valores negativos o cero
      page = 1 if page < 1
      per_page = 10 if per_page < 1

      # Llamar al servicio con paginación
      result = SpecialismService.fetch_all(page: page, per_page: per_page, search_query: search_query)

      if result[:success]
        @specialisms = result[:data][:specialisms]
        @pagination = result[:data][:pagination]
        @search_query = search_query
      else
        @specialisms = []
        @pagination = {
          page: page,
          per_page: per_page,
          total_specialisms: 0,
          total_pages: 0,
          start_record: 0,
          end_record: 0
        }
        @search_query = search_query
        flash.now[:alert] = result[:message]
      end

      render "admin/specialism/index"
    end


    def new
      @nav_link = "master-data"
      render "admin/specialism/new"
    end

    def create
      resp = SpecialismService.create(specialism_params)
      if resp[:success]
        redirect_to "/admin/specialism/#{resp[:data].id}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        puts resp
        redirect_to "/admin/specialism/new"
      end
    end

    def edit
      @nav_link = "master-data"
      specialism_id = params[:id]
      resp = SpecialismService.fetch_one(specialism_id)
      if resp[:success]
        @specialism = resp[:data]
        render "admin/specialism/edit"
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/specialism/new"
      end
    end

    def update
      resp = SpecialismService.update(params[:id], specialism_params)

      if resp[:success]
        redirect_to "/admin/specialism/#{params[:id]}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/specialism/#{params[:id]}/edit"
      end
    end

    def delete
      resp = SpecialismService.delete(params[:id])

      if resp[:success]
        redirect_to "/admin/specialism", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/specialism"
      end
    end
  end
end
