# frozen_string_literal: true

require 'rails_helper'

describe V0::Support, type: :request do
  describe 'receives contact-us based requests from consumers' do
    let(:request) { build(:support_request, :mock_front_end_request) }

    context 'with flipper enabled' do
      before do
        Flipper.enable :send_emails
      end

      after do
        Flipper.disable :send_emails
      end

      it 'sends an email to support' do
        email = double
        allow(SupportMailer).to receive(:consumer_support_email).and_return(email)
        expect(email).to receive(:deliver_later)
        post '/platform-backend/v0/support/contact-us', params: request
        expect(response.code).to eq('204')
      end
    end

    context 'with flipper disabled' do
      it 'does not send an email' do
        expect(SupportMailer).not_to receive(:consumer_support_email)
        post '/platform-backend/v0/support/contact-us', params: request
        expect(response.code).to eq('204')
      end
    end
  end

  describe 'receives contact-us based requests about publishing APIs' do
    let(:request) { build(:support_request, :set_publishing, :mock_front_end_request) }

    context 'with flipper enabled' do
      before do
        Flipper.enable :send_emails
      end

      after do
        Flipper.disable :send_emails
      end

      it 'sends an email to support' do
        email = double
        allow(SupportMailer).to receive(:publishing_support_email).and_return(email)
        expect(email).to receive(:deliver_later)
        post '/platform-backend/v0/support/contact-us', params: request
        expect(response.code).to eq('204')
      end
    end

    context 'with flipper disabled' do
      it 'does not send an email' do
        expect(SupportMailer).not_to receive(:publishing_support_email)
        post '/platform-backend/v0/support/contact-us', params: request
        expect(response.code).to eq('204')
      end
    end
  end
end
