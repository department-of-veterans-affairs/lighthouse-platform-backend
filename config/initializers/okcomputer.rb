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

  def process_failure
    mark_failure
    mark_message "#{name} is unavailable"
  end
end

class KongCheck < BaseCheck
  def check
    Kong::SandboxService.new.list_consumers ? process_success : process_failure
  rescue
    process_failure
  end

  protected

  def name
    'Kong'
  end
end

class DynamoCheck < BaseCheck
  def check
    DynamoService.new.fetch_dynamo_db ? process_success : process_failure
  rescue
    process_failure
  end

  protected

  def name
    'DynamoDB'
  end
end

class OktaCheck < BaseCheck
  def check
    Okta::SandboxService.new.list_applications ? process_success : process_failure
  rescue
    process_failure
  end

  protected

  def name
    'Okta'
  end
end

class ElasticsearchCheck < BaseCheck
  def check
    ElasticsearchService.new.search_connection ? process_success : process_failure
  rescue
    process_failure
  end

  def name
    'Elasticsearch'
  end
end

OkComputer::Registry.register 'kong', KongCheck.new
OkComputer::Registry.register 'okta', OktaCheck.new
OkComputer::Registry.register 'dynamodb', DynamoCheck.new
OkComputer::Registry.register 'elasticsearch', ElasticsearchCheck.new

OkComputer.make_optional %w[dynamodb]
