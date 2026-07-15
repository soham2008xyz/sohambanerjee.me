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

    // Wrap embeds (iframe/object/embed) in .post-content so they scale
    // responsively, matching the removed jQuery fitVids plugin's behavior
    document.querySelectorAll(".post-content iframe, .post-content object, .post-content embed").forEach(function (embed) {
      if (embed.closest(".fluid-width-video-wrapper")) return;
      var width = parseInt(embed.getAttribute("width"), 10) || embed.offsetWidth || 1;
      var height = parseInt(embed.getAttribute("height"), 10) || embed.offsetHeight || 1;
      var wrapper = document.createElement("div");
      wrapper.className = "fluid-width-video-wrapper";
      wrapper.style.paddingTop = ((height / width) * 100) + "%";
      embed.parentNode.insertBefore(wrapper, embed);
      wrapper.appendChild(embed);
      embed.removeAttribute("height");
      embed.removeAttribute("width");
    });

    // Parallax on header images
    var images = document.querySelectorAll(".post-image-image, .teaserimage-image");
    if (images.length) {
      var ticking = false;
      var top = 0;
      var updateParallax = function () {
        images.forEach(function (image) {
          image.style.transform = "translate3d(0px, " + top / 3 + "px, 0px)";
          image.style.opacity = String(1 - Math.max(top / 700, 0));
        });
        ticking = false;
      };
      var onScroll = function () {
        top = window.pageYOffset || document.documentElement.scrollTop;
        if (top < 0 || top > 1500) return;
        if (!ticking) {
          window.requestAnimationFrame(updateParallax);
          ticking = true;
        }
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
