module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_request!

      private

      def authenticate_request!
        token = extract_token
        payload = JsonWebToken.decode(token)
        @current_user = User.find(payload[:user_id])
      rescue JWT::ExpiredSignature
        render_error(code: "token_expired", message: "Token has expired", status: :unauthorized)
      rescue JWT::DecodeError
        render_error(code: "invalid_token", message: "Invalid token", status: :unauthorized)
      rescue ActiveRecord::RecordNotFound
        render_error(code: "user_not_found", message: "User not found", status: :unauthorized)
      end

      def extract_token
        header = request.headers["Authorization"]
        raise JWT::DecodeError, "Missing token" unless header&.start_with?("Bearer ")
        header.split(" ").last
      end

      def render_error(code:, message:, status:, details: nil)
        payload = { error: { code: code, message: message } }
        payload[:error][:details] = details if details.present?
        render json: payload, status: status
      end

      attr_reader :current_user
    end
  end
end