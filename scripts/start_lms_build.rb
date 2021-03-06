require "./scripts/travis.rb"
require 'yaml'
require 'active_support/all'

# If PR grab branch from PR branch env
# If push build or non-PR, use branch env
branch = [ENV['TRAVIS_PULL_REQUEST_BRANCH'], ENV['TRAVIS_BRANCH']].find { |item| item.present? }

puts "Branch found: #{branch}"

travis = Travis.new auth_token: ENV['TRAVIS_API_TOKEN'], repo_slug: "StrongMind%2Fcanvas-lms"

travis.create_request branch: branch

# need to sleep to give Travis time to assign build id
sleep 15

puts "Request id: #{travis.request_id}"
puts "Build id assigned: #{travis.build_id}"

File.open("travis_lms_build.yml", "w+") do |file|
  vars = {
    request_id: travis.request_id,
    build_id: travis.build_id
  }
  file.write(vars.to_yaml)
end

puts "Wrote request/build id to file"