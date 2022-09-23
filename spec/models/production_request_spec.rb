# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductionRequest, type: :model do
  subject do
    ProductionRequest.new(ProductionRequest.transform_params(production_request_params))
  end

  let(:production_request_params) { build(:production_access_request) }

  describe 'tests a valid ProductionRequest model' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'tests an invalid ProductionRequest model' do
    it "is invalid without an 'apis' attribute" do
      subject.apis = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without an 'organization' attribute" do
      subject.organization = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'primary_contact' association" do
      subject.primary_contact = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'secondary_contact' association" do
      subject.secondary_contact = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'status_update_emails' attribute" do
      subject.status_update_emails = nil
      expect(subject).not_to be_valid
    end

    it "is invalid without a 'value_provided' attribute" do
      subject.value_provided = nil
      expect(subject).not_to be_valid
    end
  end

  describe '#transform_params' do
    context 'transforming simple params' do
      simple_front_end_params_to_model_mappings = {
        apis: :apis,
        appDescription: :app_description,
        appName: :app_name,
        breachManagementProcess: :breach_management_process,
        businessModel: :business_model,
        centralizedBackendLog: :centralized_backend_log,
        distributingAPIKeysToCustomers: :distributing_api_keys_to_customers,
        exposeVeteranInformationToThirdParties: :expose_veteran_information_to_third_parties,
        is508Compliant: :is_508_compliant,
        listedOnMyHealthApplication: :listed_on_my_health_application,
        monitizationExplanation: :monitization_explanation,
        monitizedVeteranInformation: :monitized_veteran_information,
        multipleReqSafeguards: :multiple_req_safeguards,
        namingConvention: :naming_convention,
        organization: :organization,
        phoneNumber: :phone_number,
        piiStorageMethod: :pii_storage_method,
        platforms: :platforms,
        productionKeyCredentialStorage: :production_key_credential_storage,
        productionOrOAuthKeyCredentialStorage: :production_or_oauth_key_credential_storage,
        scopesAccessRequested: :scopes_access_requested,
        storePIIOrPHI: :store_pii_or_phi,
        thirdPartyInfoDescription: :third_party_info_description,
        valueProvided: :value_provided,
        vasiSystemName: :vasi_system_name,
        veteranFacing: :veteran_facing,
        veteranFacingDescription: :veteran_facing_description,
        vulnerabilityManagement: :vulnerability_management,
        website: :website
      }

      simple_front_end_params_to_model_mappings.each do |front_end_param, model_equivalent|
        it "transforms '#{front_end_param}' to '#{model_equivalent}'" do
          mapped_values = ProductionRequest.transform_params(production_request_params)
          expect(mapped_values[model_equivalent]).to eq(production_request_params[front_end_param])
        end
      end
    end

    context 'transforming complex params' do
      it "transforms 'primaryContact' to 'primary_contact'" do
        test_value = {
          email: 'batman@gmail.com',
          firstName: 'Bruce',
          lastName: 'Wayne'
        }
        production_request_params[:primaryContact] = test_value

        result = ProductionRequest.transform_params(production_request_params)

        expect(result[:primary_contact].email).to eq(test_value[:email])
        expect(result[:primary_contact].first_name).to eq(test_value[:firstName])
        expect(result[:primary_contact].last_name).to eq(test_value[:lastName])
      end

      it "transforms 'secondaryContact' to 'secondary_contact'" do
        test_value = {
          email: 'robin@gmail.com',
          firstName: 'Dick',
          lastName: 'Grayson'
        }
        production_request_params[:secondaryContact] = test_value

        result = ProductionRequest.transform_params(production_request_params)

        expect(result[:secondary_contact].email).to eq(test_value[:email])
        expect(result[:secondary_contact].first_name).to eq(test_value[:firstName])
        expect(result[:secondary_contact].last_name).to eq(test_value[:lastName])
      end

      describe "transforming 'policyDocuments'" do
        context "when 'policyDocuments' is nil" do
          test_value = nil

          it "sets 'terms_of_service_url' to nil" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:terms_of_service_url]).to be_nil
          end

          it "sets 'privacy_policy_url' to nil" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:privacy_policy_url]).to be_nil
          end
        end

        context "when 'policyDocuments' is an empty array" do
          test_value = []

          it "sets 'terms_of_service_url' to nil" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:terms_of_service_url]).to be_nil
          end

          it "sets 'privacy_policy_url' to nil" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:privacy_policy_url]).to be_nil
          end
        end

        context "when 'policyDocuments' is a single-element array" do
          test_value = ['http://www.acme.com/tos']

          it "sets 'terms_of_service_url' to the single-element value" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:terms_of_service_url]).to eq(test_value.first)
          end

          it "sets 'privacy_policy_url' to nil" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:privacy_policy_url]).to be_nil
          end
        end

        context "when 'policyDocuments' is a two-element array" do
          test_value = ['http://www.acme.com/tos', 'http://www.acme.com/privy']

          it "sets 'terms_of_service_url' to the first index value" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:terms_of_service_url]).to eq(test_value.first)
          end

          it "sets 'policyDocuments' to the second index value" do
            production_request_params[:policyDocuments] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:privacy_policy_url]).to eq(test_value.second)
          end
        end
      end

      describe "transforming 'signupLink'" do
        context "when 'signupLink' is nil" do
          test_value = nil

          it "sets 'sign_up_link_url' to nil" do
            production_request_params[:signUpLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:sign_up_link_url]).to be_nil
          end
        end

        context "when 'signupLink' is an empty array" do
          test_value = []

          it "sets 'sign_up_link_url' to nil" do
            production_request_params[:signUpLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:sign_up_link_url]).to be_nil
          end
        end

        context "when 'signupLink' is a single-element array" do
          test_value = ['http://www.acme.com/signup']

          it "sets 'sign_up_link_url' to the single-element value" do
            production_request_params[:signUpLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:sign_up_link_url]).to eq(test_value.first)
          end
        end

        context "when 'signupLink' is a string" do
          test_value = 'http://www.acme.com/signup'

          it "sets 'sign_up_link_url' to the string value" do
            production_request_params[:signUpLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:sign_up_link_url]).to eq(test_value)
          end
        end
      end

      describe "transforming 'supportLink'" do
        context "when 'supportLink' is nil" do
          test_value = nil

          it "sets 'support_link_url' to nil" do
            production_request_params[:supportLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:support_link_url]).to be_nil
          end
        end

        context "when 'supportLink' is an empty array" do
          test_value = []

          it "sets 'support_link_url' to nil" do
            production_request_params[:supportLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:support_link_url]).to be_nil
          end
        end

        context "when 'supportLink' is a single-element array" do
          test_value = ['http://www.acme.com/support']

          it "sets 'support_link_url' to the single-element value" do
            production_request_params[:supportLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:support_link_url]).to eq(test_value.first)
          end
        end

        context "when 'supportLink' is a string" do
          test_value = 'http://www.acme.com/support'

          it "sets 'support_link_url' to the string value" do
            production_request_params[:supportLink] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:support_link_url]).to eq(test_value)
          end
        end
      end

      describe "transforming 'statusUpdateEmails'" do
        context "when 'statusUpdateEmails' is a single-element array" do
          test_value = ['status_updates@acme.org']

          it "sets 'status_update_emails' to a string" do
            production_request_params[:statusUpdateEmails] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:status_update_emails]).to eq(test_value.first)
          end
        end

        context "when 'statusUpdateEmails' is a multi-element array" do
          test_value = ['status_updates@acme.org', 'more_status_updates@acme.org']

          it "sets 'status_update_emails' to a csv string" do
            production_request_params[:statusUpdateEmails] = test_value

            result = ProductionRequest.transform_params(production_request_params)

            expect(result[:status_update_emails]).to eq(test_value.join(','))
          end
        end
      end
    end
  end
end
