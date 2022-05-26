# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DynamoImportJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'executes perform' do
    allow(DynamoImportService).to receive(:new).and_return(Struct.new(:import_dynamo_events).new(nil))
    perform_enqueued_jobs { job }
  end
end
