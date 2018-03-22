$(document).on('click', '.clickable', function(event) {
  let url = $(this).data('url');
  if (url) {
    window.location.assign(url);
  }
});
