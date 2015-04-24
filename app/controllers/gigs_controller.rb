class GigsController < ApplicationController

  RANGE_TYPE = {
    :years => 0,
    :months => 1,
    :days => 2
  }

  def index

    if params[:search_type].present?

      search_type = params[:search_type].map {|type| type.to_sym}

      date_criteria = nil

      # if the user specified a gig date as one of the criteria, prepare all the other data
      # that goes along with doing a date query
      if params[:gig_date].present?

        gig_date = DateTime.strptime(params[:gig_date], "%m/%d/%Y")
        range_type = :months
        range = 30


        # look for the kind of range (day, year, etc) we'll be using for this date
        if params[:gig_range_type].present?
          range_type = RANGE_TYPE.key(params[:gig_range_type].to_i)
        else
          params[:gig_range_type] = RANGE_TYPE[range_type]
        end

        # look for the amount of time on either side of the given date should be included in the search
        if params[:gig_range].present?
          range = params[:gig_range].to_i
        else
          params[:gig_range] = range
        end

        date_criteria = {
          :date       => gig_date,
          :range_type => range_type,
          :range      => range
        }

      end

      # grab gigs that meet *all* the secified criteria
      @gigs = Gig.search_by(search_type, params[:gig_search_value], date_criteria)

    else
      params[:search_type] = "venue"
    end

  end

  def show
    @gig = Gig.find(params[:id])
  end

  def quick_query
    @gigs = Gig.quick_query(params[:query_id], params[:query_attribute])
    render "index"
  end

end
