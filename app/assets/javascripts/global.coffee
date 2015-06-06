$(window).on("load", (e) ->

  # loop through every table on the current page, and convert it into a datatable
  $("table.main-search-list").each( (index, tableElement) ->

    table = $(tableElement)

    # get the table's unique identifier, and look for any explicit sorting directives
    # on the table definition
    tableId = table.data("id")
    tableSort = table.data("custom-order")

    # look for any previous sorts for this grid (in the current session)
    orderCookie = Cookies.getJSON("order-" + tableId)

    # default order
    order = [[0, "asc"]]

    # if the table requests an initial sort, always use that for the render
    if (tableSort)
      order = tableSort

    # otherwise sort base on the last-sorted column (if any)
    else if (orderCookie) 
      order = [[orderCookie.column, orderCookie.direction]]

    $(table).dataTable({

      # change the label of the search control
      language: {
        search: "Filter: "
      },

      # hide the pageination controls if the table only has one page
      # (solution taken from http://stackoverflow.com/a/12393232)
      fnDrawCallback: (oSettings) ->
        if oSettings._iDisplayLength > oSettings.fnRecordsDisplay()
          $(oSettings.nTableWrapper).find('.dataTables_paginate').hide()
          
      # put the "results per page" control below the grid (when paging is active)
      sDom: '<"top">rt<"bottom"flp><"clear">'

      # the column to sort by, and the sort direction
      order: order,

      # render each row as it arrives, rather than pre-rendering the whole table (supposedly faster)
      deferRender: true

    })

  );


  # remember the last sort column/direction for all search lists
  $(".main-search-list").on("order.dt", (e, settings) ->

    order = settings.oInstance.DataTable().order()
    column = order[0][0]
    direction = order[0][1]

    tableId = settings.oInstance.data("id")

    Cookies.set("order-" + tableId, { column: column, direction: direction})

    console.log("col #{column}, direction #{direction}")

  )

)