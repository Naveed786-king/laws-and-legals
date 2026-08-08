import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc, query, orderBy
} from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const catSnap = await getDocs(query(collection(db, "categories"), orderBy("order")));
  const categories = catSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const secSnap = await getDocs(query(collection(db, "homeSections"), orderBy("order")));
  const sections = secSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  const REFERENCE_CATEGORIES = [
    "राष्ट्रीय", "लॉ एंड लीगल", "कानून", "बार व बेंच",
    "आर्ट एंड जस्टिस", "लीगल सर्विस", "लीगल एज्यूकेशन", "परिचर्चा",
  ];

  outlet.innerHTML = `
    <div class="card" style="background:#FFF8E1;">
      <h3>Quick Setup</h3>
      <p style="color:#5C6066;">One click to create the standard category set
      (राष्ट्रीय, लॉ एंड लीगल, कानून, बार व बेंच, आर्ट एंड जस्टिस, लीगल सर्विस,
      लीगल एज्यूकेशन, परिचर्चा) plus a Home Section for each - only adds
      categories that don't already exist by name.</p>
      <button class="btn-primary" id="quick-setup-btn" style="width:auto;">Create Standard Categories + Sections</button>
    </div>

    <h1>Categories</h1>
    <div class="card">
      <table>
        <thead><tr><th>Name</th><th>Order</th><th>Actions</th></tr></thead>
        <tbody>
          ${categories.map((c, i) => `
            <tr>
              <td>${escapeHtml(c.name)}</td>
              <td>${c.order}</td>
              <td>
                <button class="btn-secondary move-cat-up" data-i="${i}" ${i === 0 ? "disabled" : ""}>↑</button>
                <button class="btn-secondary move-cat-down" data-i="${i}" ${i === categories.length - 1 ? "disabled" : ""}>↓</button>
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
          ${sections.map((s, i) => `
            <tr>
              <td>${escapeHtml(s.title)}</td>
              <td>${escapeHtml(categories.find((c) => c.id === s.categoryId)?.name || "")}</td>
              <td>${s.bannerPosition}</td>
              <td>${s.order}</td>
              <td>${s.isEnabled ? "Yes" : "No"}</td>
              <td>
                <button class="btn-secondary move-sec-up" data-i="${i}" ${i === 0 ? "disabled" : ""}>↑</button>
                <button class="btn-secondary move-sec-down" data-i="${i}" ${i === sections.length - 1 ? "disabled" : ""}>↓</button>
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
  document.getElementById("quick-setup-btn").onclick = async () => {
    try {
      const existingNames = categories.map((c) => c.name);
      let nextOrder = categories.length;
      const createdIds = {};
      for (const name of REFERENCE_CATEGORIES) {
        if (existingNames.includes(name)) continue;
        const ref = await addDoc(collection(db, "categories"), { name, order: nextOrder });
        createdIds[name] = ref.id;
        nextOrder++;
      }
      // Also create a Home Section for any newly created category that
      // doesn't already have one.
      const existingSectionCategoryIds = sections.map((s) => s.categoryId);
      let sectionOrder = sections.length;
      for (const [name, id] of Object.entries(createdIds)) {
        if (existingSectionCategoryIds.includes(id)) continue;
        await addDoc(collection(db, "homeSections"), {
          title: name,
          categoryId: id,
          bannerPosition: "none",
          order: sectionOrder,
          isEnabled: true,
        });
        sectionOrder++;
      }
      toast("Standard categories and sections created");
      render(outlet, toast);
    } catch (err) {
      console.error(err);
      alert("Could not set up: " + (err && err.message ? err.message : err));
    }
  };

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
  outlet.querySelectorAll(".move-cat-up").forEach((btn) => {
    btn.onclick = () => swapOrder(categories, Number(btn.dataset.i), -1, "categories");
  });
  outlet.querySelectorAll(".move-cat-down").forEach((btn) => {
    btn.onclick = () => swapOrder(categories, Number(btn.dataset.i), 1, "categories");
  });

  async function swapOrder(list, index, direction, collectionName) {
    const otherIndex = index + direction;
    if (otherIndex < 0 || otherIndex >= list.length) return;
    const a = list[index];
    const b = list[otherIndex];
    await updateDoc(doc(db, collectionName, a.id), { order: b.order });
    await updateDoc(doc(db, collectionName, b.id), { order: a.order });
    toast("Order updated");
    render(outlet, toast);
  }

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
      try {
        const payload = {
          name: document.getElementById("c-name").value.trim(),
          order: Number(document.getElementById("c-order").value) || 0,
        };
        if (cat) await updateDoc(doc(db, "categories", cat.id), payload);
        else await addDoc(collection(db, "categories"), payload);
        toast("Category saved");
        render(outlet, toast);
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
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
  outlet.querySelectorAll(".move-sec-up").forEach((btn) => {
    btn.onclick = () => swapOrder(sections, Number(btn.dataset.i), -1, "homeSections");
  });
  outlet.querySelectorAll(".move-sec-down").forEach((btn) => {
    btn.onclick = () => swapOrder(sections, Number(btn.dataset.i), 1, "homeSections");
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
      try {
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
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
    };
  }
}
