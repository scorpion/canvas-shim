module PipelineService
  module V2
    class Noun < Models::Noun
      attr_reader :ar_model
      def initialize(object)
        @ar_model = object
        super(object)
      end

      def serializer
        case short_class_name
        when /ContentTag/
          PipelineService::V2::Nouns::ContentTag
        when /Submission/
          PipelineService::V2::Nouns::Submission
        when /User/
          PipelineService::V2::Nouns::User
        else
          PipelineService::V2::Nouns::Base
        end
      end

      def short_class_name
        @noun_class.to_s.split('::').last
      end

    end
  end
end
