# frozen_string_literal: true

class DynamoService
  def fetch_dynamo_db
    credentials = Aws::Credentials.new(Figaro.env.dynamo_access_key_id, Figaro.env.dynamo_secret_access_key)

    client = Aws::DynamoDB::Client.new(
      region: 'us-gov-west-1',
      credentials: credentials
    )

    client.scan(
      {
        scan_filter: {
        },
        table_name: Figaro.env.dynamo_table_name
      }
    )
  end
end
