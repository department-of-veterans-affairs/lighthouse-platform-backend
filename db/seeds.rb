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
  overview: %Q(
    ## Use our Health APIs to build tools that help Veterans manage their health, view their VA medical records, share their health information, and determine potential eligibility for community care. While these APIs allow greater access to health data, they do not currently allow submission of medical claims. 

    VA’s Health APIs use [HL7’s Fast Healthcare Interoperability Resources (FHIR) framework](https://www.hl7.org/fhir/overview.html) for providing healthcare data in a standardized format. FHIR solutions are built from a set of modular components, called resources, which can be easily assembled into working systems that solve real world clinical and administrative problems. 

    When you register for access to the Health APIs, you will be granted access to a synthetic set of data (provided by the MITRE Corporation) that mimics real Veteran demographics. The associated clinical resources include data generated from disease models covering up to a dozen of the most common Veteran afflictions. [Review the latest release notes](/release-notes/health).

    _VA is a supporter of the [CARIN Alliance](https://www.carinalliance.com/) Code of Conduct._
  ).strip,
  quickstart: <<~MARKDOWN
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

     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/argonaut/data-query/`
     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/dstu2/`
     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/r4/`
     * `{{ process.env.REACT_APP_API_URL }}/services/community-care/v0/eligibility`

    Accordingly, the FHIR conformance statements can be retrieved from:

     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/argonaut/data-query/metadata`
     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/dstu2/metadata`
     * `{{ process.env.REACT_APP_API_URL }}/services/fhir/v0/r4/metadata`

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
  api_environments_attributes: {
  auth_server_access_key: 'AUTHZ_SERVER_VERIFICATION',
   metadata_url: 'https://staging-api.va.gov/internal/docs/veteran-verification/metadata.json',
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
