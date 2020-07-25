
require 'csv'
require 'active_record'
require '../app/models/application_record.rb'
require '../app/classes/quick_query.rb'
require '../app/models/album.rb'
require '../app/models/gig.rb'
require '../app/models/venue.rb'

require '../import/CsvGigImport'
require '../import/CsvVenueImport'

require 'byebug'

require 'optparse'


ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    database: 'robyn_dev_backup',
    host: 'localhost',
    port: 3306,
    username: 'root'
)


custom_converter = lambda { |value, field_info|

  if value == "NULL" 
    nil
  else 
    case field_info.header
        # when 'GigDate', 'StartTime', 'ModifyDate'
            # puts "date #{field_info.header}: #{value}"
            # DateTime.strptime(value, '%m/%d/%y %H:%M')
            # puts(value)
            # DateTime.strptime(value, '%Y-%m-%d %H:%M:%S')
        when 'Circa', 'TapeExists', 'Favorite'
            value != "0"    
        else
            value
    end
  end

}


def get_col_value(row, col)
  row[col].nil? ? '' : row[col].strip
end


import_csv_file = ARGV[0]
output_csv_directory = ARGV[1]

# pull in the csv file we're importing, and convert it into a CSV table
import_table = CSV.parse(File.read(import_csv_file), headers: true, converters: [custom_converter, :numeric, :date_time])


options = {
  :preview => false,
  :csv => nil
}

OptionParser.new do |opts|
  opts.banner = "Usage: import_csv.rb [options]"

  opts.on("-cCSVDIR", "--csv", "Write CSV action to the given directory") do |c|
    options[:csv] = c
  end

  opts.on("-p", "--preview", "Show preview of import only. Must be paired with --csv option") do |c|
    options[:preview] = c
  end

end.parse!

p options
p ARGV



# handle venue import
CsvVenueImport.import_venues(import_table, options[:preview], options[:csv])

# handle gig import
CsvGigImport.import_gigs(import_table, options[:preview], options[:csv])


