require 'json'
require 'rest-client'

HOME = ENV["HOME"]

$token = ""

def authenticated()
    return File.exist?("#{HOME}/.config/gitconfig-sync")
end

def authenticate(username, password)
    if authenticated
        $token = [*File.open("#{HOME}/.config/gitconfig-sync")][2].split(/\:\s/)[1]
    else
        $token = JSON.parse(RestClient.post("https://#{username}:#{password}@api.github.com/authorizations",
                    { :scopes => ["user", "repo"], :note => "gitconfig-sync" }.to_json, :accept => :json))["token"]
        File.open("#{HOME}/.config/gitconfig-sync", "w") do |file|
            file.write("github.com:\n\tuser: #{username}\n\toauth-token: #$token")
        end
    end
end

def sync()
    puts "creating repo"
    result = RestClient.post("https://#$token:x-oauth-basic@api.github.com/user/repos",
                { :name => "gitconfig", :description => "My gitconfig", :auto_init => true }.to_json, :accept => :json)
    if result.response == 201
        result = JSON.parse(result)
    else
        puts "error:\n#{result}"
    end

end

if __FILE__ == $0
