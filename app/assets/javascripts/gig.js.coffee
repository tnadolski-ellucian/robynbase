# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$(window).on("load", (e) ->

  # hide show advanced options in list page
  $(".gig-list .advanced-options-header").on("click", (e) ->
    header = $(e.target).parents(".advanced-options-header")
    criteriaBlock = header.next();
    criteriaBlock.toggleClass("expanded");
    header.find(".glyphicon").toggleClass("glyphicon-triangle-right glyphicon-triangle-bottom")
  )

  $("#gig_date").datepicker({
    changeYear: true,
    yearRange: "1973:2015"
  });
  
)


songIndex = 100

# Adds a song selection dropdown, containing all available songs
addSongSelector = (parent, index) ->

  # grab another song selector from elsewhere on the page and make a copy
  referenceSelector = $("#template-song-selector")
  selectorCopy = referenceSelector.clone()

  # configure for the current index
  selectorCopy.attr("name", "gig[gigsets_attributes][#{index}][SONGID]")
  selectorCopy.attr("id", "gig_gigsets_attributes_#{index}_SONGID")
  selectorCopy.val("")

  parent.append(selectorCopy)


window.removeTableRow = (tableId, rowId) ->
  row = $("##{tableId} tr[data-row=#{rowId}]");
  identifier = row.next("input")

  row.remove()
  identifier.remove()


window.addTableRow = (tableId, encore) ->

  maxSequence = 0;

  # find largest order index
  $("##{tableId} tr").each((index, row) ->
    sequence = $(row).find("td:first input").val();
    maxSequence = Math.max(maxSequence, sequence) if sequence
  )
      

  newRow = $("""
    <tr data-row="#{songIndex}">
        <td>
            <input class="form-control" size="3" type="text" 
                   value="#{maxSequence + 1}" 
                   name="gig[gigsets_attributes][#{songIndex}][Chrono]" 
                   id="gig_gigsets_attributes_#{songIndex}_Chrono">
        </td>
        <td></td>
        <td>
            <input class="form-control" type="text" value="" 
                   name="gig[gigsets_attributes][#{songIndex}][Song]" 
                   id="gig_gigsets_attributes_#{songIndex}_Song">
        </td>
        <td>
            <input class="form-control" type="text" 
                   name="gig[gigsets_attributes][#{songIndex}][VersionNotes]" 
                   id="gig_gigsets_attributes_#{songIndex}_VersionNotes">
            <input type="hidden" 
                   value="#{encore}" 
                   name="gig[gigsets_attributes][#{songIndex}][Encore]" 
                   id="gig_gigsets_attributes_#{songIndex}_Encore">
        </td>
        <td> 
            <button type="button" onclick="removeTableRow('#{tableId}', #{songIndex})">
                Remove
            </button>
        </td>
    </tr>
  """)

  $("##{tableId}").append(newRow)

  songSelectorCell = newRow.find("td:nth(1)")

  addSongSelector(songSelectorCell, songIndex)

  songIndex++