# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OktaDriftJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { OktaDriftJob.perform_later }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'executes perform' do
    allow(Okta::SandboxService).to receive(:new).and_return(true)
    allow(Okta::ProductionService).to receive(:new).and_return(true)
    perform_enqueued_jobs { job }
  end
end
