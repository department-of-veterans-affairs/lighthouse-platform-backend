# frozen_string_literal: true

# Helps parse headers as needed
module GithubService
  # Returns a list of the user's teams that we consider admin teams
  def self.user_teams(token)
    url = 'https://api.github.com/user/teams?page=1'
    teams_found = []

    loop do
      res = github_get(url, token)
      approved_teams = get_approved_teams(JSON.parse(res.body))
      teams_found = approved_teams unless approved_teams.empty?
      url = get_next_link(res.headers[:link])

      break unless url
    end

    teams_found
  end

  private_class_method def self.github_get(url, token)
    RestClient.get(
      url,
      {
        Accept: 'application/vnd.github.v3+json',
        Authorization: "Bearer #{token}"
      }
    )
  end

  private_class_method def self.get_approved_teams(team_page)
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
