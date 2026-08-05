(() => {
  "use strict";

  const root = document.querySelector("[data-skills-root]");
  if (!root) return;

  const cards = Array.from(root.querySelectorAll("[data-skill-card]"));
  const groups = Array.from(root.querySelectorAll("[data-skill-group]"));
  const buttons = Array.from(root.querySelectorAll("[data-skill-filter]"));
  const searchInput = root.querySelector("[data-skill-search]");
  const emptyMessage = root.querySelector("[data-skill-empty]");

  let activeFilter = "all";
  let searchText = "";

  function updatePage() {
    let visibleCards = 0;

    cards.forEach((card) => {
      const category = (card.dataset.skillCategory || "").toLowerCase();
      const searchable = (card.dataset.skillSearchText || "").toLowerCase();

      const filterMatches =
        activeFilter === "all" || category === activeFilter;
      const searchMatches =
        searchText === "" || searchable.includes(searchText);

      const visible = filterMatches && searchMatches;
      card.hidden = !visible;

      if (visible) visibleCards += 1;
    });

    groups.forEach((group) => {
      const hasVisibleCard = Array.from(
        group.querySelectorAll("[data-skill-card]")
      ).some((card) => !card.hidden);

      group.hidden = !hasVisibleCard;
    });

    if (emptyMessage) {
      emptyMessage.hidden = visibleCards !== 0;
    }
  }

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      activeFilter = button.dataset.skillFilter || "all";

      buttons.forEach((item) => {
        const active = item === button;
        item.classList.toggle("is-active", active);
        item.setAttribute("aria-pressed", String(active));
      });

      updatePage();
    });
  });

  if (searchInput) {
    searchInput.addEventListener("input", () => {
      searchText = searchInput.value.trim().toLowerCase();
      updatePage();
    });
  }

  updatePage();
})();
