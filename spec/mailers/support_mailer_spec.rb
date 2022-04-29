# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportMailer, type: :mailer do
  describe 'sends the support team an email when an individual reaches out' do
    context 'for general support' do
      let(:request) { build(:support_request) }
      let(:mail) { SupportMailer.consumer_support_email(request) }

      it 'renders the headers' do
        expect(mail.subject).to eq('Support Needed')
        expect(mail.to).to eq([Figaro.env.support_email])
        expect(mail.from).to eq(request[:email].to_s)
      end

      it 'renders the body' do
        expect(mail.body).to include(request[:firstName])
        expect(mail.body).to include(request[:requester])
      end
    end

    context 'for publishing support' do
      let(:request) { build(:support_request, :set_publishing) }
      let(:mail) { SupportMailer.publishing_support_email(request) }

      it 'renders the headers' do
        expect(mail.subject).to eq('Publishing Support Needed')
        expect(mail.to).to eq([Figaro.env.support_email])
        expect(mail.from).to eq(request[:email].to_s)
      end

      it 'renders the body' do
        expect(mail.body).to include(request[:firstName])
        expect(mail.body).to include(request[:requester])
      end
    end
  end
end
