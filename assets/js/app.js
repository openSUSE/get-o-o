// Preselect a tab when it's referenced in url
$(document).ready(function () {
  var hash = window.location.hash;
  hash && show_tab(hash);
});

function show_tab(hash) {
  $('ul.nav a[href="' + hash + '"]').tab('show')
}
