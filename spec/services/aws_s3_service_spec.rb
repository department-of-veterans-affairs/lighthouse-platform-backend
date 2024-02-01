# frozen_string_literal: true

require 'rails_helper'

describe 'AwsS3Service' do
  it 'put_object' do
    VCR.use_cassette('aws/s3_put_object', allow_playback_repeats: true) do
      service = AwsS3Service.new
      response = service.put_object(
        bucket: 'bucket-name',
        key: 'dummy.txt',
        fileContents: 'this is dummy content',
        content_type: 'text/plain'
      )
      expect(response.etag).to eq('"d41d8cd98f00b204e9800998ecf8427e"')
    end
  end
end
