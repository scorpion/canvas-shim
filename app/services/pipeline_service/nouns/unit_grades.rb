module PipelineService
  module Nouns
    class UnitGrades
      attr_reader :course, :student, :id, :changes, :submission
      def initialize(submission)
        @course = submission.assignment.course
        @student = submission.user
        @submission = submission
        @id = submission.id
        @changes = submission.changes
      end

      def self.primary_key
        'id'
      end
    end
  end
end
