module SettingsService
  module Commands
    class GetEnrollmentSettings
      def initialize id:
        @id = id
      end

      def call
        SettingsService::Enrollment.create_table
        SettingsService::Enrollment.get(
          id: @id
        )
      end
    end
  end
end
