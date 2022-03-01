//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require best_in_place
//= require_tree .

function elementReady(selector) {
  return new Promise((resolve, reject) => {
    let el = document.querySelector(selector);
    if (el) {
      resolve(el);
      return;
    }
    new MutationObserver((mutationRecords, observer) => {
      Array.from(document.querySelectorAll(selector)).forEach((element) => {
        resolve(element);
        observer.disconnect();
      });
    }).observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  });
}

function copy(id) {
  navigator.clipboard.writeText(document.getElementById(id).outerHTML);
  $('#copy-confirm').fadeIn();
}

if (window.history.replaceState) {
  window.history.replaceState(null, null, window.location.href);
}
