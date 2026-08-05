(() => {
  "use strict";

  const root = document.querySelector("[data-projects-root]");
  if (!root) return;

  const cards = Array.from(root.querySelectorAll("[data-project-card]"));
  const buttons = Array.from(root.querySelectorAll("[data-project-filter]"));
  const search = root.querySelector("[data-project-search]");
  const empty = root.querySelector("[data-project-empty]");

  let selectedFilter = "all";
  let searchTerm = "";

  function updateProjects() {
    let visibleCount = 0;

    cards.forEach((card) => {
      const type = (card.dataset.projectType || "").toLowerCase();
      const text = (card.dataset.projectSearchText || "").toLowerCase();

      const matchesFilter =
        selectedFilter === "all" || type === selectedFilter;
      const matchesSearch =
        searchTerm === "" || text.includes(searchTerm);

      const show = matchesFilter && matchesSearch;
      card.hidden = !show;
      if (show) visibleCount += 1;
    });

    if (empty) empty.hidden = visibleCount !== 0;
  }

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      selectedFilter = button.dataset.projectFilter || "all";

      buttons.forEach((item) => {
        const active = item === button;
        item.classList.toggle("is-active", active);
        item.setAttribute("aria-pressed", String(active));
      });

      updateProjects();
    });
  });

  if (search) {
    search.addEventListener("input", () => {
      searchTerm = search.value.trim().toLowerCase();
      updateProjects();
    });
  }

  updateProjects();
})();
