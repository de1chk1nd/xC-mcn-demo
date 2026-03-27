/**
 * Student Name Placeholder Replacement
 *
 * Replaces __STUDENT__ placeholders throughout the rendered page with
 * the student name entered by the user. The value is persisted in
 * localStorage so it survives page navigations and refreshes.
 *
 * Derived domain suffixes are also replaced:
 *   __DOMAIN__           →  <student>.xc-mcn-lab.aws
 */

(function () {
  "use strict";

  var STORAGE_KEY = "xc-mcn-student";
  var PLACEHOLDER = "__STUDENT__";
  var PLACEHOLDER_DOMAIN = "__DOMAIN__";

  function getStudent() {
    return localStorage.getItem(STORAGE_KEY) || "";
  }

  function setStudent(name) {
    localStorage.setItem(STORAGE_KEY, name.trim());
  }

  function deriveDomains(student) {
    return {
      internal: student + ".xc-mcn-lab.aws",
    };
  }

  function replacePlaceholders() {
    var student = getStudent();
    if (!student) return;

    var domains = deriveDomains(student);

    // Update the input field if it exists
    var input = document.getElementById("student-input");
    if (input && !input.value) {
      input.value = student;
    }

    // Update the display span
    var display = document.getElementById("student-display");
    if (display) {
      display.textContent = student;
      display.style.fontWeight = "bold";
      display.style.color = "#1565c0";
    }

    // Replace in all relevant elements
    var selectors = "code, pre, td, p, span, li, a, h1, h2, h3, h4, h5, h6, dt, dd";
    var elements = document.querySelectorAll(selectors);

    for (var i = 0; i < elements.length; i++) {
      var el = elements[i];
      // Skip the input field itself
      if (el.id === "student-input") continue;

      if (el.innerHTML.indexOf(PLACEHOLDER) !== -1 ||
          el.innerHTML.indexOf(PLACEHOLDER_DOMAIN) !== -1) {
        el.innerHTML = el.innerHTML
          .replace(new RegExp(PLACEHOLDER, "g"), student)
          .replace(new RegExp(PLACEHOLDER_DOMAIN, "g"), domains.internal);
      }
    }
  }

  function createInputWidget() {
    // Only inject on pages that have the marker div
    var marker = document.getElementById("student-config");
    if (!marker) return;

    var student = getStudent();

    marker.innerHTML =
      '<div style="padding: 12px 16px; border: 2px solid #1565c0; border-radius: 8px; ' +
      'background: #e3f2fd; margin: 16px 0;">' +
      '  <label for="student-input" style="font-weight: 600; margin-right: 8px;">' +
      '    Enter your student name:</label>' +
      '  <input id="student-input" type="text" placeholder="e.g. jdoe" ' +
      '    value="' + (student || "") + '" ' +
      '    style="padding: 6px 10px; border: 1px solid #90caf9; border-radius: 4px; ' +
      '    font-size: 14px; width: 200px;" />' +
      '  <button onclick="window.__xcSaveStudent()" ' +
      '    style="margin-left: 8px; padding: 6px 16px; background: #1565c0; color: white; ' +
      '    border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">Save</button>' +
      '  <span style="margin-left: 16px;">Current: ' +
      '    <span id="student-display">' + (student || "<not set>") + "</span>" +
      "  </span>" +
      "</div>";
  }

  // Global save function (called by button onclick)
  window.__xcSaveStudent = function () {
    var input = document.getElementById("student-input");
    if (!input || !input.value.trim()) return;
    setStudent(input.value);
    replacePlaceholders();
  };

  // Run on every page load (MkDocs Material uses instant loading)
  if (typeof document$ !== "undefined") {
    // MkDocs Material instant loading (observable)
    document$.subscribe(function () {
      createInputWidget();
      replacePlaceholders();
    });
  } else {
    // Fallback for standard page loads
    document.addEventListener("DOMContentLoaded", function () {
      createInputWidget();
      replacePlaceholders();
    });
  }
})();
