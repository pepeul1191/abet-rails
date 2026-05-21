# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html do
        render 'errors/not_found', layout: 'blank', status: :not_found
      end

      format.json do
        render json: {
          data: nil,
          success: false,
          message: "Recurso no encontrado",
          error: "404 - #{request.method} #{request.path}"
        }, status: :not_found
      end

      format.any do
        head :not_found
      end
    end
  end

  private

  def should_render_json?
    # Si es una petición API
    return true if request.path.start_with?('/api')
    
    # Si no es método GET
    return true unless request.get?
    
    # Si es un archivo estático
    return true if static_asset?
    
    # En cualquier otro caso, renderizar HTML
    false
  end

  def static_asset?
    # Verificar extensiones de archivos estáticos
    static_extensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg', '.woff', '.woff2', '.ttf', '.eot']
    static_extensions.any? { |ext| request.path.end_with?(ext) }
  end
end