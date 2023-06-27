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

  desc 'Populate Overview Page Content'
  task seedOverviewPageContent: :environment do
    Api.all.each do |api|
      next if api.api_metadatum.blank?

      puts "Processing #{api.api_metadatum.display_name}"

      case api.api_metadatum.display_name
      when 'Benefits Intake API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Upload VA benefits claims documents.
          - Get the statuses of previously uploaded benefits documents.
          - Validate that an individual document meets VA system file requirements.
        MARKDOWN
      when 'Benefits Reference Data API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Look up static information that is filtered and formatted for VA benefits claims.
          - Return a list of service branches, disabilities, intake-sites, countries, contention-types, and more.
        MARKDOWN
      when 'Provider Directory API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return list of VA healthcare providers, locations, specialities, and office hours.
          - Determine if a VA healthcare provider is taking patients.
        MARKDOWN
      when 'VA Facilities API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return active VA facilities including health facilities, benefits facilities, cemeteries, and vet centers.
          - Return geographic locations, addresses, phone numbers, available services, hours of operation, and more of active VA facilities.
          - Search for active VA facilities by geography, radius, services, facility IDs, and more.
        MARKDOWN
      when 'VA Forms API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return all VA Forms and their last revision date.
          - Find forms by their name.
        MARKDOWN
      when 'Veteran Confirmation API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Confirm an individual’s Title 38 Veteran status.
        MARKDOWN
      when 'Address Validation API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Validate an address submitted to VA Profile.
        MARKDOWN
      when 'Decision Reviews API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Create a higher level review.
          - Return contestable issues for a Veteran.
          - Create a notice of disagreement.
          - Return all available data on a notice of disagreement submission.
          - Create a supplemental claim.
          - Return all available data on supplemental claim submission.
          - Returns eligible appeals in the legacy process for a Veteran.

          ### Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](https://developer.va.gov/support/contact-us).
        MARKDOWN
      when 'Loan Guaranty API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Transmit post-close Loan Guaranty documents.
          - Register VA-affiliated API account to a Loan Guaranty service account.

          ### Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](https://developer.va.gov/support/contact-us).
        MARKDOWN
      when 'Veteran Verification', 'Veteran Service History and Eligibility'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Confirm an individual’s Title 38 Veteran status.
          - Return disability ratings of a Veteran.
          - Return the service history of a Veteran.
        MARKDOWN
      when 'Clinical Health API (FHIR)'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return demographic and health data of patients, including Veterans treated at VA facilities, for a clinician at the point of care.
          - Search for an individual patient’s conditions, medications, observations including vital signs and lab tests, and more.

          ### Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](https://developer.va.gov/support/contact-us).
        MARKDOWN
      when 'Community Care Eligibility API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return a probability of a VA patient’s eligibility for community care.
        MARKDOWN
      when 'Benefits Documents'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return all claims evidence documents associated with a claim ID.
          - Upload a file to a Veteran’s VBMS efolder.
        MARKDOWN
      when 'Contact Information API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return, update, and add records for an individual’s home address, phone number, and email address.
        MARKDOWN
      when 'Direct Deposit Management API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return, create, or update direct deposit banking information for disability and pension compensation.
        MARKDOWN
      when 'Education Benefits API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Determine Veteran eligibility for Post-9/11 GI Bill’s education benefits.
          - Return what education benefits the Veteran has already used.
          - Discover what educational benefits remain for a Veteran.
          - Determine a Veteran’s past educational enrollment.
        MARKDOWN
      when 'Guaranty Remittance API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return a loan guarantee certificate.
          - Submit loan to the VA for remittance.
          - Submit remediation evidence to the VA for a remitted loan.
          - Check a pre-close loan against VA policies.
        MARKDOWN
      when 'Loan Review API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Transmit post-close Loan Guaranty documents.

          ### Getting access
          **Sandbox:**To request sandbox access for this API, [contact us](https://developer.va.gov/support/contact-us).
        MARKDOWN
      when 'VA Letter Generator API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Get list of official VA letters that a Veteran is eligible for.
          - Generate real-time JSON-formatted and PDF letters.
        MARKDOWN
      when 'Appeals Status API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return statuses of legacy and Appeals Modernization Act (AMA) decision reviews and appeals.

          ### Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](https://developer.va.gov/support/contact-us).
        MARKDOWN
      when 'Benefits Claims API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Find all benefits claims for a Veteran.
          - Auto-establish and submit forms 21-526EZ, 21-0966, 21-22, and 21-22a with version 1.
          - Submit documents supporting a claim with version 1.
          - Return a Veteran ID with version 2.
          - Find all benefits claims by Veteran ID with version 2.
          - Submit Evidence Waiver 5103 with version 2.
        MARKDOWN
      when 'Patient Health API (FHIR)'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ### With this API you can
          - Return demographic and health data of patients, including Veterans treated at VA facilities.
          - Search for an individual patient’s appointments, conditions, immunizations, medications, observations including vital signs and lab tests, and more.
        MARKDOWN
      else
        puts "No overview page content for #{api.name}"
      end

      api.api_metadatum.save!
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
