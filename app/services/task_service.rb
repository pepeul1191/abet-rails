# app/services/task_service.rb

require "pathname"

class TaskService < ApplicationService
  def self.fetch_all(user_id:, page: 1, per_page: 10, search_query: nil, task_type_id: nil, start_date: nil, end_date: nil)
    puts "A -------------------------------------"
    puts 'user_id: #{user_id}'
    puts "B -------------------------------------"
    begin
      tasks = Task
                .includes(:user, :task_type, :period)
                .where(user_id: user_id)
                .order(created_at: :desc)

      # 🔎 filtro por nombre
      tasks = tasks.where("name LIKE ?", "%#{search_query}%") if search_query.present?

      # 🔎 filtro por tipo de task
      tasks = tasks.where(task_type_id: task_type_id) if task_type_id.present? && task_type_id != ""

      # 📅 filtro por fecha inicio
      tasks = tasks.where("DATE(created_at) >= ?", start_date) if start_date.present?

      # 📅 filtro por fecha fin
      tasks = tasks.where("DATE(created_at) <= ?", end_date) if end_date.present?

      total_tasks = tasks.count
      total_pages = (total_tasks.to_f / per_page).ceil
      offset = (page - 1) * per_page

      paginated_tasks = tasks.offset(offset).limit(per_page)

      build_response(
        data: {
          tasks: paginated_tasks,
          pagination: {
            page: page,
            per_page: per_page,
            total_tasks: total_tasks,
            total_pages: total_pages,
            start_record: offset + 1,
            end_record: [ offset + per_page, total_tasks ].min
          }
        },
        message: "Tasks filtradas correctamente"
      )
    rescue => e
      handle_error("Error al filtrar tasks: #{e.message}", e.backtrace)
    end
  end

  def self.fetch_one(id)
    specialism = Specialism.find_by(id: id)
    return handle_not_found("Especialidad no encontrado") unless specialism

    build_response(data: specialism, message: "Especialidad encontrada")
  rescue => e
    handle_error("Error al buscar especialidad: #{e.message}", e.backtrace)
  end

  def self.create(params, abet_resp, session)
    task = Task.new

    task.name = params[:name]
    task.description = params[:description]
    task.data = abet_resp[""]
    task.zip_path = Pathname
      .new(abet_resp[:data][:zip_path])
      .relative_path_from(Rails.root)
      .to_s
    task.status = "Success"
    task.user_id = session["user"]["id"]
    task.task_type_id = params[:task_type_id]
    task.period_id = params[:period_id]
    task.data = abet_resp.dig(:data, :students).to_json

    task.save

    if task.save
      build_response(data: task, message: "Tarea creada exitosamente")
    else
      handle_validation_error(task)
    end
  rescue => e
    handle_error("Error al crear evidencia ABET: #{e.message}", e.backtrace)
  end

  def self.delete(id)
    task = Task.find_by(id: id)
    return handle_not_found("Tarea no encontrada") unless task

    # Intentar eliminar los archivos asociados
    if task.zip_path.present?
      zip_full_path = Rails.root.join(task.zip_path)
      if File.exist?(zip_full_path)
        parent_dir = File.dirname(zip_full_path)
        begin
          FileUtils.rm_rf(parent_dir) if parent_dir.to_s.start_with?(Rails.root.join("tmp", "abet").to_s)
        rescue => file_error
          puts "Error al eliminar archivos de la tarea: #{file_error.message}"
        end
      end
    end

    if task.destroy
      build_response(message: "Tarea eliminada exitosamente")
    else
      handle_error("No se pudo eliminar la tarea")
    end
  rescue => e
    handle_error("Error al eliminar la tarea: #{e.message}", e.backtrace)
  end
end
