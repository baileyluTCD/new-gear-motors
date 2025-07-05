const downObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.remove("opacity-0", "translate-y-5");
        entry.target.classList.add("animate-fade-slide-down");
        downObserver.unobserve(entry.target);
      }
    });
  },
  {
    threshold: 0.2,
  },
);

document
  .querySelectorAll("[data-animate-down]")
  .forEach((el) => downObserver.observe(el));

const rightObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.remove("opacity-0", "translate-x-10");
        entry.target.classList.add("animate-fade-slide-right");
        rightObserver.unobserve(entry.target);
      }
    });
  },
  {
    threshold: 0.2,
  },
);

document
  .querySelectorAll("[data-animate-right]")
  .forEach((el) => rightObserver.observe(el));
