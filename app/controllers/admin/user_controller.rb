# app/controllers/admin/user_controller.rb
module Admin
  class UserController < ApplicationController
    layout "dashboard"

    def user_params
      params.permit(:email, :password, :password_confirmation)
    end

    def index
      @nav_link = 'users'
      
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:email]

      page = 1 if page < 1
      per_page = 10 if per_page < 1

      result = UserService.fetch_all(
        page: page,
        per_page: per_page,
        search_query: search_query
      )

      if result[:success]
        @users = result[:data][:users]
        @pagination = result[:data][:pagination]
        @search_query = search_query
      else
        @users = []
        @pagination = {
          page: page,
          per_page: per_page,
          total_users: 0,
          total_pages: 0,
          start_record: 0,
          end_record: 0
        }
        @search_query = search_query
        flash.now[:alert] = result[:message]
      end

      render 'admin/user/index'
    end

    def new
      @nav_link = 'users'
      render 'admin/user/new'
    end

    def create
      resp = UserService.create(user_params)

      if resp[:success]
        redirect_to "/admin/user/#{resp[:data].id}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user/new"
      end
    end

    def edit
      @nav_link = 'users'
      user_id = params[:id]
      resp = UserService.fetch_one(user_id)

      if resp[:success]
        @user = resp[:data]
        render 'admin/user/edit'
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user"
      end
    end

    def update
      resp = UserService.update(params[:id], user_params)
      
      if resp[:success]
        redirect_to "/admin/user/#{params[:id]}/edit", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user/#{params[:id]}/edit"
      end
    end

    def delete
      resp = UserService.delete(params[:id])
      
      if resp[:success]
        redirect_to "/admin/user", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user"
      end
    end
  end
end