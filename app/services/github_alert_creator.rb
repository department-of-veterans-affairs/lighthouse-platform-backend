# frozen_string_literal: true

class GithubAlertCreator < ApplicationService
  def initialize(body)
    @body = body
  end

  def call
    # instantiate email client
    # define email body
    # send email

    # instantiate slack client
    # define slack message body
    # send message
  end
end
