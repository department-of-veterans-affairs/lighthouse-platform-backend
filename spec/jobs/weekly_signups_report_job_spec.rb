# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklySignupsReportJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { WeeklySignupsReportJob.perform_later }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'executes perform' do
    allow(Slack::ReportService).to receive(:new).and_return(Struct.new(:send_weekly_report).new(nil))
    perform_enqueued_jobs { job }
  end
end
