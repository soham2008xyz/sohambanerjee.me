/**
 * Main JS file for Casper behaviours (vanilla, no jQuery)
 */

(function () {
  "use strict";

  document.addEventListener("DOMContentLoaded", function () {

    // Wrap post images that have alt text in a figure with a caption
    document.querySelectorAll(".post-content img").forEach(function (img) {
      if (img.getAttribute("alt") && !img.classList.contains("emoji")) {
        var figure = document.createElement("figure");
        figure.className = "image";
        img.parentNode.insertBefore(figure, img);
        figure.appendChild(img);
        var caption = document.createElement("figcaption");
        caption.textContent = img.getAttribute("alt");
        figure.appendChild(caption);
      }
    });

    // Parallax on header images
    var images = document.querySelectorAll(".post-image-image, .teaserimage-image");
    if (images.length) {
      var onScroll = function () {
        var top = window.pageYOffset || document.documentElement.scrollTop;
        if (top < 0 || top > 1500) return;
        images.forEach(function (image) {
          image.style.transform = "translate3d(0px, " + top / 3 + "px, 0px)";
          image.style.opacity = String(1 - Math.max(top / 700, 0));
        });
      };
      window.addEventListener("scroll", onScroll, { passive: true });
      onScroll();
    }

    // Smooth-scroll for same-page anchor links
    document.querySelectorAll('a[href*="#"]:not([href="#"])').forEach(function (link) {
      link.addEventListener("click", function (e) {
        var hash = this.hash;
        if (!hash || hash.length < 2) return;
        if (location.pathname.replace(/^\//, "") !== this.pathname.replace(/^\//, "") ||
            location.hostname !== this.hostname) return;
        var target = document.getElementById(hash.slice(1)) ||
                     document.querySelector('[name="' + hash.slice(1) + '"]');
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: "smooth" });
        }
      });
    });

  });
}());
