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

  def initialize_dynamo_db # rubocop:disable Metrics/MethodLength
    raise 'just development environment things' if Figaro.env.dynamo_endpoint.blank?

    @client.create_table(
      {
        attribute_definitions: [
          { attribute_name: 'createdAt', attribute_type: 'S' },
          { attribute_name: 'email', attribute_type: 'S' }
        ],
        key_schema: [
          { attribute_name: 'email', key_type: 'HASH' },
          { attribute_name: 'createdAt', key_type: 'RANGE' }
        ],
        provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10
        },
        table_name: Figaro.env.dynamo_table_name
      }
    )

    Rails.logger.info "#{Figaro.env.dynamo_table_name} table created."
  end

  def seed_dynamo_db # rubocop:disable Metrics/MethodLength
    raise 'just development environment things' if Figaro.env.dynamo_endpoint.blank?

    num_dynamo_users = 100
    num_dynamo_users.times do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      @client.put_item(
        {
          item: {
            apis: ['benefits', 'facilities', 'benefits,facilities'].sample,
            organization: 'none',
            firstName: first_name,
            lastName: last_name,
            createdAt: Time.zone.now.to_s,
            description: ['no description', Faker::Lorem.paragraph].sample,
            email: "#{first_name}.#{last_name}@va.gov",
            tosAccepted: [true, false].sample,
            kongConsumerId: %w[b11ae7d9-2949-4e80-aa55-ccd30d4c7287 6b6f692b-0ec1-4224-9016-f7c65de680f9].sample
          },
          table_name: Figaro.env.dynamo_table_name
        }
      )
    end

    Rails.logger.info "#{num_dynamo_users} users created in dynamo #{Figaro.env.dynamo_table_name} table."
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
