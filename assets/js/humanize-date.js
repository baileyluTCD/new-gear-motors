class HumanDate extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    const humanDateString = new Date(this.textContent).toLocaleString();

    this.outerHTML = `
    <p>
      ${humanDateString}
    </p>
    `;
  }
}

customElements.define("humanize-date", HumanDate);
