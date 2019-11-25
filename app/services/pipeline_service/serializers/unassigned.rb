module PipelineService
  module Serializers
    class Unassigned
      def initialize object:
        @assignment = object
      end

      def call
        @payload = {
          assignment_id: assignment.id,
          unassigned_at: Time.now.utc.iso8601,
          unassigned_students: unassigned_student_ids
      }.to_json
      end

      private

      attr_reader :assignment

      def unassigned_student_ids
        unassigned_students = SettingsService.get_settings(
          object: 'assignment',
          id: "160771"
        )['unassigned_students']
        unless unassigned_students.empty?
          unassigned_students.split(",").map { |s| s.to_i } 
        else
          []
        end
      end
    end
  end
end



