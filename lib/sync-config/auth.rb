module SyncConfig
    def authenticated?
        return File.exist?("#{HOME}/.config/gitconfig-sync")
    end

    def query_user_pass
        print "Username\: "
        $user = STDIN.gets.chomp
        print "Password for #$user\: "
        password = STDIN.noecho(&:gets).chomp
        print "\n"
        init_auth(password)
    end

    def init_auth(password)
        $token = JSON.parse(RestClient.post("https://#$user:#{password}@api.github.com/authorizations",
                    { :scopes => ["user", "repo"], :note => "gitconfig-sync" }.to_json, :accept => :json))["token"]
        File.open("#{HOME}/.config/gitconfig-sync", "w") do |file|
            file.puts("github.com:\n\tuser: #$user\n\toauth-token: #$token")
        end
    end

    def authenticate
        if authenticated?
            file = File.readlines(File.open("#{HOME}/.config/gitconfig-sync"))
            $user = file[1].split(/\:\s/)[1].strip!
            $token = file[2].split(/\:\s/)[1].strip!
        else
            query_user_pass
        end
    end
end
