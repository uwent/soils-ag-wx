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

function copy(prefix) {
  data = document.querySelector(`#${prefix}-container`).outerHTML;
  navigator.clipboard.writeText(data);
  document.querySelectorAll("[id$='confirm']").forEach((el) => {
    el.setAttribute("style", "display: none;")
  })
  document.querySelector(`#${prefix}-confirm`).style.display = null;
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
  let today = new Date().setHours(0, 0, 0, 0)
  let errors = ""

  if (startDateValue) {
    startDateValue = startDateValue.setHours(0, 0, 0, 0)
  } else {
    errors += "Invalid start date. "
  }
  if (endDateValue) {
    endDateValue = endDateValue.setHours(0, 0, 0, 0)
    if (endDateValue >= today) errors += "End date must be prior to today's date."
  } else {
    errors += "Invalid end date. "
  }
  if (startDateValue && endDateValue) {
    if (startDateValue > endDateValue) errors += "Start date must be before end date. "
  }

  if (errors.length > 0) {
    el.querySelector("#date-warning").innerHTML = errors
    el.querySelector("#submit").disabled = true
  } else {
    el.querySelector("#date-warning").innerHTML = ""
    el.querySelector("#submit").disabled = false
  }
}

function validateDate(el) {
  let date = parseDate(el)
  let today = new Date().setHours(0, 0, 0, 0)
  let error = ""

  if (date) {
    date = date.setHours(0, 0, 0, 0)
    if (date >= today) error = "Date must be prior to the current date."
  } else {
    error = "Invalid date."
  }

  if (error.length > 0) {
    document.querySelector("#date-warning").innerHTML = error
    document.querySelector("#submit").disabled = true
  } else {
    document.querySelector("#date-warning").innerHTML = ""
    document.querySelector("#submit").disabled = false
  }
}
