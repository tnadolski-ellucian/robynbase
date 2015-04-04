$(window).on("load", (e) ->

  $("table.main-search-list").dataTable({

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

  });

)