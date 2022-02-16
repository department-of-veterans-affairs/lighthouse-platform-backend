# frozen_string_literal: true

Api.destroy_all
ApiCategory.destroy_all

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
appeals_status_api.assign_attributes(
  acl: 'appeals',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/appeals-status/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: appeals_category.id
   }
  }
)

decision_reviews_api = Api.create(name: 'decision_reviews')
decision_reviews_api.assign_attributes(
  acl: 'appeals',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/appeals-decision-reviews/metadata.json',
   environments_attributes: {
     name: 'sandbox'
   }
  },
  api_ref_attributes: {
   name: 'appeals'
  },
  api_metadatum_attributes: {
   description: 'Allows submission, management, and retrieval of decision review requests and details such as statuses in accordance with the AMA.',
   display_name: 'Decision Reviews API',
   open_data: false,
   va_internal_only: true,
   api_category_attributes: {
     id: appeals_category.id
   }
  }
)

claims_api = Api.create(name: 'claims')
claims_api.assign_attributes(
  acl: 'claims',
  auth_server_access_key: 'AUTHZ_SERVER_CLAIMS',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-claims/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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

benefits_intake_api = Api.create(name: 'benefits_intake')
benefits_intake_api.assign_attributes(
  acl: 'vba_documents',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-intake/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: benefits_category.id
   }
  }
)

benefits_reference_api = Api.create(name: 'benefits_reference_data')
benefits_reference_api.assign_attributes(
  acl: 'benefits-reference-data',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/benefits-reference-data/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: benefits_category.id
   }
  }
)

facilities_api = Api.create(name: 'va_facilities')
facilities_api.assign_attributes(
  acl: 'va_facilities',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/facilities/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: facilities_category.id
   }
  }
)

loan_guaranty_api = Api.create(name: 'loan_guaranty')
loan_guaranty_api.assign_attributes(
  acl: 'loan_guaranty',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/loan_guaranty_property/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: loan_guaranty_category.id
   }
  }
)

forms_api = Api.create(name: 'va_forms')
forms_api.assign_attributes(
  acl: 'va_forms',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/forms/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: forms_category.id
   }
  }
)

address_validation_api = Api.create(name: 'address_validation')
address_validation_api.assign_attributes(
  acl: 'internal-va:address_validation',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/address-validation/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: veteran_verification_category.id
   }
  }
)

veteran_confirmation_api = Api.create(name: 'veteran_confirmation')
veteran_confirmation_api.assign_attributes(
  acl: 'veteran_confirmation',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/veteran-confirmation/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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
   api_category_attributes: {
     id: veteran_verification_category.id
   }
  }
)

veteran_verification_api = Api.create(name: 'veteran_verification')
veteran_verification_api.assign_attributes(
  auth_server_access_key: 'AUTHZ_SERVER_VERIFICATION',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/veteran-verification/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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

community_care_api = Api.create(name: 'internal_community_care')
community_care_api.assign_attributes(
  auth_server_access_key: 'AUTHZ_SERVER_COMMUNITYCARE',
  api_environments_attributes: {
   metadata_url: 'https://api.va.gov/internal/docs/community-care-eligibility/metadata.json',
   environments_attributes: {
     name: 'sandbox'
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

fhir_health_api = Api.create(name: 'fhir_health')
fhir_health_api.assign_attributes(
  auth_server_access_key: 'AUTHZ_SERVER_HEALTH',
  api_ref_attributes: {
   name: 'health'
  },
  api_metadatum_attributes: {
   description: 'Use the OpenID Connect and SMART on FHIR standards to allow Veterans to authorize third-party applications to access data on their behalf.',
   display_name: 'Veterans Health API (FHIR)',
   open_data: false,
   va_internal_only: false,
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

ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Time.now.to_date,
                      content: <<~MARKDOWN
                        We made updates to the v1 "/forms/526" endpoint to make sure the schemas and descriptions better match the wording on the 526EZ form:

                        - Several schema descriptions were updated, but their functionality remains unchanged. Updated schema descriptions can be reviewed in the [Benefits Claims API documentation](https://developer.va.gov/explore/benefits/docs/claims?version=current).
                        - We deprecated 2 schemas because they were duplicating functionality supported by other schemas:
                          1.  `servicePay.hasSeparationPay` was deprecated because its functionality is supported by `servicePay.separationPay`.
                          2.  `servicePay.militaryRetiredPay.willReceiveInfuture` was deprecated because its functionality is supported by `servicePay.militaryRetiredPay.willReceiveInFuture`. It also fixes letter case inconsistencies.
                      MARKDOWN
                      )

ApiReleaseNote.create(api_metadatum_id: claims_api.api_metadatum.id,
                      date: Time.now.to_date,
                      content: <<~MARKDOWN
                        - (v0 & v1) - Adds `RRD` as an available value for `specialIssues` in Form 526 submissions. [#8898](https://github.com/department-of-veterans-affairs/vets-api/pull/8898)
                      MARKDOWN
                      )
