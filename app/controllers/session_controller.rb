# app/controllers/session_controller.rb
class SessionController < ApplicationController
  layout "blank"
  before_action :redirect_if_logged_in, only:[:sign_in]

  def sign_in
    
  end

  def login
    username = params[:username]
    password = params[:password]

    #result = AuthService.login_by_username(username, password)
    result = AuthService.simple_login(username, password)

    if result[:success]
      user_data = result[:data]
      # Guardar en sesión
      #session[:user_token] = user_data['token'] || user_data[:token]
      #session[:user_id] = user_data['id'] || user_data[:id]
      session[:user] = user_data[:user]
      session[:tokens] = user_data[:tokens]
      session[:roles] = user_data[:roles]
      redirect_to root_path
    else
      flash[:alert] = result[:message]
      render :sign_in 
    end
  end

  def get_session
    if session.present? && session.to_hash.any?
      render json: {
        data: session.to_hash,
        message: 'datos del usuario logueado',
        error: nil,
        success: true
      }
    else
      render json: {
        data: nil,
        message: 'No hay sesión activa',
        error: 'Sesión no encontrada',
        success: false
      }, status: :not_found
    end
  end

  def sign_out
    reset_session
    flash[:notice] = "Sesión cerrada correctamente"
    redirect_to sign_in_path
  end
end