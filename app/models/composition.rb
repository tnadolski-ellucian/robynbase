class Composition < ActiveRecord::Base

  self.table_name = "COMP"

  has_many :tracks, foreign_key: "COMPID"

  def self.search_by(kind, search)

    kind = [:title, :recorded_by, :release_year] if kind.nil? or kind.length == 0

    conditions = Array(kind).map do |term|

      case term 
        when :title
          column = "Title"
        when :year
          column = "Year"
        when :label
          column = "Label"
      end

      "#{column} LIKE ?"

    end

    if search
      where(conditions.join(" OR "), *Array.new(conditions.length, "%#{search}%"))
    else
      all
    end
  end 
  
end