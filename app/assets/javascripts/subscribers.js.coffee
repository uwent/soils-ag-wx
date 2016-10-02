# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#resend_confirmation').click (event) ->
    sub_id = $(event.target).data('sub-id')
    url = "/subscribers/" + sub_id + "/resend_confirmation"
    $.post(url)
      .done (data) ->
        alert("We have resent the confirmation. Check your email.")
      .error ->
        alert("ERROR: We were unable to resend your confirmation.")
