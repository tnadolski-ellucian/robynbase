module PerformancesHelper

  def performance_type_label(type)

    case type

      when 1
        "Concert"
      when 2
        "TV"
      when 3
        "Radio"
      
    end

  end


  def medium_label(medium) 

    case medium

      when 1
        "Audio"
      when 2
        "Video"

    end

  end

end