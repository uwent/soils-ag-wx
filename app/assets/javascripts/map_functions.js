// default (full) extents
mapExtent = {
  minLat: 38.0,
  maxLat: 50.0,
  latRange: 50.0 - 38.0,
  minLng: -98.0,
  maxLng: -82.0,
  lngRange: -82.0 - -98.0,
}

function setWiExtents() {
  mapExtent = {
    minLat: 42.4,
    maxLat: 47.2,
    latRange: 47.2 - 42.4,
    minLng: -93.0,
    maxLng: -86.7,
    lngRange: -86.7 - -93.0,
  }
}

$(document).ready(() => {
  elementReady("#map-img").then(() => {
    img = document.querySelector("#map-img")
    img.onmousedown = getCoordinates
  })
})

function inExtent(lat, lng) {
  return lat >= mapExtent.minLat &&
    lat <= mapExtent.maxLat &&
    lng >= mapExtent.minLng &&
    lng <= mapExtent.maxLng
}

function getCoordinates(e) {
  let x = 0
  let y = 0
  let imgPos = findPosition(img)

  if (!e) e = window.event
  if (e.pageX || e.pageY) {
    x = e.pageX
    y = e.pageY
  }
  else if (e.clientX || e.clientY) {
    x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
    y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
  }
  x = x - imgPos[0]
  y = y - imgPos[1]
  // console.log("Clicked on x:" + x + " y:" + y);
  findLatLong(x, y)
}

function findPosition(e) {
  if (typeof (e.offsetParent) != "undefined") {
    for (var posX = 0, posY = 0; e; e = e.offsetParent) {
      posX += e.offsetLeft
      posY += e.offsetTop
    }
    return [posX, posY]
  } else {
    return [e.x, e.y]
  }
}

function findSize(e) {
  let rect = e.getBoundingClientRect()
  let x = rect.width
  let y = rect.height
  // console.log("Image size: " + x + " by " + y);
  return [x, y]
}

function drawDot(x, y) {
  let size = 5
  let units = "px"
  let div = document.createElement("div")
  div.id = "dot"
  div.class = "dot"
  div.style.top = (y - size / 2.0).toFixed() + units
  div.style.left = (x - size / 2.0).toFixed() + units
  $("#dot").remove()
  img.appendChild(div)
  // console.log("Dot placed at x:" + x + " y:" + y)
}

function findLatLong(x, y) {
  let imgSize = findSize(img)
  let scale = imgSize[0] / 1000.0
  let xMin = 50 * scale
  let xMax = 950 * scale
  let yMin = 50 * scale
  let yMax = 910 * scale

  // if click is inside map area
  if (x >= xMin && x <= xMax && y >= yMin && y <= yMax) {
    let xPos = (x - xMin) / (xMax - xMin)
    let yPos = (y - yMin) / (yMax - yMin)
    let lat = mapExtent.maxLat - mapExtent.latRange * yPos
    let lng = mapExtent.minLng + mapExtent.lngRange * xPos
    drawDot(x, y)
    updateSelector(lat, lng)
  }
}

function moveDot() {
  if (typeof img === 'undefined') return

  let lat = latitude.value
  let lng = longitude.value
  let imgSize = findSize(img)
  let scale = imgSize[0] / 1000.0
  let xMin = 50 * scale
  let xMax = 950 * scale
  let yMin = 50 * scale
  let yMax = 910 * scale

  if (inExtent(lat, lng)) {
    let relLat = (lat - mapExtent.minLat) / (mapExtent.latRange)
    let relLong = (lng - mapExtent.minLng) / (mapExtent.lngRange)
    let x = xMin + relLong * (xMax - xMin)
    let y = yMax - relLat * (yMax - yMin)
    // console.log("Placing dot at lat: " + lat + ", " + long);
    drawDot(x, y)
  }
}

function updateSelector(lat, lng) {
  lat = lat.toFixed(1)
  lng = lng.toFixed(1)
  $('#latitude').val(lat)
  $('#longitude').val(lng)
  console.log(`Clicked on ${lat}, ${lng}`)
}
