# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'],
    {
      scope: 'email, profile',
      prompt: 'select_account',
      image_aspect_ratio: 'square',
      image_size: 50
    }
end

# Configuración adicional necesaria
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.silence_get_warning = true  # Silencia la advertencia de GET

# Manejo de errores (opcional pero recomendado)
OmniAuth.config.on_failure = Proc.new do |env|
  error_type = env['omniauth.error.type']
  Rails.logger.error "OmniAuth Failure: #{error_type}"
  
  # Redirige al sign_in con el error
  controller = env['action_controller.instance']
  if controller
    controller.flash[:alert] = "Error de autenticación con Google: #{error_type}"
    controller.redirect_to "/sign_in"
  else
    Rack::Response.new(
      ["Authentication failed"],
      302,
      {"Location" => "/sign_in"}
    )
  end
end