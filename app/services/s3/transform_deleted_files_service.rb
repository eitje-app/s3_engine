require 'json'

module S3::TransformDeletedFilesService
  class << self

    BUCKET = 'eitje-deleted-jurr-2'

    def set_setters(start_date = Date.yesterday)
      @start_date = start_date
      set_logger
      set_bucket
      set_tables
      set_dates(start_date)
    end

    def migrate_files(start_date: Date.today)
      set_setters(start_date)

      s3 = Aws::S3::Client.new
      envs_to_migrate = []

      set_tables.each do |table|  

        folder = table
        folder = "verlofverzoeks" if table == "verlof_verzoeken"

        puts "requesting #{table} on #{start_date.strftime("%Y-%m-%d")}..."

        object  = s3.get_object(bucket: 'eitje-backups', key: "#{folder}/#{start_date.strftime("%Y-%m-%d")}.json")
        json    = JSON.parse(object.body.read.as_json).map(&:symbolize_keys)
        
        if table == 'topics'
          env_ids = json.map {|row| row[:environment_ids]}.flatten.compact.uniq
        else
          env_ids = json.map {|row| row[:env]}.uniq.map { |name| Environment.find_by(naam: name)&.id }
        end

        envs_to_migrate << env_ids
      rescue Aws::S3::Errors::NoSuchKey => e
        # in case the file does not exist on S3, cause there are no deleted 
        # records, skip to next table
        puts "no records found for #{table} on #{start_date.strftime("%Y-%m-%d")}!"
        []
      end

      envs_to_migrate = envs_to_migrate.flatten.uniq.compact
      
      envs_to_migrate.each { |env_id| migrate_files_single_env(env_id, start_date: start_date, skip_setters: true) }
    end

    def migrate_files_single_env(environment_id, start_date: Date.yesterday, skip_setters: false)
      set_setters(start_date) unless skip_setters
      @env = Environment.find(environment_id)
      @tables.each do |table| 
        @table = table          
        compose_file
      end
    end

    def migrate_files_multi_env(environment_ids, start_date: Date.yesterday)
      set_setters(start_date)
      environment_ids.each { |id| migrate_files_single_env(id, start_date: start_date, skip_setters: true) }
    end

    def migrate_files_single_org(organisation_id, start_date: Date.yesterday)
      env_ids = Organisation.find(organisation_id).environment_ids
      migrate_files_multi_env(env_ids, start_date: start_date)
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

      @records = (@records | @existing_records) if @existing_records
      set_json
      upload_file

      rescue => e
        message = "Error for env #{@env.naam} (##{@env.id}) with table '#{@table}' => #{e.class}: #{e.message}.\n\nBacktrace:#{e.backtrace}\n"
        puts message
        @logger.error message
    end

    def upload_file
      @s3.put_object(bucket: BUCKET, key: @file_name, body: @json)
    end

  end
end
