# frozen_string_literal: true

FactoryBot.define do
  factory :production_access_request, class: Hash do
    apis { Faker::Hipster.word }
    appDescription { 'A social media platform with one room.' }
    appImageLink { Faker::Internet.url(path: '/assets/app.jpeg') }
    appName { 'One to Bind Them' }
    breachManagementProcess { 'golem' }
    businessModel { 'magical rings >> profit' }
    centralizedBackendLog { 'non-existent' }
    distributingAPIKeysToCustomers { false }
    exposeVeteranInformationToThirdParties { false }
    is508Compliant { true }
    listedOnMyHealthApplication { false }
    logoIcon { 'https://dvp-oauth-application-directory-logos.s3-us-gov-west-1.amazonaws.com/AppleHealth+Logo+1024x1024.png' }
    logoLarge { 'https://dvp-oauth-application-directory-logos.s3-us-gov-west-1.amazonaws.com/AppleHealth+Logo+1024x1024.png' }
    medicalDisclaimerImageLink { Faker::Internet.url(path: '/assets/medicalDisclaimer.jpeg') }
    monitizationExplanation { 'n/a' }
    monitizedVeteranInformation { true }
    multipleReqSafeguards { 'golem' }
    namingConvention { 'overly-complicated' }
    organization { 'Sauron.INC' }
    patientWaitTimeImageLink { Faker::Internet.url(path: '/assets/patientWaitTime.jpeg') }
    phoneNumber { '(555) 555-5555' }
    piiStorageMethod { 'Locking away in the fires from whence it came.' }
    platforms { 'iOS' }
    policyDocuments { [Faker::Internet.url(path: '/tos')] }
    primaryContact { association :production_access_request_user }
    productionKeyCredentialStorage { 'stored in a volcano on mount doom' }
    productionOrOAuthKeyCredentialStorage { 'also stored in a volcano' }
    scopesAccessRequested { 'profile' }
    secondaryContact { association :production_access_request_user }
    signUpLink { [Faker::Internet.url(path: '/signup')] }
    statusUpdateEmails { [Faker::Internet.safe_email] }
    storePIIOrPHI { false }
    supportLink { [Faker::Internet.url(path: '/support')] }
    thirdPartyInfoDescription { 'n/a' }
    valueProvided { 'n/a' }
    vasiSystemName { Faker::Hipster.word }
    veteranFacing { true }
    vulnerabilityManagement { 'golem' }
    website { Faker::Internet.url }

    initialize_with { attributes }
  end
end
