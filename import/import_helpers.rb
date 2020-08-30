# Import Utilities
module ImportHelpers

  def get_col_value(row, col)
    row[col].nil? ? '' : row[col].strip
  end

end