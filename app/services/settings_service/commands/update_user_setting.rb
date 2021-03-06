module SettingsService
  module Commands
    class UpdateUserSetting
      # DEPRICATED: Use "UpdateSettings instead"
      def initialize id:, setting:, value:
        @id = id
        @setting = setting
        @value = value
      end

      def call
        SettingsService::User.create_table
        SettingsService::User.put(
          id: @id,
          setting: @setting,
          value: @value
        )
      end
    end
  end
end
