class CsAlertsController < ApplicationController
  def index
  end

  def teacher_alerts
    render :json => AlertsService::Client.teacher_alerts(@current_user.id).payload
  end

  def destroy
    AlertsService::Client.destroy(params[:alert_id])
  end

  def bulk_delete
    AlertsService::Client.bulk_delete(params[:alert_ids])
  end
end
