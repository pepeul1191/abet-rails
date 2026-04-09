# app/services/auth_service.rb
class AuthService < ApplicationService
  include HTTParty

  default_timeout 30
  headers 'Content-Type' => 'application/json', 'Accept' => 'application/json'

  def self.simple_login(username, password)
    admin_username = ENV['USERNAME']
    admin_password = ENV['PASSWORD']

    if admin_username.blank? || admin_password.blank?
      return handle_error("admin credentials not configured")
    end

    if username == admin_username && password == admin_password
      login_response = {
        user: {
          id: 0,
          username: admin_username,
          name: "Admin User"
        },
        roles: ["admin"],
        tokens: {
          access: "admin-access-token",
          file: "admin-file-token"
        }
      }
      build_response(data: login_response, message: "Admin login successful")
    else
      
    end
  end

  def self.login_by_username(username, password) # contra servicio de accesos
    # Validate input
    if username.blank? || password.blank?
      return handle_error("username and password are required")
    end

    # Call the private helper methods to perform the HTTP requests
    access_api_response = make_auth_access_request(username, password)
    return access_api_response unless access_api_response[:success]

    Rails.logger.info access_api_response

    files_api_response = make_auth_files_request
    return files_api_response unless files_api_response[:success]
    # Map the response to the desired format
    login_response = {
      success: access_api_response[:data]['success'],
      message: access_api_response[:data]['message'],
      user: access_api_response[:data]['data']['user'],
      roles: access_api_response[:data]['data']['roles'],
      tokens: {
        access: access_api_response[:data]['data']['token'],
        file: files_api_response[:data]['data']['token']
      }
    }

    build_response(data: login_response, message: "Login successful")
  end

  private

  def self.make_auth_files_request
    # Get environment variables
    url = ENV['URL_FILES_SERVICE']
    x_auth_header = ENV['X_AUTH_FILES_SERVICE']

    if url.blank? || x_auth_header.blank?
      return handle_error("files service is not available (missing configuration)")
    end

    request_body = {}

    # Agrupar todas las excepciones en un solo rescue
    begin
      # Perform the HTTP request
      response = post(
        "#{url}/api/v1/sign-in",
        body: request_body.to_json,
        headers: {
          'X-Auth-Trigger' => x_auth_header
        }
      )

      Rails.logger.info "Files service response: #{response.body}"

      # Check if response was successful
      if response.success?
        files_api_response = response.parsed_response
        build_response(data: files_api_response, message: "Files authentication successful")
      else
        error_response = response.parsed_response rescue {}
        error_message = error_response['message'] || error_response[:message] || "Error in files service (Code: #{response.code})"
        handle_error(error_message, response.body)
      end

    rescue => e
      Rails.logger.error "Error during files authentication: #{e.message}"
      handle_error("could not connect to the files service", e.message)
    end
  end

  def self.make_auth_access_request(username, password)
    # Get environment variables
    url = ENV['URL_ACCESS_SERVICE']
    x_auth_header = ENV['X_AUTH_ACCESS_SERVICE']
    system_id_str = ENV['SYSTEM_ID']

    if url.blank? || x_auth_header.blank? || system_id_str.blank?
      return handle_error("authentication service is not available (missing configuration)")
    end

    begin
      system_id = system_id_str.to_i
    rescue ArgumentError
      return handle_error("invalid system configuration")
    end

    request_body = {
      username: username,
      password: password,
      system_id: system_id
    }

    # Agrupar todas las excepciones en un solo rescue
    begin
      # Perform the HTTP request
      response = post(
        "#{url}/api/v1/users/sign-in/by-username",
        body: request_body.to_json,
        headers: {
          'X-Auth-Trigger' => x_auth_header
        }
      )

      Rails.logger.info "Authentication service response: #{response.body}"

      # Check if response was successful
      if response.success?
        access_api_response = response.parsed_response
        build_response(data: access_api_response, message: "Authentication successful")
      else
        error_response = response.parsed_response rescue {}
        error_message = error_response['message'] || error_response[:message] || "Error in authentication service (Code: #{response.code})"
        handle_error(error_message, response.body)
      end

    rescue => e
      Rails.logger.error "Error during authentication: #{e.message}"
      handle_error("could not connect to the authentication service", e.message)
    end
  end

  # Health check method
  def self.health_check
    url = ENV['URL_ACCESS_SERVICE']
    
    if url.blank?
      return handle_error("Authentication service URL not configured")
    end

    begin
      response = get("#{url}/health", timeout: 5)

      if response.success?
        build_response(message: "Authentication service available")
      else
        handle_error("Authentication service not available")
      end

    rescue => e
      handle_error("Error checking authentication service", e.message)
    end
  end
end