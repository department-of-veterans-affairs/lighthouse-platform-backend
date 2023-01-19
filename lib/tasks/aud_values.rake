namespace :aud_values do
    desc 'inject OAuth audience values'
    task seedAudienceValues: :environment do
      apis = ApiMetadatum.where.not(oauth_info: nil)
      apis.each do |api|
        update_oauth_aud_values(api, 'acgInfo') if api.oauth_info['acgInfo'].present?
        update_oauth_aud_values(api, 'ccgInfo') if api.oauth_info['ccgInfo'].present?
      end
    end
  
    def get_aud_values(url_fragment, type, audience)
      audience_values = {
        'claims' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'benefits-documents' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'direct-deposit-management' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'clinical_health' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'community_care' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'fhir' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'lgy_guaranty_remittance' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'loan-review' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'address_validation' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'contact_information' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'va_letter_generator' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'veteran_verification' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        },
        'pgd' => {
          'acgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          },
          'ccgInfo' => {
            'sandboxAud' => 'UPDATEME',
            'productionAud' => 'UPDATEME'
          }
        }
      }.freeze
      audience_values[url_fragment][type][audience]
    end
  
    def update_oauth_aud_values(api, oauth_type)
      url_fragment = api[:url_fragment]
      api.oauth_info[oauth_type]['productionAud'] = get_aud_values(url_fragment, oauth_type, 'productionAud')
      api.oauth_info[oauth_type]['sandboxAud'] = get_aud_values(url_fragment, oauth_type, 'sandboxAud')
      api.save
    end
  end