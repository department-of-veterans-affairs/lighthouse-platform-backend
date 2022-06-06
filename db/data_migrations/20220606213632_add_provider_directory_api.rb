class AddProviderDirectoryApi < ActiveRecord::DataMigration
  def up
    health_category = ApiCategory.find_by(key: 'health')

    guaranty_remittance_api = Api.create(name: 'provider-directory')
    guaranty_remittance_api.update(
      api_environments_attributes: {
        acl: 'provider_directory',
        metadata_url: 'https://api.va.gov/internal/docs/provider-directory-r4/v0/openapi.json',
        environments_attributes: {
          name: %w[sandbox production]
        }
      },
      api_ref_attributes: {
        name: 'providerDirectory'
      },
      api_metadatum_attributes: {
        description: 'Use this API to return lists of VA providers and their information, such as locations, specialties, office hours, and more.',
        display_name: 'Provider Directory API',
        open_data: false,
        va_internal_only: false,
        url_fragment: 'provider_directory',
        api_category_attributes: {
          id: health_category.id
        }
      }
    )
  end
end
