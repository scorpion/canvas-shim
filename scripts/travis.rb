require 'httparty'

class Travis
  attr_accessor :auth_token, :repo_slug
  attr_accessor :debug_build_response, :create_request_response, :list_requests_response, :show_build_response

  def initialize(auth_token: nil, repo_slug: nil)
    raise 'You must provided a Travis Auth Token to use this class' if auth_token.nil?

    @auth_token = auth_token
    @repo_slug  = repo_slug
    @headers    = {
      'Content-Type'       => 'application/json',
      'Accept'             => 'application/json',
      'Travis-API-Version' => '3',
      'Authorization'      => "token #{@auth_token}"
    }
  end

  def request_id
    @request_id ||= @create_request_response['request']['id']
  end

  def build_id
    @build_id ||= begin
      @build = show_request(id: @request_id)['builds']
      @build.first.id
    end
  end

  # Trigger a debug build
  # JOB_ID = 523737962 # shim job
  # JOB ID = 524218744 # canvas job
  #
  def debug_build(job_id: nil)
    raise 'You must provided a Travis Job ID to initiate a debug build' if job_id.nil?

    raw_response = HTTParty.post("https://api.travis-ci.org/job/#{job_id}/debug", {
      headers: @headers,
      body: {'quiet' => true}.to_json,
      debug_output: STDOUT
    })

    @debug_build_response = JSON.parse(raw_response.body)
  end

  # Trigger a spec run on a branch
  # BRANCH='19-04-15-shim-specs-in-lms'
  #
  def create_request(branch: nil)
    raise 'You must provide a branch name to start a build' if branch.nil?

    raw_response = HTTParty.post("https://api.travis-ci.org/repo/#{@repo_slug}/requests", {
      headers: @headers,
      body: {
        'request' => {
          'branch' => branch,
          'message': "Canvas LMS build API triggered via commit on Canvas Shim.",
          'config': {
            'script': "export SHIM_BRANCH='#{branch}'; STRONGMIND_SPEC=1 HEADLESS=1 ./script/run-tests.sh"
          }
        }
      }.to_json,
      debug_output: STDOUT
    })

    @create_request_response = JSON.parse(raw_response.body)
  end

  # Show Request
  #
  def show_request(id: nil)
    raw_response = HTTParty.get("https://api.travis-ci.org/repo/#{@repo_slug}/request/#{id || request_id}", {
      headers: @headers,
      debug_output: STDOUT
    })

    @show_request_response = JSON.parse(raw_response.body)
  end

  # List Requests
  #
  def list_requests
    raw_response = HTTParty.get("https://api.travis-ci.org/repo/#{@repo_slug}/requests", {
      headers: @headers,
      debug_output: STDOUT
    })

    @list_requests_response = JSON.parse(raw_response.body)
  end

  # Show Build
  #
  def show_build(build_id: nil)
    raise 'You must provided a request id to check on a build' if build_id.nil?

    raw_response = HTTParty.get("https://api.travis-ci.org/build/#{build_id || self.build_id}", {
      headers: @headers,
      debug_output: STDOUT
    })

    @show_build_response = JSON.parse(raw_response.body)
  end

  def check_build(build_id: nil)
    raw_response = HTTParty.get("https://api.travis-ci.org/build/#{build_id || self.build_id}", {
      headers: @headers,
      debug_output: STDOUT
    })

    @show_build_response = JSON.parse(raw_response.body)
    @show_build_response["state"]
  end
end
