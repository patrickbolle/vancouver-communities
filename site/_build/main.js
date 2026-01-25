// Make h2 titles clickable (navigates to their anchor)
document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('.content h2').forEach(function(h2) {
    var anchor = h2.querySelector('a[href^="#"]');
    if (anchor) {
      h2.style.cursor = 'pointer';
      h2.addEventListener('click', function(e) {
        if (e.target.tagName !== 'A') {
          window.location.hash = anchor.getAttribute('href').slice(1);
        }
      });
    }
  });
});
