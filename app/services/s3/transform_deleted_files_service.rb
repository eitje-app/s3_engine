require 'json'

module S3::TransformDeletedFilesService
  class << self

    BUCKET = 'eitje-deleted-jurr'

    def migrate_files
      set_bucket
      set_path
      set_tables
      set_dates

      Environment.find_each do |env|
        @env = env
        
        @tables.each do |table| 
          @table = table          
          compose_file
        end
      end
    end

    def set_bucket
      @s3 = Aws::S3::Client.new
    end

    def set_path
      @path = Dir.glob("#{Rails.root}/app/deleted_files").first
    end

    def set_tables
      @tables = S3::OldDeletedRecordsService::singleton_class::DB_TABLES
    end

    def set_dates
      @dates = {start_date: '2019-07-18', end_date: Date.today.strftime("%Y-%m-%d")}
    end

    def set_json
      records = S3::OldDeletedRecordsService.get_records(env_id: @env.id, env_name: @env.naam, db_table: @table, **@dates)
      @json   = JSON.pretty_generate(records)
    end

    def set_file_name
      @file_name = "env_#{@env.id}_deleted_#{@table}.json"
    end

    def compose_file
      set_json
      set_file_name
      upload_file  
    end

    def upload_file
      @s3.put_object(bucket: BUCKET, key: @file_name, body: @json)
    end

  end
end