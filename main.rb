require 'fileutils'
require 'io/console'
require 'git'
require 'json'
require 'rest-client'
require 'rubygems'

HOME = ENV["HOME"]

$user = ""
$token = ""

def authenticated
    return File.exist?("#{HOME}/.config/gitconfig-sync")
end

def repo_exists(username = $user)
    RestClient.get("https://api.github.com/repos/#{username}/gitconfig",
                    { :Authorization => "token #$token" }) { |response, request, result, &block|
                        if response.code != 404
                            return true
                        else
                            return false
                        end
                    }
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
    if authenticated
        file = File.readlines(File.open("#{HOME}/.config/gitconfig-sync"))
        $user = file[1].split(/\:\s/)[1].strip!
        $token = file[2].split(/\:\s/)[1].strip!
    else
        query_user_pass
    end
end

def sync_push
    if !repo_exists
        puts "creating repository"
        result = RestClient.post("https://api.github.com/user/repos",
                    { :name => "gitconfig", :description => "My gitconfig" }.to_json,
                    :accept => :json, :Authorization => "token #$token")
    end

    Dir.chdir HOME do
        puts "initializing local repository"
        git = Git.init
        puts "updating origin"
        git.add_remote("origin", "https://#$token@github.com/#$user/gitconfig.git")

        puts "uploading gitconfig"
        git.add(".gitconfig")
        git.commit("Synchronized gitconfig")
        git.push(git.remote("origin"))

        puts "cleaning directory"
        FileUtils.rm_rf(".git")

        puts "finished"
    end
end

def sync_pull(username = $user)
    Dir.chdir HOME do
        puts "initializing local repository"
        git = Git.init

        puts "updating origin"
        git.add_remote("origin", "https://#$token@github.com/#$user/gitconfig.git")

        puts "creating backup of gitconfig"
        FileUtils.mv(".gitconfig", ".gitconfig.backup")

        puts "pulling new gitconfig"
        git.pull

        puts "cleaning directory"
        FileUtils.rm_rf(".gitconfig.backup")
        FileUtils.rm_rf(".git")

        puts "finished"
    end
end

if ARGV[0] == "--push"
    authenticate
    sync_push
elsif ARGV[0] == "--pull"
    authenticate
    sync_pull
elsif ARGV[0] == "--help"
    puts "Usage: <Script> [Options]"
    puts "Options:"
    puts "\t--push: Push gitconfig to Github"
    puts "\t--pull: Pull gitconfig from Github"
else
    puts "Use \"--help\" for usage"
end
