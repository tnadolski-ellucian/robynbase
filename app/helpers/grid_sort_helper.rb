module GridSortHelper

  def get_initial_sort()

    if @initial_sort.present? 
      "[[#{@initial_sort[:column_index]}, \"#{@initial_sort[:direction]}\"]]"
    else 
      ""
    end

  end

end
