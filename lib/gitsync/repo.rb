module GitSync
    module Repo
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
    end
end
