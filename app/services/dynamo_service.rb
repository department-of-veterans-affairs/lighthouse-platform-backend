# frozen_string_literal: true

class DynamoService
  def initialize
    @client = Aws::DynamoDB::Client.new(dynamo_client_options)
  end

  def fetch_dynamo_db
    @client.scan(
      {
        scan_filter: {
        },
        table_name: Figaro.env.dynamo_table_name
      }
    )
  end

  def initialize_dynamo_db
    raise 'just development environment things' if Figaro.env.dynamo_endpoint.blank?

    @client.create_table(
      {
        attribute_definitions: [
          { attribute_name: 'createdAt', attribute_type: 'S' },
          { attribute_name: 'email', attribute_type: 'S' },
        ],
        key_schema: [
          { attribute_name: 'email', key_type: 'HASH' },
          { attribute_name: 'createdAt', key_type: 'RANGE' },
        ],
        provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10,
        },
        table_name: Figaro.env.dynamo_table_name
      }
    )
  end

  private

  # 
  # Note: "endpoint" option is only required running dynamodb locally in a development environment 
  # 
  # @return [Hash] Options to initialize a dynamo db client
  def dynamo_client_options
    credentials = Aws::Credentials.new(Figaro.env.dynamo_access_key_id, Figaro.env.dynamo_secret_access_key)
    options = {
      region: Figaro.env.aws_region,
      credentials: credentials
    }
    options[:endpoint] = Figaro.env.dynamo_endpoint if Figaro.env.dynamo_endpoint.present?

    options
  end
end
