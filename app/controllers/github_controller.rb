class GithubController < ApplicationController
  skip_before_action :verify_authenticity_token

  def alert
    GithubAlertCreator.call(params[:body])
  end
end
