# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SandboxMailer, type: :mailer do
  let(:sandbox_request) { build(:sandbox_signup_request, :generate_apis_after_parse) }
  let(:kong_consumer) { build(:kong_consumer) }
  let(:okta_consumers) { { acg: build(:okta_consumer) } }

  describe 'sends a welcome email to the consumer' do
    let(:mail) do
      SandboxMailer.consumer_sandbox_signup(sandbox_request,
                                            kong_consumer,
                                            okta_consumers,
                                            nil)
    end

    it 'renders the headers' do
      expect(mail.to).to eq([sandbox_request[:email]])
    end

    it 'renders the body' do
      expect(mail.body).to include(sandbox_request[:firstName])
      expect(mail.body).to include('If you find a bug or would like to make a feature request')
    end

    context 'with all of the provided information' do
      it 'displays the oauth information' do
        expect(mail.body).to include('Your OAuth client secret is:')
      end

      it 'displays the key_auth information' do
        expect(mail.body).to include('as an HTTP request header')
      end
    end

    context 'with no key_auth values' do
      let(:oauth_email) do
        SandboxMailer.consumer_sandbox_signup(sandbox_request,
                                              nil,
                                              okta_consumers,
                                              nil)
      end

      it 'hides the key_auth fields' do
        expect(oauth_email.body).not_to include('as an HTTP request header')
      end
    end

    context 'with no oauth values' do
      let(:key_auth_email) do
        SandboxMailer.consumer_sandbox_signup(sandbox_request,
                                              kong_consumer,
                                              nil,
                                              nil)
      end

      it 'hides the oauth fields' do
        expect(key_auth_email.body).not_to include("Here's your OAuth Client Secret:")
      end
    end
  end

  describe 'sends va_profile_distribution an email' do
    let(:mail) { SandboxMailer.va_profile_sandbox_signup(sandbox_request) }

    it 'renders the headers' do
      expect(mail.to).to eq([Figaro.env.va_profile_distribution])
    end

    it 'renders the body' do
      expect(mail.body).to include("<strong>First Name:</strong> #{sandbox_request[:firstName]}")
    end
  end
end
