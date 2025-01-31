module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create_user
        result = UsersService.create_user(user_params)

        if result[:success]
          render json: result[:user], status: :created
        else
          render json: { errors: result[:errors] }, status: :unprocessable_entity
        end
      end

      def user_login
        begin
          result = UsersService.authenticate_user(login_params)
          render json: { message: "Login successful", token: result[:token] }, status: :ok
        rescue UsersService::InvalidEmailError, UsersService::InvalidPasswordError => e
          render json: { error: e.message }, status: :bad_request
        end
      end

      def forgot_password
        begin
          result = UsersService.forgot_password(forgot_password_params[:email])
          if result[:success]
            render json: { message: result[:message], otp: result[:otp] }, status: :ok
          else
            render json: { error: result[:error] }, status: :bad_request
          end
        rescue UsersService::InvalidEmailError => e
          render json: { error: e.message }, status: :bad_request
        end
      end
      def reset_password
        user = User.find_by(id: params[:id])
        result = UsersService.reset_password(user,rp_params)
        if result[:success]
            render json: { message: result[:message]}, status: :ok
          else
            render json: { error: result[:error] }, status: :bad_request
          end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :phone_number)
      end

      def login_params
        params.require(:user).permit(:email, :password) # only include email and password
      end

      def rp_params
        params.require(:user).permit(:new_password, :otp) # only include email and password
      end

      def forgot_password_params
        if params[:user].present?
          params.require(:user).permit(:email)
        else
          params.permit(:email) # Handle cases where the email is passed directly
        end
      end
    end
  end
end
