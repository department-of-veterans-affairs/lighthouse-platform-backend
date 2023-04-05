# frozen_string_literal: true

namespace :lpb do
  desc 'Inject sandbox and production .well-known config urls'
  task seedWellKnownConfigValues: :environment do
    apis = ApiMetadatum.where.not(oauth_info: nil)
    apis.each do |api|
      p api[:display_name]
      process_auth_type(api, 'acgInfo') if api.oauth_info['acgInfo'].present?
      process_auth_type(api, 'ccgInfo') if api.oauth_info['ccgInfo'].present?
    end
  end

  desc 'Populates new IA fields'
  task seedIAFieldValues: :environment do
    Api.all.each do |api|
      next if api.api_metadatum.blank?

      sanitized_api_name = api.api_metadatum.display_name.downcase
                              .gsub('api', '')
                              .gsub('fhir', '')
                              .gsub('(', '')
                              .gsub(')', '')
                              .strip
      api_name_pieces = sanitized_api_name.split
      hyphenated_api_name = api_name_pieces.join('-')
      url_slug = hyphenated_api_name

      api.api_metadatum.url_slug = url_slug
      api.api_metadatum.restricted_access_toggle = false
      api.api_metadatum.restricted_access_details = ''
      api.api_metadatum.overview_page_content = '# This is default content'
      api.api_metadatum.save!
    end

    ApiCategory.all.each do |category|
      sanitized_category_name = category.name.downcase.gsub('apis', '').strip
      category_name_pieces = sanitized_category_name.split
      hyphenated_category_name = category_name_pieces.join('-')
      url_slug = hyphenated_category_name

      category.url_slug = url_slug
      category.save!
    end
  end

  def get_base_url(environment)
    base_urls = {
      'production' => 'https://api.va.gov',
      'qa' => 'https://dev-api.va.gov',
      'sandbox' => 'https://sandbox-api.va.gov',
      'staging' => 'https://staging-api.va.gov',
      'test' => 'https://dev-api.va.gov'
    }.freeze
    base_urls[environment]
  end

  def get_path(url_fragment, type)
    paths = {
      'address_validation' => {
        'ccgInfo' => '/oauth2/va-profile/system/v1/.well-known/openid-configuration'
      },
      'benefits-documents' => {
        'ccgInfo' => '/oauth2/benefits-documents/system/v1/.well-known/openid-configuration'
      },
      'claims' => {
        'acgInfo' => '/oauth2/claims/v1/.well-known/openid-configuration',
        'ccgInfo' => '/oauth2/claims/system/v1/.well-known/openid-configuration'
      },
      'clinical_health' => {
        'acgInfo' => '/oauth2/clinical-health/system/v1/.well-known/openid-configuration'
      },
      'community_care' => {
        'acgInfo' => '/oauth2/community-care/v1/.well-known/openid-configuration'
      },
      'contact_information' => {
        'ccgInfo' => '/oauth2/va-profile/system/v1/.well-known/openid-configuration'
      },
      'direct-deposit-management' => {
        'ccgInfo' => '/oauth2/direct-deposit-management/system/v1/.well-known/openid-configuration'
      },
      'fhir' => {
        'acgInfo' => '/oauth2/health/v1/.well-known/openid-configuration',
        'ccgInfo' => '/oauth2/health/system/v1/.well-known/openid-configuration'
      },
      'lgy_guaranty_remittance' => {
        'ccgInfo' => '/oauth2/loan-guaranty/system/v1/.well-known/openid-configuration'
      },
      'loan-review' => {
        'ccgInfo' => '/oauth2/loan-review/system/v1/.well-known/openid-configuration'
      },
      'pgd' => {
        'ccgInfo' => '/oauth2/pgd/system/v1/.well-known/openid-configuration'
      },
      'va_letter_generator' => {
        'ccgInfo' => '/oauth2/va-letter-generator/system/v1/.well-known/openid-configuration'
      },
      'veteran_verification' => {
        'acgInfo' => '/oauth2/veteran-verification/v1/.well-known/openid-configuration',
        'ccgInfo' => '/oauth2/veteran-verification/system/v1/.well-known/openid-configuration'
      }
    }.freeze
    paths[url_fragment][type]
  end

  def process_auth_type(api, type)
    url_fragment = api[:url_fragment]
    environment = ENV.fetch('ENVIRONMENT', 'qa')
    p api.oauth_info
    json = JSON.parse(api.oauth_info)
    prod_merge = {
      'productionWellKnownConfig' => get_base_url(environment) + get_path(url_fragment, type)
    }
    p prod_merge
    json[type] = json[type].to_hash.merge(prod_merge)
    environment = 'sandbox' if environment == 'production'
    sandbox_merge = {
      'sandboxWellKnownConfig' => get_base_url(environment) + get_path(url_fragment, type)
    }
    p sandbox_merge
    json[type] = json[type].to_hash.merge(sandbox_merge)
    api.oauth_info = json.to_json
    api.save
  end
end
