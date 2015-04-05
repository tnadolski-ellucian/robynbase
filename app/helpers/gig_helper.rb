module GigHelper

  def gig_song_details(gig_song)

    out = ""

    # author (if not robyn)
    if gig_song.song.Author.present? 
      out += "<span class='gig-song-author'> <small>#{gig_song.song.Author}</small> </span>"
    end

    # includes segue marker
    if gig_song.VersionNotes.present?
      out += "<span class='gig-song-version-notes text-success'> <small>#{gig_song.VersionNotes}</small> </span>"
    end

    out.html_safe

  end 

end
