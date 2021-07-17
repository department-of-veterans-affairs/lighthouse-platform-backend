# frozen_string_literal: true

# HealthCheck.setup do |config|
#   # uri prefix (no leading slash)
#   config.uri = 'platform-backend/health_check'
#
#   # Text output upon success
#   config.success = 'success'
#
#   # Text output upon failure
#   config.failure = 'health_check failed'
#
#   # Disable the error message to prevent /health_check from leaking
#   # sensitive information
#   config.include_error_in_response_body = false
#
#   # Log level (success or failure message with error details is sent to rails log unless this is set to nil)
#   config.log_level = 'debug'
#
#   # Timeout in seconds used when checking smtp server
#   config.smtp_timeout = 30.0
#
#   # http status code used when plain text error message is output
#   # Set to 200 if you want your want to distinguish between partial (text does not include success) and
#   # total failure of rails application (http status of 500 etc)
#
#   config.http_status_for_error_text = 500
#
#   # http status code used when an error object is output (json or xml)
#   # Set to 200 if you want to distinguish between partial (healthy property == false) and
#   # total failure of rails application (http status of 500 etc)
#
#   config.http_status_for_error_object = 500
#
#   # bucket names to test connectivity - required only if s3 check used, access permissions can be mixed
#   # config.buckets = { 'bucket_name' => %i[R W D] }
#
#   # You can customize which checks happen on a standard health check, eg to set an explicit list use:
#   config.standard_checks = %w[database migrations custom]
#
#   # Or to exclude one check:
#   config.standard_checks -= ['emailconf']
#
#   # You can set what tests are run with the 'full' or 'all' parameter
#   config.full_checks = %w[database migrations custom email cache redis resque-redis sidekiq-redis s3]
# end
