module AlertsService
  module Alerts
    class StudentDiscussionEntry < Alert
      ALERT_ATTRIBUTES = %i{ teacher_id student_id assignment_id message course_id}

      def initialize(atts)
        super
      end

      def assignment
        Assignment.find(assignment_id)
      end

      def student
        User.find(student_id)
      end

      def detail
        @message
      end

      def description
        'Student Replied To Discussion Topic'
      end
    end
  end
end