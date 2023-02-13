# frozen_string_literal: true

namespace :lpb do
  desc 'inject OAuth audience values'
  task seedAudienceValues: :environment do
    apis = ApiMetadatum.where.not(oauth_info: nil)
    apis.each do |api|
      json = JSON.parse(api.oauth_info)
      update_oauth_aud_values(api, 'acgInfo') if json['acgInfo'].present?
      update_oauth_aud_values(api, 'ccgInfo') if json['ccgInfo'].present?
    end
  end

  def get_aud_values(url_fragment, type, audience)
    audience_values = {
      'claims' => {
        'acgInfo' => {
          'productionAud' => 'aus7y0lyttrObgW622p7',
          'sandboxAud' => 'aus7y0lyttrObgW622p7'
        },
        'ccgInfo' => {
          'productionAud' => 'ausajojxqhTsDSVlA297',
          'sandboxAud' => 'ausdg7guis2TYDlFe2p7'
        }
      },
      'benefits-documents' => {
        'ccgInfo' => {
          'productionAud' => 'ausi3ui83fLa68IJv2p7',
          'sandboxAud' => 'ausi3ui83fLa68IJv2p7'
        }
      },
      'direct-deposit-management' => {
        'ccgInfo' => {
          'productionAud' => 'ausg0il3dn00rACLJ297',
          'sandboxAud' => 'ausi0e21hbv5iElEh2p7'
        }
      },
      'clinical_health' => {
        'acgInfo' => {
          'productionAud' => 'default',
          'sandboxAud' => 'default'
        },
        'ccgInfo' => {
          'productionAud' => 'aus8nm1q0f7VQ0a482p7',
          'sandboxAud' => 'aus8nm1q0f7VQ0a482p7'
        }
      },
      'community_care' => {
        'acgInfo' => {
          'productionAud' => 'aus89xnh1xznM13SK2p7',
          'sandboxAud' => 'aus89xnh1xznM13SK2p7'
        }
      },
      'lgy_guaranty_remittance' => {
        'ccgInfo' => {
          'productionAud' => 'auseavl6o5AjGZr2n2p7',
          'sandboxAud' => 'auseavl6o5AjGZr2n2p7'
        }
      },
      'loan-review' => {
        'ccgInfo' => {
          'productionAud' => 'aushu53xo9vsmmmKv2p7',
          'sandboxAud' => 'aushu53xo9vsmmmKv2p7'
        }
      },
      'address_validation' => {
        'ccgInfo' => {
          'productionAud' => 'ausfhzmx8hzZ6Pdye2p7',
          'sandboxAud' => 'ausfhzmx8hzZ6Pdye2p7'
        }
      },
      'contact_information' => {
        'ccgInfo' => {
          'productionAud' => 'TBD',
          'sandboxAud' => 'ausfhzmx8hzZ6Pdye2p7'
        }
      },
      'va_letter_generator' => {
        'ccgInfo' => {
          'productionAud' => 'auscxt2pniuC00goZ297',
          'sandboxAud' => 'ausftw7zk6eHr7gMN2p7'
        }
      },
      'veteran_verification' => {
        'acgInfo' => {
          'productionAud' => 'aus7y0sefudDrg2HI2p7',
          'sandboxAud' => 'aus7y0sefudDrg2HI2p7'
        }
      },
      'fhir' => {
        'acgInfo' => {
          'productionAud' => 'default',
          'sandboxAud' => 'default'
        },
        'ccgInfo' => {
          'productionAud' => 'aus8evxtl123l7Td3297',
          'sandboxAud' => 'aus8nm1q0f7VQ0a482p7'
        }
      }
    }.freeze
    audience_values.dig(url_fragment, type, audience)
  end

  def update_oauth_aud_values(api, oauth_type)
    url_fragment = api[:url_fragment]
    environment = ENV.fetch('ENVIRONMENT') || 'qa'
    sandbox_aud = get_aud_values(url_fragment, oauth_type, 'sandboxAud')
    production_aud = if environment == 'production'
                       get_aud_values(url_fragment, oauth_type,
                                      'productionAud')
                     else
                       sandbox_aud
                     end
    if sandbox_aud.present? && production_aud.present?
      audiences = {
        'sandboxAud' => sandbox_aud,
        'productionAud' => production_aud
      }
      json = JSON.parse(api.oauth_info)
      json[oauth_type] = json[oauth_type].to_hash.merge(audiences)
      api.oauth_info = json.to_json
      api.save
    end
  end
end
