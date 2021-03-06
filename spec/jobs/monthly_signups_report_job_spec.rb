# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlySignupsReportJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { MonthlySignupsReportJob.perform_later }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  context 'creates an event when flippered' do
    subject(:job) { MonthlySignupsReportJob.perform_now }

    before do
      Flipper.enable(:alert_signups_report)
    end

    after do
      Flipper.disable(:alert_signups_report)
    end

    it 'with relevant data' do
      VCR.use_cassette('slack/report_200', match_requests_on: [:method]) do
        expect { job }
          .to change(Event, :count).by(1)
      end
    end
  end

  it 'executes perform' do
    allow(Slack::ReportService).to receive(:new).and_return(Struct.new(:send_report).new(nil))
    perform_enqueued_jobs { job }
  end
end
