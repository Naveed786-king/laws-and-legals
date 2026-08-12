import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc, query, orderBy
} from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const catSnap = await getDocs(query(collection(db, "categories"), orderBy("order")));
  const categories = catSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const secSnap = await getDocs(query(collection(db, "homeSections"), orderBy("order")));
  const sections = secSnap.docs.map((d) => ({ id: d.id, ...d.data() }));
  const bannerSnap = await getDocs(collection(db, "banners"));
  const banners = bannerSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  function sectionSummary(s) {
    if ((s.type || "category") === "banner") {
      const b = banners.find((x) => x.id === s.bannerId);
      return `Banner: ${b ? (b.destinationUrl || b.id) : "(not found)"}`;
    }
    return `Category: ${categories.find((c) => c.id === s.categoryId)?.name || "(not found)"}`;
  }

  outlet.innerHTML = `
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
        <thead><tr><th>Title</th><th>Type</th><th>Order</th><th>Enabled</th><th>Actions</th></tr></thead>
        <tbody>
          ${sections.map((s, i) => `
            <tr>
              <td>${escapeHtml(s.title || "(banner)")}</td>
              <td>${sectionSummary(s)}</td>
              <td>${s.order}</td>
              <td>${s.isEnabled ? "Yes" : "No"}</td>
              <td>
                <button class="btn-secondary move-sec-up" data-i="${i}" ${i === 0 ? "disabled" : ""}>↑</button>
                <button class="btn-secondary move-sec-down" data-i="${i}" ${i === sections.length - 1 ? "disabled" : ""}>↓</button>
                <button class="btn-secondary edit-sec-btn" data-id="${s.id}">Edit</button>
                <button class="btn-danger delete-sec-btn" data-id="${s.id}">Delete</button>
              </td>
            </tr>
          `).join("") || `<tr><td colspan="5">No sections yet.</td></tr>`}
        </tbody>
      </table>
      <button class="btn-primary" id="new-sec-btn" style="width:auto;margin-top:12px;">+ New Section</button>
      <div class="hidden" id="sec-type-card" style="margin-top:16px;"></div>
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
  const secDeleteButtons = outlet.querySelectorAll(".delete-sec-btn");
  secDeleteButtons.forEach((btn) => {
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

  document.getElementById("new-sec-btn").onclick = () => {
    showTypeChoice();
    document.getElementById("sec-type-card").scrollIntoView({ behavior: "smooth", block: "start" });
  };
  outlet.querySelectorAll(".edit-sec-btn").forEach((btn) => {
    btn.onclick = () => {
      const sec = sections.find((s) => s.id === btn.dataset.id);
      showSecForm(sec, sec.type || "category");
      document.getElementById("sec-form-card").scrollIntoView({ behavior: "smooth", block: "start" });
    };
  });

  // Step 1: ask what kind of section this should be.
  function showTypeChoice() {
    document.getElementById("sec-form-card").classList.add("hidden");
    document.getElementById("sec-form-card").innerHTML = "";
    const card = document.getElementById("sec-type-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <h3>What kind of section is this?</h3>
      <p style="color:#5C6066;">Choose based on what you need - a feed of posts from one category,
      or a standalone banner image.</p>
      <div class="row" style="gap:12px;">
        <button class="btn-primary" id="choose-category-btn" style="width:auto;" ${categories.length === 0 ? "disabled" : ""}>Category Section</button>
        <button class="btn-primary" id="choose-banner-btn" style="width:auto;" ${banners.length === 0 ? "disabled" : ""}>Banner Section</button>
      </div>
      ${categories.length === 0 ? `<p style="color:#5C6066;font-size:13px;margin-top:8px;">Add a category above first to use a Category Section.</p>` : ""}
      ${banners.length === 0 ? `<p style="color:#5C6066;font-size:13px;">Add a banner in the Banners tab first to use a Banner Section.</p>` : ""}
    `;
    document.getElementById("choose-category-btn").onclick = () => {
      card.classList.add("hidden");
      showSecForm(null, "category");
      document.getElementById("sec-form-card").scrollIntoView({ behavior: "smooth", block: "start" });
    };
    document.getElementById("choose-banner-btn").onclick = () => {
      card.classList.add("hidden");
      showSecForm(null, "banner");
      document.getElementById("sec-form-card").scrollIntoView({ behavior: "smooth", block: "start" });
    };
  }

  // Step 2: the actual form, specific to the chosen type.
  function showSecForm(sec, type) {
    const card = document.getElementById("sec-form-card");
    card.classList.remove("hidden");

    if (type === "banner") {
      card.innerHTML = `
        <h3>${sec ? "Edit Banner Section" : "New Banner Section"}</h3>
        <label class="field-label">Which Banner</label>
        <select id="s-banner-id">
          <option value="">-- Select a banner --</option>
          ${banners.map((b) => `
            <option value="${b.id}" ${sec && sec.bannerId === b.id ? "selected" : ""}>
              ${b.destinationUrl || b.id} ${b.isEnabled ? "" : "(disabled)"}
            </option>
          `).join("")}
        </select>
        <div id="s-banner-preview" style="margin-top:8px;"></div>
        <label class="field-label">Order (controls position on home page)</label>
        <input type="number" id="s-order" value="${sec ? sec.order : sections.length}" />
        <label class="field-label"><input type="checkbox" id="s-enabled" ${!sec || sec.isEnabled ? "checked" : ""} style="width:auto;display:inline;"/> Enabled</label>
        <div class="row" style="margin-top:16px;gap:8px;">
          <button class="btn-primary" id="save-sec-btn" style="width:auto;">Save</button>
          <button class="btn-secondary" id="cancel-sec-btn" style="width:auto;">Cancel</button>
        </div>
      `;

      const updatePreview = () => {
        const bannerId = document.getElementById("s-banner-id").value;
        const banner = banners.find((b) => b.id === bannerId);
        const preview = document.getElementById("s-banner-preview");
        preview.innerHTML = banner && banner.imageUrl
          ? `<img class="thumb" src="${banner.imageUrl}" style="width:200px;height:auto;" onerror="this.style.display='none'" />`
          : "";
      };
      document.getElementById("s-banner-id").onchange = updatePreview;
      updatePreview();

      document.getElementById("cancel-sec-btn").onclick = () => card.classList.add("hidden");
      document.getElementById("save-sec-btn").onclick = async () => {
        try {
          const bannerId = document.getElementById("s-banner-id").value;
          if (!bannerId) { alert("Please select a banner."); return; }
          const payload = {
            type: "banner",
            title: "",
            bannerId,
            order: Number(document.getElementById("s-order").value) || 0,
            isEnabled: document.getElementById("s-enabled").checked,
          };
          if (sec) await updateDoc(doc(db, "homeSections", sec.id), payload);
          else await addDoc(collection(db, "homeSections"), payload);
          toast("Banner section saved");
          render(outlet, toast);
        } catch (err) {
          console.error(err);
          alert("Could not save: " + (err && err.message ? err.message : err));
        }
      };
      return;
    }

    // type === "category"
    card.innerHTML = `
      <h3>${sec ? "Edit Category Section" : "New Category Section"}</h3>
      <label class="field-label">Section Title</label>
      <input id="s-title" value="${sec ? escapeHtml(sec.title) : ""}" />
      <label class="field-label">Category</label>
      <select id="s-category">
        ${categories.map((c) => `<option value="${c.id}" ${sec && sec.categoryId === c.id ? "selected" : ""}>${escapeHtml(c.name)}</option>`).join("")}
      </select>
      <label class="field-label">Order (controls position on home page)</label>
      <input type="number" id="s-order" value="${sec ? sec.order : sections.length}" />
      <label class="field-label">Posts to show in this section</label>
      <input type="number" id="s-limit" value="${sec ? (sec.postsLimit || 5) : 5}" min="1" max="20" />
      <label class="field-label"><input type="checkbox" id="s-enabled" ${!sec || sec.isEnabled ? "checked" : ""} style="width:auto;display:inline;"/> Enabled</label>
      <div class="row" style="margin-top:16px;gap:8px;">
        <button class="btn-primary" id="save-sec-btn" style="width:auto;">Save</button>
        <button class="btn-secondary" id="cancel-sec-btn" style="width:auto;">Cancel</button>
      </div>
    `;
    document.getElementById("cancel-sec-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-sec-btn").onclick = async () => {
      try {
        const categoryId = document.getElementById("s-category").value;
        const payload = {
          type: "category",
          title: document.getElementById("s-title").value.trim(),
          categoryId,
          order: Number(document.getElementById("s-order").value) || 0,
          postsLimit: Number(document.getElementById("s-limit").value) || 5,
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
