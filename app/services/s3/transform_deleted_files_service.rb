require 'json'

module S3::TransformDeletedFilesService
  class << self

    BUCKET = 'eitje-deleted-jurr-2'

    def migrate_files(start_date: '2019-07-18')
      @start_date = start_date

      set_logger
      set_bucket
      set_tables
      set_dates(start_date)

      Environment.in_use.find_each do |env|
        @env = env
        
        @tables.each do |table| 
          @table = table          
          compose_file
        end
      end
    end

    def set_logger
      @logger = Logger.new "log/migrate_deleted_records_#{DateTime.now.strftime('%Y_%m_%d_%H:%M:%S')}.log"
    end

    def set_bucket
      @s3 = Aws::S3::Client.new
    end

    def set_tables
      @tables = S3::OldDeletedRecordsService::singleton_class::DB_TABLES
    end

    def set_dates(start_date)
      format_start_date
      @dates = {start_date: @start_date, end_date: Date.today.strftime("%Y-%m-%d")}
    end

    def format_start_date
      @start_date = @start_date.class == String ? @start_date : @start_date.strftime("%Y-%m-%d")
    end

    def set_records
      @records = S3::OldDeletedRecordsService.get_records(env_id: @env.id, env_name: @env.naam, db_table: @table, **@dates)
    end

    def set_json
      @json = JSON.pretty_generate(@records)
    end

    def set_file_name
      @file_name = "env_#{@env.id}_deleted_#{@table}.json"
    end

    def set_existing_records
      object = @s3.get_object(bucket: BUCKET, key: @file_name)
      @existing_records = JSON.parse(object.body.read.as_json).map(&:symbolize_keys)
      
      rescue Aws::S3::Errors::NoSuchKey => e
        @existing_records = nil
    end

    def compose_file
      set_records
      set_file_name
      set_existing_records

      (@records += @existing_records) if @existing_records
      set_json
      upload_file  
      rescue => e
        @logger.error "Error for env #{@env.naam} (##{@env.id}) with table '#{@table}' => #{e.class}: #{e.message}.\n\nBacktrace:#{e.backtrace}\n"
    end

    def upload_file
      @s3.put_object(bucket: BUCKET, key: @file_name, body: @json)
    end

  end
end