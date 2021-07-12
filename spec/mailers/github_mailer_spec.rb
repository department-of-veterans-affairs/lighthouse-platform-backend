# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubMailer, type: :mailer do
  let(:body) do
    {
      alert: {
        secret_type: 'adafruit_io_key'
      },
      repository: {
        full_name: 'Codertocat/Hello-World',
        html_url: 'https://github.com/Codertocat/Hello-World'
      },
      organization: {
        login: 'Codertocat'
      }
    }
  end

  describe '#security_email' do
    it 'triggers correctly' do
      response = subject.security_email(body)
      expect(response['from'].unparsed_value).to eq('noreply@vasecretscanner.gov')
      expect(response[:to].unparsed_value).to eq('testing@example.com')
      expect(response.subject).to eq('Github Secret Scanner Alert')
      expect(response.body.class).to eq(Mail::Body)
    end
  end
end
