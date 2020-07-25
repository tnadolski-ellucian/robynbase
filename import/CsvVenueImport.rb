require 'csv'
require 'active_record'

require '../app/models/application_record.rb'
require '../app/models/venue.rb'

require 'byebug'

# CSV Venue Import Utilities
module CsvVenueImport

  # Write the given venue info to console
  def self.print_venue(v)
    puts("[#{v[:venue_name]}] / City: #{v[:city]} / State: #{v[:state]} / Country: #{v[:country]}")
  end

  # Returns the given venue in CSV format, using a pipe (|) separator)
  #
  # If show_metadata is set, also includes metadata in the csv:
  #   - index of its position in the source file
  #   - reason it was marked invalid
  #
  def self.venue_to_csv(v, show_metadata = false)

    csv_entry = "#{v[:venue_name]}|#{v[:city]}|#{v[:state]}|#{v[:country]}"

    if show_metadata
      csv_entry << "|#{v[:index]}|#{v[:reason]}"
    end

    csv_entry

  end



  # Returns the given list of venues in CSV format. The CSV:
  #   - Uses pipe (|) as the separator
  #   - Includes column names on the first line
  #
  # If show_metadata is set, also includes metadata in the csv (where applicable):
  #   - index of its position in the source file
  #   - reason it was marked invalid
  #
  def self.venues_to_csv(venues, show_metadata)
    a = "Name|City|State|Country" + (show_metadata ? "|Index|Reason" : "") + "\n"
    a + venues.map {|v| "#{venue_to_csv(v, show_metadata)}"}.join("\n")
  end


  # def self.prepare_mismatched_csv(venues)
  #
  #   csv_data = "DB Name|DB City|DB State|DB Country|Import Name|Import City|Import State|Import Country|Import Index\n"
  #
  #   mismatched_venues = venues.select { |v| not v[:venue_name].nil?}.sort {|a, b| a[:venue_name] <=> b[:venue_name]}
  #
  #   prepare_venue_list(mismatched_venues).each do |venue|
  #
  #     csv_data << venue_to_csv(venue)
  #     csv_data << '|'
  #     csv_data << venue_to_csv(venue[:import_venue])
  #     csv_data << '|'
  #     csv_data << "#{venue[:import_venue][:index]}"
  #     csv_data << "\n"
  #
  #   end
  #
  #   csv_data
  #
  # end


  # def print_venue_csv(v)
  #   puts("#{v[:venue_name]}|#{v[:city]}|#{v[:state]}|#{v[:country]}#{v[:index].nil? ? '' : "|#{v[:index]}"}")
  # end

  # def prepare_venue_list(venues)
  #   venues.select { |v| not v[:venue_name].nil?}.sort {|a, b| a[:venue_name] <=> b[:venue_name]}
  # end

  # Add the given list of venues to the database
  def self.create_venues(venues)

    venues.each do |venue|

      # print_venue(venue)

      new_venue = Venue.new do |v|
        v.Name    = venue[:venue_name]
        v.City    = venue[:city]
        v.State   = venue[:state]
        v.Country = venue[:country]
      end

      new_venue.save

    end

  end


  # Analyzes the given CSV table, to prepare the venues for import
  #
  # 1. Extracts venues to add to the database
  # 2. Extracts venues that already exist
  # 3. Extracts venues that have some sort of error that prevents them from being imported
  #
  # Returns a tuple with three items (one for each list of gigs)
  def self.analyze_venues(import_table)

    index = 1

    # the categories of venues extracted from the gig table
    new_venues = []
    extant_venues = []
    data_errors  = []

    # mismatched_venues = []


    # loop through each row of the table
    import_table.each { |row|

      index += 1

      # put together data on the gig venu
      venue_info = {
          :venue_name => row['Venue'].nil? ? nil : row['Venue'].strip,
          :city       => row['City'].nil? ? nil : row['City'].strip,
          :state      => row['State'].nil? ? nil : row['State'].strip,
          :country    => row['Country'].nil? ? nil : row['Country'].strip,
          :index      => index # the index of the record in the original table
      }

      # make sure we have everything we need to recognize a venue
      if venue_info[:venue_name].nil? or venue_info[:country].nil?
        data_errors.push(venue_info.merge({:reason => 'Missing unique key info'}))
      else

        ### look up the venue of the current gig in the database

        # note: enue name, city, state, and country are the unique keys for this lookup
        venue = Venue.where(
            :Name    => venue_info[:venue_name],
            :City    => venue_info[:city],
            :State   => venue_info[:state],
            :Country => venue_info[:country]
        )

        # if we didn't find the venue, add it to the list of new venues; otherwise the list of extant venues
        if venue.blank?

          # # look it up by name
          # actual_venue = Venue.where(:Name => venue_info[:venue_name])
          #
          # # if it's there, assume there was a mismatch between the import data and the db
          # if actual_venue.present?
          #
          #   mismatched_venues.push(
          #       {
          #         :venue_name   => actual_venue.first.Name,
          #         :city         => actual_venue.first.City,
          #         :state        => actual_venue.first.State,
          #         :country      => actual_venue.first.Country,
          #         :import_venue => venue_info
          #       }
          #   )
          #
          # # otherwise it's legit not there
          # else
          new_venues.push(venue_info)

          # end

        else
          extant_venues.push(venue_info)
        end

      end

    }

    # remove the 'index' element from all new venues
    new_venues.map! {|v| v.reject {|k, v| k == :index}}

    # remove duplicate venues
    new_venues.uniq!

    # # remove duplicate mismatches
    # mismatched_venues.uniq! do |v|
    #   v[:import_venue].reject {|k, v| k == :index}
    # end

    # [new_venues, mismatched_venues, data_errors]
    [new_venues, extant_venues, data_errors]

  end


  # MISMATCHED_VENUES_CSV = 'mismatched_venues.csv'
  # NEW_VENUES_CSV = 'venues_new.csv'
  # EXTANT_VENUES_CSV = 'venues_extant.csv'
  # VENUE_DATA_ISSUES_CSV = 'venues_data_issues.csv'

  def self.dump_venue_csv(venue_analysis, output_csv_directory)

    new_venues_csv = "#{output_csv_directory}/venues_new.csv"
    extant_venues_csv = "#{output_csv_directory}/venues_extant.csv"
    venue_data_issues_csv = "#{output_csv_directory}/venues_data_issues.csv"

    # missing_venues, mismatched_venues, data_issues = venue_analysis
    new_venues, extant_venues, data_issues = venue_analysis

    # write out missing venus in csv form
    # File.write("csv/#{MISMATCHED_VENUES_CSV}", prepare_mismatched_csv(mismatched_venues.uniq))
    # puts("Mismatched Venues: csv/#{MISMATCHED_VENUES_CSV}")

    # write out new venues in csv form
    File.write(new_venues_csv, venues_to_csv(new_venues, false))
    puts("New Venues: #{new_venues_csv}")

    # write out extant venues in csv form
    File.write(extant_venues_csv, venues_to_csv(extant_venues, true))
    puts("Extant Venues: #{extant_venues_csv}")

    # write out data errors
    File.write(venue_data_issues_csv, venues_to_csv(data_issues, true))
    puts("Bad Dates: #{venue_data_issues_csv}")

  end


  # Extracts venues from the given csv import_table, and writes them to the database
  #
  # If dump_csv is set, writes the venue analysis to three CSV files:
  #   - venues_new.csv
  #   - venues_extant.csv
  #   - venues_data_issues.csv
  #
  def self.import_venues(import_table, preview_only = false, output_csv_directory = nil)

    venue_analysis = self.analyze_venues(import_table)

    if output_csv_directory.present?
      self.dump_venue_csv(venue_analysis, output_csv_directory)
    end

    new_venues, mismatched_venues, data_issues = venue_analysis

    # if there are any new venues, add them to the database
    if not preview_only and new_venues.present?
      puts 'Importing new venues'
      self.create_venues(new_venues)
    end

  end

end