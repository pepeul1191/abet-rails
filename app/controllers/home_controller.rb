# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout :layout_by_role
  before_action :require_login

  def index
    @welcome_message = "Bienvenido a mi aplicación"
    @nav_link = 'home'
    
    # Obtener roles del usuario desde la sesión
    user_roles = session[:roles] || ['user']
    
    # Renderizar diferente vista según el rol
    if user_roles.include?('admin')
      render 'home/admin_index'
    elsif user_roles.include?('user')
      render 'home/user_index'
    else
      render 'home/guest_index'
    end
  end
end