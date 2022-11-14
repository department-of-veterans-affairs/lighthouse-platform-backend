# frozen_string_literal: true

require 'rails_helper'

describe 'AwsSigv4Service' do
  let :expected_sigv4_policy do
    {
      acl: 'public-read',
      bucketName: 'bucket-name',
      contentType: 'image/png',
      key: 'original/image.png',
      logoUrls: [
        'https://bucket-name.s3.us-gov-west-1.amazonaws.com/40x40/image.png',
        'https://bucket-name.s3.us-gov-west-1.amazonaws.com/1024x1024/image.png'
      ],
      policy: 'eyJleHBpcmF0aW9uIjoiMjAyMi0xMS0wN1QxNjoyMzoxMVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJidWNrZXQtbmFtZSJ9LFsiZXEiLCIka2V5Iiwib3JpZ2luYWwvaW1hZ2UucG5nIl0seyJhY2wiOiJwdWJsaWMtcmVhZCJ9LFsiZXEiLCIkQ29udGVudC1UeXBlIiwiaW1hZ2UvcG5nIl0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1jcmVkZW50aWFsIjoiQVNJQVFXRVJUWVVJT1BBU0FNUExFLzIwMjIxMTA3L3VzLWdvdi13ZXN0LTEvczMvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1kYXRlIjoiMjAyMjExMDdUMTYwODExWiJ9LHsieC1hbXotc2VjdXJpdHktdG9rZW4iOiJzZXNzaW9uX3Rva2VuX3Nlc3Npb25fdG9rZW5fc2Vzc2lvbl90b2tlbl9zZXNzaW9uX3Rva2VuIn1dfQ==', # rubocop:disable Layout/LineLength
      resizeTriggerUrls: [
        'http://bucket-name.s3-website-us-gov-west-1.amazonaws.com/40x40/image.png',
        'http://bucket-name.s3-website-us-gov-west-1.amazonaws.com/1024x1024/image.png'
      ],
      s3RegionEndpoint: 's3.us-gov-west-1.amazonaws.com',
      xAmzAlgorithm: 'AWS4-HMAC-SHA256',
      xAmzCredential: 'ASIAQWERTYUIOPASAMPLE/20221107/us-gov-west-1/s3/aws4_request',
      xAmzDate: '20221107T160811Z',
      xAmzExpires: 900,
      xAmzSecurityToken: 'session_token_session_token_session_token_session_token',
      xAmzSignature: 'f4e8e7259ddbdc12244e662da83a37579a708dd1e1da71829d64443700879381'
    }
  end

  it 'service init' do
    VCR.use_cassette('aws/sts_assume_role', allow_playback_repeats: true, match_requests_on: [:method]) do
      service = AwsSigv4Service.new
      service.set_key('image.png')
      service.set_content_type('image/png')

      Timecop.freeze(DateTime.parse('2022/11/07 T16:08:11Z'))
      response = service.sign_request
      Timecop.return

      expect(response.to_json).to eq(expected_sigv4_policy.to_json)
    end
  end
end
