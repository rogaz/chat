# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@destroy_line = (data) ->
  $("#line_" + data).fadeOut 100
  return

@move_to_bottom = () ->
  $("#lines").scrollTop $("#lines")[0].scrollHeight
  return

$(document).ready ->
  $("textarea#line_text").keypress (e) ->
    if e.which == 13
      $("form#new_line").submit()
      $('#line_text').focus().val ""
    e.preventDefault() if e.keyCode == 13 and not e.shiftKey

