function handleAnimations(entries, observer) {
  for (const entry of entries) {
    if (!entry.isIntersecting) continue;
    const el = entry.target;

    if (el.hasAttribute("data-animate-down")) {
      el.classList.remove("opacity-0", "translate-y-5");
      el.classList.add("animate-fade-slide-down");
    } else if (el.hasAttribute("data-animate-right")) {
      el.classList.remove("opacity-0", "translate-x-10");
      el.classList.add("animate-fade-slide-right");
    }

    observer.unobserve(el);
  }
}

const animationObserver = new IntersectionObserver(handleAnimations, {
  threshold: 0.2,
});

document
  .querySelectorAll("[data-animate-down], [data-animate-right]")
  .forEach((el) => animationObserver.observe(el));
