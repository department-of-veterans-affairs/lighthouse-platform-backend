# frozen_string_literal: true

module V0
  class Support < V0::Base
    version 'v0'

    helpers do
      def publishing_support_email(request)
        SupportMailer.publishing_support_email(request).deliver_later
      end

      def consumer_support_email(request)
        SupportMailer.consumer_support_email(request).deliver_later
      end
    end

    resource 'support' do
      desc 'Handles contact-us support requests', deprecated: true
      params do
        requires :email, as: :requester, type: String, allow_blank: false
        requires :firstName, type: String, allow_blank: false
        requires :lastName, type: String, allow_blank: false
        optional :organization, type: String
        requires :type, type: String,
                        values: %w[DEFAULT PUBLISHING],
                        allow_blank: false
        given type: ->(val) { val == 'DEFAULT' } do
          optional :apis, type: Array[String]
          requires :description, type: String
        end
        given type: ->(val) { val == 'PUBLISHING' } do
          optional :apiDescription, type: String
          requires :apiDetails, type: String, allow_blank: false
          requires :apiInternalOnly, type: Boolean, allow_blank: false
          given apiInternalOnly: ->(val) { val } do
            requires :apiInternalOnlyDetails, type: String, allow_blank: false
          end
          optional :apiOtherInfo, type: String
        end
      end

      post 'contact-us/requests' do
        header 'Access-Control-Allow-Origin', request.host_with_port
        protect_from_forgery

        body false
        return unless Flipper.enabled? :send_emails

        email_params = declared(params, include_missing: false)
        if params[:type] == 'PUBLISHING'
          publishing_support_email email_params
        else
          consumer_support_email email_params
        end
      end
    end
  end
end
