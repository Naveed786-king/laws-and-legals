import { db, collection, getDocs, setDoc, deleteDoc, doc, serverTimestamp } from "../firebase-init.js";
import { escapeHtml } from "../ui.js";
import { createBlockEditor } from "../block-editor.js";

const DEFAULT_SLUGS = ["about", "contact", "advertise", "privacy", "terms"];

export async function render(outlet, toast) {
  const snap = await getDocs(collection(db, "pages"));
  const existing = {};
  snap.docs.forEach((d) => { existing[d.id] = d.data(); });

  const allSlugs = Array.from(new Set([...DEFAULT_SLUGS, ...Object.keys(existing)]));

  outlet.innerHTML = `
    <div class="row between">
      <h1>Pages</h1>
      <button class="btn-primary" id="new-page-btn" style="width:auto;">+ Custom Page</button>
    </div>
    <div class="card">
      <table>
        <thead><tr><th>Slug</th><th>Title</th><th>Actions</th></tr></thead>
        <tbody>
          ${allSlugs.map((slug) => `
            <tr>
              <td>${slug}</td>
              <td>${escapeHtml(existing[slug]?.title || "(not set)")}</td>
              <td>
                <button class="btn-secondary edit-btn" data-slug="${slug}">Edit</button>
                ${!DEFAULT_SLUGS.includes(slug) ? `<button class="btn-danger delete-btn" data-slug="${slug}">Delete</button>` : ""}
              </td>
            </tr>
          `).join("")}
        </tbody>
      </table>
    </div>
    <div class="card hidden" id="page-form-card"></div>
  `;

  document.getElementById("new-page-btn").onclick = () => {
    const slug = prompt("Enter a URL slug for the new page (letters, numbers, hyphens):");
    if (slug) showForm(slug.trim().toLowerCase().replace(/[^a-z0-9-]/g, "-"), null);
  };
  outlet.querySelectorAll(".edit-btn").forEach((btn) => {
    btn.onclick = () => showForm(btn.dataset.slug, existing[btn.dataset.slug]);
  });
  outlet.querySelectorAll(".delete-btn").forEach((btn) => {
    btn.onclick = async () => {
      if (!confirm("Delete this page?")) return;
      await deleteDoc(doc(db, "pages", btn.dataset.slug));
      toast("Page deleted");
      render(outlet, toast);
    };
  });

  function showForm(slug, page) {
    const card = document.getElementById("page-form-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <h3>Edit Page: /${slug}</h3>
      <label class="field-label">Title</label>
      <input id="f-title" value="${page ? escapeHtml(page.title) : ""}" />
      <label class="field-label">Content</label>
      <div id="page-content-mount"></div>
      <div class="row" style="margin-top:16px;">
        <button class="btn-primary" id="save-page-btn" style="width:auto;">Save</button>
        <button class="btn-secondary" id="cancel-page-btn" style="width:auto;">Cancel</button>
      </div>
    `;

    const initialBlocks = page && page.blocks && page.blocks.length > 0
      ? page.blocks
      : (page && page.content ? [{ type: "paragraph", html: page.content.replace(/<[^>]+>/g, "") }] : []);
    const editor = createBlockEditor(document.getElementById("page-content-mount"), initialBlocks);

    document.getElementById("cancel-page-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-page-btn").onclick = async () => {
      try {
        await setDoc(doc(db, "pages", slug), {
          title: document.getElementById("f-title").value.trim(),
          content: editor.toHtml(),
          blocks: editor.toBlocks(),
          updatedAt: serverTimestamp(),
        });
        toast("Page saved");
        render(outlet, toast);
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
    };
  }
}
