$(document).on('click', '.clickable', function(event) {
  var url = $(this).data('url');
  if (url) {
    if (typeof Turbolinks !== 'undefined' && Turbolinks.supported) {
      Turbolinks.visit(url);
    } else {
      window.location.assign(url);
    }
  }
});
