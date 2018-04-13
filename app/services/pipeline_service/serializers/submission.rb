module PipelineService
  module Serializers
    # This ugly thing lets us call the canvas user api
    class Submission
      include ::Api
      include ::Api::V1::Submission
      include ActionView::Helpers
      include ActionDispatch::Routing::UrlFor
      include Rails.application.routes.url_helpers

      attr_reader :request

      def params;{};end

      def initialize(object:)
        default_url_options[:host] = ENV['CANVAS_DOMAIN']
        @object = object
        @admin = PipelineService::Account.account_admin
        @request = Struct.new(:host_with_port).new('hostwithport')
      end

      def call
        @current_user = @admin
        submission_json(@object, @object.assignment, @admin, {}, nil, [])
      end
    end
  end
end
