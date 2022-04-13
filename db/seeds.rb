# frozen_string_literal: true

columns = [ :url ]
values =  HTTParty.get('https://urlhaus.abuse.ch/downloads/text/').body
                                                                  .split("\r\n")
                                                                  .delete_if { |line| line.starts_with?('#') }
                                                                  .map { |line| [line] }
MaliciousUrl.import columns, values, validate: false, on_duplicate_key_ignore: true


appeals_category = ApiCategory.create(
  name: 'Appeals APIs',
  key: 'appeals',
  short_description: 'Enables managing benefit decision appeals on behalf of a Veteran.',
  consumer_docs_link_text: 'Read the consumer onboarding guide for getting production access',
  overview: <<~MARKDOWN
    ## Allows internal VA users to manage Veterans’ decision review requests per the [Appeals Modernization Act (AMA)](https://benefits.va.gov/benefits/appeals.asp) or the legacy benefits appeals process. 

    Allows you to submit, manage, or check the status of decision reviews (appeals) related to VA benefits claims. [Review the latest release notes](/release-notes/appeals).
  MARKDOWN
)
benefits_category = ApiCategory.create(
  name: 'Benefits APIs',
  key: 'benefits',
  short_description: 'Enables approved organizations to submit benefits-related PDFs and access information on a Veteran’s behalf.',
  consumer_docs_link_text: 'Read the consumer onboarding guide for getting production access',
  veteran_redirect_link_url: 'https://www.va.gov/claim-or-appeal-status/',
  veteran_redirect_link_text: 'benefits or appeals claim status',
  veteran_redirect_message: 'Are you a Veteran or a Veteran representative? Check your',
  overview: <<~MARKDOWN
    ## Enables electronic submission and status tracking of non-medical, VA-related benefit claims.

    Our benefits APIs allow you to submit and track electronic benefits claims, submit PDF claims and supplemental documentation, and more. Using these APIs allows you to speed up claims processing when compared to traditional mail or fax submissions. Read the API documentation to find out which claims these APIs handle. [Review the latest release notes](/release-notes/benefits).
  MARKDOWN
)
facilities_category = ApiCategory.create(
  name: 'Facilities APIs',
  key: 'facilities',
  short_description: 'Use the VA Facilities API to find relevant information about a specific VA facility.',
  consumer_docs_link_text: 'Learn about getting production access using open data APIs',
  veteran_redirect_link_url: 'https://www.va.gov/find-locations/',
  veteran_redirect_link_text: "Find the facility that's right for you",
  veteran_redirect_message: 'Are you a Veteran?',
  overview: <<~MARKDOWN
    ## Use the VA Facilities API to find information about a specific VA facility. 

    This API uses open data to return contact information, location, hours of operation and available services for VA facilities. For medical facilities only, we provide data on appointment wait times and patient satisfaction. [Review the latest release notes](/release-notes/facilities).
  MARKDOWN
)
health_category = ApiCategory.create(
  name: 'Health APIs',
  key: 'health',
  short_description: 'Use our APIs to build tools that help Veterans manage their health.',
  consumer_docs_link_text: 'Read the consumer onboarding guide for getting production access',
  overview: (<<~MARKDOWN
    ## Use our Health APIs to build tools that help Veterans manage their health, view their VA medical records, share their health information, and determine potential eligibility for community care. While these APIs allow greater access to health data, they do not currently allow submission of medical claims. 

    VA’s Health APIs use [HL7’s Fast Healthcare Interoperability Resources (FHIR) framework](https://www.hl7.org/fhir/overview.html) for providing healthcare data in a standardized format. FHIR solutions are built from a set of modular components, called resources, which can be easily assembled into working systems that solve real world clinical and administrative problems. 

    When you register for access to the Health APIs, you will be granted access to a synthetic set of data (provided by the MITRE Corporation) that mimics real Veteran demographics. The associated clinical resources include data generated from disease models covering up to a dozen of the most common Veteran afflictions. [Review the latest release notes](/release-notes/health).

    _VA is a supporter of the [CARIN Alliance](https://www.carinalliance.com/) Code of Conduct._
  MARKDOWN
  ), quickstart: <<~MARKDOWN
    VA’s Health APIs allow a user/application to make queries that will return health records in FHIR format, without interacting with or understanding the inner workings of VA systems.

    The database that powers the development environment is populated with synthetic Veteran data provided by MITRE Corporation. The data contains sample Veteran health records (both living and deceased) that mimic real Veteran demographics. The associated clinical resources include data generated from disease models covering up to a dozen of the most common Veteran afflictions.

    The Community Care Eligibility API also allows a user/application to retrieve an array of different Veteran eligibilities from a synthetic dataset.

    ## Development API access

    The VA API Platform uses the [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html) standard to allow Veterans to authorize third-party applications to access data on their behalf. Some Health APIs also use the [SMART on FHIR](http://docs.smarthealthit.org/) profile. Both OpenID Connect and SMART on FHIR are built on OAuth 2.

    ### What is the criteria to be considered for Development API access?

    The following basic information should be provided:

     * Your name
     * Email address
     * Organization name
     * OAuth Redirect URI

    ### What happens after I am approved?

    You will receive an email from the VA API team notifying you of your approval, and it will include a new Client ID and Secret for your application. The base URI for the Health API endpoints are:

     * `https://api.va.gov/services/fhir/v0/argonaut/data-query/`
     * `https://api.va.gov/services/fhir/v0/dstu2/`
     * `https://api.va.gov/services/fhir/v0/r4/`
     * `https://api.va.gov/services/community-care/v0/eligibility`

    Accordingly, the FHIR conformance statements can be retrieved from:

     * `https://api.va.gov/services/fhir/v0/argonaut/data-query/metadata`
     * `https://api.va.gov/services/fhir/v0/dstu2/metadata`
     * `https://api.va.gov/services/fhir/v0/r4/metadata`

    You will also be provided with a set of test accounts to use that will allow you to access specific synthetic data patient records.

    ## Developer Guidelines

    Below are guidelines you should follow to be successful in your VA API integration.

    ### Data Refresh

    The APIs accessed via the Development environment are using the same underlying logic as VA’s production APIs; only the underlying data store is different. The synthetic data store is static and is not refreshed at the same intervals as production.

    ### Usage

    API usage is not restricted within the Development environment.
  MARKDOWN
)
loan_guaranty_category = ApiCategory.create(
  name: 'Loan Guaranty APIs',
  key: 'loanGuaranty',
  short_description: 'Enables electronic submission and status tracking of non-medical, VA-related benefit claims.',
  consumer_docs_link_text: 'Read the consumer onboarding guide for getting production access',
  overview: <<~MARKDOWN
    ## Help approved lenders automate and navigate the VA home loan process.

    Our Loan Guaranty (LGY) APIs assist with processing and guaranteeing VA home loans. [Review the latest release notes](/release-notes/loanGuaranty).
  MARKDOWN
)
forms_category = ApiCategory.create(
  name: 'Forms APIs',
  key: 'vaForms',
  short_description: 'Look up VA forms and check for new versions.',
  consumer_docs_link_text: 'Learn about getting production access using open data APIs',
  veteran_redirect_link_url: 'https://www.va.gov/find-forms/',
  veteran_redirect_link_text: 'Find the forms you need',
  veteran_redirect_message: 'Are you a Veteran?',
  overview: <<~MARKDOWN
    ## Use this API to stay up-to-date on VA forms.

    This API uses open data to make it easier to keep up with the ever-changing landscape of VA forms. This API indexes data sourced from [VA.gov](https://www.va.gov/vaforms/search_action.asp), creating unique hashes for each version of a form and allowing quick lookup. [Review the latest release notes](/release-notes/vaForms).
  MARKDOWN
)
veteran_verification_category = ApiCategory.create(
  name: 'Veteran Verification APIs',
  key: 'verification',
  short_description: 'Empowering Veterans to take control of their data and put it to work.',
  consumer_docs_link_text: 'Read the consumer onboarding guide for getting production access',
  overview: <<~MARKDOWN
    ## These APIs allow verification of Veteran status and data. They return service history, confirm Veteran status, and validate address information. 

    We’re giving Veterans better control of and access to their information – including their service history, Veteran status, discharge information, and more by working with government agencies and industry partners to help Veterans put their information to work. [Review the latest release notes](/release-notes/verification).
  MARKDOWN
)

appeals_status_api = Api.create(name: 'appeals')
appeals_status_api.update(
  acl: 'appeals',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/appeals-status/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'appeals'
  },
  api_metadatum_attributes: {
   description: 'Allows retrieval of all decision review request statuses (both legacy and AMA). Statuses are read only.',
   display_name: 'Appeals Status API',
   open_data: false,
   va_internal_only: true,
   url_fragment: 'appeals',
   api_category_attributes: {
     id: appeals_category.id
   }
  }
)

decision_reviews_api = Api.create(name: 'decision-reviews')
decision_reviews_api.update(
  acl: 'hlr',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/appeals-decision-reviews/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'decision_reviews'
  },
  api_metadatum_attributes: {
   description: 'Allows submission, management, and retrieval of decision review requests and details such as statuses in accordance with the AMA.',
   display_name: 'Decision Reviews API',
   open_data: false,
   va_internal_only: true,
   url_fragment: 'decision_reviews',
   api_category_attributes: {
     id: appeals_category.id
   }
  }
)

claims_api = Api.create(name: 'claims')
claims_api.update(
  acl: 'claims',
  auth_server_access_key: 'AUTHZ_SERVER_CLAIMS',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-claims/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'claims'
  },
  api_metadatum_attributes: {
   description: 'Submit and track claims',
   display_name: 'Benefits Claims API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'claims',
   oauth_info: {
     acgInfo: {
       baseAuthPath: '/oauth2/claims/v1',
       scopes: ['profile', 'openid', 'offline_access', 'claim.read', 'claim.write'],
     },
     ccgInfo: {
       baseAuthPath: '/oauth2/claims/system/v1',
       productionAud: 'ausajojxqhTsDSVlA297',
       sandboxAud: 'ausdg7guis2TYDlFe2p7',
       scopes: ['claim.read', 'claim.write'],
     },
   }.to_json,
   api_category_attributes: {
     id: benefits_category.id
   }
  }
)

benefits_intake_api = Api.create(name: 'benefits-intake')
benefits_intake_api.update(
  acl: 'vba_documents',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-intake/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'benefits'
  },
  api_metadatum_attributes: {
   description: 'Submit PDF claims',
   display_name: 'Benefits Intake API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'benefits',
   api_category_attributes: {
     id: benefits_category.id
   }
  }
)

benefits_reference_api = Api.create(name: 'benefits-reference-data')
benefits_reference_api.update(
  acl: 'benefits-reference-data',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-reference-data/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'benefitsReferenceData'
  },
  api_metadatum_attributes: {
   description: 'Look up data and codes for VA benefits claims',
   display_name: 'Benefits Reference Data API',
   open_data: true,
   va_internal_only: false,
   url_fragment: 'benefits_reference_data',
   api_category_attributes: {
     id: benefits_category.id
   }
  }
)

facilities_api = Api.create(name: 'va-facilities')
facilities_api.update(
  acl: 'va_facilities',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/facilities/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'facilities'
  },
  api_metadatum_attributes: {
   description: 'VA Facilities',
   display_name: 'VA Facilities API',
   open_data: true,
   va_internal_only: false,
   url_fragment: 'facilities',
   api_category_attributes: {
     id: facilities_category.id
   }
  }
)

loan_guaranty_api = Api.create(name: 'loan-guaranty')
loan_guaranty_api.update(
  acl: 'loan_guaranty',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/loan_guaranty_property/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'loan_guaranty'
  },
  api_metadatum_attributes: {
   description: 'Use the Loan Guaranty API to Manage VA Home Loans.',
   display_name: 'Loan Guaranty API',
   open_data: false,
   va_internal_only: true,
   url_fragment: 'loan_guaranty',
   api_category_attributes: {
     id: loan_guaranty_category.id
   }
  }
)

lgy_guaranty_remittance_api = Api.create(name: 'lgy-guaranty-remittance')
lgy_guaranty_remittance_api.update(
  auth_server_access_key: 'AUTHZ_SERVER_LOAN_GUARANTY',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/lgy-remittance/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'lgyGuarantyRemittance'
  },
  api_metadatum_attributes: {
   description: 'Lets lenders automate parts of the mortgage post-closing process.',
   display_name: 'Guaranty Remittance API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'lgy_guaranty_remittance',
   oauth_info: {
    ccgInfo: {
      baseAuthPath: '/oauth2/loan-guaranty/system/v1',
      productionAud: 'ausbts6ndxFQDyeBM297',
      sandboxAud: 'auseavl6o5AjGZr2n2p7',
      scopes: ['system.loan-remittance.read', 'system.loan-remittance.write', 'system.remediation-evidence.write'],
    },
  }.to_json,
   api_category_attributes: {
     id: loan_guaranty_category.id
   }
  }
)

forms_api = Api.create(name: 'va-forms')
forms_api.update(
  acl: 'va_forms',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/forms/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'vaForms'
  },
  api_metadatum_attributes: {
   description: 'Look up VA forms and check for new versions.',
   display_name: 'VA Forms API',
   open_data: true,
   va_internal_only: false,
   url_fragment: 'vaForms',
   api_category_attributes: {
     id: forms_category.id
   }
  }
)

address_validation_api = Api.create(name: 'address-validation')
address_validation_api.update(
  acl: 'internal-va:address_validation',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/address-validation/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'addressValidation'
  },
  api_metadatum_attributes: {
   description: 'Provides methods to standardize and validate addresses.',
   display_name: 'Address Validation API',
   open_data: false,
   va_internal_only: true,
   url_fragment: 'address_validation',
   api_category_attributes: {
     id: veteran_verification_category.id
   }
  }
)

veteran_confirmation_api = Api.create(name: 'veteran-confirmation')
veteran_confirmation_api.update(
  acl: 'veteran_confirmation',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/veteran-confirmation/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'confirmation'
  },
  api_metadatum_attributes: {
   description: 'Confirm Veteran status for a given person with an API key.',
   display_name: 'Veteran Confirmation API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'veteran_confirmation',
   api_category_attributes: {
     id: veteran_verification_category.id
   }
  }
)

veteran_verification_api = Api.create(name: 'veteran-verification')
veteran_verification_api.update(
  auth_server_access_key: 'AUTHZ_SERVER_VERIFICATION',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/veteran-verification/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'verification'
  },
  api_metadatum_attributes: {
   description: 'Confirm Veteran status for a given person, or get a Veteran’s service history or disability rating.',
   display_name: 'Veteran Verification API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'veteran_verification',
   oauth_info: {
    acgInfo: {
      baseAuthPath: '/oauth2/veteran-verification/v1',
      scopes: [
        'profile',
        'openid',
        'offline_access',
        'service_history.read',
        'disability_rating.read',
        'veteran_status.read',
      ],
    },
  }.to_json,
   api_category_attributes: {
     id: veteran_verification_category.id
   }
  }
)

community_care_api = Api.create(name: 'internal-community-care')
community_care_api.update(
  auth_server_access_key: 'AUTHZ_SERVER_COMMUNITYCARE',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/community-care-eligibility/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'communityCare'
  },
  api_metadatum_attributes: {
   description: "VA's Community Care Eligibility API utilizes VA's Facility API, VA's Enrollment & Eligibility system and others to satisfy requirements found in the VA's MISSION Act of 2018.",
   display_name: 'Community Care Eligibility API',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'community_care',
   oauth_info: {
    acgInfo: {
      baseAuthPath: '/oauth2/community-care/v1',
      scopes: [
        'profile',
        'openid',
        'offline_access',
        'launch/patient',
        'patient/CommunityCareEligibility.read',
      ],
    },
  }.to_json,
   api_category_attributes: {
     id: health_category.id
   }
  }
)

urgent_care_api = Api.create(name: 'urgent-care')
urgent_care_api.update(
  api_metadatum_attributes: {
   description: "The VA's Health Urgent Care Eligibility API supports industry standards (e.g., Fast Healthcare Interoperability Resources [FHIR]) and provides access to a Veteran's urgent care eligibility status.",
   display_name: 'Urgent Care Eligibility API (FHIR)',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'urgent_care',
   api_category_attributes: {
     id: health_category.id
   }
  }
)
urgent_care_api.deprecate!(deprecation_date: Time.parse('13 Jul 2020 00:00 EDT'),
                           deprecation_content: (<<~MARKDOWN
                              This API is deprecated and scheduled for deactivation in the 3rd quarter of 2020. 
                            MARKDOWN
                            ))
urgent_care_api.deactivate!(deactivation_date: Time.parse('20 Jul 2020 00:00 EDT'),
                            deactivation_content: (<<~MARKDOWN
                                Our Urgent Care Eligibility API was deactivated on July 20, 2020. The API and related 
                                documentation is no longer accessible. For more information, [contact us](/support/contact-us) 
                                or visit our [Google Developer Forum](https://groups.google.com/forum/m/#!forum/va-lighthouse).
                              MARKDOWN
                              ))

clinical_fhir_api = Api.create(name: 'clinical-fhir-api')
clinical_fhir_api.update(
  auth_server_access_key: 'AUTHZ_SERVER_HEALTH',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/fhir-clinical-health/metadata.json',
   environments_attributes: {
     name: ['sandbox', 'production']
   }
  },
  api_ref_attributes: {
   name: 'health'
  },
  api_metadatum_attributes: {
   description: 'Use to develop clinical-facing applications that improve access to and management of patient health data.',
   display_name: 'Clinical Health API (FHIR)',
   open_data: false,
   va_internal_only: true,
   url_fragment: 'clinical_health',
   oauth_info: {
    acgInfo: {
      baseAuthPath: '/oauth2/clinical-health/v1',
      scopes: [
        'profile',
        'openid',
        'offline_access',
        'fhirUser',
        'launch',
        'patient/Condition.read',
        'patient/Observation.read',
        'patient/Patient.read',
        'patient/Practitioner.read',
      ],
    },
  }.to_json,
   api_category_attributes: {
     id: health_category.id
   }
  }
)

fhir_health_api = Api.create(name: 'fhir-health')
fhir_health_api.update(
  auth_server_access_key: 'AUTHZ_SERVER_HEALTH',
  api_ref_attributes: {
   name: 'health'
  },
  api_metadatum_attributes: {
   description: 'Use the OpenID Connect and SMART on FHIR standards to allow Veterans to authorize third-party applications to access data on their behalf.',
   display_name: 'Veterans Health API (FHIR)',
   open_data: false,
   va_internal_only: false,
   url_fragment: 'fhir',
   oauth_info: {
      acgInfo: {
        baseAuthPath: '/oauth2/health/v1',
        scopes: [
          'profile',
          'openid',
          'offline_access',
          'launch/patient',
          'patient/AllergyIntolerance.read',
          'patient/Appointment.read',
          'patient/Condition.read',
          'patient/Device.read',
          'patient/DiagnosticReport.read',
          'patient/Immunization.read',
          'patient/Location.read',
          'patient/Medication.read',
          'patient/MedicationOrder.read',
          'patient/MedicationRequest.read',
          'patient/MedicationStatement.read',
          'patient/Observation.read',
          'patient/Organization.read',
          'patient/Patient.read',
          'patient/Practitioner.read',
          'patient/PractitionerRole.read',
          'patient/Procedure.read',
        ],
      },
      ccgInfo: {
        baseAuthPath: '/oauth2/health/system/v1',
        productionAud: 'aus8evxtl123l7Td3297',
        sandboxAud: 'aus8nm1q0f7VQ0a482p7',
        scopes: [
          'launch',
          'system/AllergyIntolerance.read',
          'system/Appointment.read',
          'system/Condition.read',
          'system/Coverage.read',
          'system/Coverage.write',
          'system/DiagnosticReport.read',
          'system/Immunization.read',
          'system/Location.read',
          'system/Medication.read',
          'system/MedicationOrder.read',
          'system/Observation.read',
          'system/Organization.read',
          'system/Patient.read',
        ],
      },
    }.to_json,
   api_category_attributes: {
     id: health_category.id
   },
   multi_open_api_intro: <<~MARKDOWN
    The VA's FHIR Health APIs allow consumers to develop applications using Veteran data. Please see the tabs below for the specific FHIR implementations. Data entered through the production environment Veterans Health API is held in the original data source for 36 hours before it is visible elsewhere, including in any patient-facing applications. This holding period exists to allow health care providers time to discuss health data, such as sensitive diagnoses, before the patient sees this data elsewhere.

    The following Veteran data is excluded from the 36 hour hold:
    * COVID lab tests
    * All immunizations

    > **NOTICE**: Lighthouse encourages using the R4 specification to conform with the [21st Century Cures Act](https://www.federalregister.gov/documents/2020/05/01/2020-07419/21st-century-cures-act-interoperability-information-blocking-and-the-onc-health-it-certification#h-13), which requires adoption of R4 by December 31, 2022.
   MARKDOWN
  }
)
ApiEnvironment.find_or_create_by(metadata_url: 'https://api.va.gov/internal/docs/fhir-r4/metadata.json',
                                 api: fhir_health_api,
                                 environment: Environment.find_or_create_by(name: 'sandbox'),
                                 key: 'r4',
                                 label: 'R4')
ApiEnvironment.find_or_create_by(metadata_url: 'https://api.va.gov/internal/docs/fhir-argonaut/metadata.json',
                                 api: fhir_health_api,
                                 environment: Environment.find_or_create_by(name: 'sandbox'),
                                 key: 'argonaut',
                                 label: 'Argonaut',
                                 api_intro: <<~MARKDOWN
                                  ## Argonaut Data Query

                                  The Argonaut Project is a joint project of major US EHR vendors to advance industry adoption of modern, open interoperability standards. VA’s FHIR Argonaut Data Query API is based upon the FHIR DSTU-2 specification, particularly the [Argonaut Data Query Implementation Guide](http://www.fhir.org/guides/argonaut/r2/index.html). As noted in the implementation guide, the resources and requirements supported by Argonaut are a subset of those profiles included in DSTU-2.

                                  The profiles included in VA’s Argonaut Data Query API are compliant with the FHIR Argonaut Data Query Implementation Guide and satisfy the following two following use cases:

                                   * Patient uses provider-approved web application to access health data
                                   * Patient uses provider-approved mobile app to access health data 
                                 MARKDOWN
                                )
ApiEnvironment.find_or_create_by(metadata_url: 'https://api.va.gov/internal/docs/fhir-dstu2/metadata.json',
                                 api: fhir_health_api,
                                 environment: Environment.find_or_create_by(name: 'sandbox'),
                                 key: 'dstu2',
                                 label: 'DSTU2',
                                 api_intro: <<~MARKDOWN
                                  ## DSTU2

                                  VA's FHIR DSTU-2 API is an industry accepted standard and consists of resources that represent granular clinical concepts, including health, administrative, and financial resources. The following describes the VA's implementation of HL7's FHIR DSTU-2 standard.
                                 MARKDOWN
                                )

ApiReleaseNote.create(api_metadatum_id: urgent_care_api.api_metadatum.id,
                      date: Date.strptime('July 21, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Our Urgent Care Eligibility API was deactivated on July 21, 2020. The API and related documentation is no longer accessible. For more information, [contact us](https://developer.va.gov/support/contact-us) or visit our [Google Developer Forum](https://groups.google.com/forum/m/#!forum/va-lighthouse)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: urgent_care_api.api_metadatum.id,
                      date: Date.strptime('July 13, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The Urgent Care Eligibility API is deprecated and scheduled for deactivation in the 3rd quarter of 2020.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: urgent_care_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The optional query parameter `prompt` has been added to the authorization flow.

                        - Supported prompts: login. If specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-saml-proxy/pull/111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: urgent_care_api.api_metadatum.id,
                      date: Date.strptime('July 30, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the Urgent Care Eligibility API
                      MARKDOWN
                     )


ApiReleaseNote.create(api_metadatum_id: appeals_status_api.api_metadatum.id,
                      date: Date.strptime('January 31, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Add Power of Attorney verification for future Appeals Version 1 [#2717](https://github.com/department-of-veterans-affairs/vets-api/pull/2717)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: appeals_status_api.api_metadatum.id,
                      date: Date.strptime('January 14, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Bug discovered and fixed for safe null requests [#2727](https://github.com/department-of-veterans-affairs/vets-api/pull/2727)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: appeals_status_api.api_metadatum.id,
                      date: Date.strptime('June 11, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Implement VA-required headers to retrieve status [#2024](https://github.com/department-of-veterans-affairs/vets-api/pull/2024)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: appeals_status_api.api_metadatum.id,
                      date: Date.strptime('May 23, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Add appeals service API [#1961](https://github.com/department-of-veterans-affairs/vets-api/pull/1961)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: decision_reviews_api.api_metadatum.id,
                      date: Date.strptime('January 11, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Release Notes for new Contestable Issues standalone endpoint

                        We added a new endpoint (`GET /contestable_issues/{decision_review_type}`) to the Decision Reviews API. This endpoint returns contestable issues for a specific Veteran. Using this endpoint lets you tailor your appeal submission flow based on the Veteran’s issues. 

                        This endpoint returns contestable issues for a single Veteran based on the Veteran’s social security number.
                        You can search for contestable issues based on these appeal types: higher_level_reviews, notice_of_disagreements, and supplemental_claims. 
                        The endpoint returns only issues that have been decided as of the receiptDate. 
                        Read the Decision Review API documentation to learn more.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: decision_reviews_api.api_metadatum.id,
                      date: Date.strptime('July 26, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Decision Reviews API version 2 Release Notes

                        Version 2 of the Decision Reviews API is now released with the following changes:

                        We've added a new key, `informalConferenceContact` (required when an informal conference is requested), which will allow us to support both Veteran and representative contacts for informal conferences.
                        We've updated the possible responses enum of `informalConferenceTime` to reflect the above  changes.
                        `socOptIn` is now required.
                        For the representative name, we've split `name` into `firstName` and `lastName` to be more flexible and allow more accurate entries.
                        The Veteran email field `emailAddressText` has been changed to `email`.

                        Added hlrCreateAddress to now accept an address for this API. This change follows NOD format:
                        -`addressLine1`
                        -`addressLine2`
                        -`addressLine3`
                        -`city`
                        -`stateCode` - enum of all 2-character state codes (see the documentation for more info)
                        -`countryCodeISO2`
                        -`zipCode5`
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: decision_reviews_api.api_metadatum.id,
                      date: Date.strptime('June 6, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Initial release of the Decision Review API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 24, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) We have turned back on the new Veteran first and last name field validations described in the May 17 release notes. In addition to these new validations, we will allow spaces in these fields, including leading and trailing spaces (white space). #6986

                        [#6986](https://github.com/department-of-veterans-affairs/vets-api/pull/6986)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 20, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) On May 17, we made changes to Veteran First and Last name field validations for the Benefits Intake API, which are described in a release note below. 

                        Based on the high number of errors being received, we are temporarily turning off these changes and reverting back to previous field requirements. We are working on updating the new validations to allow spaces and reduce the number of errors returned. 

                        When those changes are made, we will turn on the new validations, post an updated release note, and send a notification to all consumers.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 17, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) In order to further automate matches of submitted documents with Veterans downstream, the required Veteran First and Last name metadata fields now only allow alpha characters, dashes -, and forward slashes /. Additionally, these fields must be less than or equal to 50 characters. No numbers or other special characters may be submitted in these fields. 

                        Submissions with invalid characters will receive Error Status DOC102  "Invalid Veteran name (e.g. empty, invalid characters, or too long). Names must match the regular expression /^[a-zA-Z\-\/]{1,50}$/"

                        [#6882](https://github.com/department-of-veterans-affairs/vets-api/pull/6882)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('April 2, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) We added new error detail messages that provide additional detail for a small number of submissions returning the DOC202 ERROR code.
                        * Unidentified Mail: We could not associate this submission with a Veteran. Please verify the identifying information and resubmit.
                        * Duplicate Submission: This document was already uploaded, faxed, or mailed and was or is being processed. This is a duplicate submission and will not be processed.
                        * Blank Document: The attachment contains no content. Please verify the attachment and resubmit, if needed.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('March 29, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Version 0.0.1 of the Benefits Intake API was removed on March 29, 2021. Refer to [version 1.0.0](https://developer.va.gov/explore/benefits/docs/benefits?version=current) of the API and related documentation. For more information, [contact us](https://developer.va.gov/support/contact-us) or visit our [Google Developer Forum](https://groups.google.com/forum/m/#!forum/va-lighthouse).
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('March 1, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) The Benefits-Intake API now has a new claim/benefit selection option to help ensure submissions reach the correct business line so they can be processed as quickly as possible: [#6037](https://github.com/department-of-veterans-affairs/vets-api/pull/6037)

                        The existing businessLine metadata field can be empty, or it can contain the code to indicate a document is related to one of these claim/benefit types:

                        CMP – Compensation requests such as those related to disability, unemployment, and pandemic claims
                        PMC – Pension requests including survivor’s pension
                        INS – Insurance such as life insurance, disability insurance, and other health insurance
                        EDU – Education benefits, programs, and affiliations
                        VRE – Veteran Readiness & Employment such as employment questionnaires, employment discrimination, employment verification
                        BVA – Board of Veteran Appeals
                        FID – Fiduciary/financial appointee, including family member benefits
                        OTH – Other (which will be routed to CMP)

                        This change is currently optional, but may become a required field in a future iteration of the API.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('November 30, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Added uploaded PDF metadata (page count, total pages, document count, and document dimensions) to the DB and in the HTTP response:
                        * Database migration [#5380](https://github.com/department-of-veterans-affairs/vets-api/pull/5380)
                        * JSON metadata stored in DB and added to the status check response [#5303](https://github.com/department-of-veterans-affairs/vets-api/pull/5303)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('October 7, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Add support for base64 encoding [#3995](https://github.com/department-of-veterans-affairs/vets-api/pull/3395)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 29, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) New `expired` status added to individual status endpoint [#3353](https://github.com/department-of-veterans-affairs/vets-api/pull/3353)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('August 19, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Validation on document page size [#3213](https://github.com/department-of-veterans-affairs/vets-api/pull/3213)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 24, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Cache statuses for /uploads/report endpoint [#3158](https://github.com/department-of-veterans-affairs/vets-api/pull/3158)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 11, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Revert changes to error handling [#3150](https://github.com/department-of-veterans-affairs/vets-api/pull/3150)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 9, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Announced support for v1, which includes 2 breaking changes:
                        * "vbms" status [#3027](https://github.com/department-of-veterans-affairs/vets-api/pull/3027)
                        * Updates to error handling [#3053](https://github.com/department-of-veterans-affairs/vets-api/pull/3053)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('June 11, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Adding Metadata Endpoints for V0 and V1 end points [#3093](https://github.com/department-of-veterans-affairs/vets-api/pull/3093)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('June 3, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Upgrade Ruby to 2.4.5 [#2995](https://github.com/department-of-veterans-affairs/vets-api/pull/2995)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 28, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Rails 5.2.3 [#2933](https://github.com/department-of-veterans-affairs/vets-api/pull/2933)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 23, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Create self-service testing tool [#3059](https://github.com/department-of-veterans-affairs/vets-api/pull/3059)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 3, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Validate Against Empty Files [#3025](https://github.com/department-of-veterans-affairs/vets-api/pull/3025)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 1, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Rails 5.1 [#2897](https://github.com/department-of-veterans-affairs/vets-api/pull/2897)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('April 9, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Upgrade API to Rails 5.0.7.2 [#2833](Upgrade API to Rails 5.0.7.2 (#2833)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('March 18, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Handle new vbms success status without passing it along to consumers (would be a breaking change) [#2877](https://github.com/department-of-veterans-affairs/vets-api/pull/2877)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('January 28, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Status simulation in Developer environment [#2751](https://github.com/department-of-veterans-affairs/vets-api/pull/2751)
                        - Can now specify status in developer environment, and receive mocked data for that status.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('October 8, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Update API URLs to va.gov domains in documentation [#2332](https://github.com/department-of-veterans-affairs/vets-api/pull/2332)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('September 18, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Implement VA-required logging for uploads [#2072](https://github.com/department-of-veterans-affairs/vets-api/pull/2072)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('August 27, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Validating PDF format on upload [#2213](https://github.com/department-of-veterans-affairs/vets-api/pull/2213)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 23, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Limit the size of individual attachments in uploads [#2094](https://github.com/department-of-veterans-affairs/vets-api/pull/2094)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 19, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        * (v0) Improve pension and burial claim uploads to Central Mail [#2143](https://github.com/department-of-veterans-affairs/vets-api/pull/2143)
                        * (v0) Add Consumer ID to Central Mail upload submission [#2071](https://github.com/department-of-veterans-affairs/vets-api/pull/2071)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('July 2, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Add Amazon SNS support to endpoint [#2058](https://github.com/department-of-veterans-affairs/vets-api/pull/2058)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('June 8, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Add numeric-characters-only validation to fileNumber metadata element [#2020](https://github.com/department-of-veterans-affairs/vets-api/pull/2020)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 17, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Add bulk status report [#1947](https://github.com/department-of-veterans-affairs/vets-api/pull/1947)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('May 8, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Start uploading documents to Central Mail [#1896](https://github.com/department-of-veterans-affairs/vets-api/pull/1896)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('April 26, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Start retrieving statuses from Central Mail [#1887](https://github.com/department-of-veterans-affairs/vets-api/pull/1887)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_intake_api.api_metadatum.id,
                      date: Date.strptime('April 20, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Create initial service [#1887](https://github.com/department-of-veterans-affairs/vets-api/pull/1887)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: benefits_reference_api.api_metadatum.id,
                      date: Date.strptime('February 4, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We added a new API to the developer portal. This API was previously the EVSS Data Reference Service. It allows consumers to look up the following data for use with benefits claims:

                        - Contention types
                        - Countries
                        - Disabilities
                        - Intake sites
                        - Military pay types
                        - Service branches
                        - Special circumstances
                        - States
                        - VA medical treatment facilities

                        This API will return only the data that can be used for benefits claims. For example, this API may return only a subset of states or countries that apply to benefits claims.

                        There are some important differences between this API and the service it replaces:

                        - The new service requires an API key. [Obtain one through this onboarding process](https://developer.va.gov/onboarding).
                        - There are some stylistic changes to each endpoints’ response format:
                            * Contention Types
                              + "contentionTypes" array renamed to "items"
                            * Countries
                              + "countries" array renamed to "items"
                            * Disabilities
                              + "disability" array renamed to "items"
                              + "classificationCode" renamed to "id"
                              + "id" is type long
                              + "endDate" renamed to "endDateTime"
                              + "endDateTime" reported in YYY-MM-DDTHH:MM:SSZ format
                              + "endDateTime" always included, even if null
                            * Intake Sites
                              + "intakeSites" array renamed to "items"
                              + "code" renamed to "id"
                              + "id" is type long
                            * Military Pay Types
                              + "militaryPayTypes" array renamed to "items"
                            * Service Branches
                              + "serviceBranches" array renamed to "items"
                            * Special Circumstances
                              + "specialCircumstances" array renamed to "items"
                            * States
                              + "states" array renamed to "items"
                            * Treatment Centers
                              + "facilities" array renamed to "items"


                        - Responses are in JSON instead of HTML.
                        - Minor improvements to HTTPS Response Codes. (i.e. treatment centers invalid state was 200 and is now 400, new 429 rate limit errors, unauthorized 401, refer to [API specification](https://developer.va.gov/explore/benefits/docs/benefits_reference_data?version=current) for complete information).
                        - For the treatment center endpoint, the optional “stateCode” query parameter must now be 2 capital letters, otherwise a 400 response is returned. Previously, a 200 with a blank array was returned.
                        - Optional pagination is supported (new fields were added to in the responses even if the optional pagination parameters are not used for certain end points).
                        - URLs for the services are changed. The legacy production URLs are https://www.ebenefits.va.gov:444/wss-referencedata-services-web/rest/referencedata/v1/`<endpoint name>` and the new production URLs are: https://api.va.gov/services/benefits-reference-data/v1/`<endpoint name>`.


                        It's important to know that with the new version, you will need to support backward compatibility. You should:
                        - Be prepared to handle HTTP status codes not explicitly specified in endpoint definitions.
                        - Be tolerant with unknown fields in the payload, ignore deserialization of new fields, but do not eliminate them from the payload if needed for subsequent PUT requests.
                        - Follow the redirect when the server returns HTTP status code 301 (Moved Permanently).


                        Learn more about this API by reviewing the [Benefits Reference Data API documentation](/explore/benefits/docs/benefits_reference_data).

                        For cross-reference purposes, the PR for this release is [#4015](https://tools.health.dev-developer.va.gov/jenkins/job/department-of-veterans-affairs/job/health-apis-deployer/job/d2/4015/).
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('February 10, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - Updated test user representative Tamara Ellis' individual POA code to `067`. [#320](https://github.com/department-of-veterans-affairs/vets-api-clients/pull/320)
                        -- Using Tamara Ellis' previous code of `A1Q` will still work, but attempts to assign `A1Q` to a Veteran test user will not change their POA code.  Using `067` will change their POA code.
                        - Updated test user representative John Doe's individual POA code to `072`.  [#320](https://github.com/department-of-veterans-affairs/vets-api-clients/pull/320)
                        -- Using John Doe's previous code of `A1H` will still work, but attempts to assign `A1H` to a Veteran test user will not change their POA code.  Using `072` will change their POA code.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 25, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We made updates to the v1 "/forms/526" endpoint to make sure the schemas and descriptions better match the wording on the 526EZ form:

                        - Several schema descriptions were updated, but their functionality remains unchanged. Updated schema descriptions can be reviewed in the [Benefits Claims API documentation](https://developer.va.gov/explore/benefits/docs/claims?version=current).
                        - We deprecated 2 schemas because they were duplicating functionality supported by other schemas:
                          1.  `servicePay.hasSeparationPay` was deprecated because its functionality is supported by `servicePay.separationPay`.
                          2.  `servicePay.militaryRetiredPay.willReceiveInfuture` was deprecated because its functionality is supported by `servicePay.militaryRetiredPay.willReceiveInFuture`. It also fixes letter case inconsistencies.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 24, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v0 & v1) - Adds `RRD` as an available value for `specialIssues` in Form 526 submissions. [#8898](https://github.com/department-of-veterans-affairs/vets-api/pull/8898)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 19, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Updated form 526 schema and developer docs to allow `treatments.startDate` to be an optional field [#8890](https://github.com/department-of-veterans-affairs/vets-api/pull/8890)
                        - (v1) Updated form 526 schema and developer docs to add optional `disabilities.serviceRelevance` field [#8890](https://github.com/department-of-veterans-affairs/vets-api/pull/8890)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('December 17, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Updated `directDeposit.accountType` enum for 526 form 'validate' endpoint to be case insensitive [#8716](https://github.com/department-of-veterans-affairs/vets-api/pull/8716)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('December 14, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Updated `directDeposit.accountType` enum for 526 form to be case insensitive [#8655](https://github.com/department-of-veterans-affairs/vets-api/pull/8655)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('May 3, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v0 & v1) Fixed documentation to properly define consentLimits for a POST 2122 submission [#6728](https://github.com/department-of-veterans-affairs/vets-api/pull/6728)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 22, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) "/forms/2122/active" now returns current and previous POA regardless of prior submissions to Lighthouse Claims API [#6621](https://github.com/department-of-veterans-affairs/vets-api/pull/6621)
                        - (v0 & v1) Fixed bug where a Veteran was unable to submit a POA change for a previously used Representative [#6486](https://github.com/department-of-veterans-affairs/vets-api/pull/6486)
                        - (v0 & v1) Fixed bug where some service branch options within a disability claim submission were invalid [#6640](https://github.com/department-of-veterans-affairs/vets-api/pull/6640)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 30, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v0 & v1) Deprecate "schema" endpoint for 526 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Deprecate "schema" endpoint for 0966 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Deprecate "schema" endpoint for 2122 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Deprecate "validate" endpoint for 526 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Deprecate "validate" endpoint for 0966 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Deprecate "validate" endpoint for 2122 form [#6289](https://github.com/department-of-veterans-affairs/vets-api/pull/6289)
                        - (v0 & v1) Reduce valid flashes to 526 endpoint to shorter more relevant list [#6256](https://github.com/department-of-veterans-affairs/vets-api/pull/6256)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 4, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v0 & v1) Write flashes to BGS when 526 claims are submitted for auto-establishment [#5248](https://github.com/department-of-veterans-affairs/vets-api/pull/5248)
                        - (v0 & v1) Write special issues to BGS when 526 claims are submitted for auto-establishment [#5576](https://github.com/department-of-veterans-affairs/vets-api/pull/5576)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('September 14, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Add `validate` endpoint for 2122 form [#4881](https://github.com/department-of-veterans-affairs/vets-api/pull/4881)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('September 1, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Update claims API documentation [#4783](https://github.com/department-of-veterans-affairs/vets-api/pull/4783)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('August 25, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Migrate Intent to FIle from EVSS to BGS [#4575](https://github.com/department-of-veterans-affairs/vets-api/pull/4575)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('August 17, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added camel inflected schemas to claims API [#4730](https://github.com/department-of-veterans-affairs/vets-api/pull/4730)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('August 7, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Add `validate` endpoint for 0966 form [#4656](https://github.com/department-of-veterans-affairs/vets-api/pull/4656)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('July 16, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Ability to generate and upload a signed 2122 PDF form using submitted signatures [#4463](https://github.com/department-of-veterans-affairs/vets-api/pull/4463)

                        - Updated schema changes for 2122
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 25, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Updated `homelessSituationType` and `homelessnessRiskSituationType` enums [#4383](https://github.com/department-of-veterans-affairs/vets-api/pull/4383)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 17, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Add optional base64 encoding information to documentation [#4381](https://github.com/department-of-veterans-affairs/vets-api/pull/4381)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The optional query parameter `prompt` has been added to the authorization flow.

                        - Supported prompts: login. If specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-saml-proxy/pull/111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('November 27, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Add "claimDate" field to set receipt dates for internal consumers [#3596](https://github.com/department-of-veterans-affairs/vets-api/pull/3596)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('November 20, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Require attachment for original claims submitted by representatives [#3554](https://github.com/department-of-veterans-affairs/vets-api/pull/3554)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('November 12, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Validate existence of previous claim to determine "original claim" status and require attachment in those cases [#3471](https://github.com/department-of-veterans-affairs/vets-api/pull/3471)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('September 24, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0 & v1) Add "autoCestPDFGenerationDisabled" boolean field [#3328](https://github.com/department-of-veterans-affairs/vets-api/pull/3328)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('July 23, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Announced production support for external use of v1, allowing:

                        - Users with existing Power of Attorney to establish 526 claims on a Veteran's behalf
                        - Authenticated Veterans to establish 526 claims on their own behalf
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 25, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Creating ITF expiration validation for 526 [#3119](https://github.com/department-of-veterans-affairs/vets-api/pull/3119)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 17, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Add supporting documents to claims [#3111](https://github.com/department-of-veterans-affairs/vets-api/pull/3111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Add machine readable source to errors [#3097](https://github.com/department-of-veterans-affairs/vets-api/pull/3097)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('June 3, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - Add a couple specs for empty ITF requests [#3083](https://github.com/department-of-veterans-affairs/vets-api/pull/3083)
                        - Upgrade Ruby to 2.4.5 [#2995](https://github.com/department-of-veterans-affairs/vets-api/pull/2995)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('May 30, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - Adding logic to match claims detail and auto claim serializers [#3061](https://github.com/department-of-veterans-affairs/vets-api/pull/3061)
                        - Adding Form Schema documentation and json api compliance [#3075](https://github.com/department-of-veterans-affairs/vets-api/pull/3075)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('May 28, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - Rails 5.2.3 [#2933](https://github.com/department-of-veterans-affairs/vets-api/pull/2933)
                        - Get request for displaying JSON Schema for each form [#3072](https://github.com/department-of-veterans-affairs/vets-api/pull/3072)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('May 20, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Claims docs fix [#3055](https://github.com/department-of-veterans-affairs/vets-api/pull/3055)
                        - (v1) add edipi to from_identity call [#3047](https://github.com/department-of-veterans-affairs/vets-api/pull/3047)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('May 1, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Art.claims 404 [#3015](https://github.com/department-of-veterans-affairs/vets-api/pull/3015)
                        - (v1) Rails 5.1 [#2897](https://github.com/department-of-veterans-affairs/vets-api/pull/2897)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 30, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Creating Swagger Blocks Documentation for Claims V1 [#2952](https://github.com/department-of-veterans-affairs/vets-api/pull/2952)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 23, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Check PoA with Okta [#2990](https://github.com/department-of-veterans-affairs/vets-api/pull/2990)
                        - (v1) Intent To File Claims Api [#2990](https://github.com/department-of-veterans-affairs/vets-api/pull/2990)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 17, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Art.claims api schema [#2965](https://github.com/department-of-veterans-affairs/vets-api/pull/2965)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 12, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Verify PoA from OGC data [#2951](https://github.com/department-of-veterans-affairs/vets-api/pull/2951)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 11, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Add ability to set users from oauth token or headers [#2949](https://github.com/department-of-veterans-affairs/vets-api/pull/2949)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 9, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        - (v1) Upgrade API to Rails 5.0.7.2 [#2833](https://github.com/department-of-veterans-affairs/vets-api/pull/2833)
                        - (v1 )Uploading Uploads to EVSS for Auto-CEST [#2915](https://github.com/department-of-veterans-affairs/vets-api/pull/2915)
                        - (v1) 526 Additional Validations [#2936](https://github.com/department-of-veterans-affairs/vets-api/pull/2936)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('April 5, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v1) Split off Claims v1 [#2927](https://github.com/department-of-veterans-affairs/vets-api/pull/2927)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 26, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Create mock override to test auto-establishment in staging [#2908](https://github.com/department-of-veterans-affairs/vets-api/pull/2908)

                        - Our upstream partners limit the number of test submissions allowed in staging, so we now use mocked data by default.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 21, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Fix security vulnerability in disability claim auto-establishment [#2903](https://github.com/department-of-veterans-affairs/vets-api/pull/2903)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 20, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Fix duplicate submissions for disability claim auto-establishment [#2852](https://github.com/department-of-veterans-affairs/vets-api/pull/2852)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 18, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Add support for uploading documents to auto-established disability compensation claims [#2868](https://github.com/department-of-veterans-affairs/vets-api/pull/2868)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('March 15, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Improve Veteran lookup for disability claim auto-establishment and claim status [#2863](https://github.com/department-of-veterans-affairs/vets-api/pull/2863)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 8, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Implement initial VA internal-only disability claim auto-establishment [#2824](https://github.com/department-of-veterans-affairs/vets-api/pull/2824)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 8, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Implement Power of Attorney lookup for future v1 [#2709](https://github.com/department-of-veterans-affairs/vets-api/pull/2709)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Date.strptime('January 4, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) Update claim statuses to be consistent with VA.gov [#2701](https://github.com/department-of-veterans-affairs/vets-api/pull/2701)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('January 11, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We added a new Radius field to lat/long searches.
                        * When the Radius field is supplied, only results within the specified radius will be returned.
                        * This field is optional.

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/272)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('July 6, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Time zone data has now been added to API repsonse   
                        * `time_zone` represents the corresponding IANA format time zone for the facility returned 
                        * Example value for Orlando VA Medical Center: "America/New_York"

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/226)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 15, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We added a new meta section to the /nearby endpoint with a new `band_version` field.
                        * `band_version` represents the data set used in the distance calculation
                        * `band_version` value may be up to 6 weeks behind the current date
                        * Example value: "FEB2021" with a return date in March, 2021

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/209)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 1, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Service-specific details are now available for the Covid19Vaccine service where applicable.
                        * `detailed_services` was added to the facilities API response for all facilities
                        * Facilities offering the Covid19Vaccine health service provide detailed service info in this field

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/198)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('January 29, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Corrected `operationalHoursSpecialInstructions` to `operational_hours_special_instructions`

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/195)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('January 20, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now return additional notes related to operational hours for a facility.
                        * New field `operationalhoursspecialinstructions` included in the Facilities API response
                        * This field is only applicable to health facilities (vha) and vet centers (vc)
                        * Example value: "Administrative hours are Monday-Friday 8:00 a.m. to 4:30 p.m."

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/172)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('January 11, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now see if a facility offers Covid-19 vaccines.
                        * `Covid19Vaccine` will return as a new service type for facilities, where available
                        * The `Covid19Vaccine` service does not have satisfaction scores or wait times

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/184)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('December 2, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Location queries now support filtering by mobile status.
                        * Added `mobile` filter parameter to facilities endpoint
                        * Options for `mobile` are `true` or `false`

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/169)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('November 16, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now search for facilities by Veterans Integrated Service Network (VISN).
                        * Added `visn` search parameter to facilities endpoint
                        * Additional search parameters (such as `lat` and `long`) are not supported with this search type

                        [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/165)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('August 24, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        A new `/ids` endpoint was added to the Facilities API which retrieves all facility IDs and supports filtering by facility type.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 20, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now see if Health facilities offer Podiatry or Nutrition services.
                        * Added `Podiatry` and `Nutrition` to the array of available services for a facility, where available. At this time, we do not have satisfaction scores and are not exposing wait times for podiatry or nutrition services.

                          [View the code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/38)

                        You can now see Health facilities' operating status and any important textual notes about that facility.
                        - Added `operating_status` and `additional_info` flags to the API response for Health facilities (other facility types will return null for these fields). Options for operating_status are `normal, notice, limited, closed`; options for `additional_info` is a text string showing details of facility notices for visitors, such as messages about parking lot closures or floor visitation information.
                        - `active_status` is deprecated and replaced with `operating_status`. It will be removed in version 1.

                         [View code change(s)](https://github.com/department-of-veterans-affairs/lighthouse-facilities/pull/58)
                         
                         Note: the Facilities API codebase was refactored and separated from the vets-api repository.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('December 6, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The Veterans Integrated Service Network (VISN) identifier for each health facility is now available.
                        - `visn` has been added to all `/facilities` endpoints. [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3609)
                        - For non-health facilities, this will return as `null`.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('November 8, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The `/nearby` endpoint received major changes.
                        - Previously, the server retrieved an isochrone (a line connecting points of the same time) for a provided location and looked for facilities that fell within that polygon. Now the opposite is true: facilities have isochrones that are compared against the provided location. Users should see increased performance from this endpoint as a result.
                        - Data about drive times now comes directly from the Veterans Health Administration (VHA). Responses may vary slightly from the previous implementation because of this switch.
                        - The response schema has also changed. Instead of returning facility data from `/nearby`, the endpoint now provides `min_time` and `max_time` attributes for the matching polygons and links to endpoints that can be queried to retrieve full information about the associated facility. This schema change allows us to keep `/nearby` within v0 of the Facilities API instead of incrementing to v1. See the schema changes by [visiting the documentation](https://developer.va.gov/explore/facilities/docs/facilities).

                        [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3512)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('October 23, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        When including latitude and longitude parameters in a request to  `/facilities` the results are now sorted in ascending order by distance.
                        -  Previously the facilities in the response were sorted by type first and then distance. Now the closest facilities to the requested location will be returned first regardless of type. [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3461)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('September 30, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now see if Health facilities are mobile or temporarily deactivated.
                        - Added `mobile` and `active_status` flags to the API response for Health facilities (other facility types will return `null` for these fields). Options for `mobile` are `true` or `false`; options for `active_status` are `A` for Active or `T` for Temporarily deactivated. [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3339/commits)
                          - Mobile facilities are subject to frequent address changes. To get the exact current location, please call the number listed.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('September 20, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        You can now query facilities in `/nearby` using latitude and longitude
                        - As an alternative option to `address`, this adds the ability to make a request to `/va_facilities/v1/nearby` using `lat` and `lng` as input parameters. [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3273/commits)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('June 17, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Get nearby facilities for an address [#3084](https://github.com/department-of-veterans-affairs/vets-api/pull/3084)
                        - `/nearby`, the first available endpoint for v1 of Facilities API, returns all facilities within a provided drive time for an address
                        - v1 changes
                          - Changed `long` to `lng` to accommodate typed languages [#15](https://github.com/department-of-veterans-affairs/vets-api-clients/issues/15)
                          - Wait times are now nested in the Health services array
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 26, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Get facilities by state [#2992](https://github.com/department-of-veterans-affairs/vets-api/pull/2992)
                        - Facilities endpoint now accepts `state` as a parameter. This returns all facilities in a particular state/territory.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 25, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Get facilities by zip [#2987](https://github.com/department-of-veterans-affairs/vets-api/pull/2987)
                        - Facilities endpoint now accepts `zip` as a parameter. This returns all facilities in a particular zip code.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('April 18, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Fix error when returning CSV [#2974](https://github.com/department-of-veterans-affairs/vets-api/pull/2974)
                        - The `/facilities/all` endpoint no longer returns a 500 status code when a user requests `text/csv`
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('February 13, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Standardize closed days to "Closed" in Facilities API [#2802](https://github.com/department-of-veterans-affairs/vets-api/pull/2802)
                        - Changes any casing of "closed" and "-" to "Closed" for a consistent convention in the Facilities API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('January 16, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Fix facilities api bugs [#2735](https://github.com/department-of-veterans-affairs/vets-api/pull/2735)
                        - Allows users to pass both a list of IDs and a lat/long in the same request.
                        - Populate missing location data in NCA, VBA, and VC facilities, [view specific change](https://github.com/department-of-veterans-affairs/vets-api/pull/2735/files#diff-a0253f0a6c07463fb11a513df82f21d2).
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('December 26, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Remove community care providers from all facilities search [#2582](https://github.com/department-of-veterans-affairs/vets-api/pull/2582)
                        - Reverts back to the old functionality, removing community care providers from the all facility search
                        - Community care providers can now only be searched by passing `type=cc_provider` into the search endpoint
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('November 20, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Add facilities distances [#2687](https://github.com/department-of-veterans-affairs/vets-api/pull/2687)
                        - Adds distance to meta property of lat/long inquiries to the Facilities API and adds documentation for the meta property
                        - Facility distances from lat/long point are returned in responses
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('November 12, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Community care provider searches [#2405](https://github.com/department-of-veterans-affairs/vets-api/pull/2405)
                        - This enhances the facilities search endpoint to include community care providers in the search by default
                        - Additionally, it supports searching for just community care  providers by passing `type=cc_provider` into the search endpoint
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: facilities_api.api_metadatum.id,
                      date: Date.strptime('August 13, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the VA Facilities API
                        - VA_Facilities API endpoint for external API consumers. Supports json/[geojson](http://geojson.org/) results and a bulk "get all" endpoint in geojson and csv format.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: clinical_fhir_api.api_metadatum.id,
                      date: Date.strptime('August 16, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the Clinical Health API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: community_care_api.api_metadatum.id,
                      date: Date.strptime('July 23, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The CCE API now presents and accounts for a veteran's PACT status (Patient Aligned Care Team) when calculating eligibility.
                        - PACT status is only consulted for PrimaryCare requests. A veteran with an active PACT is ineligible for community care for Primary Care appointments.  
                        - The new field 'pactStatus' has been added to the API response when it has been used in the eligibility determination.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/health-apis-community-care-eligibility/pull/131)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: community_care_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The optional query parameter `prompt` has been added to the authorization flow.
                        - Supported prompts: login. If specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-saml-proxy/pull/111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: community_care_api.api_metadatum.id,
                      date: Date.strptime('July 30, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the Community Care Eligibility API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: loan_guaranty_api.api_metadatum.id,
                      date: Date.strptime('March 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the Loan Guaranty API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('July 6, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) We added a new searching algorithm that applies spell checking, full text search, and ranking based on popularity. These features allow users to more quickly find the forms they need. 
                        * [#7108](https://github.com/department-of-veterans-affairs/vets-api/pull/7108)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('May 11, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) We added a new property to the Show endpoint (created_at) which is for VA.gov internal use only. [#6818](https://github.com/department-of-veterans-affairs/vets-api/pull/6818)
                        * Example value: "created_at": "2021-03-30T16:28:30.333Z"
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('May 4, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) We added functionality that ensures removing the Form Details URL from unpublished forms.
                        *  [#6743](https://github.com/department-of-veterans-affairs/vets-api/pull/6743)
                        (v0) We added a feature flag that can enable an improved searching algorithm for the Forms API.
                        *  [#6229](https://github.com/department-of-veterans-affairs/vets-api/pull/6229)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('March 30, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) We added a new field, last_sha256_change, to the VA Forms API FormsIndex endpoint. This will allow consumers to know when the pdf file last changed.
                        * Added the last sha256 revision to the FormsIndex endpoint [#6292](https://github.com/department-of-veterans-affairs/vets-api/pull/6292)
                          * Example value: "last_sha256_change": "2019-08-01"
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('March 16, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        (v0) We added a new field, va_form_administration, to the VA Forms API which will be used to populate the "Related to" field on the [form search results page](https://www.va.gov/find-forms/) when the benefits_category field is not available.
                        * Database migration to add column [#6082](https://github.com/department-of-veterans-affairs/vets-api/pull/6082)
                        * Added field to Form Reloader [#6133](https://github.com/department-of-veterans-affairs/vets-api/pull/6133)
                        * New JSON field is included in the VA Forms API response [#6077](https://github.com/department-of-veterans-affairs/vets-api/pull/6077)
                          * Example value: "va_form_administration": "Veterans Benefits Administration"
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: forms_api.api_metadatum.id,
                      date: Date.strptime('November 20, 2019', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Initial release of the VA Forms API
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: address_validation_api.api_metadatum.id,
                      date: Date.strptime('September 26, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Create Address Validation API
                        - The ‘validate’ API accepts a structured JSON address object (broken down by street/city/state/zip/etc), and returns a result indicating whether the address is valid, and if so includes a canonicalized address and geocoding information (lat/long) for the address.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_confirmation_api.api_metadatum.id,
                      date: Date.strptime('January 13, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launched Veteran Confirmation API with a status endpoint
                        - `/status`: Allows third-parties to request confirmation from the VA of an individual's Veteran status after providing a valid API key and identifying attributes for the individual.

                        [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/3676)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('Sep 22, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The Veteran Verification API v1.0.0 was updated to include a change to the /disability_rating endpoint response. The DisabilityRatingAttributes will now show date (2018-03-27) rather than datetime (2018-03-27T21:00:41.000+0000). 

                        This was introduced as a versioned change to allow API consumers to upgrade at their convenience. We encourage all consumers to migrate to the new version as v0.0.0 will be removed on December 1, 2021.
                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/7546)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('Aug 24, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The Veteran Verification API was updated to include more accurate Guard and Reserve Service data based on qualifying periods which is filtered to not include training or Title 32 service.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/7685)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The optional query parameter `prompt` has been added to the authorization flow.
                        - Supported prompts: login. If specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-saml-proxy/pull/111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('May 11, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added combined disability rating and individual disability ratings to the disability_rating endpoint.
                        - `/disability_rating` endpoint: Adds `combined_disability_rating` field to responses. This is expressed as a percentage and represents how much a Veteran’s disability decreases their overall health and ability to function.
                        - `/disability_rating` endpoint: Adds `individual_ratings` array to responses with each entry representing whether the individual condition is service related, when the Veteran could begin claiming benefits related to this disability, and the disability rating for the individual condition expressed as a percentage.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/4223)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('April 15, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added Veteran First & Last Name to service_history endpoint.
                        - `/service_history`: Adds `first_name` and `last_name` fields to responses.

                        [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/4121)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('March 18, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added pay grade information to service_history endpoint.
                        - `/service_history`: Adds `pay_grade_code` and `separation_reason` fields to responses.

                        [View code change(s)](https://github.com/department-of-veterans-affairs/vets-api/pull/4016)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('November 8, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launched the Disability Rating and Veteran Status endpoints
                        - `/disability_rating`: Given an authenticated user, this created an endpoint that returns a Veteran's disability rating from VA
                        - `/status`: Allows third-parties to request confirmation from the VA of an individual's Veteran status after receiving authorization to do so using an Open ID Connect flow.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: veteran_verification_api.api_metadatum.id,
                      date: Date.strptime('June 11, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launched the Service History endpoint
                        - `/service_history`: Given an authenticated user, this created an endpoint that returns a Veteran's service history from VA
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('February 10, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added support to allow `identifier` search by Integration Control Number (ICN) in the R4 `Practitioner` resource.  You can now search by either ICN or National Provider Identifier (NPI) using `identifier`.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('January 27, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The `manufacturer.display` field has been updated in the R4 `Immunization` resource. This field is populated based on CVX to manufacturer mappings from the [CDC Product Names to CVX and MVX code set](https://www2a.cdc.gov/vaccines/iis/iisstandards/vaccines.asp?rpt=tradename). In cases where a CVX code maps to multiple manufacturers, the exact manufacturer can't be determined and thus `manufacturer.display` will be omitted from the response.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('January 13, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added FHIR R4 `Encounter` Resource data, which includes the ability to search by `patient`, `date`, and `_lastUpdated` date.

                        The `vaccineCode` field in the R4 `Immunization` resource now includes the Vaccine Short Description as well as the Vaccine Group Code and Name based on the [CDC CVX to Vaccine Groups code set](https://www2a.cdc.gov/vaccines/iis/iisstandards/vaccines.asp?rpt=vg).

                        Added support for `_lastUpdated` search in the R4 `Observation` resource.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('January 10, 2022', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        ### January 10, 2022
                        We changed the `referenceRange` data field that is returned with the `Observation` resource.
                         - It no longer returns the field `high` or `low` if there is not an associated value.
                         - It now returns the `system`, `code`, and `unit` fields only if all data are present.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('December 13, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added support for `_lastUpdated` search in both the DSTU2 and R4 `Procedure` resource.

                        Integrated a new data source that contains COVID Vaccination data for VA Employees who received their vaccinations at a VA Facility.  This data is now available in the `Immunization` resource.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('November 16, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added `qualification.code.text` and `address.period` data fields to the `Practitioner` resource.

                        Added the `code.text` data field to the `PractitionerRole` resource.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('September 21, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We added new elements and values to the R4 `Condition` FHIR mapping. 
                          -  The `clinicalStatus` element now supports the value `inactive`.
                          -  The `verificationStatus` element now returns these additional values:`provisional`, `differential`, `confirmed`, and `refuted`. Previously, this element always returned  `unconfirmed`.
                          -  The `recorder` element is now added.

                        The R4 `AllergyIntolerance` FHIR mapping now includes both `clincalStatus` and `verificationStatus`.  Previously, only one was populated based on value. 

                        The `primarySource` for the R4 `Immunization` FHIR mapping now supports Boolean values. Previously, it was always `true`.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('August 24, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added the `code` data to the R4 `AllergyIntolerance` resource to be compliant with [US Core Implementation Guide](http://hl7.org/fhir/us/core/StructureDefinition-us-core-allergyintolerance.html).

                        Updated the `Condition` resource to include [SNOMED CT](http://snomed.info/sct) and ICD-10-CM codings when both are available.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('May 4, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added an `identifier` to the `Organization` resource to represent the VA Facility to be consistent with the Facility ID used by the Facilities API. For example a VAMC has an identifier of the form `vha_[stationNumber]` like `vha_673`.

                        Added an `identifier` to the `Location` resource to represent the VA clinic. This `identifier` has the form `vha_[stationNumber]_[clinic identifier]`.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('February 24, 2021', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Added the FHIR R4 resource `Appointment`, which includes the ability to search appointments by `Patient` and `Location` references and searching by `_lastUpdated` date.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('December 15, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The following three R4 resources have been made available: `Device`, `Practitioner`, and `PractitionerRole`. Not all US Core searches are yet supported for `Practitioner` and `PractitionerRole`.

                        The hold times for `Immunization` and COVID 19 Lab Results have been eliminated.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('August 31, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        In adherence to changes per the [21st Century Cures Act](https://www.federalregister.gov/documents/2020/05/01/2020-07419/21st-century-cures-act-interoperability-information-blocking-and-the-onc-health-it-certification#h-13), the Veteran Health API profile, in line with the US Core Implementation Guide has added FHIR R4 resources to the R4 tab.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('August 7, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We have updated the mock health records for test users in the Sandbox environment for the Veterans Health API `Condition` resource to list conditions from either SNOMED-CT or ICD-10 code sets.  Previously only SNOMED-CT codes were available.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('July 31, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        We are decreasing the data hold time for the Veterans Health API from 72 hours to 36 hours, effective July 31, 2020, based on an updated VHA policy.  When a physician enters or changes patient data, there is a holding period before the data is released and visible through other applications such as health apps. The holding period gives physicians time to contact their patients and discuss health data, such as sensitive diagnoses, before the patient sees this data elsewhere. This change applies only to real data entered into the production environment.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('July 13, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The CoverageEligibilityResponse resource for Urgent Care is deprecated and scheduled for deactivation in the 3rd quarter of 2020.
                        We are working on new FHIR R4 resources and will add those in the 3rd quarter of 2020.
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('June 10, 2020', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        The optional query parameter `prompt` has been added to the authorization flow.
                        - Supported prompts: login. If specified, the user will be forced to provide credentials regardless of session state. If omitted, an existing active session with the identity provider may not require the user to provide credentials.

                        [View code changes(s)](https://github.com/department-of-veterans-affairs/vets-saml-proxy/pull/111)
                      MARKDOWN
                     )
ApiReleaseNote.create(api_metadatum_id: fhir_health_api.api_metadatum.id,
                      date: Date.strptime('December 4, 2018', '%B %d, %Y'),
                      content: <<~MARKDOWN
                        Launch of the Veterans Health API
                        - Available for development environment access.
                      MARKDOWN
                     )
