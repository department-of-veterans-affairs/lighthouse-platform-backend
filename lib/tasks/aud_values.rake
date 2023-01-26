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
          'sandboxAud' => 'aus7y0lyttrObgW622p7',
          'productionAud' => 'aus7y0lyttrObgW622p7'
        },
        'ccgInfo' => {
          'sandboxAud' => 'ausdg7guis2TYDlFe2p7',
          'productionAud' => 'ausdg7guis2TYDlFe2p7'
        }
      },
      'benefits-documents' => {
        'ccgInfo' => {
          'sandboxAud' => 'ausi3ui83fLa68IJv2p7',
          'productionAud' => 'ausi3ui83fLa68IJv2p7'
        }
      },
      'direct-deposit-management' => {
        'ccgInfo' => {
          'sandboxAud' => 'ausi0e21hbv5iElEh2p7',
          'productionAud' => 'ausi0e21hbv5iElEh2p7'
        }
      },
      'clinical_health' => {
        'acgInfo' => {
          'sandboxAud' => 'default',
          'productionAud' => 'default'
        },
        'ccgInfo' => {
          'sandboxAud' => 'aus8nm1q0f7VQ0a482p7',
          'productionAud' => 'aus8nm1q0f7VQ0a482p7'
        }
      },
      'community_care' => {
        'acgInfo' => {
          'sandboxAud' => 'aus89xnh1xznM13SK2p7',
          'productionAud' => 'aus89xnh1xznM13SK2p7'
        }
      },
      'lgy_guaranty_remittance' => {
        'ccgInfo' => {
          'sandboxAud' => 'auseavl6o5AjGZr2n2p7',
          'productionAud' => 'auseavl6o5AjGZr2n2p7'
        }
      },
      'loan-review' => {
        'ccgInfo' => {
          'sandboxAud' => 'aushu53xo9vsmmmKv2p7',
          'productionAud' => 'aushu53xo9vsmmmKv2p7'
        }
      },
      'address_validation' => {
        'ccgInfo' => {
          'sandboxAud' => 'ausfhzmx8hzZ6Pdye2p7',
          'productionAud' => 'ausfhzmx8hzZ6Pdye2p7'
        }
      },
      'contact_information' => {
        'ccgInfo' => {
          'sandboxAud' => 'ausfhzmx8hzZ6Pdye2p7',
          'productionAud' => 'TBD'
        }
      },
      'va_letter_generator' => {
        'ccgInfo' => {
          'sandboxAud' => 'ausftw7zk6eHr7gMN2p7',
          'productionAud' => 'ausftw7zk6eHr7gMN2p7'
        }
      },
      'veteran_verification' => {
        'acgInfo' => {
          'sandboxAud' => 'aus7y0sefudDrg2HI2p7',
          'productionAud' => 'aus7y0sefudDrg2HI2p7'
        }
      }
    }.freeze
    audience_values.dig([url_fragment], [type], [audience])
  end

  def update_oauth_aud_values(api, oauth_type)
    url_fragment = api[:url_fragment]
    environment = ENV.fetch('ENVIRONMENT') || 'qa'
    sandbox_aud = get_aud_values(url_fragment, oauth_type, 'sandboxAud')
    production_aud = environment == 'production' ? get_aud_values(url_fragment, oauth_type, 'productionAud') : sandbox_aud
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
