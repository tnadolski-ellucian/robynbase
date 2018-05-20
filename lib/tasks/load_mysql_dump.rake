desc "Import a MySQL dump file (file must be specified in env variable FILENAME)"

namespace :db do
  namespace :data do
    task :load_mysql_dump => 'environment' do
        environment = (ENV.include?("RAILS_ENV")) ? (ENV["RAILS_ENV"]) : 'development'
        ENV["RAILS_ENV"] = RAILS_ENV = environment

        database = Rails.configuration.database_configuration[Rails.env]["database"]
        user = Rails.configuration.database_configuration[Rails.env]["username"]
        password = Rails.configuration.database_configuration[Rails.env]["password"]
        filename = ENV['FILENAME']
        raise "Please specify a source file (FILENAME=[source.sql])" if filename.blank?

        puts "Connecting to #{environment}..."
        ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

        # puts "Truncating table offices..."
        # ActiveRecord::Base.connection.execute("truncate table offices")

        puts "Importing data from #{filename}..."
        puts "mysql -u#{user} -p#{password} #{database} < #{filename}"
        sh "mysql -u#{user} -p#{password} #{database} < #{filename}"
        puts "Completed loading #{filename} into #{environment} environment."
      end
    end
  end