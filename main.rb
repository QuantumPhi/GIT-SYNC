require 'json'
require 'rest-client'

HOME = ENV["HOME"]

$token

def checkauth()
    return File.exist?("#{HOME}/.config/sync")
end

def auth(username, password)
    response = JSON.parse(RestClient.post("https://#{username}:#{password}@api.github.com/authorizations",
               { :scopes => ["user", "repo"], :note => "sync" }.to_json, :accept => :json))
    $token = response["token"]
end

def sync()


if __FILE__ == $0
