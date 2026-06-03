module Teachers
  class HomeController < ApplicationController
    layout "dashboard"

    # Agrega aquí la lógica de tu controlador
    def index
      @nav_link = 'abet'
    end
end

