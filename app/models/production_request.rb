# frozen_string_literal: true

class ProductionRequest < ApplicationRecord
  has_one :primary_contact, dependent: :destroy
  has_one :secondary_contact, dependent: :destroy

  validates :apis, presence: true
  validates :organization, presence: true
  validates :primary_contact, presence: true
  validates :secondary_contact, presence: true
  validates :status_update_emails, presence: true
  validates :value_provided, presence: true

  class << self
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def transform_params(params)
      {
        apis: params[:apis],
        app_description: params[:appDescription],
        app_name: params[:appName],
        breach_management_process: params[:breachManagementProcess],
        business_model: params[:businessModel],
        centralized_backend_log: params[:centralizedBackendLog],
        distributing_api_keys_to_customers: params[:distributingAPIKeysToCustomers],
        expose_veteran_information_to_third_parties: params[:exposeVeteranInformationToThirdParties],
        is_508_compliant: params[:is508Compliant],
        listed_on_my_health_application: params[:listedOnMyHealthApplication],
        monitization_explanation: params[:monitizationExplanation],
        monitized_veteran_information: params[:monitizedVeteranInformation],
        multiple_req_safeguards: params[:multipleReqSafeguards],
        naming_convention: params[:namingConvention],
        organization: params[:organization],
        phone_number: params[:phoneNumber],
        pii_storage_method: params[:piiStorageMethod],
        platforms: params[:platforms],
        production_key_credential_storage: params[:productionKeyCredentialStorage],
        production_or_oauth_key_credential_storage: params[:productionOrOAuthKeyCredentialStorage],
        scopes_access_requested: params[:scopesAccessRequested],
        store_pii_or_phi: params[:storePIIOrPHI],
        third_party_info_description: params[:thirdPartyInfoDescription],
        value_provided: params[:valueProvided],
        vasi_system_name: params[:vasiSystemName],
        veteran_facing: params[:veteranFacing],
        veteran_facing_description: params[:veteranFacingDescription],
        vulnerability_management: params[:vulnerabilityManagement],
        website: params[:website],
        # now process the slightly more complex transformations
        privacy_policy_url: extract_privacy_policy_url(policy_documents_param: params[:policyDocuments]),
        sign_up_link_url: extract_sign_up_link_url(sign_up_link_param: params[:signUpLink]),
        status_update_emails: extract_status_update_emails(status_update_emails_param: params[:statusUpdateEmails]),
        support_link_url: extract_support_link_url(support_link_param: params[:supportLink]),
        terms_of_service_url: extract_terms_of_service_url(policy_documents_param: params[:policyDocuments]),
        primary_contact: PrimaryContact.new(
          email: params[:primaryContact][:email],
          first_name: params[:primaryContact][:firstName],
          last_name: params[:primaryContact][:lastName]
        ),
        secondary_contact: SecondaryContact.new(
          email: params[:secondaryContact][:email],
          first_name: params[:secondaryContact][:firstName],
          last_name: params[:secondaryContact][:lastName]
        )
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def extract_privacy_policy_url(policy_documents_param:)
      return if policy_documents_param.blank?
      return if policy_documents_param.second.blank?

      policy_documents_param.second
    end

    def extract_sign_up_link_url(sign_up_link_param:)
      return if sign_up_link_param.blank?

      [sign_up_link_param].flatten.first
    end

    def extract_status_update_emails(status_update_emails_param:)
      status_update_emails_param.join(',')
    end

    def extract_support_link_url(support_link_param:)
      return if support_link_param.blank?

      [support_link_param].flatten.first
    end

    def extract_terms_of_service_url(policy_documents_param:)
      return if policy_documents_param.blank?

      policy_documents_param.first
    end
  end
end
