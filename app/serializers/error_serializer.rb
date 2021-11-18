# frozen_string_literal: true

class ErrorSerializer < Blueprinter::Base
  field :errors do |error, _options|
    [error.message]
  end
end
