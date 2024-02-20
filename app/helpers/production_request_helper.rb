# frozen_string_literal: true

module ProductionRequestHelper
  def build_api_references(apis:)
    ApiService.parse(apis, filter_lpb: true)
  end

  def extract_status_update_emails(status_update_emails_param:)
    status_update_emails_param.join(',')
  end

  def build_contact_reference(contact_info:, contact_type:)
    email = contact_info[:email]
    first_name = contact_info[:firstName]
    last_name = contact_info[:lastName]

    users = User.where('LOWER(email) = ?', email.downcase.strip)
    user = users.present? ? users.first : User.new(email: email.strip)
    user.first_name = first_name
    user.last_name = last_name

    ProductionRequestContact.new(user:, contact_type:)
  end

  def extract_privacy_policy_url(policy_documents_param:)
    return if policy_documents_param.blank?
    return if policy_documents_param.second.blank?

    policy_documents_param.second
  end

  def extract_sign_up_link_url(sign_up_link_param:)
    return if sign_up_link_param.blank?

    [sign_up_link_param].flatten.first
  end

  def extract_support_link_url(support_link_param:)
    return if support_link_param.blank?

    [support_link_param].flatten.first
  end

  def extract_terms_of_service_url(policy_documents_param:)
    return if policy_documents_param.blank?

    policy_documents_param.first
  end

  def oauth_public_key_to_json(oauth_public_key_param:)
    return if oauth_public_key_param.blank?

    oauth_public_key_param.to_json
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def create_production_request_record!(params:)
    prod_req = ProductionRequest.new
    prod_req.address_line_1 = params[:addressLine1]
    prod_req.address_line_2 = params[:addressLine2]
    prod_req.address_line_3 = params[:addressLine3]
    prod_req.apis = build_api_references(apis: params[:apis])
    prod_req.app_description = params[:appDescription]
    prod_req.app_name = params[:appName]
    prod_req.breach_management_process = params[:breachManagementProcess]
    prod_req.business_model = params[:businessModel]
    prod_req.centralized_backend_log = params[:centralizedBackendLog]
    prod_req.city = params[:city]
    prod_req.country = params[:country]
    prod_req.distributing_api_keys_to_customers = params[:distributingAPIKeysToCustomers]
    prod_req.expose_veteran_information_to_third_parties = params[:exposeVeteranInformationToThirdParties]
    prod_req.is_508_compliant = params[:is508Compliant]
    prod_req.listed_on_my_health_application = params[:listedOnMyHealthApplication]
    prod_req.monitization_explanation = params[:monitizationExplanation]
    prod_req.monitized_veteran_information = params[:monitizedVeteranInformation]
    prod_req.multiple_req_safeguards = params[:multipleReqSafeguards]
    prod_req.naming_convention = params[:namingConvention]
    prod_req.oauth_application_type = params[:oAuthApplicationType]
    prod_req.oauth_public_key = oauth_public_key_to_json(oauth_public_key_param: params[:oAuthPublicKey])
    prod_req.oauth_redirect_uri = params[:oAuthRedirectURI]
    prod_req.organization = params[:organization]
    prod_req.phone_number = params[:phoneNumber]
    prod_req.pii_storage_method = params[:piiStorageMethod]
    prod_req.platforms = params[:platforms]
    prod_req.primary_contact = build_contact_reference(
      contact_info: params[:primaryContact],
      contact_type: 'primary'
    )
    prod_req.privacy_policy_url = extract_privacy_policy_url(policy_documents_param: params[:policyDocuments])
    prod_req.production_key_credential_storage = params[:productionKeyCredentialStorage]
    prod_req.production_or_oauth_key_credential_storage = params[:productionOrOAuthKeyCredentialStorage]
    prod_req.secondary_contact = build_contact_reference(
      contact_info: params[:secondaryContact],
      contact_type: 'secondary'
    )
    prod_req.scopes_access_requested = params[:scopesAccessRequested]
    prod_req.sign_up_link_url = extract_sign_up_link_url(sign_up_link_param: params[:signUpLink])
    prod_req.state = params[:state]
    prod_req.status_update_emails = extract_status_update_emails(
      status_update_emails_param: params[:statusUpdateEmails]
    )
    prod_req.store_pii_or_phi = params[:storePIIOrPHI]
    prod_req.support_link_url = extract_support_link_url(support_link_param: params[:supportLink])
    prod_req.terms_of_service_url = extract_terms_of_service_url(policy_documents_param: params[:policyDocuments])
    prod_req.third_party_info_description = params[:thirdPartyInfoDescription]
    prod_req.value_provided = params[:valueProvided]
    prod_req.vasi_system_name = params[:vasiSystemName]
    prod_req.veteran_facing = params[:veteranFacing]
    prod_req.veteran_facing_description = params[:veteranFacingDescription]
    prod_req.vulnerability_management = params[:vulnerabilityManagement]
    prod_req.website = params[:website]
    prod_req.zip_code_5 = params[:zipCode5]
    prod_req.save!
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
