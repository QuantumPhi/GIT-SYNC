require 'rubygems'
require 'bundler/setup'

require 'io/console'
require 'json'
require 'fileutils'
require 'git'
require 'rest-client'

require 'sync-config/sync-auth'
require 'sync-config/sync-util'


module SyncConfig
    HOME = ENV["HOME"]

    $user = ""
    $token = ""

    def push
        authenticate
        if !repo_exists
            print "Creating upstream repository..."
            wait_task {
                result = RestClient.post("https://api.github.com/user/repos",
                            { :name => "gitconfig", :description => "My gitconfig" }.to_json,
                              :accept => :json, :Authorization => "token #$token")
            }
            puts "Done"
        end

        Dir.chdir HOME do
            print "Initializing local repository..."
            git = nil
            wait_task {
                git = Git.init
            }
            puts "Done"

            print "Updating origin..."
            wait_task {
                git.add_remote("origin", "https://#$token@github.com/#$user/gitconfig.git")
            }
            puts "Done"

            print "Uploading gitconfig..."
            wait_task {
                git.add(".gitconfig")
                git.commit("Synchronized gitconfig")
                git.push(git.remote("origin"))
            }
            puts "Done"

            puts "Finished"
        end
    end

    def pull(username = $user)
        authenticate
        Dir.chdir HOME do
            print "Initializing local repository..."
            git = nil
            wait_task {
                git = Git.init
            }
            puts "Done"

            print "Updating origin..."
            wait_task {
                git.add_remote("origin", "https://#$token@github.com/#$user/gitconfig.git")
            }
            puts "Done"

            print "Creating backup of gitconfig..."
            wait_task {
                FileUtils.mv(".gitconfig", ".gitconfig.backup")
            }
            puts "Done"

            print "Pulling new gitconfig..."
            wait_task {
                git.pull
            }
            puts "Done"

            puts "Finished"
        end
    end

    module_function :push, :pull, :authenticated?, :query_user_pass, :init_auth, :authenticate, :repo_exists, :wait_task
    public :push, :pull
    private :authenticated?, :query_user_pass, :init_auth, :authenticate, :repo_exists, :wait_task
end

SyncConfig.methods.each do |method|
    puts method
end
if ARGV[0] == "--push"
  SyncConfig.push
elsif ARGV[0] == "--pull"
  SyncConfig.pull
elsif ARGV[0] == "--help"
  puts "Usage: <Script> [Options]"
  puts "Options:"
  puts "\t--push: Push gitconfig to Github"
  puts "\t--pull: Pull gitconfig from Github"
end
