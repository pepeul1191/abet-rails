# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout :layout_by_role
  before_action :require_login

  def index
    # Tu lógica aquí
    @welcome_message = "Bienvenido a mi aplicación"
    @nav_link = 'home'
  end
end