import { escapeHtml } from "./ui.js";

/**
 * A block-based content editor covering the common WordPress-style needs:
 * Heading, rich-text Paragraph (bold/italic/underline/link toolbar), Bullet
 * List, Image, Quote, Divider, YouTube embed, and Button/CTA link. This is
 * not a full WordPress/Gutenberg clone (that's a huge codebase), but it
 * covers real editorial needs without leaving the admin dashboard.
 *
 * Renders into `container`. .toHtml() returns the saved HTML string (read
 * by the Android app's renderer), .toBlocks() returns the raw block data
 * (kept for re-editing, since HTML alone can't losslessly round-trip back
 * into blocks).
 */
export function createBlockEditor(container, initialBlocks = []) {
  let blocks = initialBlocks.length > 0 ? [...initialBlocks] : [{ type: "paragraph", html: "" }];

  const BLOCK_TYPES = [
    { type: "heading", label: "+ Heading" },
    { type: "paragraph", label: "+ Paragraph" },
    { type: "list", label: "+ List" },
    { type: "image", label: "+ Image" },
    { type: "quote", label: "+ Quote" },
    { type: "divider", label: "+ Divider" },
    { type: "youtube", label: "+ YouTube" },
    { type: "button", label: "+ Button" },
  ];

  function render() {
    container.innerHTML = `
      <div id="blocks-list"></div>
      <div class="row" style="margin-top:10px;gap:6px;flex-wrap:wrap;">
        ${BLOCK_TYPES.map((t) => `<button type="button" class="btn-secondary add-block-btn" data-type="${t.type}">${t.label}</button>`).join("")}
      </div>
    `;
    const list = container.querySelector("#blocks-list");
    blocks.forEach((block, i) => list.appendChild(renderBlock(block, i)));

    container.querySelectorAll(".add-block-btn").forEach((btn) => {
      btn.onclick = () => {
        const type = btn.dataset.type;
        const defaults = {
          heading: { type, html: "" },
          paragraph: { type, html: "" },
          quote: { type, html: "" },
          list: { type, items: [""] },
          image: { type, url: "" },
          divider: { type },
          youtube: { type, videoId: "" },
          button: { type, label: "", url: "" },
        };
        blocks.push(defaults[type] || { type, html: "" });
        render();
      };
    });
  }

  function controlsHtml(block, index) {
    return `
      <div class="row between" style="margin-bottom:6px;">
        <span style="font-size:11px;text-transform:uppercase;color:#5C6066;font-weight:600;">${block.type}</span>
        <div>
          <button type="button" class="btn-secondary move-up" data-i="${index}" ${index === 0 ? "disabled" : ""}>↑</button>
          <button type="button" class="btn-secondary move-down" data-i="${index}" ${index === blocks.length - 1 ? "disabled" : ""}>↓</button>
          <button type="button" class="btn-danger remove-block" data-i="${index}">✕</button>
        </div>
      </div>
    `;
  }

  function toolbarHtml(index) {
    return `
      <div class="row" style="gap:4px;margin-bottom:6px;">
        <button type="button" class="btn-secondary fmt-btn" data-i="${index}" data-cmd="bold" title="Bold"><b>B</b></button>
        <button type="button" class="btn-secondary fmt-btn" data-i="${index}" data-cmd="italic" title="Italic"><i>I</i></button>
        <button type="button" class="btn-secondary fmt-btn" data-i="${index}" data-cmd="underline" title="Underline"><u>U</u></button>
        <button type="button" class="btn-secondary fmt-link-btn" data-i="${index}" title="Link">🔗</button>
      </div>
    `;
  }

  function renderBlock(block, index) {
    const wrap = document.createElement("div");
    wrap.className = "card";
    wrap.style.marginBottom = "10px";
    wrap.style.padding = "12px";

    const controls = controlsHtml(block, index);

    if (block.type === "heading") {
      wrap.innerHTML = controls +
        `<div class="rich-input" contenteditable="true" data-i="${index}" style="min-height:32px;font-weight:700;font-size:18px;border:1px solid #D8DADE;border-radius:8px;padding:8px;" data-placeholder="Heading text">${block.html || ""}</div>`;
    } else if (block.type === "paragraph" || block.type === "quote") {
      wrap.innerHTML = controls + toolbarHtml(index) +
        `<div class="rich-input" contenteditable="true" data-i="${index}" style="min-height:80px;border:1px solid #D8DADE;border-radius:8px;padding:8px;${block.type === "quote" ? "font-style:italic;border-left:4px solid #B80000;" : ""}" data-placeholder="${block.type === "quote" ? "Quote text" : "Paragraph text"}">${block.html || ""}</div>`;
    } else if (block.type === "list") {
      const itemsHtml = (block.items || [""]).map((item, itemIdx) =>
        `<input class="list-item-input" data-i="${index}" data-item="${itemIdx}" value="${escapeHtml(item)}" placeholder="List item" style="margin-bottom:6px;" />`
      ).join("");
      wrap.innerHTML = controls + `<div class="list-items">${itemsHtml}</div><button type="button" class="btn-secondary add-list-item" data-i="${index}">+ Item</button>`;
    } else if (block.type === "image") {
      wrap.innerHTML = controls +
        `<input class="block-image-url" data-i="${index}" value="${escapeHtml(block.url || "")}" placeholder="Paste image URL (e.g. https://...)" />` +
        (block.url ? `<img class="thumb" src="${block.url}" style="width:160px;height:auto;margin-top:8px;display:block;" onerror="this.style.display='none'" />` : "");
    } else if (block.type === "divider") {
      wrap.innerHTML = controls + `<hr style="border:none;border-top:2px solid #D8DADE;margin:8px 0;" /><p style="color:#5C6066;font-size:12px;">A horizontal divider line will appear here in the post.</p>`;
    } else if (block.type === "youtube") {
      wrap.innerHTML = controls +
        `<label class="field-label">YouTube Video ID</label>` +
        `<input class="block-youtube-id" data-i="${index}" value="${escapeHtml(block.videoId || "")}" placeholder="e.g. dQw4w9WgXcQ (the part after v= in the URL)" />` +
        (block.videoId ? `<p style="color:#5C6066;font-size:12px;">Will show as a tappable video card in the app.</p>` : "");
    } else if (block.type === "button") {
      wrap.innerHTML = controls +
        `<label class="field-label">Button Label</label>` +
        `<input class="block-button-label" data-i="${index}" value="${escapeHtml(block.label || "")}" placeholder="e.g. Read the full order" />` +
        `<label class="field-label">Button Link URL</label>` +
        `<input class="block-button-url" data-i="${index}" value="${escapeHtml(block.url || "")}" placeholder="https://..." />`;
    }

    return wrap;
  }

  container.addEventListener("input", (e) => {
    const i = Number(e.target.dataset.i);
    if (Number.isNaN(i)) return;
    if (e.target.classList.contains("rich-input")) {
      blocks[i].html = e.target.innerHTML;
    } else if (e.target.classList.contains("list-item-input")) {
      const itemIdx = Number(e.target.dataset.item);
      blocks[i].items[itemIdx] = e.target.value;
    } else if (e.target.classList.contains("block-image-url")) {
      blocks[i].url = e.target.value;
    } else if (e.target.classList.contains("block-youtube-id")) {
      blocks[i].videoId = e.target.value.trim();
    } else if (e.target.classList.contains("block-button-label")) {
      blocks[i].label = e.target.value;
    } else if (e.target.classList.contains("block-button-url")) {
      blocks[i].url = e.target.value;
    }
  });

  container.addEventListener("click", async (e) => {
    if (e.target.closest(".fmt-btn")) {
      const btn = e.target.closest(".fmt-btn");
      const i = Number(btn.dataset.i);
      const editable = container.querySelector(`.rich-input[data-i="${i}"]`);
      editable.focus();
      document.execCommand(btn.dataset.cmd, false, null);
      blocks[i].html = editable.innerHTML;
      return;
    }
    if (e.target.closest(".fmt-link-btn")) {
      const btn = e.target.closest(".fmt-link-btn");
      const i = Number(btn.dataset.i);
      const url = prompt("Link URL:");
      if (!url) return;
      const editable = container.querySelector(`.rich-input[data-i="${i}"]`);
      editable.focus();
      document.execCommand("createLink", false, url);
      blocks[i].html = editable.innerHTML;
      return;
    }
    if (e.target.classList.contains("move-up")) {
      const i = Number(e.target.dataset.i);
      [blocks[i - 1], blocks[i]] = [blocks[i], blocks[i - 1]];
      render();
    } else if (e.target.classList.contains("move-down")) {
      const i = Number(e.target.dataset.i);
      [blocks[i], blocks[i + 1]] = [blocks[i + 1], blocks[i]];
      render();
    } else if (e.target.classList.contains("remove-block")) {
      const i = Number(e.target.dataset.i);
      blocks.splice(i, 1);
      if (blocks.length === 0) blocks.push({ type: "paragraph", html: "" });
      render();
    } else if (e.target.classList.contains("add-list-item")) {
      const i = Number(e.target.dataset.i);
      blocks[i].items.push("");
      render();
    }
  });

  // Refresh image preview once the user finishes typing a URL, without
  // re-rendering (and losing focus) on every keystroke.
  container.addEventListener("blur", (e) => {
    if (e.target.classList.contains("block-image-url") || e.target.classList.contains("block-youtube-id")) render();
  }, true);

  render();

  // Only these inline tags are allowed through from execCommand's output -
  // strips anything else (e.g. stray spans/styles some browsers insert).
  function sanitizeInlineHtml(html) {
    const allowed = /<\/?(b|strong|i|em|u|a)(\s+href="[^"]*")?>/gi;
    const div = document.createElement("div");
    div.innerHTML = html || "";
    const walk = (node) => {
      [...node.childNodes].forEach((child) => {
        if (child.nodeType === 1) {
          const tag = child.tagName.toLowerCase();
          if (["b", "strong", "i", "em", "u"].includes(tag)) {
            walk(child);
          } else if (tag === "a") {
            const href = child.getAttribute("href") || "";
            const text = child.textContent;
            child.replaceWith(...[document.createTextNode("")]);
            // Re-insert as a clean anchor via outerHTML replace below.
            const clean = document.createElement("a");
            clean.setAttribute("href", href);
            clean.textContent = text;
            node.insertBefore(clean, child);
          } else {
            walk(child);
            child.replaceWith(...child.childNodes);
          }
        }
      });
    };
    walk(div);
    return div.innerHTML;
  }

  return {
    toHtml() {
      return blocks.map((b) => {
        if (b.type === "heading") return `<h2>${sanitizeInlineHtml(b.html)}</h2>`;
        if (b.type === "paragraph") return `<p>${sanitizeInlineHtml(b.html)}</p>`;
        if (b.type === "quote") return `<blockquote>${sanitizeInlineHtml(b.html)}</blockquote>`;
        if (b.type === "list") {
          const items = (b.items || []).filter((it) => it.trim()).map((it) => `<li>${escapeHtml(it)}</li>`).join("");
          return `<ul>${items}</ul>`;
        }
        if (b.type === "image") return b.url ? `<img src="${b.url}" />` : "";
        if (b.type === "divider") return "<hr/>";
        if (b.type === "youtube") return b.videoId ? `<p data-yt="${escapeHtml(b.videoId)}"></p>` : "";
        if (b.type === "button") return (b.label && b.url) ? `<p data-cta="${escapeHtml(b.url)}">${escapeHtml(b.label)}</p>` : "";
        return "";
      }).join("\n");
    },
    toBlocks() {
      return blocks;
    },
  };
}
