(function () {
  "use strict";

  function initializePublicationFilters() {
    const cards = Array.from(document.querySelectorAll("[data-publication-card]"));
    const filterButtons = Array.from(document.querySelectorAll("[data-publication-filter]"));
    const searchInput = document.getElementById("publication-search");
    const visibleCount = document.getElementById("publication-visible-count");
    const emptyState = document.getElementById("publication-empty");

    if (!cards.length || !filterButtons.length || !searchInput) {
      return;
    }

    let activeFilter = "all";

    function updatePublications() {
      const query = searchInput.value.trim().toLowerCase();
      let shown = 0;

      cards.forEach(function (card) {
        const matchesType = activeFilter === "all" || card.dataset.type === activeFilter;
        const matchesSearch = !query || (card.dataset.search || "").includes(query);
        const shouldShow = matchesType && matchesSearch;

        card.hidden = !shouldShow;
        if (shouldShow) {
          shown += 1;
        }
      });

      if (visibleCount) {
        visibleCount.textContent = String(shown);
      }

      if (emptyState) {
        emptyState.hidden = shown !== 0;
      }
    }

    filterButtons.forEach(function (button) {
      button.addEventListener("click", function () {
        activeFilter = button.dataset.publicationFilter || "all";

        filterButtons.forEach(function (candidate) {
          const isActive = candidate === button;
          candidate.classList.toggle("is-active", isActive);
          candidate.setAttribute("aria-pressed", String(isActive));
        });

        updatePublications();
      });
    });

    searchInput.addEventListener("input", updatePublications);
    updatePublications();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initializePublicationFilters);
  } else {
    initializePublicationFilters();
  }
})();
