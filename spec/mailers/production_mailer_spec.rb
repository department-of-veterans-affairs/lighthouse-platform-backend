# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductionMailer, type: :mailer do
  let(:production_request) { build(:production_access_request) }
  let(:contact) { production_request[:primaryContact] }

  describe 'sends support email on production access request' do
    let(:mail) { ProductionMailer.support_production_access(production_request) }

    it 'renders the headers' do
      expect(mail.subject).to eq("Production Access Requested for #{production_request[:organization]}")
      expect(mail.to).to eq([Figaro.env.support_email])
    end

    it 'renders the body' do
      expect(mail.body).to include(contact[:firstName])
      expect(mail.body).to include(production_request[:organization])
    end
  end

  describe 'sends the consumer an email confirmation' do
    let(:mail) { ProductionMailer.consumer_production_access(production_request) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your Request for Production Access is Submitted')
      expect(mail.to).to eq([contact[:email]])
    end

    it 'renders the body' do
      expect(mail.body).to include('<strong>What’s next?</strong>')
      expect(mail.body).to include('Submit your production access request.')
    end
  end
end
