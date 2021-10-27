# frozen_string_literal: true

# Helps parse headers as needed
module GithubService
  def self.user_teams(token)
    url = 'https://api.github.com/user/teams?page=1'
    teams_found = []

    loop do
      res = do_github_req(url, token)
      valid_teams = get_valid_teams(JSON.parse(res.body))
      teams_found = valid_teams unless valid_teams.empty?
      url = get_next_link(res.headers[:link])

      break unless url
    end

    teams_found
  end

  private_class_method def self.do_github_req(url, token)
    RestClient.get(
      url,
      {
        Accept: 'application/vnd.github.v3+json',
        Authorization: "Bearer #{token}"
      }
    )
  end

  private_class_method def self.get_valid_teams(team_page)
    Rails.configuration.github.teams.yield_self do |teams|
      # Transform team['id'] to a string in comparison. Figaro pulls all values as strings
      teams.select { |team| team_page.any? { |page_team| page_team['id'].to_s == team[:id] } }
    end
  end

  private_class_method def self.get_next_link(link_header)
    return unless link_header

    lines = link_header.split(',')
    line_with_next_link = lines.find { |line| line.include?('rel="next"') }
    return unless line_with_next_link

    next_link_split = line_with_next_link.split(';')
    # The first element contains the link per github api docs
    next_link_split[0]
  end
end
