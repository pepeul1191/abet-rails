# app/services/task_type_service.rb
class TaskTypeService < ApplicationService
  def self.fetch_one(id)
    task_type = TaskType.find_by(id: id)
    return handle_not_found("Tipo de tarea no encontrado") unless task_type

    build_response(data: task_type, message: "Tipo de tarea encontrado")
  rescue => e
    handle_error("Error al buscar tipo de tarea: #{e.message}", e.backtrace)
  end

  def self.fetch_all(page: 1, per_page: 10, search_query: nil)
    begin
      task_types = TaskType.all.order(name: :asc)

      if search_query.present?
        task_types = task_types.where("name LIKE ?", "%#{search_query}%")
      end

      total_task_types = task_types.count
      total_pages = (total_task_types.to_f / per_page).ceil
      offset = (page - 1) * per_page

      paginated_task_types = task_types.offset(offset).limit(per_page)

      pagination_data = {
        task_types: paginated_task_types,
        pagination: {
          page: page,
          per_page: per_page,
          total_task_types: total_task_types,
          total_pages: total_pages,
          start_record: offset + 1,
          end_record: [offset + per_page, total_task_types].min
        }
      }

      build_response(
        data: pagination_data,
        message: "Lista de tipos de tarea obtenida exitosamente"
      )
    rescue => e
      handle_error(
        "Error al obtener los tipos de tarea: #{e.message}",
        e.backtrace
      )
    end
  end

  def self.create(params)
    task_type = TaskType.new(params)

    if task_type.save
      build_response(
        data: task_type,
        message: "Tipo de tarea creado exitosamente"
      )
    else
      handle_validation_error(task_type)
    end
  rescue => e
    handle_error("Error al crear tipo de tarea: #{e.message}", e.backtrace)
  end

  def self.update(id, params)
    task_type = TaskType.find_by(id: id)
    return handle_not_found("Tipo de tarea no encontrado") unless task_type

    if task_type.update(params)
      build_response(
        data: task_type,
        message: "Tipo de tarea actualizado exitosamente"
      )
    else
      handle_validation_error(task_type)
    end
  rescue => e
    handle_error("Error al actualizar tipo de tarea: #{e.message}", e.backtrace)
  end

  def self.delete(id)
    task_type = TaskType.find_by(id: id)
    return handle_not_found("Tipo de tarea no encontrado") unless task_type

    if task_type.destroy
      build_response(message: "Tipo de tarea eliminado exitosamente")
    else
      handle_error("No se pudo eliminar el tipo de tarea")
    end
  rescue => e
    handle_error("Error al eliminar tipo de tarea: #{e.message}", e.backtrace)
  end
end