import { db, doc, getDoc, setDoc, collection, getDocs, query, orderBy } from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const catSnap = await getDocs(query(collection(db, "categories"), orderBy("order")));
  const categories = catSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const pagesSnap = await getDocs(collection(db, "pages"));
  const pages = pagesSnap.docs.map((d) => ({ slug: d.id, title: d.data().title || d.id }));

  const configDoc = await getDoc(doc(db, "menu", "config"));
  let items = configDoc.exists() ? (configDoc.data().items || []) : [];

  function renderList() {
    outlet.innerHTML = `
      <h1>Menu</h1>
      <p style="color:#5C6066;">Controls what appears in the app's left-side menu (tap the ☰ icon in the app).
      Add categories or pages, and reorder them with ↑↓.</p>
      <div class="card">
        <table>
          <thead><tr><th>Label</th><th>Links to</th><th>Actions</th></tr></thead>
          <tbody>
            ${items.map((item, i) => `
              <tr>
                <td>${escapeHtml(item.label)}</td>
                <td>${item.type}${item.targetId ? ": " + escapeHtml(item.targetId) : ""}</td>
                <td>
                  <button class="btn-secondary move-up" data-i="${i}" ${i === 0 ? "disabled" : ""}>↑</button>
                  <button class="btn-secondary move-down" data-i="${i}" ${i === items.length - 1 ? "disabled" : ""}>↓</button>
                  <button class="btn-danger remove-item" data-i="${i}">✕</button>
                </td>
              </tr>
            `).join("") || `<tr><td colspan="3">No menu items yet.</td></tr>`}
          </tbody>
        </table>
        <div class="row" style="margin-top:16px;gap:8px;">
          <select id="new-item-type" style="width:auto;">
            <option value="category">Category</option>
            <option value="page">Page</option>
          </select>
          <select id="new-item-target" style="width:auto;"></select>
          <button class="btn-secondary" id="add-item-btn" style="width:auto;">+ Add</button>
        </div>
        <button class="btn-primary" id="save-menu-btn" style="width:auto;margin-top:16px;">Save Menu</button>
      </div>
    `;

    function refreshTargetOptions() {
      const type = document.getElementById("new-item-type").value;
      const targetSelect = document.getElementById("new-item-target");
      const options = type === "category"
        ? categories.map((c) => ({ value: c.id, label: c.name }))
        : pages.map((p) => ({ value: p.slug, label: p.title }));
      targetSelect.innerHTML = options.map((o) => `<option value="${o.value}">${escapeHtml(o.label)}</option>`).join("");
    }
    refreshTargetOptions();
    document.getElementById("new-item-type").onchange = refreshTargetOptions;

    document.getElementById("add-item-btn").onclick = () => {
      const type = document.getElementById("new-item-type").value;
      const targetSelect = document.getElementById("new-item-target");
      const targetId = targetSelect.value;
      const label = targetSelect.options[targetSelect.selectedIndex]?.text || "";
      if (!targetId) return;
      items.push({ label, type, targetId });
      renderList();
    };

    outlet.querySelectorAll(".move-up").forEach((btn) => {
      btn.onclick = () => {
        const i = Number(btn.dataset.i);
        [items[i - 1], items[i]] = [items[i], items[i - 1]];
        renderList();
      };
    });
    outlet.querySelectorAll(".move-down").forEach((btn) => {
      btn.onclick = () => {
        const i = Number(btn.dataset.i);
        [items[i], items[i + 1]] = [items[i + 1], items[i]];
        renderList();
      };
    });
    outlet.querySelectorAll(".remove-item").forEach((btn) => {
      btn.onclick = () => {
        items.splice(Number(btn.dataset.i), 1);
        renderList();
      };
    });

    document.getElementById("save-menu-btn").onclick = async () => {
      try {
        await setDoc(doc(db, "menu", "config"), { items });
        toast("Menu saved");
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
    };
  }

  renderList();
}
