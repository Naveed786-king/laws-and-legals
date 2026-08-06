import { escapeHtml } from "./ui.js";

/**
 * A minimal block-based content editor: Heading, Paragraph, Bullet List,
 * and Image blocks. Renders into `container`. Call .toHtml() to get the
 * saved HTML string (compatible with the Android app's content renderer),
 * and .toBlocks() to get the raw block data (stored alongside for future
 * re-editing, since HTML alone is lossy to re-parse into blocks reliably).
 *
 * initialBlocks: array of {type: 'heading'|'paragraph'|'list'|'image', ...}
 */
export function createBlockEditor(container, initialBlocks = []) {
  let blocks = initialBlocks.length > 0 ? [...initialBlocks] : [{ type: "paragraph", text: "" }];

  function render() {
    container.innerHTML = `
      <div id="blocks-list"></div>
      <div class="row" style="margin-top:10px;gap:8px;">
        <button type="button" class="btn-secondary add-block-btn" data-type="heading">+ Heading</button>
        <button type="button" class="btn-secondary add-block-btn" data-type="paragraph">+ Paragraph</button>
        <button type="button" class="btn-secondary add-block-btn" data-type="list">+ List</button>
        <button type="button" class="btn-secondary add-block-btn" data-type="image">+ Image</button>
      </div>
    `;
    const list = container.querySelector("#blocks-list");
    blocks.forEach((block, i) => list.appendChild(renderBlock(block, i)));

    container.querySelectorAll(".add-block-btn").forEach((btn) => {
      btn.onclick = () => {
        const type = btn.dataset.type;
        const newBlock =
          type === "list" ? { type: "list", items: [""] } :
          type === "image" ? { type: "image", url: "" } :
          { type, text: "" };
        blocks.push(newBlock);
        render();
      };
    });
  }

  function renderBlock(block, index) {
    const wrap = document.createElement("div");
    wrap.className = "card";
    wrap.style.marginBottom = "10px";
    wrap.style.padding = "12px";

    const controls = `
      <div class="row between" style="margin-bottom:6px;">
        <span style="font-size:11px;text-transform:uppercase;color:#5C6066;font-weight:600;">${block.type}</span>
        <div>
          <button type="button" class="btn-secondary move-up" data-i="${index}" ${index === 0 ? "disabled" : ""}>↑</button>
          <button type="button" class="btn-secondary move-down" data-i="${index}" ${index === blocks.length - 1 ? "disabled" : ""}>↓</button>
          <button type="button" class="btn-danger remove-block" data-i="${index}">✕</button>
        </div>
      </div>
    `;

    if (block.type === "heading") {
      wrap.innerHTML = controls + `<input class="block-input" data-i="${index}" value="${escapeHtml(block.text || "")}" placeholder="Heading text" />`;
    } else if (block.type === "paragraph") {
      wrap.innerHTML = controls + `<textarea class="block-input" data-i="${index}" placeholder="Paragraph text">${escapeHtml(block.text || "")}</textarea>`;
    } else if (block.type === "list") {
      const itemsHtml = (block.items || [""]).map((item, itemIdx) =>
        `<input class="list-item-input" data-i="${index}" data-item="${itemIdx}" value="${escapeHtml(item)}" placeholder="List item" style="margin-bottom:6px;" />`
      ).join("");
      wrap.innerHTML = controls + `<div class="list-items">${itemsHtml}</div><button type="button" class="btn-secondary add-list-item" data-i="${index}">+ Item</button>`;
    } else if (block.type === "image") {
      wrap.innerHTML = controls +
        `<input class="block-image-url" data-i="${index}" value="${escapeHtml(block.url || "")}" placeholder="Paste image URL (e.g. https://...)" />` +
        (block.url ? `<img class="thumb" src="${block.url}" style="width:160px;height:auto;margin-top:8px;display:block;" onerror="this.style.display='none'" />` : "");
    }

    return wrap;
  }

  container.addEventListener("input", (e) => {
    const i = Number(e.target.dataset.i);
    if (e.target.classList.contains("block-input")) {
      blocks[i].text = e.target.value;
    } else if (e.target.classList.contains("list-item-input")) {
      const itemIdx = Number(e.target.dataset.item);
      blocks[i].items[itemIdx] = e.target.value;
    } else if (e.target.classList.contains("block-image-url")) {
      blocks[i].url = e.target.value;
    }
  });

  container.addEventListener("click", async (e) => {
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
      if (blocks.length === 0) blocks.push({ type: "paragraph", text: "" });
      render();
    } else if (e.target.classList.contains("add-list-item")) {
      const i = Number(e.target.dataset.i);
      blocks[i].items.push("");
      render();
    }
  });

  // Refresh the preview thumbnail once the user finishes typing a URL,
  // without re-rendering (and losing focus) on every keystroke.
  container.addEventListener("blur", (e) => {
    if (e.target.classList.contains("block-image-url")) render();
  }, true);

  render();

  return {
    toHtml() {
      return blocks.map((b) => {
        if (b.type === "heading") return `<h2>${escapeHtml(b.text || "")}</h2>`;
        if (b.type === "paragraph") return `<p>${escapeHtml(b.text || "")}</p>`;
        if (b.type === "list") {
          const items = (b.items || []).filter((it) => it.trim()).map((it) => `<li>${escapeHtml(it)}</li>`).join("");
          return `<ul>${items}</ul>`;
        }
        if (b.type === "image") return b.url ? `<img src="${b.url}" />` : "";
        return "";
      }).join("\n");
    },
    toBlocks() {
      return blocks;
    },
  };
}
