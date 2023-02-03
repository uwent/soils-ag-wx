$(document).ready(() => {
  elementReady("#map-img").then(() => {
    img = document.querySelector("#map-img")
    img.onmousedown = getCoordinates
  })
})

function getCoordinates(e) {
  var x = 0;
  var y = 0;
  var imgPos = findPosition(img);

  if (!e) var e = window.event;
  if (e.pageX || e.pageY) {
    x = e.pageX;
    y = e.pageY;
  }
  else if (e.clientX || e.clientY) {
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
  }
  x = x - imgPos[0];
  y = y - imgPos[1];
  // console.log("Clicked on x:" + x + " y:" + y);
  findLatLong(x, y);
}

function findPosition(e) {
  if (typeof (e.offsetParent) != "undefined") {
    for (var posX = 0, posY = 0; e; e = e.offsetParent) {
      posX += e.offsetLeft;
      posY += e.offsetTop;
    }
    return [posX, posY];
  } else {
    return [e.x, e.y];
  }
}

function findSize(e) {
  var rect = e.getBoundingClientRect();
  var x = rect.width;
  var y = rect.height;
  // console.log("Image size: " + x + " by " + y);
  return [x, y]
}

function drawDot(x, y) {
  var size = 5;
  units = "px";
  $("#dot").remove();
  var div = document.createElement("div");
  div.id = "dot";
  div.class = "dot";
  div.style.top = (y - size / 2.0).toFixed() + units;
  div.style.left = (x - size / 2.0).toFixed() + units;
  img.appendChild(div);
  // console.log("Dot placed at x:" + x + " y:" + y)
}

function findLatLong(x, y) {
  var imgSize = findSize(img);
  var scale = imgSize[0] / 1000.0;
  var xMin = 50 * scale;
  var xMax = 950 * scale;
  var yMin = 50 * scale;
  var yMax = 910 * scale;
  var minLat = 38.0;
  var maxLat = 50.0;
  var minLong = -98.0;
  var maxLong = -82.0;
  var latRange = maxLat - minLat;
  var longRange = maxLong - minLong;

  if (x >= xMin && x <= xMax && y >= yMin && y <= yMax) {
    var xPos = (x - xMin) / (xMax - xMin);
    var yPos = (y - yMin) / (yMax - yMin);
    // console.log("x percent: " + xPos);
    // console.log("y percent: " + yPos);
    var lat = maxLat - latRange * yPos;
    var long = minLong + longRange * xPos;
    // console.log("Lat: " + lat);
    // console.log("Long: " + long);
    drawDot(x, y);
    updateSelector(lat, long);
  }
}

function moveDot() {
  if (typeof img === 'undefined') return

  var lat = latitude.value;
  var long = longitude.value;
  var imgSize = findSize(img);
  var scale = imgSize[0] / 1000.0;
  var xMin = 50 * scale;
  var xMax = 950 * scale;
  var yMin = 50 * scale;
  var yMax = 910 * scale;
  var minLat = 38.0;
  var maxLat = 50.0;
  var minLong = -98.0;
  var maxLong = -82.0;

  if (lat >= minLat && lat <= maxLat && long >= minLong && long <= maxLong) {
    var relLat = (lat - minLat) / (maxLat - minLat);
    var relLong = (long - minLong) / (maxLong - minLong);
    // console.log(relLong);
    // console.log(relLat);
    var x = xMin + relLong * (xMax - xMin);
    var y = yMax - relLat * (yMax - yMin);
    // console.log("Placing dot at lat: " + lat + ", " + long);
    drawDot(x, y);
  }
}

function updateSelector(lat, long) {
  var lat = lat.toFixed(1);
  var long = long.toFixed(1);
  console.log("Clicked on " + lat + "," + long)
  $('#latitude').val(lat);
  $('#longitude').val(long);
}

