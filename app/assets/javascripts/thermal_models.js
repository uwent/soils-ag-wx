function displayAllDds(){
  document.getElementById("oak-wilt-list").style.display= "block";
}

function validateDate() {
  let year = document.getElementById("grid_date_end_date_1i").value
  let month = document.getElementById("grid_date_end_date_2i").value
  let day = document.getElementById("grid_date_end_date_3i").value
  let date = new Date(`${month}-${day}-${year}`)
  let today = new Date()
  if (date.setHours(0,0,0,0) >= today.setHours(0,0,0,0)) {
    document.getElementById("date-warning").style.display= "block";
    document.getElementById("submit").disabled = true;
  } else {
    document.getElementById("date-warning").style.display= "none";
    document.getElementById("submit").disabled = false;
  }
}
