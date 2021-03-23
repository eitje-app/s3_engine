module S3::NewDeletedRecordsService
  class << self

   DB_TABLES = %w$ shifts teams users contracts infos posts $

    def test(table)
      S3::NewDeletedRecordsService.get_records(
        db_table: table, start_date: '2021-03-01', end_date: '2021-03-23', env_id: 1
      )
    end

    def get_records(db_table:, start_date:, end_date:, env_id:)    
      @date_range = Date.parse(start_date)..Date.parse(end_date)
      @s3         = Aws::S3::Client.new 
      @db_table   = db_table
      @env_id     = env_id

      set_file_name
      validate_args

      query_records
      filter_records
      @records
    end

    def validate_args
      throw :db_table_name_is_not_valid unless DB_TABLES.include?(@db_table)
    end

    def set_file_name
      @file_name = "env_#{@env_id}_deleted_#{@db_table}.json"
    end

    def query_records    
      file     = @s3.get_object(bucket: 'eitje-deleted-jurr', key: @file_name)
      @records = JSON.parse(file.body.read.as_json).map(&:symbolize_keys)
    end

    def filter_records
      return if no_deleted_at?
      @records.select! { |record| @date_range.include?(Date.parse(record[:deleted_at])) }
    end

    def no_deleted_at?
      %w[infos].include? @db_table # files without deleted_at field
    end

  end
end