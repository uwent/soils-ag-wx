# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $(".best_in_place").best_in_place()

  min_lat = 38.0
  max_lat = 50.0
  min_long = -98.0
  max_long = -82.0

  sub_count = 0
  if $('#sub_count').length > 0
    sub_count = parseInt($('#sub_count').val())

  validate_lat = (lat) ->
    if !$.isNumeric(lat)
      return false
    lat_num = parseFloat(lat)
    return (lat_num >= min_lat && lat_num <= max_lat)

  validate_name = (site_name) ->
    return $.trim(site_name)

  validate_long = (long) ->
    if !$.isNumeric(long)
      return false
    long_num = parseFloat(long)
    return (long_num >= min_long && long_num <= max_long)

  validate = (site_name, lat, long) ->
    validations = []
    if !validate_name(site_name)
      validations.push("Invalid site name.")
    if !validate_lat(lat)
      validations.push("Invalid latitude. Must be a number between " + min_lat + " and " + max_lat)
    if !validate_long(long)
      validations.push("Invalid longitude. Must be a number between " + min_long + " and " + max_long)
    return validations

  add_to_table = (sub) ->
    control_row = $('#add-controls')
    cross_icon = $('#delete-cross').val()
    new_row = "<tr><td>" + sub.name + "</td>" +
      "<td>" + sub.latitude + "</td>" +
      "<td>" + sub.longitude + "</td>" +
      "<td class='delete-site' data-subscription-id=" + sub.id + "><span>Delete Site</span> <img class='delete-cross' src='" + cross_icon + "'></td>"
    $(new_row).insertBefore(control_row)
    sub_count = sub_count + 1
    if sub_count >= 15
      $('#submit_site').prop('disabled', true)

  erase_inputs = ->
    $('#site_name').val("")
    $('#latitude').val("")
    $('#longitude').val("")

  # =====================================================================
  # Clicked to resend the confirmation email
  # =====================================================================
  $('#resend_confirmation').click (event) ->
    sub_id = $(event.target).data('sub-id')
    url = "/subscribers/" + sub_id + "/resend_confirmation"
    $.post(url)
      .done (data) ->
        alert("We have resent the confirmation. Check your email.")
      .error ->
        alert("ERROR: We were unable to resend your confirmation.")

  # =====================================================================
  # submit adding a subscription
  # =====================================================================
  $('#submit_site').click (event) ->
    subscriber_id = $('#subscriber_id').val()
    site_name = $('#site_name').val()
    lat = $('#latitude').val()
    long = $('#longitude').val()
    valid = validate(site_name, lat, long)
    if (valid.length > 0)
      alert(valid.join("\n"))
      return false

    $.ajax
      type: 'POST'
      url:  $('#add_url').val()
      data:
        site_name: site_name
        latitude: parseFloat(lat).toFixed(1)
        longitude: parseFloat(long).toFixed(1)
        to_edit_id: subscriber_id
      success: (data) ->
        if (data.id)
          add_to_table(data)
          erase_inputs()
        else
          alert(data.message)

  $('table').on 'click', '.delete-site', (event) ->
    sub_id = $(event.target).closest('td').data('subscription-id')
    parent_row = $(event.target).closest('tr')
    subscriber_id = $('#subscriber_id').val()
    $.ajax
      type: 'POST'
      url: $('#remove_url').val()
      data:
        subscription_id: sub_id
        to_edit_id: subscriber_id
      success: (data) ->
        if (data.message != 'Error')
          parent_row.fadeOut(1000, =>
            $(this).remove())
        $('#submit_site').prop('disabled', false)
