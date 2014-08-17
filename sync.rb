require 'json'
require 'rest-client'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

def auth(username, password)
    puts "#{username}:#{password}"
    response = RestClient.post("https://#{username}:#{password}@api.github.com/authorizations",
    { :scopes => ["user", "repo"], :note => "sync" }.to_json, :accept => :json)
    puts response
end

auth(ARGV[0], ARGV[1])
