
$(document).on('turbolinks:load', function() {

  // target external links
  $('a:not(.internal)').filter(function() {
    return this.hostname && this.hostname !== location.hostname;
  }).addClass("external");

});


// popups
$(document).on('click', 'a.popup, a.external', function(event) {
  event.preventDefault();

  let href = $(this).attr("href");
  let width = $(this).attr("data-width");
  let height = $(this).attr("data-height");

  let popup;

  if (width && height) {
    popup = window.open(href, "popup", "height=" + height + ",width=" + width + "");
  } else {
    popup = window.open(href);
  }

  return;
});
