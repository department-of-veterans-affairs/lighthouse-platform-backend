# frozen_string_literal: true

class TestUserEmail < ApplicationRecord
  include ApplicationHelper

  def get_deeplinks
    user = User.where(email: email).first
    links = ''
    links += single_link(user, 'community-care-eligibility', 'Community Care Eligibility API)', communityCare)
    links += single_link(user, 'patient-health', 'Patient Health API (FHIR))', health)
    links += single_link(user, 'benefits-claims', 'Benefits Claims API)', claims)
    links += single_link(user, 'veteran-verification', 'Veteran Verification API', verification)

    links.delete_suffix('\\n')
  end

  private

  def single_link(user, url_slug, name, condition)
    if condition
      "[#{name}](https://developer.va.gov#{generate_deeplink(url_slug, user)})\\n"
    else
      ''
    end
  end
end
