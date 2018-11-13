module PipelineService
  module Events
    class Emitter
      def initialize args={}
        @object = args[:object]
        @args = args
        @responder = @args[:responder] || Events::Responders::SIS
      end

      def call
        build_message
        build_responder
        build_subscriptions
        emit
      end

      private

      attr_reader :subscriptions, :object, :responder, :message

      def events
        {
          graded_out: Events::GradedOutEvent,
          grade_changed: Events::GradeChangedEvent
        }
      end

      def build_subscriptions
        @subscriptions = [:graded_out, :grade_changed].map do |event_name|
          Events::Subscription.new(event: event_name, responder: responder)
        end
      end

      def build_responder
        @responder = responder.new(
          object: object,
          message: message
        )
      end

      def serializer
        case object
        when Submission
          Serializers::UnitGrades
        when Enrollment
          Serializers::CanvasAPIEnrollment
        end
      end

      def build_message
        @message = serializer.new(object: object).call
      end

      def emit
        subscriptions.each do |subscription|
          next unless events[subscription.event]
          events[subscription.event].new(
            @args.merge(subscription: subscription)
          ).emit
        end
      end
    end
  end
end
