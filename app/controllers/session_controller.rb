# app/controllers/session_controller.rb
class SessionController < ApplicationController
  layout "blank"
  before_action :redirect_if_logged_in, only:[:sign_in]
  skip_before_action :verify_authenticity_token, only: [:google_oauth_callback]
  skip_before_action :verify_authenticity_token, only: [:login]

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

      # Guardar en sesión
      session[:user] = {
        'id' => user_data[:user][:username],
        'username' => user_data[:user][:username],
        'name' => user_data[:user][:name] || user_data[:user][:username],
        'email' => user_data[:user][:email],
        'oauth' => false
      }
      session[:tokens] = user_data[:tokens]
      session[:roles] = user_data[:roles]

      # Registrar login exitoso
      LoginLog.create!(
        user_id: user_data[:user][:id],
        success: true,
        ip_address: request.remote_ip,
        created_at: Time.current
      )

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

  # OmniAuth espera esta acción por defecto
  def create
    # Esto es un alias del callback de Google
    google_oauth_callback
  end

  # Iniciar autenticación con Google
  def google_oauth
    redirect_to "/auth/google_oauth2", allow_other_host: true
  end

  # Callback después de autenticación con Google
  def google_oauth_callback
    auth = request.env['omniauth.auth']
    
    if auth.blank?
      flash[:alert] = "No se recibió información de autenticación"
      redirect_to sign_in_path and return
    end

    # Buscar o crear usuario con los datos de Google
    user = find_user_from_google(auth)
    
    if user.active?
      # Preparar estructura de sesión
      session[:user] = {
        'id' => user.id,
        'username' => user.username,
        'name' => auth.info.name,
        'email' => user.email,
        'image_url' => user.image_url,
        'oauth' => true,
        'provider' => 'google'
      }
      
      session[:tokens] = {
        'access' => auth.credentials.token,
        'refresh' => auth.credentials.refresh_token,
        'expires_at' => auth.credentials.expires_at,
        'type' => 'google_oauth'
      }
      
      session[:roles] = ['user']
      
      # Registrar login exitoso con Google
      LoginLog.create!(
        user_id: user.id,
        success: true,
        ip_address: request.remote_ip,
        created_at: Time.current
      )
      
      flash[:notice] = "Bienvenido #{auth.info.name}! Has iniciado sesión con Google."
      redirect_to root_path
    else
      # Registrar intento fallido
      if user
        LoginLog.create!(
          user_id: user.id,
          success: false,
          ip_address: request.remote_ip,
          created_at: Time.current
        )
      end
      
      flash[:alert] = user&.errors&.full_messages&.join(', ') || "Usuario de Google no registrado o inactivo. Por favor, contacte al administrador."
      redirect_to sign_in_path
    end
  end

  # Manejar errores de OAuth
  def oauth_failure
    error_message = params[:message] || request.env['omniauth.error']&.message || 'Error desconocido'
    flash[:alert] = "Autenticación con Google fallida: #{error_message}"
    redirect_to sign_in_path
  end

  def sign_out
    # Si es OAuth, opcionalmente revocar token
    if session[:user]&.dig('oauth') && session[:tokens]&.dig('access')
      revoke_google_token(session[:tokens]['access'])
    end
    
    reset_session
    flash[:notice] = "Sesión cerrada correctamente"
    redirect_to sign_in_path
  end

  private

  def redirect_if_logged_in
    if session[:user].present?
      redirect_to root_path
    end
  end

  def find_user_from_google(auth)
    # Buscar por email si ya existe
    user = User.find_by(email: auth.info.email)
    if user
      # Vincular cuenta existente con Google
      user.update(
        last_login_at: Time.current,
        provider: auth.provider,
        uid: auth.uid,
        google_token: auth.credentials.token,
        google_refresh_token: auth.credentials.refresh_token,
        # image_url: auth.info.image
      )
      return user
    else
      Rails.logger.error "Su cuenta no está registrada. Por favor, contacte al administrador."
      return nil
    end
  end

  def find_or_create_user_from_google(auth)
    # Buscar por provider y uid
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    if user.nil?
      # Buscar por email si ya existe
      user = User.find_by(email: auth.info.email)
      if user
        # Vincular cuenta existente con Google
        user.update(
          provider: auth.provider,
          uid: auth.uid,
          google_token: auth.credentials.token,
          google_refresh_token: auth.credentials.refresh_token,
          image_url: auth.info.image
        )
      else
        # Crear nuevo usuario
        user = User.new
        user.username = generate_unique_username(auth.info.email)
        user.email = auth.info.email
        user.image_url = auth.info.image
        user.provider = auth.provider
        user.uid = auth.uid
        user.google_token = auth.credentials.token
        user.google_refresh_token = auth.credentials.refresh_token
        user.active = true
        user.password_digest = SecureRandom.hex(20)
        
        unless user.save
          Rails.logger.error "Error creating OAuth user: #{user.errors.full_messages}"
          return nil
        end
      end
    else
      # usuario no registrado
      #reset_session
      flash[:notice] = "Usuario no registrado"
      redirect_to sign_in_path
    end
    
    user
  end

  def generate_unique_username(email)
    base_username = email.split('@').first
    base_username = base_username[0...15] # Limitar a 15 caracteres
    username = base_username
    counter = 1
    
    while User.exists?(username: username)
      username = "#{base_username}#{counter}"
      username = username[0...20] if username.length > 20
      counter += 1
    end
    
    username
  end

  def revoke_google_token(token)
    return unless token.present?
    
    begin
      require 'net/http'
      uri = URI.parse("https://oauth2.googleapis.com/revoke")
      response = Net::HTTP.post_form(uri, 'token' => token)
      
      if response.code == '200'
        Rails.logger.info "Google token revoked successfully"
      else
        Rails.logger.warn "Failed to revoke Google token: #{response.code}"
      end
    rescue => e
      Rails.logger.error "Error revoking Google token: #{e.message}"
    end
  end
end