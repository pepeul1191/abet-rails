# app/services/user_service.rb
class UserService < ApplicationService
  def self.fetch_one(id, as_json: true)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    build_response(data: user.as_json(except: :password_digest), message: "Usuario encontrado")
  rescue => e
    handle_error("Error al buscar usuario: #{e.message}", e.backtrace)
  end

  def self.fetch_all(page: 1, per_page: 10, search_query: nil, status: nil)
    begin
      # Consulta base
      users = User.all.order(id: :asc)
      
      # Filtrar por activos/inactivos
      unless status.nil? || status == ''
        users = users.where(active: status == 'true')
      end

      # Filtro de búsqueda (por username o email)
      if search_query.present?
        users = users.where("username LIKE ? OR email LIKE ?", "%#{search_query}%", "%#{search_query}%")
      end

      # Paginación
      total_users = users.count
      total_pages = (total_users.to_f / per_page).ceil
      offset = (page - 1) * per_page

      paginated_users = users.offset(offset).limit(per_page)

      pagination_data = {
        users: paginated_users.as_json(except: :password_digest),
        pagination: {
          page: page,
          per_page: per_page,
          total_users: total_users,
          total_pages: total_pages,
          start_record: offset + 1,
          end_record: [offset + per_page, total_users].min
        }
      }

      build_response(data: pagination_data, message: "Lista de usuarios obtenida exitosamente")
    rescue => e
      handle_error("Error al obtener usuarios: #{e.message}", e.backtrace)
    end
  end

  def self.create(params)
    # Extract password fields
    password = params[:password]
    password_confirmation = params[:password_confirmation]
    
    # Set default image_url if empty
    image_url = params[:image_url].presence || 'img/user.png'
    
    # Clean params by removing password fields
    clean_params = params.except(:password, :password_confirmation).merge(image_url: image_url)
    
    # Case 1: Both passwords are empty - generate random password
    if password.blank? && password_confirmation.blank?
      # Generate a random password
      random_password = generate_random_password
      
      user = User.new(clean_params)
      user.password = random_password
      user.password_confirmation = random_password
      
    # Case 2: Both passwords are provided - validate they match
    elsif password.present? && password_confirmation.present?
      if password == password_confirmation
        user = User.new(clean_params)
        user.password = password
        user.password_confirmation = password_confirmation
      else
        return {
          success: false,
          error: "Las contraseñas no coinciden",
          status: :unprocessable_entity
        }
      end
      
    # Case 3: Only one password provided - error
    else
      return {
        success: false,
        error: "Debe proporcionar ambas contraseñas o ninguna",
        status: :unprocessable_entity
      }
    end
    
    # Por defecto el usuario se crea activo
    user.active = true if user.active.nil?
    
    if user.save
      response_data = user.as_json(except: :password_digest)
      
      # If random password was generated, add it to response for admin to see
      if password.blank? && password_confirmation.blank?
        response_data[:generated_password] = random_password
      end
      
      build_response(data: response_data, message: "Usuario creado exitosamente")
    else
      handle_validation_error(user)
    end
  rescue => e
    puts "Backtrace:"
    puts e.backtrace
    handle_error("Error al crear usuario: #{e.message}", e.backtrace)
  end

  # Helper method to generate random password
  def self.generate_random_password(length = 12)
    # Generate a random password with letters, numbers, and special characters
    chars = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    special_chars = ['!', '@', '#', '$', '%', '&', '*']
    
    # Ensure at least one special character for security
    password = special_chars.sample + Array.new(length - 1) { chars.sample }.join
    
    # Shuffle the password to mix the special character
    password.chars.shuffle.join
  end

  def self.update(id, params)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    # Filtrar parámetros actualizables
    update_params = params.slice(:username, :email, :image_url, :active)
    
    # Manejar actualización de password si se proporciona
    if params[:password].present?
      update_params[:password] = params[:password]
      update_params[:password_confirmation] = params[:password_confirmation] if params[:password_confirmation].present?
    end

    if user.update(update_params)
      build_response(data: user.as_json(except: :password_digest), message: "Usuario actualizado exitosamente")
    else
      handle_validation_error(user)
    end
  rescue => e
    handle_error("Error al actualizar usuario: #{e.message}", e.backtrace)
  end

  def self.delete(id)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    if user.destroy
      build_response(message: "Usuario eliminado")
    else
      handle_error("No se pudo eliminar el usuario")
    end
  rescue => e
    handle_error("Error al desactivar usuario: #{e.message}", e.backtrace)
  end

  # Método para eliminar físicamente (hard delete)
  def self.hard_delete(id)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    if user.destroy
      build_response(message: "Usuario eliminado permanentemente")
    else
      handle_error("No se pudo eliminar el usuario")
    end
  rescue => e
    handle_error("Error al eliminar usuario: #{e.message}", e.backtrace)
  end

  # Método para activar/desactivar usuario
  def self.toggle_active(id)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    new_state = !user.active
    if user.update(active: new_state)
      message = new_state ? "Usuario activado exitosamente" : "Usuario desactivado exitosamente"
      build_response(data: user.as_json(except: :password_digest), message: message)
    else
      handle_error("No se pudo cambiar el estado del usuario")
    end
  rescue => e
    handle_error("Error al cambiar estado del usuario: #{e.message}", e.backtrace)
  end

  # Método adicional para buscar por username
  def self.find_by_username(username)
    user = User.find_by(username: username)
    return handle_not_found("Usuario no encontrado") unless user

    build_response(data: user.as_json(except: :password_digest), message: "Usuario encontrado")
  rescue => e
    handle_error("Error al buscar usuario: #{e.message}", e.backtrace)
  end

  # Método para obtener solo usuarios activos
  def self.fetch_active(page: 1, per_page: 10, search_query: nil)
    fetch_all(page: page, per_page: per_page, search_query: search_query, status: false)
  end

  # Método para obtener solo usuarios inactivos
  def self.fetch_inactive(page: 1, per_page: 10, search_query: nil)
    fetch_all(page: page, per_page: per_page, search_query: search_query, status: true)
  end
end