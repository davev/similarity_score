$(document).on('click', '.clickable', function(event) {
  event.preventDefault();

  let url = $(this).data('url');
  if (url) {
    if (typeof Turbolinks !== 'undefined' && Turbolinks.supported) {
      Turbolinks.visit(url);
    } else {
      window.location.assign(url);
    }
  }
});
