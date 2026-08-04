import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc, query, orderBy
} from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const catSnap = await getDocs(query(collection(db, "categories"), orderBy("order")));
  const categories = catSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const secSnap = await getDocs(query(collection(db, "homeSections"), orderBy("order")));
  const sections = secSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  outlet.innerHTML = `
    <h1>Categories</h1>
    <div class="card">
      <table>
        <thead><tr><th>Name</th><th>Order</th><th>Actions</th></tr></thead>
        <tbody>
          ${categories.map((c) => `
            <tr>
              <td>${escapeHtml(c.name)}</td>
              <td>${c.order}</td>
              <td>
                <button class="btn-secondary edit-cat-btn" data-id="${c.id}">Edit</button>
                <button class="btn-danger delete-cat-btn" data-id="${c.id}">Delete</button>
              </td>
            </tr>
          `).join("") || `<tr><td colspan="3">No categories yet.</td></tr>`}
        </tbody>
      </table>
      <button class="btn-secondary" id="new-cat-btn" style="width:auto;margin-top:12px;">+ New Category</button>
      <div class="hidden" id="cat-form-card" style="margin-top:16px;"></div>
    </div>

    <h1>Home Page Sections</h1>
    <div class="card">
      <table>
        <thead><tr><th>Title</th><th>Category</th><th>Banner</th><th>Order</th><th>Enabled</th><th>Actions</th></tr></thead>
        <tbody>
          ${sections.map((s) => `
            <tr>
              <td>${escapeHtml(s.title)}</td>
              <td>${escapeHtml(categories.find((c) => c.id === s.categoryId)?.name || "")}</td>
              <td>${s.bannerPosition}</td>
              <td>${s.order}</td>
              <td>${s.isEnabled ? "Yes" : "No"}</td>
              <td>
                <button class="btn-secondary edit-sec-btn" data-id="${s.id}">Edit</button>
                <button class="btn-danger delete-sec-btn" data-id="${s.id}">Delete</button>
              </td>
            </tr>
          `).join("") || `<tr><td colspan="6">No sections yet.</td></tr>`}
        </tbody>
      </table>
      <button class="btn-primary" id="new-sec-btn" style="width:auto;margin-top:12px;" ${categories.length === 0 ? "disabled" : ""}>+ New Section</button>
      <div class="hidden" id="sec-form-card" style="margin-top:16px;"></div>
    </div>
  `;

  // ---- Categories ----
  document.getElementById("new-cat-btn").onclick = () => showCatForm(null);
  outlet.querySelectorAll(".edit-cat-btn").forEach((btn) => {
    btn.onclick = () => showCatForm(categories.find((c) => c.id === btn.dataset.id));
  });
  outlet.querySelectorAll(".delete-cat-btn").forEach((btn) => {
    btn.onclick = async () => {
      if (!confirm("Delete this category? Sections using it should be removed too.")) return;
      await deleteDoc(doc(db, "categories", btn.dataset.id));
      toast("Category deleted");
      render(outlet, toast);
    };
  });

  function showCatForm(cat) {
    const card = document.getElementById("cat-form-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <label class="field-label">Name</label>
      <input id="c-name" value="${cat ? escapeHtml(cat.name) : ""}" />
      <label class="field-label">Order</label>
      <input type="number" id="c-order" value="${cat ? cat.order : categories.length}" />
      <button class="btn-primary" id="save-cat-btn" style="width:auto;">Save</button>
    `;
    document.getElementById("save-cat-btn").onclick = async () => {
      const payload = {
        name: document.getElementById("c-name").value.trim(),
        order: Number(document.getElementById("c-order").value) || 0,
      };
      if (cat) await updateDoc(doc(db, "categories", cat.id), payload);
      else await addDoc(collection(db, "categories"), payload);
      toast("Category saved");
      render(outlet, toast);
    };
  }

  // ---- Sections ----
  document.getElementById("new-sec-btn").onclick = () => showSecForm(null);
  outlet.querySelectorAll(".edit-sec-btn").forEach((btn) => {
    btn.onclick = () => showSecForm(sections.find((s) => s.id === btn.dataset.id));
  });
  outlet.querySelectorAll(".delete-sec-btn").forEach((btn) => {
    btn.onclick = async () => {
      if (!confirm("Delete this section?")) return;
      await deleteDoc(doc(db, "homeSections", btn.dataset.id));
      toast("Section deleted");
      render(outlet, toast);
    };
  });

  function showSecForm(sec) {
    const card = document.getElementById("sec-form-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <label class="field-label">Section Title</label>
      <input id="s-title" value="${sec ? escapeHtml(sec.title) : ""}" />
      <label class="field-label">Category</label>
      <select id="s-category">
        ${categories.map((c) => `<option value="${c.id}" ${sec && sec.categoryId === c.id ? "selected" : ""}>${escapeHtml(c.name)}</option>`).join("")}
      </select>
      <label class="field-label">Banner Position</label>
      <select id="s-banner">
        <option value="none" ${sec && sec.bannerPosition === "none" ? "selected" : ""}>None</option>
        <option value="above" ${sec && sec.bannerPosition === "above" ? "selected" : ""}>Above section</option>
        <option value="below" ${sec && sec.bannerPosition === "below" ? "selected" : ""}>Below section</option>
      </select>
      <label class="field-label">Order (controls position on home page)</label>
      <input type="number" id="s-order" value="${sec ? sec.order : sections.length}" />
      <label class="field-label"><input type="checkbox" id="s-enabled" ${!sec || sec.isEnabled ? "checked" : ""} style="width:auto;display:inline;"/> Enabled</label>
      <button class="btn-primary" id="save-sec-btn" style="width:auto;">Save</button>
    `;
    document.getElementById("save-sec-btn").onclick = async () => {
      const categoryId = document.getElementById("s-category").value;
      const category = categories.find((c) => c.id === categoryId);
      const payload = {
        title: document.getElementById("s-title").value.trim(),
        categoryId,
        bannerPosition: document.getElementById("s-banner").value,
        order: Number(document.getElementById("s-order").value) || 0,
        isEnabled: document.getElementById("s-enabled").checked,
      };
      if (sec) await updateDoc(doc(db, "homeSections", sec.id), payload);
      else await addDoc(collection(db, "homeSections"), payload);
      toast("Section saved");
      render(outlet, toast);
    };
  }
}
