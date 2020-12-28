require 'csv'
require 'active_record'

require_relative '../app/models/application_record.rb'
require_relative '../app/models/gig.rb'
require_relative '../app/models/song.rb'
require_relative '../app/models/gigset.rb'
require_relative '../app/models/venue.rb'
require_relative './import_helpers.rb'

# CSV Gig import utilities
module CsvGigImport

  #   /^                -> start
  #   (.*?)\s*          -> song name
  #   (?:\[(.+)\])?\s?  -> optional artist 
  #   (?:<<(.+)>>)?     -> optional version notes
  #   (?:{{(Encore)}})? -> optional encore marker
  #   $/                -> end
  SONG_MATCHER = /^(.*?)\s*(?:\[(.+)\])?\s?(?:<<(.+)>>)?\s?(?:{{(Encore)}})?$/

  SongData = Struct.new(:song_name, :artist, :version_notes, :encore)

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
      csv_data << g[:set_num].to_s
      csv_data << '|'
      csv_data << g[:gig_type]
      csv_data << '|'
      csv_data << g[:guests]
      csv_data << '|'
      csv_data << g[:notes]

      if show_metadata
        csv_data << '|'
        csv_data << g[:index].to_s
        csv_data << '|'
        csv_data << (g[:reason].nil? ? "" : g[:reason])
      end

      csv_data

    rescue TypeError => e
      puts "Error getting gig! #{e.message}"
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
    a = "Venue Name|Venue ID|Date|Billed As|Set Num|Gig Type|Guests|Notes" + (show_metadata ? "|Index|Reason" : "") + "\n"
    a + gigs.map {|g| "#{gig_to_csv(g, show_metadata)}"}.join("\n")
  end

  def self.missing_songs_to_csv(songs)
    a = "Name|Author|\n"
    a + songs.map {|s| "#{s.song_name}|#{s.artist ? s.artist : ''}|"}.join("\n")
  end

  # Add the given list of gigs to the database
  def self.crupdate_gigs(gigs, update, create_missing_songs)

    newly_created_songs = {}

    gigs.each do |gig_info|

      # if we're updating the gig, grab it first; otherwise create a new one
      if update
        gig = Gig.where(:GigDate => gig_info[:gig_date], :VENUEID => gig_info[:venue_id],  :SetNum => gig_info[:set_num])
        gig = gig.to_a.first
      else
        gig = Gig.new
      end

      gig.BilledAs  = gig_info[:billed_as]
      gig.Venue     = gig_info[:venue_name]
      gig.VENUEID   = gig_info[:venue_id]
      gig.GigType   = gig_info[:gig_type]
      gig.GigDate   = gig_info[:gig_date]
      gig.GigYear   = gig_info[:gig_date].year.to_s
      gig.Circa     = gig_info[:circa]
      gig.SetNum    = gig_info[:set_num]
      gig.Guests    = gig_info[:guests]
      gig.ShortNote = gig_info[:notes]

      # import set list if present
      if gig_info[:set_list].present?

        # always start setlists from scratch
        gig.gigsets.clear

        # create a new gigset record for each song
        gig_info[:set_list].each do |entry|

          song_name_compare = entry[:song].upcase

          # create new song reecords for missing songs (if requested to do so)
          if create_missing_songs and entry[:song_id].blank? 

            # if we've already created this song, figure out the song id of that new record
            if newly_created_songs[song_name_compare].present?
              entry[:song_id] = newly_created_songs[song_name_compare]

            # otherwise add the new song  
            else
              new_song = Song.make_song_record(entry[:song], entry[:author])
              new_song.save
              entry[:song_id] = new_song.SONGID            

              # remember that we created this song
              newly_created_songs[song_name_compare] = entry[:song_id]
              
            end

          end

          record = Gigset.new
          record.Chrono = entry[:chrono]
          record.Song   = entry[:song]
          record.SONGID = entry[:song_id]
          record.VersionNotes = entry[:version_notes]
          record.Encore = entry[:encore] === "Encore"

          gig.gigsets << record

        end

      end

      gig.save

    end

  end

  # Returns the import value if it's available; otherwise return the extant value
  def self.get_field(import_value, extant_value)
    if import_value.blank?
      extant_value
    else
      import_value
    end    
  end

  # Analyzes the given CSV table, to prepare the gigs for import
  #
  # 1. Extracts gigs to add to the database
  # 2. Extracts gigs that already exist
  # 3. Extracts gigs that have some sort of error that prevents them from being imported
  #
  # Returns a tuple with three items (one for each list of gigs)
  def self.prepare_gigs(import_table, create_missing_songs)

    extant_gigs = []
    new_gigs = []
    updated_gigs = []
    data_errors = []
    missing_songs = []

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
          :notes => get_col_value(row, 'Notes'),
          :index => index
      }

      if venue_query.present?

        if venue_query.many?

          data_errors.push(gig_info.merge({
              :reason => "Got multiple hits for #{venue_info[:venue_name]} / #{venue_info[:city]} / #{venue_info[:state]} / #{venue_info[:country]}"
          }))

        else

          venue = venue_query.to_a.first

          # use the gig-specific venue name if it's available; otherwise fall back to official venue
          # name
          venue_name = row['GigVenue'].nil? ? venue.Name : row['GigVenue'].strip

          gig_info.merge!({
              :venue_id => venue.VENUEID,
              :venue_name => venue_name,
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

            # only process setlists for shows after 2013
            if gig_date.year >= 2013 and row['SetList'].present?

              set_list = []

              index = 1
                  
              # loop through each line in the set list cell
              row['SetList'].each_line() do |song|
                     
                song.strip!

                # break the song name list into its constituent pieces
                song_data = SONG_MATCHER.match(song) {|m| SongData.new(*m.captures)}

                item = {
                  :chrono => index,
                  :song => song_data.song_name,
                  :version_notes => song_data.version_notes,
                  :author => song_data.artist,
                  :encore => song_data.encore
                }

                # only add to the set if the song name isn't blank
                if song_data.song_name.present?

                  # look for a song with the given name
                  song_record = Song.find_full_name(song_data.song_name)
        
                  # if there isn't one there, we'll just display the song name (unlinked)
                  if song_record.empty?

                    missing_songs.push(song_data)

                    if not create_missing_songs

                      item[:song] = "#{song_data.song_name}#{song_data.artist.present? ? ' [' + song_data.artist + ']' : ''}"

                      data_errors.push(gig_info.merge({
                          :reason => "Could not find associated song for: #{song}"
                      }))        

                    end

                  # otherwise record the song id
                  else
                    item[:song_id] = song_record.first.SONGID
                  end

                  index += 1

                  # add to the set list
                  set_list << item
        
                end

              end
      
              # register the set list for this gig
              gig_info[:set_list] = set_list
              
            end      

            # look for the current gig in the database
            #
            # note: we use gig date / venue id / set num as the unique key
            gig = Gig.where(:GigDate => gig_date, :VENUEID => venue.VENUEID, :SetNum => gig_info[:set_num])

            if gig.present?

              gig = gig.to_a.first

              # update gig with spreadsheet data
              gig.BilledAs  = get_field(gig_info[:billed_as], gig.BilledAs)
              gig.GigType   = get_field(gig_info[:gig_type], gig.GigType)
              gig.GigYear   = get_field(gig_info[:gig_date].year.to_s, gig.GigYear)
              gig.Circa     = get_field(gig_info[:circa], gig.Circa)
              gig.SetNum    = get_field(gig_info[:set_num], gig.SetNum)
              gig.Guests    = get_field(gig_info[:guests], gig.Guests)
              gig.ShortNote = get_field(gig_info[:notes], gig.ShortNote)

              if gig.changed? or gig_info[:set_list].present?
                updated_gigs.push(gig_info)
              else
                extant_gigs.push(gig_info)
              end

            else
              new_gigs.push(gig_info)
            end

          end

        end

      else
        
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

    [new_gigs, updated_gigs, extant_gigs, data_errors, missing_songs]

  end


  # Dumps prepared gig info to a csv
  def self.dump_gig_csv(prepared_gigs, output_csv_directory)

    new_gigs_csv = "#{output_csv_directory}/gigs_new.csv"
    extant_gigs_csv = "#{output_csv_directory}/gigs_extant.csv"
    updated_gigs_csv = "#{output_csv_directory}/gigs_updated.csv"
    gig_data_issues_csv = "#{output_csv_directory}/gigs_data_issues.csv"
    gig_missing_songs_csv = "#{output_csv_directory}/gigs_missing_songs.csv"

    new_gigs, updated_gigs, extant_gigs, data_issues, missing_songs = prepared_gigs

    # write out new gigs
    File.write(new_gigs_csv, gigs_to_csv(new_gigs))
    puts("New Gigs: #{new_gigs_csv}")

    # write out updated gigs
    File.write(updated_gigs_csv, gigs_to_csv(updated_gigs, true))
    puts("Updated Gigs: #{updated_gigs_csv}")

    # write out existing gigs
    File.write(extant_gigs_csv, gigs_to_csv(extant_gigs, true))
    puts("Extant Gigs: #{extant_gigs_csv}")

    # write out data errors
    File.write(gig_data_issues_csv, gigs_to_csv(data_issues, true))
    puts("Data Issues: #{gig_data_issues_csv}")

    # write out missing songs
    File.write(gig_missing_songs_csv, missing_songs_to_csv(missing_songs.uniq {|s| s[:song_name].upcase}.sort{|a, b| a[:song_name] <=> b[:song_name]}))
    puts("Missing songs: #{gig_missing_songs_csv}")

end


  # Extracts gigs from the given csv import_table, and writes them to the database
  #
  # If dump_csv is set, writes the gig analysis to csv files CSV files:
  #   - gigs_new.csv
  #   - gigs_extant.csv
  #   - gigs_data_issues.csv
  #   - gig_missing_songs.csv
  #
  def self.import_gigs(import_table, preview_only = false, output_csv_directory = nil, no_updates = false, no_creates = false, create_missing_songs = false)

    prepared_gigs = self.prepare_gigs(import_table, create_missing_songs)

    if output_csv_directory.present?
      dump_gig_csv(prepared_gigs, output_csv_directory)
    end

    new_gigs, updated_gigs, extant_gigs, data_issues = prepared_gigs

    # if we're not in preview-only mode, update db
    unless preview_only

      # if there are any new gigs, add them to the database
      if new_gigs.present? and not no_creates
        puts "Creating new gigs"
        crupdate_gigs(new_gigs, false, create_missing_songs)
      end

      # if there are any updated gigs, add them to the database
      if updated_gigs.present? and not no_updates
        puts "Updating changed gigs"
        crupdate_gigs(updated_gigs, true, create_missing_songs)
      end

    end

  end

end