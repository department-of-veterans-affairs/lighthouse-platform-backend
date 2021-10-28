# frozen_string_literal: true

# Handles OAuth callbacks managed via the omniauth gem (via the devise gem)
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :github

    def github
      auth = request.env['omniauth.auth']
      token = auth.credentials.token
      users_approved_teams = GithubService.user_teams token
      is_admin = !users_approved_teams.empty?

      @user = User.from_omniauth(auth, is_admin)

      if is_admin
        sign_in_user_and_redirect @user
      else
        redirect_to root_path, alert: t('devise.failure.must_belong_to_team')
      end
    end

    def failure
      redirect_to root_path
    end

    private

    def sign_in_user_and_redirect(user)
      if user.persisted?
        sign_in_and_redirect user
        set_flash_message(:notice, :success, kind: 'Github') if is_navigational_format?
      else
        session['devise.github_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to root_path
      end
    end
  end
end
