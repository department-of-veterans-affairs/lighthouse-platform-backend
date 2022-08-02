# frozen_string_literal: true

module V0
  class Base < Grape::API
    mount V0::Consumers
    mount V0::Providers
    mount V0::Support

    add_swagger_documentation \
      mount_path: '/v0/openapi',
      info: {
        title: 'Lighthouse Platform Backend',
        description: 'Source of truth for information regarding a Lighthouse consumer',
        contact_url: 'https://github.com/department-of-veterans-affairs/lighthouse-platform-backend'
      }
  end
end
