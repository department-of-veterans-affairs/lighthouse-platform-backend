# frozen_string_literal: true

require 'rails_helper'

def stub_github_team_req(page_num, body, next_page = nil) # rubocop:disable Metrics/MethodLength
  headers = { 'Content-Type': 'application/json' }
  headers[:Link] = "https://api.github.com/user/teams?page=#{next_page}; rel=\"next\"" if next_page

  stub_request(:get, "https://api.github.com/user/teams?page=#{page_num}")
    .with(
      headers:
        {
          Accept: 'application/vnd.github.v3+json',
          Authorization: 'Bearer fake_token'
        }
    )
    .to_return(
      body:,
      headers:,
      status: 200
    )
end

RSpec.describe GithubService do
  it 'returns matching team from config' do
    stub_github_team_req(1, '[{"id": "0", "name": "name in response"}]')
    expect(GithubService.user_teams('fake_token')).to eq [id: '0', name: 'test team']
  end

  it 'returns a blank array if no teams match' do
    stub_github_team_req(1, '[{"id": "1", "name": "not the test team"}]')
    expect(GithubService.user_teams('fake_token')).to eq []
  end

  it 'handles pagination' do
    stub_github_team_req(1, '[{"id": "1", "name": "does not match test team id"}]', 2)
    stub_github_team_req(2, '[{"id": "0", "name": "name in response"}]')
    expect(GithubService.user_teams('fake_token')).to eq [id: '0', name: 'test team']
  end
end
