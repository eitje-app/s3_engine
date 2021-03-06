module S3::NewDeletedRecordsService
  class << self

   DB_TABLES = %w$ shifts teams users contracts infos posts topics verlof_verzoeken$

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

      # Previously (before adding 'topics') the request bucket was 'eitje-deleted-jurr'
      # but somehow topics break if we dont request the bucket '-2'. Now for other tables
      # the original returns waaaaay many records, so probably does not filter by date or
      # something. Change for now and investigate if shit goes BG.

      begin
        file = @s3.get_object(bucket: 'eitje-deleted-jurr-2', key: @file_name)
        @records = JSON.parse(file.body.read.as_json).map(&:symbolize_keys)
      rescue Aws::S3::Errors::NoSuchKey
        @records = [] # files are only generated when an env has some deleted envs, through by uploading them old-style first
      end
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

__END__

def show_env(env_id, db_table = "verlof_verzoeken")
  start_date = (Date.today - 1.years).to_s
  end_date = (Date.today).to_s
  records = S3::NewDeletedRecordsService.get_records(db_table: db_table, start_date: start_date, end_date: end_date, env_id: env_id)
end

show_env(1176)
show_env(1176, "verlof_verzoeken")
