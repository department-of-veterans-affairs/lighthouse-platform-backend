# frozen_string_literal: true

class ErrorSerializer < Blueprinter::Base
  field :errors do |error, _options|
    messages = [error.message]
    messages += [error.backtrace] unless Rails.env.production?

    messages
  end
end
