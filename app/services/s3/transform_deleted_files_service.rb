require 'json'

module S3::TransformDeletedFilesService
  class << self

    def test
      set_path
      set_tables
      set_dates

      Environment.find_each do |env|
        @env = env
        
        @tables.each do |table| 
          @table = table
          next if table == 'shifts'
          
          create_new_file
        end
      end
    end

    def set_path
      @path = Dir.glob("#{Rails.root}/app/deleted_files").first
    end

    def set_tables
      @tables = S3::OldDeletedRecordsService::singleton_class::DB_TABLES
    end

    def set_dates
      @dates = {start_date: '2018-01-01', end_date: Date.today.strftime("%Y-%m-%d")}
    end

    def set_json
      # records = S3::OldDeletedRecordsService.get_records(env_id: 22, env_name: 'Cafe eitje', db_table: @table, **@dates)
      records = S3::OldDeletedRecordsService.get_records(env_id: @env.id, env_name: @env.naam, db_table: @table, **@dates)
      @json   = JSON.pretty_generate(records)
    end

    def set_file_path
      file_name  = "env_#{@env.id}_deleted_#{@table}.json"
      @file_path = "#{@path}/#{file_name}"
    end

    def create_new_file
      set_json
      set_file_path 
      File.write(@file_path, @json)
    end

  end
end