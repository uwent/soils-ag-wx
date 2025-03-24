function getGeoLocation() {
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(handleGeoLocation, showError);
  } else {
    flashGeoMsg("Browser doesn't support location.");
  }
}

function handleGeoLocation(position) {
  var lat = position.coords.latitude.toFixed(1);
  var lng = position.coords.longitude.toFixed(1);
  flashGeoMsg("Got location!");
  console.log("Got location from browser: " + lat + ", " + lng);
  $("#latitude").val(lat);
  $("#longitude").val(lng);
  try {
    moveDot();
  } catch {}
}

function showError(error) {
  switch (error.code) {
    case error.PERMISSION_DENIED:
      flashGeoMsg("User denied the request for Geolocation.");
      break;
    case error.POSITION_UNAVAILABLE:
      flashGeoMsg("Location information is unavailable.");
      break;
    case error.TIMEOUT:
      flashGeoMsg("The request to get user location timed out.");
      break;
    case error.UNKNOWN_ERROR:
      flashGeoMsg("An unknown error occurred.");
      break;
  }
}

async function flashGeoMsg(msg) {
  let e = document.getElementById("geo-loc-msg");
  e.innerHTML = msg;
  await new Promise((resolve) => setTimeout(resolve, 2000));
  $(e).fadeOut(500);
  await new Promise((resolve) => setTimeout(resolve, 500));
  e.innerHTML = "";
  $(e).fadeIn();
}
