$(document).ready(() => {
  $(".best_in_place").best_in_place()

  $(document).on("best_in_place:error", () => {
    let msg = "Unable to update site, cannot have duplicate names or locations."
    let el = `<span id='bip-error' class='error'>${msg}</span>`
    $("#bip-notice").html(el)
    $("#bip-error").delay(10000).fadeOut()
  });

  $(document).on('best_in_place:success', () => {
    let msg = "Successfully updated site"
    let el = `<span id='bip-success' class='success'>${msg}</span>`
    $("#bip-notice").html(el)
    $("#bip-success").delay(10000).fadeOut()
  });
})
