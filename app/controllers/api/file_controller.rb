# app/controllers/api/file_controller.rb
class Api::FileController < ApplicationController
  #skip_before_action :verify_authenticity_token, only: [:upload_image]

  def upload_user_image
    result = FileService.upload_user_image(params[:file], user_id: params[:user_id])
    
    if result[:success]
      render json: {
        success: true,
        message: result[:message],
        image_url: result[:data][:image_url],
        filename: result[:data][:filename],
        size: result[:data][:size]
      }, status: :ok
    else
      render json: { error: result[:message] }, status: result[:status] || :unprocessable_entity
    end
  end
end