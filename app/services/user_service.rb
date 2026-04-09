# app/services/user_service.rb
class UserService < ApplicationService
  def self.fetch_one(id)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    build_response(data: user, message: "Usuario encontrado")
  rescue => e
    handle_error("Error al buscar usuario: #{e.message}", e.backtrace)
  end

  def self.fetch_all(page: 1, per_page: 10, search_query: nil)
    begin
      # Consulta base
      users = User.all.order(email: :asc)

      # Filtro de búsqueda
      if search_query.present?
        users = users.where("email LIKE ?", "%#{search_query}%")
      end

      # Paginación
      total_users = users.count
      total_pages = (total_users.to_f / per_page).ceil
      offset = (page - 1) * per_page

      paginated_users = users.offset(offset).limit(per_page)

      pagination_data = {
        users: paginated_users,
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
    user = User.new(params)

    if user.save
      build_response(data: user, message: "Usuario creado exitosamente")
    else
      handle_validation_error(user)
    end
  rescue => e
    handle_error("Error al crear usuario: #{e.message}", e.backtrace)
  end

  def self.update(id, params)
    user = User.find_by(id: id)
    return handle_not_found("Usuario no encontrado") unless user

    if user.update(params)
      build_response(data: user, message: "Usuario actualizado exitosamente")
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
      build_response(message: "Usuario eliminado exitosamente")
    else
      handle_error("No se pudo eliminar el usuario")
    end
  rescue => e
    handle_error("Error al eliminar usuario: #{e.message}", e.backtrace)
  end
end