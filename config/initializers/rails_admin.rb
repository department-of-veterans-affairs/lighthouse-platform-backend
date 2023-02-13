# frozen_string_literal: true

RailsAdmin.config do |config|
  config.asset_source = :sprockets
  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate!(scope: :user) if ActiveRecord::Type::Boolean.new.deserialize(Figaro.env.enable_github_auth)
  end
  config.current_user_method(&:current_user)

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'ApiMetadatum' do
    show do
      configure :oauth_info do
        formatted_value do
          JSON.pretty_generate(JSON.parse(value))
        rescue
          JSON.pretty_generate(JSON.parse('{}'))
        end
      end
    end
    edit do
      configure :oauth_info, :code_mirror do
        formatted_value do
          JSON.pretty_generate(JSON.parse(value))
        rescue
          JSON.pretty_generate(JSON.parse('{}'))
        end
      end
    end
    list do
      configure :oauth_info do
        label 'OAuth Types'
        formatted_value do
          if value.present?
            output = []
            output << 'ACG' if value['acgInfo'].present?
            output << 'CCG' if value['ccgInfo'].present?
            output.to_s
          end
        end
      end
    end
  end
end
