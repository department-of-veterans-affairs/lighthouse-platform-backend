# frozen_string_literal: true

OkComputer.check_in_parallel = true

class BaseCheck < OkComputer::Check
  protected

  def name
    'Unknown'
  end

  def process_success
    mark_message "#{name} is running"
  end

  def process_failure(e = nil)
    message = "??? #{name} is unavailable"
    Rails.logger.warn e.present? ? "#{message}: #{e.message}" : message
    mark_failure
    mark_message "#{name} is unavailable"
  end
end

class SandboxKongCheck < BaseCheck
  def check
    Kong::SandboxService.new.list_consumers ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  protected

  def name
    'Kong[sandbox]'
  end
end

class ProductionKongCheck < BaseCheck
  def check
    Kong::ProductionService.new.list_consumers ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  protected

  def name
    'Kong[production]'
  end
end

class DynamoCheck < BaseCheck
  def check
    DynamoService.new.fetch_dynamo_db ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  protected

  def name
    'DynamoDB'
  end
end

class SandboxOktaCheck < BaseCheck
  def check
    Okta::SandboxService.new.list_applications ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  protected

  def name
    'Okta[sandbox]'
  end
end

class ProductionOktaCheck < BaseCheck
  def check
    Okta::ProductionService.new.list_applications ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  protected

  def name
    'Okta[production]'
  end
end

class ElasticsearchCheck < BaseCheck
  def check
    ElasticsearchService.new.search_connection ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  def name
    'Elasticsearch'
  end
end

class GovDeliveryCheck < BaseCheck
  def check
    client = GovDelivery::TMS::Client.new(Figaro.env.govdelivery_key, api_root: Figaro.env.govdelivery_host)
    client.from_addresses.get.collection.present? ? process_success : process_failure
  rescue => e
    process_failure(e)
  end

  def name
    'GovDelivery'
  end
end

OkComputer::Registry.register 'kong-sandbox', SandboxKongCheck.new
OkComputer::Registry.register 'kong-prod', ProductionKongCheck.new
OkComputer::Registry.register 'okta-sandbox', SandboxOktaCheck.new
OkComputer::Registry.register 'okta-prod', ProductionOktaCheck.new
OkComputer::Registry.register 'dynamodb', DynamoCheck.new
OkComputer::Registry.register 'elasticsearch', ElasticsearchCheck.new
OkComputer::Registry.register 'govdelivery', GovDeliveryCheck.new

OkComputer.make_optional %w[dynamodb]
