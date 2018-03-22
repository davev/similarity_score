$(document).on('click', '.clickable', function(event) {
  let url = $(this).data('url');
  if (url) {
    Turbolinks.visit(url);
    // window.location.assign(url); non-Turbolinks-way
  }
});
