require "./scripts/travis.rb"
require 'yaml'
require 'active_support'

travis = Travis.new auth_token: '2Zs3QvPdUqpWXL1kB-aM5A', repo_slug: "StrongMind%2Fcanvas-lms"


build_values = YAML.load(File.read("travis_lms_build.yml")).with_indifferent_access

puts "Build values: #{build_values}"

build_id = build_values[:build_id]

if build_id.present?
  loop do
    sleep 20
    state = travis.check_build(build_id: build_id)

    puts "Build check: #{state}"

    break if ['failed', 'canceled'].include?(state)
  end

  # From Travis docs
  # If any of the commands in the first four phases of the job lifecycle return a non-zero exit code, the build is broken

  exit(1) unless travis.show_build_response["result"] == 'approved'
else
  puts "No LMS build ID found, exiting with fail status"
  exit(1)
end
