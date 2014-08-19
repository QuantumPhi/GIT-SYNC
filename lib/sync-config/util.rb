module SyncConfig
    def wait_task(fps=10)
        chars = %w[| / - \\]
        delay = 1.0/fps
        iter = 0
        spinner = Thread.new do
            while iter do
                print chars[(iter+=1) % chars.length]
                sleep delay
                print "\b"
            end
        end
        yield.tap{
            iter = false
            spinner.join
        }
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

    def clean_success(files)
        puts "Success. Cleaning directory."
        FileUtils.rm_rf(".git")
        if files.length > 0
            files.each do |file|
                FileUtils.rm_rf(file)
            end
        end
    end

    def clean_error(files)
        puts "Error. Aborting."
        FileUtils.rm_rf(".git")
        if files.length > 0
            files.each do |file|
                FileUtils.rm_rf(file)
            end
        end
    end

    def fix_config
        puts "Pull failed. Reverting .gitconfig."
        FileUtils.mv(".gitconfig.backup", ".gitconfig")
    end
end
