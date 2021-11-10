//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require best_in_place

function copy(id) {
  navigator.clipboard.writeText(document.getElementById(id).outerHTML);
  $('#copy-confirm').fadeIn();
}
