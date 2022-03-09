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
      desc 'Handles contact-us support requests'
      params do
        optional :apis, type: Array[String]
        optional :apiDescription, type: String
        optional :apiDetails, type: String
        optional :apiInternalOnly, type: Boolean
        optional :apiInternalOnlyDetails, type: String
        optional :apiOtherInfo, type: String
        optional :description, type: String
        requires :email, as: :requester, type: String
        requires :firstName, type: String
        requires :lastName, type: String
        optional :organization, type: String
      end

      post 'contact-us' do
        body false
        return unless Flipper.enabled? :send_emails

        if params[:type] == 'PUBLISHING'
          publishing_support_email declared(params)
        else
          consumer_support_email declared(params)
        end
      end
    end
  end
end
