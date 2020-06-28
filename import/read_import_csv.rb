
require 'csv'
require 'active_record'
require '../app/models/application_record.rb'
require '../app/classes/quick_query.rb'
require '../app/models/album.rb'
require '../app/models/gig.rb'
require '../app/models/venue.rb'

ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    database: 'robyn_dev_backup',
    host: 'localhost',
    port: 3306,
    username: 'root'
)

# puts Gig.find(1).inspect

def print_venue(v)
  puts("[#{v[:venue_name]}][#{v[:index]}] / City: #{v[:city]} / State: #{v[:state]} / Country: #{v[:country]}")
end

def venue_to_csv(v)
  # "#{v[:venue_name]}|#{v[:index].nil? ? '' : "#{v[:index]}|"}#{v[:city]}|#{v[:state]}|#{v[:country]}"
  "#{v[:venue_name]}|#{v[:city]}|#{v[:state]}|#{v[:country]}"
end

def print_venue_csv(v)
  puts("#{v[:venue_name]}|#{v[:index].nil? ? '' : "#{v[:index]}|"}#{v[:city]}|#{v[:state]}|#{v[:country]}")
end

def prepare_venue_list(venues)
  venues.select { |v| not v[:venue_name].nil?}.sort {|a, b| a[:venue_name] <=> b[:venue_name]}
end

def prepare_venue_csv(venues)
  puts("Name,#{venues.first.fetch(:index, nil).nil? ? '' : "Index,"}City,State,Country")
  prepare_venue_list(venues).map {|v| print_venue_csv(v)}
end

def prepare_venue_csv2(venues)
  a = "Name|#{venues.first.fetch(:index, nil).nil? ? '' : "Index|"}City|State|Country\n"
  a + prepare_venue_list(venues).map {|v| "#{venue_to_csv(v)}"}.join("\n")
end


def prepare_mismatched_csv(venues)

  csv_data = "Name|City|State|Country|Current Name|Current City|Current State|Current Country|Index\n"

  prepare_venue_list(venues).each do |venue|

    csv_data << venue_to_csv(venue)
    csv_data << '|'
    csv_data << venue_to_csv(venue[:import_venue])
    csv_data << '|'
    csv_data << "#{venue[:import_venue][:index]}"
    csv_data << "\n"

  end

  csv_data

end

# TODO --- fix this up
def create_new_gig(gig_info)

  new_gig = Gig.new do |g|
      g.BilledAs = row["BilledAs"]
      g.Venue = row["Venue"]
      g.VENUEID = row["VENUEID"]
      g.GigType = row["GigType"]
      g.GigDate = row["GigDate"]
      g.GigYear = row["GigYear"]
      g.Circa = row["Circa"]
      g.SetNum = row["SetNum"]
      g.StartTime = row["StartTime"]
      g.Length = row["Length"]
      g.Guests = row["Guests"]
      g.ShortNote = row["ShortNote"]
      g.Shirts = row["Shirts"]
      g.Reviews = row["Reviews"]
      g.TapeExists = row["TapeExists"]
      g.Performance = row["Performance"]
      g.Sound = row["Sound"]
      g.Rarity = row["Rarity"]
      g.Format = row["Format"]
      g.Genealogy = row["Genealogy"]
      g.Flaws = row["Flaws"]
      g.Favorite = row["Favorite"]
      g.Master = row["Master"]
      g.Type = row["`Type"]
      g.Archived = row["Archived"]
      g.FEGID = row["FEGID"]
      g.ModifyDate = row["ModifyDate"]
  end
    
    puts new_gig.inspect
    
    new_gig.save
end

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

# pull in the csv file we're importing, and convert it into a CSV table
import_table = CSV.parse(File.read("robyn_import.csv"), headers: true, converters: [custom_converter, :numeric, :date_time])




index = 1

# the categories of venues extracted from the gig table
missing_venues    = [] 
mismatched_venues = []

# errors in the data
date_errors  = []

gig_issues = []

# loop through each row of the table
import_table.each { |row|

  index += 1

  # grab the dgig date
  year  = row['Year']
  month = row['Month']
  day   = row['Day']

  # account for unknown month/day
  month = 1 if month == "?" or month.nil?
  day   = 1 if day == "?" or day.nil?

  # puts "#{year} #{month} #{day}"

  # put together data on the gig venu
  venue_info = {
      :venue_name => row['Venue'].nil? ? nil : row['Venue'].strip,
      :city       => row['City'].nil? ? nil : row['City'].strip,
      :state      => row['State'].nil? ? nil : row['State'].strip,
      :country    => row['Country'].nil? ? nil : row['Country'].strip,
      :index      => index # the index of the record in the original table
  }

  # create the gig date
  begin
    gig_date = DateTime.new(year, month, day)
  rescue ArgumentError, NoMethodError
    date_errors.push(venue_info)
  end


  # look for the current gig in the database 
  #
  # note: we use the gig date and the venue name as the unique key
  gig = Gig.where(:GigDate => gig_date, :Venue => venue_info[:venue_name])

  if gig.present?
    # puts(gig)
    # puts "Found gig for #{gig.Venue} / #{gig_date} (#{index})"
  end

  # look up the venu of the current gig in the database

  # note: we use the venue name, city, state, and country as the unique keys for this lookup
  venue = Venue.where(
      :Name    => venue_info[:venue_name],
      :City    => venue_info[:city],
      :State   => venue_info[:state],
      :Country => venue_info[:country]
  )

  # if we didn't find the venue, figure out *why* we didn't find it
  if venue.blank?

    # look it up by name
    actual_venue = Venue.where(:Name => venue_info[:venue_name])

    # if it's there, assume there was a mismatch between the import data and the db
    if actual_venue.present?

      mismatched_venues.push({
        :venue_name   => actual_venue.first.Name,
        :city         => actual_venue.first.City,
        :state        => actual_venue.first.State,
        :country      => actual_venue.first.Country,
        :import_venue => venue_info
      })

    # otherwise it's legit not there
    else
      missing_venues.push(venue_info)

    end

  end

}

# remove the 'index' element from all missing venus
missing_venues.map! {|v| v.reject {|k, v| k == :index}}

# puts ("\n\nMismatched Venues\n===========")
# prepare_venue_list(mismatched_venues).each {|v| print_venue(v)}
# prepare_venue_csv(mismatched_venues)

MISMATCHED_VENUES_CSV = 'mismatched_venues.csv';
MISSING_VENUES_CSV = 'missing_venues.csv';

# write out missing venus in csv form
File.write("csv/#{MISMATCHED_VENUES_CSV}", prepare_mismatched_csv(mismatched_venues))
puts("Mismatched Venues: csv/#{MISMATCHED_VENUES_CSV}")


# write out csv of missing venus
File.write("csv/#{MISSING_VENUES_CSV}", prepare_venue_csv2(missing_venues.uniq))
puts("Missing Venues: csv/#{MISSING_VENUES_CSV}")

# write out date errors
File.write("csv/bad_dates.csv", prepare_venue_csv2(date_errors))
puts("Bad Dates: csv/bad_dates.csv")


