module S3::OldDeletedRecordsService
  class << self

   DB_TABLES = %w$ shifts teams users contracts infos posts topics verlof_verzoeken$

    def get_records(db_table:, start_date:, end_date:, env_id:, env_name:)

      # validate_args(db_table)
      
      @start_date = start_date
      @end_date   = end_date
      @db_table   = db_table
      @env_name   = env_name
      @env_id     = env_id
      @date_range = get_date_range

      @file_names_filtered_by_table = request_object_names
      @file_names_filtered_by_date  = filter_by_date

      read_all_files
    end

    # validations

    def validate_args(db_table)
      throw :db_table_name_is_not_valid unless DB_TABLES.include?(db_table)
    end

    # base method

    def read_all_files
      @file_names_filtered_by_date.map do |file_name|       
        
        @file_name = file_name
        @file      = request_object 

        case @db_table
        when 'users'
          filter_users_table_by_env
        when 'topics'
          filter_topics_table_by_env
        else
          filter_file_by_env
        end

      end.flatten
    end

    # filter methods

    def filter_file_by_env
      has_env_id ? filter_by_env_id : filter_by_env_name
    end

    def filter_by_env_id
      @file.select { |row| row[:environment_id] == @env_id }
    end

    def filter_by_env_name
      @file.select { |row| row[:env] == @env_name }
    end

    def filter_users_table_by_env
      @file.select { |row| row[:envs].include? @env_name }
    end

    def filter_topics_table_by_env
      @file.select { |row| row[:environment_ids]&.include?(@env_id) }
    end

    def filter_by_date   
      @file_names_filtered_by_table.select { |file_name| @date_range.include?(get_date(file_name)) }
    end

    def has_env_id
      @file.first.has_key?(:env_id)
    end

    # date methods

    def get_date_range
      (Date.parse(@start_date)..Date.parse(@end_date)).to_a.map {|x| x.strftime("%Y-%m-%d") }
    end

    def get_date(file_name)
      file_name.match(/\d{4}-\d{2}-\d{2}/).to_s
    end

    # AWS methods

    def request_object_names
      s3      = Aws::S3::Client.new
      objects = s3.list_objects(bucket: 'eitje-backups', prefix: @db_table).contents
      names   = objects.collect &:key
    end

    def request_object
      s3     = Aws::S3::Client.new
      object = s3.get_object(bucket: 'eitje-backups', key: @file_name)
      json   = JSON.parse(object.body.read.as_json).map(&:symbolize_keys)
    end

  end
end