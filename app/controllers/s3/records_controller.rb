module S3
  class RecordsController < ApplicationController


    def deleted_records
      data = S3::OldDeletedRecordsService.get_records(**slice_params(:db_table, :start_date, :end_date, :env_id, :env_name))
      render json: {deleted_records: data}
    end

  end
end