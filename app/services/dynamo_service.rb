# frozen_string_literal: true

class DynamoService
  def fetch_dynamo_db
    credentials = Aws::Credentials.new(ENV['dynamo_access_key_id'], ENV['dynamo_secret_access_key'])

    client = Aws::DynamoDB::Client.new(
      region: ENV['aws_region'],
      credentials: credentials
    )

    client.scan(
      {
        scan_filter: {
        },
        table_name: ENV['dynamo_table_name']
      }
    )
  end
end
