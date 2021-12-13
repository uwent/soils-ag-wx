//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require best_in_place

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
