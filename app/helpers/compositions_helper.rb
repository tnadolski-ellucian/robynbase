module CompositionsHelper

  def album_block_header_title(album)

    albumInfo = "#{album.Medium ? album.Medium : "Unknown Medium"} (#{html_escape(album.Year.to_i.to_s)}) "
    
    if album.Comments.present?
      comments = " <span class='album-comments'> #{html_escape(album.Comments)} </span>"
      albumInfo += comments
    end

    return albumInfo.html_safe

  end
end
