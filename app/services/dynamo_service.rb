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
