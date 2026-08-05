(() => {
  'use strict';
  const root = document.querySelector('[data-activities-root]');
  if (!root) return;
  const cards = [...root.querySelectorAll('[data-activity-card]')];
  const sections = [...root.querySelectorAll('[data-activity-section]')];
  const buttons = [...root.querySelectorAll('[data-activity-filter]')];
  const search = root.querySelector('[data-activity-search]');
  const empty = root.querySelector('[data-activity-empty]');
  let filter = 'all', term = '';
  function update() {
    let count = 0;
    cards.forEach(card => {
      const category = (card.dataset.activityCategory || '').toLowerCase();
      const text = (card.dataset.activitySearch || '').toLowerCase();
      const show = (filter === 'all' || category === filter) && (!term || text.includes(term));
      card.hidden = !show;
      if (show) count++;
    });
    sections.forEach(section => {
      const visible = [...section.querySelectorAll('[data-activity-card]')].some(card => !card.hidden);
      section.hidden = !visible;
    });
    if (empty) empty.hidden = count !== 0;
  }
  buttons.forEach(button => button.addEventListener('click', () => {
    filter = button.dataset.activityFilter || 'all';
    buttons.forEach(b => { const active = b === button; b.classList.toggle('is-active', active); b.setAttribute('aria-pressed', String(active)); });
    update();
  }));
  if (search) search.addEventListener('input', () => { term = search.value.trim().toLowerCase(); update(); });
  update();
})();
