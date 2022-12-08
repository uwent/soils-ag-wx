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

if (window.history.replaceState) {
  window.history.replaceState(null, null, window.location.href);
}

function parseDate(el) {
  let year = el.querySelector("[id$='date_1i']").value
  let month = el.querySelector("[id$='date_2i']").value
  let day = el.querySelector("[id$='date_3i']").value
  let date = new Date(`${month}-${day}-${year}`)
  return (date.getDate() == day) ? date : false
}

function validateDates(el) {
  let startDate = el.querySelector("#start-date")
  let endDate = el.querySelector("#end-date")
  let startDateValue = parseDate(startDate)
  let endDateValue = parseDate(endDate)
  let errors = ""
  errors += startDateValue ? "" : "Invalid start date. "
  errors += endDateValue ? "" : "Invalid end date. "

  if (startDateValue && endDateValue) {
    errors += (startDateValue < endDateValue) ? "" : "Start date must be before end date. "
  }

  if (errors.length > 0) {
    el.querySelector("#date-warning").innerHTML = errors
    el.querySelector("#submit").disabled = true
  } else {
    el.querySelector("#date-warning").innerHTML = ""
    el.querySelector("#submit").disabled = false
  }
}
