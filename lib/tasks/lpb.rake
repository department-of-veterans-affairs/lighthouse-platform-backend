# frozen_string_literal: true

namespace :lpb do
  desc 'Inject sandbox and production .well-known config urls'
  task seedWellKnownConfigValues: :environment do
    apis = ApiMetadatum.where.not(oauth_info: nil)
    # apis = [ApiMetadatum.find(3)]
    p apis.length
    apis.each do |api|
      p api[:display_name]
      process_auth_type(api, 'acgInfo') if api.oauth_info['acgInfo'].present?
      process_auth_type(api, 'ccgInfo') if api.oauth_info['ccgInfo'].present?
    end
  end

  def get_base_url(environment)
    base_urls = {
      'development' => 'https://dev-api.va.gov',
      'production' => 'https://api.va.gov',
      'sandbox' => 'https://sandbox-api.va.gov',
      'staging' => 'https://staging-api.va.gov',
      'test' => 'https://dev-api.va.gov'
    }.freeze
    base_urls[environment]
  end

  def get_path(url_fragment, type)
    paths = {
      'claims' => {
        'acgInfo' => '/oauth2/claims/v1/.well-known/openid-configuration',
        'ccgInfo' => '/oauth2/claims/system/v1/.well-known/openid-configuration'
      },
      'benefits-documents' => {
        'ccgInfo' => '/oauth2/benefits-documents/system/v1/.well-known/openid-configuration'
      },
      'direct-deposit-management' => {
        'ccgInfo' => '/oauth2/direct-deposit-management/system/v1/.well-known/openid-configuration'
      },
      'clinical_health' => {
        'acgInfo' => '/oauth2/clinical-health/system/v1/.well-known/openid-configuration'
      },
      'community_care' => {
        'acgInfo' => '/oauth2/community-care/v1/.well-known/openid-configuration'
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
      'address_validation' => {
        'ccgInfo' => '/oauth2/va-profile/system/v1/.well-known/openid-configuration'
      },
      'contact_information' => {
        'ccgInfo' => '/oauth2/va-profile/system/v1/.well-known/openid-configuration'
      },
      'va_letter_generator' => {
        'ccgInfo' => '/oauth2/va-letter-generator/system/v1/.well-known/openid-configuration'
      },
      'veteran_verification' => {
        'acgInfo' => '/oauth2/veteran-verification/v1/.well-known/openid-configuration'
      },
      'pgd' => {
        'ccgInfo' => '/oauth2/pgd/system/v1/.well-known/openid-configuration'
      }
    }.freeze
    paths[url_fragment][type]
  end

  def process_auth_type(api, type)
    url_fragment = api[:url_fragment]
    environment = ENV.fetch('RAILS_ENV')
    p api.oauth_info
    api.oauth_info[type]['productionWellKnownConfig'] = get_base_url(environment) + get_path(url_fragment, type)
    environment = 'sandbox' if environment == 'production'
    api.oauth_info[type]['sandboxWellKnownConfig'] = get_base_url(environment) + get_path(url_fragment, type)
    p api.oauth_info
    api.save
  end
end
