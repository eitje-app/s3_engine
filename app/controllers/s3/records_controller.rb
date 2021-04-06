class S3::RecordsController < API::Admin::BaseController #ApplicationController

  before_action :authorize_admin

  def deleted_records
    data = S3::OldDeletedRecordsService.get_records(**slice_params(:db_table, :start_date, :end_date, :env_id, :env_name))
    render json: {deleted_records: data}
  end

  private

  def slice_params(*args)
    params.slice(*args).as_json.symbolize_keys
  end

end

