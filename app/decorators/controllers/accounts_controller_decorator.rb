AccountsController.class_eval do
  def strongmind_settings
    @holidays = SettingsService.get_settings(object: :school, id: 1)['holidays']
    @holidays = @holidays.split(",") if @holidays
    @holidays ||= (ENV["HOLIDAYS"] && @holidays != false) ? ENV["HOLIDAYS"].split(",") : []
    js_env({HOLIDAYS: @holidays})
    instructure_settings
  end

  alias_method :instructure_settings, :settings
  alias_method :settings, :strongmind_settings

  def strongmind_update
    if params[:holidays]
      SettingsService.update_settings(
        object: 'school',
        id: 1,
        setting: 'holidays',
        value: holidays
      )
    end

    instructure_update
  end

  alias_method :instructure_update, :update
  alias_method :update, :strongmind_update

  private
  def holidays
    params[:holidays].blank? ? false : params[:holidays]
  end
end
