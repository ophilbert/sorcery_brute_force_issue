class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: %i[new create]

  def create
    login(params[:email], params[:password], params[:remember]) do |user, failure|
      # if the login fails, we need to handle it
      # based on the different failure cases
      if failure
        case failure
          # increase failed_login_count for user
        when :invalid_password
          user.register_failed_login!
          flash.now[:alert] = "Login failed. Was attempt number: #{user.reload.failed_logins_count}"
          # send user an email when they are locked out
        when :locked
          # UserMailer.unlock_token_email(user.id).deliver_later
          flash.now[:alert] = "oh no, you're locked out! Please check your email"
          # invalid_login or any other error
        else
          flash.now[:alert] = 'Login failed'
        end
        render action: 'new'
      # since there are no login failures, we can redirect the user
      # back to wherever they were trying to go, or the root page
      else
        redirect_back_or_to(:root, notice: 'Login successful')
      end
    end
  end

  def destroy
    logout
    redirect_to(:users, notice: 'Logged out!')
  end
end
