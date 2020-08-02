require 'csv'
require 'active_record'

require_relative '../app/models/application_record.rb'
require_relative '../app/models/gig.rb'
require_relative '../app/models/venue.rb'

# CSV Gig import utilities
module CsvGigImport

  # Returns the given gig in CSV format, using a pipe (|) separator)
  #
  # If show_metadata is set, also includes metadata in the csv:
  #   - index of its position in the source file
  #   - reason it was marked invalid
  #
  def self.gig_to_csv(g, show_metadata)

    begin

      # byebug

      csv_data = ""

      csv_data << (g[:venue_name].nil? ? "" : g[:venue_name])
      csv_data << '|'
      csv_data << (g[:venue_id].nil? ? "" : g[:venue_id].to_s)
      csv_data << '|'
      csv_data << (g[:gig_date].nil? ? "" : g[:gig_date].to_s)
      csv_data << '|'
      csv_data << g[:billed_as]
      csv_data << '|'
      csv_data << g[:gig_type]
      csv_data << '|'
      csv_data << g[:guests]

      if show_metadata
        csv_data << '|'
        csv_data << g[:index].to_s
        csv_data << '|'
        csv_data << (g[:reason].nil? ? "" : g[:reason])
      end

      csv_data

    rescue TypeError
      puts g.inspect
    end

  end


  # Returns the given list of gigs in CSV format. The CSV:
  #   - Uses pipe (|) as the separator
  #   - Includes column names on the first line
  #
  # If show_metadata is set, also includes metadata in the csv (where applicable):
  #   - index of its position in the source file
  #   - reason it was marked invalid
  #
  def self.gigs_to_csv(gigs, show_metadata = false)
    a = "Venue Name|Venue ID|Date|Billed As|Gig Type|Guests" + (show_metadata ? "|Index|Reason" : "") + "\n"
    a + gigs.map {|g| "#{gig_to_csv(g, show_metadata)}"}.join("\n")
  end


  # Add the given list of gigs to the database
  def self.create_gigs(gigs)

    gigs.each do |gig_info|

      new_gig = Gig.new do |g|
        # byebug
        g.BilledAs = gig_info[:billed_as]
        g.Venue    = gig_info[:venue_name]
        g.VENUEID  = gig_info[:venue_id]
        g.GigType  = gig_info[:gig_type]
        g.GigDate  = gig_info[:gig_date]
        g.GigYear  = gig_info[:gig_date].year.to_s
        g.Circa    = gig_info[:circa]
        g.SetNum   = gig_info[:set_num]
        g.Guests   = gig_info[:guests]
      end

      new_gig.save

    end

  end


  # Analyzes the given CSV table, to prepare the gigs for import
  #
  # 1. Extracts gigs to add to the database
  # 2. Extracts gigs that already exist
  # 3. Extracts gigs that have some sort of error that prevents them from being imported
  #
  # Returns a tuple with three items (one for each list of gigs)
  def self.prepare_gigs(import_table)

    extant_gigs = []
    new_gigs = []
    data_errors = []

    index = 0

    # loop through each row of the table
    import_table.each { |row|

      index += 1

      # grab the gig date
      year  = row['Year']
      month = row['Month']
      day   = row['Day']

      # account for unknown month/day
      month = 1 if month == "?" or month.nil?
      day   = 1 if day   == "?" or day.nil?

      # put together data on the gig venu
      venue_info = {
          :venue_name => row['Venue'].nil? ? nil : row['Venue'].strip,
          :city       => row['City'].nil? ? nil : row['City'].strip,
          :state      => row['State'].nil? ? nil : row['State'].strip,
          :country    => row['Country'].nil? ? nil : row['Country'].strip,
      }

      # get the venue
      venue_query = Venue.where(
          :Name    => venue_info[:venue_name],
          :City    => venue_info[:city],
          :State   => venue_info[:state],
          :Country => venue_info[:country]
      )

      gig_info = {
          :billed_as => get_col_value(row,'BilledAs'),
          :gig_type => get_col_value(row, 'GigType'),
          :circa => row['Circa'],
          :set_num => row['SetNum'],
          :guests => get_col_value(row, 'Guests'),
          :index => index
      }

      if venue_query.present?

        if venue_query.many?

          data_errors.push(gig_info.merge({
              :reason => "Got multiple hits for #{venue_info[:venue_name]} / #{venue_info[:city]} / #{venue_info[:state]} / #{venue_info[:country]}"
          }))

        else

          venue = venue_query.to_a.first

          gig_info.merge!({
              :venue_id => venue.VENUEID,
              :venue_name => venue.Name,
          })

          gig_date = nil

          # create the gig date
          begin
            gig_date = DateTime.new(year, month, day)

          rescue ArgumentError, NoMethodError
            data_errors.push(gig_info.merge({
                :reason => 'Date error'
            }))

          end


          if gig_date.present?

            gig_info.merge!({
                :gig_date => gig_date
            })

            # look for the current gig in the database
            #
            # note: we use gig date and venue name as the unique key
            gig = Gig.where(:GigDate => gig_date, :VENUEID => venue.VENUEID)

            if gig.present?
              extant_gigs.push(gig_info)
            else
              new_gigs.push(gig_info)
            end

          end

        end

      else
        # byebug
        venue_name = row['Venue']
        if venue_name.present?
          data_errors.push(gig_info.merge({:reason => "Could not find venue #{venue_name}"}))
        else
          data_errors.push(gig_info.merge({:reason => "Missing venue name"}))
        end


      end

    }

    # remove the 'index' element from all new gigs
    new_gigs.map! {|v| v.reject {|k, v| k == :index}}

    [new_gigs, extant_gigs, data_errors]

  end


  # Dumps prepared gig info to a csv
  def self.dump_gig_csv(prepared_gigs, output_csv_directory)

    new_gigs_csv = "#{output_csv_directory}/gigs_new.csv"
    extant_gigs_csv = "#{output_csv_directory}/gigs_extant.csv"
    gig_data_issues_csv = "#{output_csv_directory}/gigs_data_issues.csv"

    new_gigs, extant_gigs, data_issues = prepared_gigs

    # write out new gigs
    File.write(new_gigs_csv, gigs_to_csv(new_gigs))
    puts("New Gigs: #{new_gigs_csv}")

    # write out existing gigs
    File.write(extant_gigs_csv, gigs_to_csv(extant_gigs, true))
    puts("Extant Gigs: #{extant_gigs_csv}")

    # write out data errors
    File.write(gig_data_issues_csv, gigs_to_csv(data_issues, true))
    puts("Data Issues: #{gig_data_issues_csv}")

  end


  # Extracts gigs from the given csv import_table, and writes them to the database
  #
  # If dump_csv is set, writes the gig analysis to three CSV files:
  #   - gigs_new.csv
  #   - gigs_extant.csv
  #   - gigs_data_issues.csv
  #
  def self.import_gigs(import_table, preview_only = false, output_csv_directory = nil)

    prepared_gigs = self.prepare_gigs(import_table)

    if output_csv_directory.present?
      dump_gig_csv(prepared_gigs, output_csv_directory)
    end

    new_gigs, extant_gigs, data_issues = prepared_gigs

    # if there are any new gigs, add them to the database
    if not preview_only and new_gigs.present?
      puts "Importing new gigs"
      create_gigs(new_gigs);
    end

  end

end