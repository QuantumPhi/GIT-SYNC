require 'sync-config/authenticate'
require 'sync-config/repo'

HOME = ENV["HOME"]

$user = ""
$token = ""

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
