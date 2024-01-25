# frozen_string_literal: true

class Scope
  def self.consumer_read
    'consumer.read'
  end

  def self.consumer_write
    'consumer.write'
  end

  def self.provider_read
    'provider.read'
  end

  def self.provider_write
    'provider.write'
  end

  def self.utilities_read
    'utilities.read'
  end

  def self.utilities_write
    'utilities.write'
  end
end
