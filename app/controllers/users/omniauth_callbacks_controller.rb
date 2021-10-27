# frozen_string_literal: true

# Handles OAuth callbacks managed via the omniauth gem (via the devise gem)
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :github

    def github
      github_teams = retrieve_github_teams(
        request.env['omniauth.auth'].credentials.token
      )

      if github_teams.empty?
        redirect_to root_path, alert: t('devise.failure.must_belong_to_team')
      else
        @user = User.from_omniauth(request.env['omniauth.auth'], github_teams)
        sign_in_user_and_redirect @user
      end
    end

    def failure
      redirect_to root_path
    end

    private

    def retrieve_github_teams(token)
      raw_team_info = GithubService.user_teams token
      # raw_team_info.map do |github_team|
      #   Team.where(id: github_team[:id]).first_or_create do |team|
      #     team.name = github_team[:name]
      #   end
      # end
    end

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
