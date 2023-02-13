//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/datepicker
//= require best_in_place
//= require jquery.purr

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

function copyTable(prefix = "copy") {
  let elem = document.querySelector(`#${prefix}-container`)
  if (elem) {
    let data = elem.outerHTML
    navigator.clipboard.writeText(data)

    // hide any other copy-confirm notices
    let confirm_elems = document.querySelectorAll("[id$='confirm']")
    if (confirm_elems) {
      confirm_elems.forEach((el) => {
        el.setAttribute("style", "display: none;")
      })
    }

    // show the copy confirm element
    let confirm_elem = document.querySelector(`#${prefix}-confirm`)
    if (confirm_elem) {
      confirm_elem.style.display = null;
    }
  }
}

if (window.history.replaceState) {
  window.history.replaceState(null, null, window.location.href);
}

function validateDates(changed = "end", id_prefix = "datepicker") {
  let startPicker = document.querySelector(`#${id_prefix}-start`)
  let endPicker = document.querySelector(`#${id_prefix}-end`)

  if (!startPicker || !endPicker) return

  let startPickerValue = startPicker.valueAsDate
  let endPickerValue = endPicker.valueAsDate

  if (endPickerValue < startPickerValue) {
    if (changed == "start") {
      endPicker.valueAsDate = startPickerValue
    } else {
      startPicker.valueAsDate = endPickerValue
    }
  }
}
