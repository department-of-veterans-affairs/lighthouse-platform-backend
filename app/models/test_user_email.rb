# frozen_string_literal: true

class TestUserEmail < ApplicationRecord
  include ApplicationHelper

  def get_deeplinks
    user = User.where(email: self.email).first
    links = ''
    links += "[https://developer.va.gov#{generate_deeplink('veteran-verification', user)}](Veteran Verification API)\\n" if self.verification
    links += "[https://developer.va.gov#{generate_deeplink('community-care-eligibility', user)}](Community Care Eligibility API)\\n" if self.communityCare
    links += "[https://developer.va.gov#{generate_deeplink('clinical-health', user)}](Clinical Health API)\\n" if self.clinicalHealth
    links += "[https://developer.va.gov#{generate_deeplink('patient-health', user)}](Patient Health API (FHIR))\\n" if self.health
    links += "[https://developer.va.gov#{generate_deeplink('benefits-claims', user)}](Benefits Claims API)\\n" if self.claims

    links.delete_suffix("\\n")
  end
end
