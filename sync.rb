require 'json'
require 'rest-client'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

def auth(username, password)
    response = RestClient.post "https://#{username}:#{password}@api.github.com/authorizations",
                                { :params => { 'scopes' => ['user', 'repo'], 'note' => 'octocat-sync' } }
    puts response;
end

auth()
