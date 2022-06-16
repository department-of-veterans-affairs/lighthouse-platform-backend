# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackgroundJobEnforcer, type: :model do
  describe 'background job enforcer' do
    subject do
      create(:background_job_enforcer)
    end

    it 'accepts a job_type and date' do
      expect(subject).to be_valid
    end
  end

  describe 'with innacurate data' do
    subject do
      BackgroundJobEnforcer.new(job_type: nil, date: Time.zone.today)
    end

    it 'is invalid without job_type' do
      expect(subject).not_to be_valid
    end
  end

  describe 'with duplicate dates' do
    let(:bot_create) { create(:background_job_enforcer) }
    subject do
      BackgroundJobEnforcer.create(job_type: bot_create[:job_type], date: Time.zone.today)
    end

    before do
      bot_create
    end

    it 'fails to create the latter' do
      expect { subject }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
