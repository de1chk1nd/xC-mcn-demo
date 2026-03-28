(function() {
  "use strict";

  var STORAGE_KEY = "xc-mcn-student";
  var PH = "__STUDENT__";
  var PH_DOMAIN = "__DOMAIN__";

  function getStudent() {
    return localStorage.getItem(STORAGE_KEY) || "";
  }

  function setStudent(value) {
    localStorage.setItem(STORAGE_KEY, value.trim());
  }

  function replacePlaceholders() {
    var student = getStudent();
    if (!student) return;

    var domain = student + ".xc-mcn-lab.aws";

    var display = document.getElementById("student-display");
    if (display) {
      display.textContent = student;
      display.style.color = "#003a75";
    }

    updateDomainStatus(student);

    var input = document.getElementById("student-input");
    if (input && !input.value) {
      input.value = student;
    }

    var els = document.querySelectorAll("code, pre, td, p, li, span, b, a, h1, h2, h3");
    for (var i = 0; i < els.length; i++) {
      var el = els[i];
      if (el.id === "student-input" || el.id === "student-display") continue;
    if (el.innerHTML.indexOf(PH) !== -1 || el.innerHTML.indexOf(PH_DOMAIN) !== -1) {
        el.innerHTML = el.innerHTML
          .replace(new RegExp(PH, "g"), student)
          .replace(new RegExp(PH_DOMAIN, "g"), domain);
    }
    }
  }

  window.saveStudent = function() {
    var input = document.getElementById("student-input");
    if (!input || !input.value.trim()) return;
    setStudent(input.value);
    replacePlaceholders();
  };

  window.clearStudent = function() {
    localStorage.removeItem(STORAGE_KEY);
    var input = document.getElementById("student-input");
    if (input) input.value = "";
    var display = document.getElementById("student-display");
    if (display) {
      display.textContent = "<not set>";
      display.style.color = "#475569";
    }
    updateDomainStatus("");
  };

  function updateDomainStatus(student) {
    var badges = document.querySelectorAll(".domain-badge");
    for (var i = 0; i < badges.length; i++) {
      if (!student) {
        badges[i].className = "domain-badge pending";
        badges[i].innerHTML = "__DOMAIN__ <span class=\"icon\">✖</span>";
      } else {
        badges[i].className = "domain-badge ready";
        badges[i].innerHTML = student + ".xc-mcn-lab.aws <span class=\"icon\">✔</span>";
      }
    }
  }

  window.show = function(id, ev) {
    var sections = document.querySelectorAll("section");
    for (var i = 0; i < sections.length; i++) sections[i].classList.remove("active");
    var target = document.getElementById(id);
    if (target) target.classList.add("active");

    // Always sync sidebar highlight via data-target
    var links = document.querySelectorAll(".sidebar a");
    for (var j = 0; j < links.length; j++) links[j].classList.remove("active");
    var match = document.querySelector(".sidebar a[data-target='" + id + "']");
    if (match) match.classList.add("active");

    // Persist active page in localStorage + URL hash
    saveActivePage(id);
    if (history.replaceState) {
      history.replaceState(null, "", "#" + id);
    } else {
      window.location.hash = id;
    }

    window.scrollTo(0, 0);
    replacePlaceholders();
    updateNavButtons();
    updateProgress();
  };

  window.openImageModal = function(src) {
    var modal = document.getElementById("image-modal");
    var img = document.getElementById("image-modal-img");
    if (!modal || !img) return;
    img.src = src;
    modal.classList.remove("closing");
    void modal.offsetWidth;
    modal.classList.add("open");
    modal.setAttribute("aria-hidden", "false");
  };

  window.closeImageModal = function() {
    var modal = document.getElementById("image-modal");
    var img = document.getElementById("image-modal-img");
    if (!modal || !img) return;
    modal.classList.add("closing");
    modal.classList.remove("open");
    setTimeout(function() {
      modal.classList.remove("closing");
      img.src = "";
      modal.setAttribute("aria-hidden", "true");
    }, 500);
  };

  function addCopyButtons() {
    var pres = document.querySelectorAll("pre");
    for (var i = 0; i < pres.length; i++) {
      if (!pres[i].querySelector(".copy-btn")) {
        var btn = document.createElement("button");
        btn.className = "copy-btn";
        btn.textContent = "Copy";
        pres[i].appendChild(btn);
      }
    }
  }

  document.addEventListener("click", function(e) {
    if (e.target.classList.contains("copy-btn")) {
      var code = e.target.parentElement.querySelector("code");
      if (!code) return;
      navigator.clipboard.writeText(code.textContent);
      e.target.textContent = "Copied!";
      setTimeout(function() { e.target.textContent = "Copy"; }, 1200);
    }
  });

  function updateNavButtons() {
    var navs = document.querySelectorAll(".section-nav");
    for (var i = 0; i < navs.length; i++) {
      (function(n) {
        n.innerHTML = "";
        var prev = n.getAttribute("data-prev");
        var next = n.getAttribute("data-next");
        var forId = n.getAttribute("data-for");
        var activeSection = document.querySelector("section.active");
        if (activeSection && forId !== activeSection.id) {
          n.style.display = "none";
          return;
        }
        n.style.display = "flex";
        if (prev) {
          var prevBtn = document.createElement("button");
          prevBtn.textContent = "← Previous";
          prevBtn.onclick = function(e) { show(prev, e); };
          n.appendChild(prevBtn);
        }
        if (next) {
          var nextBtn = document.createElement("button");
          nextBtn.textContent = "Next →";
          nextBtn.onclick = function(e) { show(next, e); };
          n.appendChild(nextBtn);
        }
      })(navs[i]);
    }
  }

  function updateProgress() {
    var sections = Array.prototype.slice.call(document.querySelectorAll("section"));
    var active = document.querySelector("section.active");
    var index = sections.indexOf(active);
    if (index < 0) return;
    var step = index + 1;
    var total = sections.length;

    var bar = document.getElementById("progress-bar");
    var label = document.getElementById("progress-label");
    if (bar) bar.style.width = (step / total * 100) + "%";
    if (label) label.textContent = "Step " + step + " of " + total;
  }

  var PAGE_KEY = "xc-mcn-page";

  function getActivePage() {
    // Priority: URL hash > localStorage > default "home"
    var hash = window.location.hash.replace("#", "");
    if (hash && document.getElementById(hash)) return hash;
    var stored = localStorage.getItem(PAGE_KEY);
    if (stored && document.getElementById(stored)) return stored;
    return "home";
  }

  function saveActivePage(id) {
    localStorage.setItem(PAGE_KEY, id);
  }

  window.addEventListener("DOMContentLoaded", function() {
    addCopyButtons();
    updateDomainStatus(getStudent());

    // Navigate to the correct page before anything else
    var page = getActivePage();
    show(page, null);
  });

  document.addEventListener("keydown", function(e) {
    if (e.key === "Escape") {
      closeImageModal();
    }
  });
})();
