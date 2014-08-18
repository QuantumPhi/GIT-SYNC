require 'fileutils'
require 'io/console'
require 'json'
require 'open-uri'
require 'rest-client'
require 'rubygems'
require 'ruby-git'

HOME = ENV["HOME"]

$user = ""
$token = ""

def authenticated
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

def authenticate()
    if authenticated
        file = File.readlines(File.open("#{HOME}/.config/gitconfig-sync"))
        $user = file[1].split(/\:\s/)[1]
        $token = file[2].split(/\:\s/)[1]
    else
        query_user_pass
    end
end

def sync_push()
    puts "creating repository"
    result = RestClient.post("https://api.github.com/user/repos",
                { :name => "gitconfig", :description => "My gitconfig" }.to_json,
                  :accept => :json, :Authorization => "token #$token")
    if result.code == 201
        result = JSON.parse(result)
    else
        puts "error:\n#{result}"
    end

    puts "initializing local repository"
    g = Git.init("#{HOME}")

    puts "updating origin"
    g.add_remote("origin", "https://github.com/#$user/gitconfig")

    puts uploading gitconfig
    g.add("#{HOME}/.gitconfig")
    g.commit("Synchronized gitconfig")
    g.push(g.remote("origin"))

    puts "cleaning directory"
    FileUtils.rm_rf("#{HOME}/.git")
end

def sync_pull(username = $user)
    puts "downloading gitconfig"
    data = URI.parse("https://github.com/#{username}/gitconfig").read

    file = File.open("#{HOME}/.gitconfig")

    puts "clearing gitconfig"
    file.truncate(0)

    puts "writing to gitconfig"
    file.write(data)
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
