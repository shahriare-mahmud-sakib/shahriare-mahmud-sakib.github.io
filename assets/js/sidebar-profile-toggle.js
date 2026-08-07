(() => {
  "use strict";

  const MOBILE_MAX_WIDTH = 1023;
  const WRAPPER_SELECTOR = ".sms-author-card__links-wrapper";
  const BUTTON_SELECTOR = ".sms-author-card__follow";
  const LIST_SELECTOR = ".sms-author-links";

  function isMobile() {
    return window.innerWidth <= MOBILE_MAX_WIDTH;
  }

  function setOpen(wrapper, open) {
    const button = wrapper.querySelector(BUTTON_SELECTOR);
    const list = wrapper.querySelector(LIST_SELECTOR);

    wrapper.classList.toggle("is-open", open);

    if (button) {
      button.setAttribute("aria-expanded", String(open));
    }

    if (list) {
      list.setAttribute("aria-hidden", String(!open && isMobile()));
    }
  }

  function initialise() {
    document.querySelectorAll(WRAPPER_SELECTOR).forEach((wrapper) => {
      setOpen(wrapper, !isMobile());
    });
  }

  /*
   * Capture-phase handling prevents the theme's older jQuery fadeToggle
   * listener from also running on phones and leaving inline display styles.
   */
  document.addEventListener(
    "click",
    (event) => {
      const button = event.target.closest(BUTTON_SELECTOR);

      if (button && isMobile()) {
        const wrapper = button.closest(WRAPPER_SELECTOR);

        if (!wrapper) return;

        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();

        setOpen(wrapper, !wrapper.classList.contains("is-open"));
        return;
      }

      document.querySelectorAll(`${WRAPPER_SELECTOR}.is-open`).forEach((wrapper) => {
        if (!isMobile()) return;

        if (!wrapper.contains(event.target)) {
          setOpen(wrapper, false);
        }
      });

      const selectedLink = event.target.closest(
        `${WRAPPER_SELECTOR}.is-open .sms-author-links a`
      );

      if (selectedLink && isMobile()) {
        const wrapper = selectedLink.closest(WRAPPER_SELECTOR);
        if (wrapper) setOpen(wrapper, false);
      }
    },
    true
  );

  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape" || !isMobile()) return;

    document.querySelectorAll(`${WRAPPER_SELECTOR}.is-open`).forEach((wrapper) => {
      setOpen(wrapper, false);

      const button = wrapper.querySelector(BUTTON_SELECTOR);
      if (button) button.focus();
    });
  });

  let previousMobileState = isMobile();

  window.addEventListener(
    "resize",
    () => {
      const currentMobileState = isMobile();

      if (currentMobileState === previousMobileState) return;

      previousMobileState = currentMobileState;

      document.querySelectorAll(WRAPPER_SELECTOR).forEach((wrapper) => {
        setOpen(wrapper, !currentMobileState);
      });
    },
    { passive: true }
  );

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialise, { once: true });
  } else {
    initialise();
  }
})();
