module Api
  module V1
    class AuthController < ApplicationController
      protect_from_forgery with: :null_session

      def login
        user = User.find_by(email: params[:email]&.downcase)

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id, role: user.role)
          render json: { token: token, user: { id: user.id, email: user.email } }
        else
          render json: {
            error: { code: "invalid_credentials", message: "Email or password is incorrect" }
          }, status: :unauthorized
        end
      end
    end
  end
end