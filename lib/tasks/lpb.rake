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

  desc 'Fix category url_slug fields to their expected values'
  task fixCategoryUrlSlugValues: :environment do
    ApiCategory.all.each do |category|
      category.url_slug = case category.key
                          when 'loanGuaranty'
                            'loan-guaranty'
                          when 'vaForms'
                            'forms'
                          else
                            category.key
                          end
      category.save!
    end
  end

  desc 'Populate Overview Page Content'
  task seedOverviewPageContent: :environment do
    apis_with_content = []
    apis_without_content = []
    apis_without_metadata = []

    Api.all.each do |api|
      if api.api_metadatum.blank?
        apis_without_metadata.push(api.name)
        next
      end

      puts "Processing #{api.api_metadatum.display_name}"

      case api.api_metadatum.display_name
      when 'Benefits Intake API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Upload VA benefits claims documents.
          - Get the statuses of previously uploaded benefits documents.
          - Validate that an individual document meets VA system file requirements.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Benefits Reference Data API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Look up static information that is filtered and formatted for VA benefits claims.
          - Return a list of service branches, disabilities, intake-sites, countries, contention-types, and more.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Provider Directory API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return list of VA healthcare providers, locations, specialities, and office hours.
          - Determine if a VA healthcare provider is taking patients.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'VA Facilities API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return active VA facilities including health facilities, benefits facilities, cemeteries, and vet centers.
          - Return geographic locations, addresses, phone numbers, available services, hours of operation, and more of active VA facilities.
          - Search for active VA facilities by geography, radius, services, facility IDs, and more.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'VA Forms API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return all VA Forms and their last revision date.
          - Find forms by their name.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Veteran Confirmation API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Confirm an individual’s Title 38 Veteran status.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Address Validation API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Validate an address submitted to VA Profile.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Decision Reviews API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Create a Higher-Level Review.
          - Return contestable issues for a Veteran.
          - Create a Notice of Disagreement.
          - Return all available data on a Notice of Disagreement submission.
          - Create a Supplemental Claim.
          - Return all available data on a Supplemental Claim submission.
          - Returns eligible appeals in the legacy process for a Veteran.

          ## Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](/support/contact-us).

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Loan Guaranty API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Transmit post-close Loan Guaranty documents.
          - Register VA-affiliated API account to a Loan Guaranty service account.

          ## Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](/support/contact-us).

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Veteran Verification API', 'Veteran Service History and Eligibility API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Confirm an individual’s Title 38 Veteran status.
          - Return disability ratings of a Veteran.
          - Return the service history of a Veteran.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Clinical Health API (FHIR)'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return demographic and health data of patients, including Veterans treated at VA facilities, for a clinician at the point of care.
          - Search for an individual patient’s conditions, medications, observations including vital signs and lab tests, and more.

          ## Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](/support/contact-us).

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Community Care Eligibility API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return a probability of a VA patient’s eligibility for community care.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Benefits Documents API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return all claims evidence documents associated with a claim ID.
          - Upload a file to a Veteran’s VBMS efolder.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Contact Information API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return, update, and add records for an individual’s home address, phone number, and email address.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Direct Deposit Management API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return, create, or update direct deposit banking information for disability and pension compensation.
          - Determine eligibility for direct deposit including detection of payments.
          - Validate routing information.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Education Benefits API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Determine Veteran eligibility for Post-9/11 GI Bill’s education benefits.
          - Return what education benefits the Veteran has already used.
          - Discover what educational benefits remain for a Veteran.
          - Determine a Veteran’s past educational enrollment.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Guaranty Remittance API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return a loan guarantee certificate.
          - Submit loan to the VA for remittance.
          - Submit remediation evidence to the VA for a remitted loan.
          - Check a pre-close loan against VA policies.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Loan Review API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Transmit post-close Loan Guaranty documents.

          ## Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](/support/contact-us).

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'VA Letter Generator API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Get list of official VA letters that a Veteran is eligible for.
          - Generate real-time JSON-formatted and PDF letters.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Appeals Status API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return statuses of legacy and Appeals Modernization Act (AMA) decision reviews and appeals.

          ## Getting access
          **Sandbox:** To request sandbox access for this API, [contact us](/support/contact-us).

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Benefits Claims API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Find all benefits claims for a Veteran.
          - Auto-establish and submit forms 21-526EZ, 21-0966, 21-22, and 21-22a with version 1.
          - Submit documents supporting a claim with version 1.
          - Return a Veteran ID with version 2.
          - Find all benefits claims by Veteran ID with version 2.
          - Submit Evidence Waiver 5103 with version 2.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Patient Health API (FHIR)'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return demographic and health data of patients, including Veterans treated at VA facilities.
          - Search for an individual patient’s appointments, conditions, immunizations, medications, observations including vital signs and lab tests, and more.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Notice of Disagreements API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Create and submit a Notice of Disagreement.
          - Submit evidence for a Notice of Disagreement.
          - Find a Notice of Disagreement.
          - Return details about a specific Notice of Disagreement, including its status.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Supplemental Claims API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Create and submit a Supplemental Claim.
          - Submit evidence for a Supplemental Claim.
          - Find a Supplemental Claim.
          - Return details about a specific Supplemental Claim, including its status.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Legacy Appeals API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Return a list of a claimant's active legacy appeals which are not part of the Appeals Modernization Act (AMA) process.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Higher Level Reviews API', 'Higher-Level Reviews API'
        api.api_metadatum.display_name = 'Higher-Level Reviews API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          - Create and submit a Higher-Level Review.
          - Find a Higher-Level Review.
          - Return details about a specific Higher-Level Review, including its status.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      when 'Appealable Issues API'
        api.api_metadatum.overview_page_content = <<~MARKDOWN
          ## With this API you can
          -  Return all appealable issues for a specific Veteran.

          ## Getting access
          **Sandbox:** [Start developing](/explore/api/{API_URL_SLUG}/sandbox-access) immediately with test data.

          **Production:** Timeline for getting production access varies. [Learn more about getting production access](/onboarding/request-prod-access).
        MARKDOWN
      else
        puts "No overview page content for #{api.api_metadatum.display_name}"
        apis_without_content.push api.api_metadatum.display_name
        next
      end

      apis_with_content.push api.api_metadatum.display_name

      api.api_metadatum.save!
    end

    puts "These apis were updated: display_names(#{apis_with_content.join(', ')})"
    # rubocop:disable Layout/LineLength
    puts "These apis were not updated because their display name did not match any of the values in the switch case: display_names(#{apis_without_content.join(', ')})"
    puts "These apis were not updated because they did not have api_metadatum: names(#{apis_without_metadata.join(', ')})"
    # rubocop:enable Layout/LineLength
  end

  desc 'Update API descriptions'
  task updateApiDescriptions: :environment do
    apis_with_content = []
    apis_without_content = []
    apis_without_metadata = []

    Api.all.each do |api|
      next if api.api_metadatum.blank?

      case api.api_metadatum.display_name
      when 'Benefits Claims API'
        api.api_metadatum.description = 'Find and submit Veteran benefits claims.'
      when 'Benefits Intake API'
        api.api_metadatum.description = 'Upload and get the status of VA benefits documents.'
      when 'Benefits Reference Data API'
        api.api_metadatum.description = 'Look up data and codes that help with VA benefits claims.'
      when 'Contact Information API'
        api.api_metadatum.description = 'Find, update, and add Veteran contact information.'
      when 'Loan Review API'
        api.api_metadatum.description = 'Transmit post-close Loan Guaranty documents.'
      when 'VA Facilities API'
        # rubocop:disable Layout/LineLength
        api.api_metadatum.description = 'Find VA facilities, including their addresses, available services, and hours of operation.'
        # rubocop:enable Layout/LineLength
      else
        puts "No updated description for #{api.api_metadatum.display_name}"
        apis_without_content.push api.api_metadatum.display_name
        next
      end

      apis_with_content.push api.api_metadatum.display_name

      api.api_metadatum.save!
    end

    puts "These apis were updated: display_names(#{apis_with_content.join(', ')})"
    # rubocop:disable Layout/LineLength
    puts "These apis were not updated because their display name did not match any of the values in the switch case: display_names(#{apis_without_content.join(', ')})"
    puts "These apis were not updated because they did not have api_metadatum: names(#{apis_without_metadata.join(', ')})"
    # rubocop:enable Layout/LineLength
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

  desc 'Fix Veteran Verification URL Slug'
  task updateVeteranVerificationUrlSlug: :environment do
    apis = ApiMetadatum.where(display_name: 'Veteran Service History and Eligibility API')
    apis.each do |api|
      api.url_slug = 'veteran-service-history-and-eligibility'
      api.save
    end
  end

  desc 'Export emails and deeplinks'
  task idmeEmailsExport: :environment do
    require 'csv'
    require 'set'
    puts 'Starting export for ID.me emails with deeplinks...'
    csv_file_name = 'test-users-with-deeplinks.csv'
    events = Event.where(event_type: 'sandbox_signup')
    events.each do |event|
      event_apis = event.content['apis'].split(',')
      event_apis.each do |event_api|
        if event_api == 'claims'
          TestUserEmail.upsert({ # rubocop:disable Rails/SkipsModelValidations
                                 email: event.content['email'],
                                 claims: true
                               }, unique_by: :email)
        end
        if event_api == 'communityCare'
          TestUserEmail.upsert({ # rubocop:disable Rails/SkipsModelValidations
                                 email: event.content['email'],
                                 communityCare: true
                               }, unique_by: :email)
        end
        if event_api == 'health'
          TestUserEmail.upsert({ # rubocop:disable Rails/SkipsModelValidations
                                 email: event.content['email'],
                                 health: true
                               }, unique_by: :email)
        end
        if event_api == 'verification'
          TestUserEmail.upsert({ # rubocop:disable Rails/SkipsModelValidations
                                 email: event.content['email'],
                                 verification: true
                               }, unique_by: :email)
        end
      end
    end
    puts 'All required signups added to test_user_emails table.'
    test_users = TestUserEmail.all
    CSV.open(csv_file_name, 'w') do |csv|
      csv << %w[email links]
      test_users.each do |user|
        csv << [user.email, user.get_deeplinks]
      end
    end
    puts 'Created and populated test-users-with-deeplinks.csv file.'
    csv_file = File.read(csv_file_name)
    s3 = AwsS3Service.new
    bucket = ENV.fetch('TEST_USERS_BUCKET')
    response = s3.put_object(bucket: bucket, key: csv_file_name, fileContents: csv_file, content_type: 'text/csv')
    if response.etag
      puts "File uploaded to S3 bucket"
    else
      puts 'An error occured doing s3.put_object'
    end
    puts 'End of export'
  end
end
