// Preselect a tab when it's referenced in url
$(document).ready(function () {
  var hash = window.location.hash;
  hash && show_tab(hash);
  const params = new URLSearchParams(window.location.search);

  if (params.get('type'))
    not_and_only(params.get('type'));
});

function not_and_only(name) {
  var elements = document.getElementsByClassName(`not-${name}`);
  Array.from(elements).forEach(function(element) {
    element.style.display = "none";
  });
  var elements = document.getElementsByClassName(`only-${name}`);
  Array.from(elements).forEach(function(element) {
    element.style.display = "block";
  });
}

function show_tab(hash) {
  $('ul.nav a[href="' + hash + '"]').tab('show')
}
