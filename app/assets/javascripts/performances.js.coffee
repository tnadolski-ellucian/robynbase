# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(window).on("load", (e) ->

  # hide show advanced options in list page
  $(".performance-list .advanced-options-header").on("click", (e) ->
    header = $(e.target).parents(".advanced-options-header")
    criteriaBlock = header.next();
    criteriaBlock.toggleClass("expanded");
    header.find(".glyphicon").toggleClass("glyphicon-triangle-right glyphicon-triangle-bottom")
  )

)