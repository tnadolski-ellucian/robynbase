module QuickQueryHelper

  def render_quick_query(qq)

    q = render_link(qq)

    if qq.secondary_queries.present?

      qq.secondary_queries.each do |secondary| 
        q = q + "<small>#{render_link(qq, secondary)}</small>"
      end

    end

    q.html_safe

  end

  def get_all_quick_queries(type)
    type.get_quick_queries.collect {|qq| render_quick_query(qq)}
  end

  def render_link(qq, secondary = nil)
    "<a href='#{qq.route(secondary)}'>#{qq.label(secondary)}</a>"
  end

end