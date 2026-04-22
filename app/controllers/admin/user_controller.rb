# app/controllers/admin/user_controller.rb
module Admin
  class UserController < ApplicationController
    layout "dashboard"

    def user_params
      params.permit(:username, :email, :password, :password_confirmation, :image_url, :active)
    end

    def index
      @nav_link = 'users'
      
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 10
      search_query = params[:search] || params[:email]
      status = params[:status] || nil

      page = 1 if page < 1
      per_page = 10 if per_page < 1

      result = UserService.fetch_all(
        page: page,
        per_page: per_page,
        search_query: search_query,
        status: status
      )

      if result[:success]
        @users = result[:data][:users]
        @pagination = result[:data][:pagination]
        @search_query = search_query
        @status = status
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
        @status = status
        flash.now[:alert] = result[:message]
      end

      render 'admin/user/index'
    end

    def new
      @nav_link = 'users'
      @user = User.new
      render 'admin/user/new'
    end

    def create
      puts '1 ++++++++++++++++++++++++++++++++++++'
      puts params
      puts '2 ++++++++++++++++++++++++++++++++++++'
      resp = UserService.create(params)

      if resp[:success]
        redirect_to "/admin/user/#{resp[:data]['id']}/edit", notice: resp[:message]
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

    def hard_delete
      resp = UserService.hard_delete(params[:id])
      
      if resp[:success]
        redirect_to "/admin/user", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user"
      end
    end

    def toggle_active
      resp = UserService.toggle_active(params[:id])
      
      if resp[:success]
        redirect_to "/admin/user", notice: resp[:message]
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user"
      end
    end

    def show
      @nav_link = 'users'
      user_id = params[:id]
      resp = UserService.fetch_one(user_id)

      if resp[:success]
        @user = resp[:data]
        render 'admin/user/show'
      else
        flash[:alert] = resp[:message]
        redirect_to "/admin/user"
      end
    end
  end
end