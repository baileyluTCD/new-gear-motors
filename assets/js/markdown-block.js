import { marked } from "marked";

class Markdown extends HTMLElement {
  constructor() {
    super();
  }

  connectedCallback() {
    this.outerHTML = `
    <div class="markdown-block">
      <style>
          .markdown-block {
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
          .markdown-block h1 {
            font-size: 1.75rem;
            font-weight: 700;
          }
          .markdown-block h2 {
            font-size: 1.5rem;
            font-weight: 600;
          }
          .markdown-block h3 {
            font-size: 1.25rem;
            font-weight: 600;
          }
          .markdown-block a {
            text-decoration: underline;
          }
          .markdown-block a:hover {
            color: #2b6cb0;
          }
          .markdown-block li::before {
            content: "";
            display: inline-block;
            width: 0.5em;
            height: 0.5em;
            background-color: currentColor;
            border-radius: 50%;
            margin-right: 0.5em;
            vertical-align: middle;
          }
          .markdown-block code {
            background-color: #f7fafc;
            padding: 0.2em 0.4em;
            border-radius: 4px;
            font-family: "Source Code Pro", monospace, monospace;
            font-size: 0.9em;
          }
          .markdown-block pre {
            background-color: #f7fafc;
            padding: 1em;
            border-radius: 6px;
            overflow-x: auto;
            font-family: "Source Code Pro", monospace, monospace;
            font-size: 0.9em;
          }
          .markdown-block blockquote {
            border-left: 4px solid #cbd5e0;
            color: #718096;
            padding-left: 1em;
            margin: 1em 0;
            font-style: italic;
            background-color: #f7fafc;
          }
          .markdown-block hr {
            border: none;
            border-top: 1px solid #e2e8f0;
            margin: 2em 0;
          }
        </style>
      ${marked.parse(this.textContent)}
    </div>
    `;
  }
}

customElements.define("markdown-block", Markdown);
