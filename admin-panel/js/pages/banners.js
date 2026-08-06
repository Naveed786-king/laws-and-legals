import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc, query, orderBy
} from "../firebase-init.js";

const POSITIONS = ["home_top", "home_middle", "post_bottom"];

export async function render(outlet, toast) {
  const snap = await getDocs(query(collection(db, "banners"), orderBy("priority")));
  const banners = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

  outlet.innerHTML = `
    <div class="row between">
      <h1>Banners</h1>
      <button class="btn-primary" id="new-banner-btn" style="width:auto;">+ New Banner</button>
    </div>
    <div class="card">
      <table>
        <thead><tr><th></th><th>Position</th><th>Priority</th><th>Enabled</th><th>Actions</th></tr></thead>
        <tbody>
          ${banners.map((b) => `
            <tr>
              <td><img class="thumb" src="${b.imageUrl || ''}" /></td>
              <td>${b.position}</td>
              <td>${b.priority}</td>
              <td>${b.isEnabled ? "Yes" : "No"}</td>
              <td>
                <button class="btn-secondary edit-btn" data-id="${b.id}">Edit</button>
                <button class="btn-danger delete-btn" data-id="${b.id}">Delete</button>
              </td>
            </tr>
          `).join("") || `<tr><td colspan="5">No banners yet.</td></tr>`}
        </tbody>
      </table>
    </div>
    <div class="card hidden" id="banner-form-card"></div>
  `;

  document.getElementById("new-banner-btn").onclick = () => showForm(null);
  outlet.querySelectorAll(".edit-btn").forEach((btn) => {
    btn.onclick = () => showForm(banners.find((b) => b.id === btn.dataset.id));
  });
  outlet.querySelectorAll(".delete-btn").forEach((btn) => {
    btn.onclick = async () => {
      if (!confirm("Delete this banner?")) return;
      await deleteDoc(doc(db, "banners", btn.dataset.id));
      toast("Banner deleted");
      render(outlet, toast);
    };
  });

  function showForm(banner) {
    const card = document.getElementById("banner-form-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <h3>${banner ? "Edit Banner" : "New Banner"}</h3>
      <label class="field-label">Destination URL</label>
      <input id="f-url" value="${banner ? banner.destinationUrl : ""}" placeholder="https://..." />
      <label class="field-label">Position</label>
      <select id="f-position">
        ${POSITIONS.map((p) => `<option value="${p}" ${banner && banner.position === p ? "selected" : ""}>${p}</option>`).join("")}
      </select>
      <label class="field-label">Priority (lower shows first)</label>
      <input type="number" id="f-priority" value="${banner ? banner.priority : 1}" />
      <label class="field-label"><input type="checkbox" id="f-enabled" ${!banner || banner.isEnabled ? "checked" : ""} style="width:auto;display:inline;"/> Enabled</label>
      <label class="field-label">Banner Image URL</label>
      <input id="f-image-url" value="${banner ? (banner.imageUrl || '') : ''}" placeholder="https://... (paste any image URL)" />
      ${banner && banner.imageUrl ? `<img class="thumb" src="${banner.imageUrl}" style="width:160px;height:auto;margin-top:8px;" onerror="this.style.display='none'" />` : ""}
      <div class="row" style="margin-top:16px;">
        <button class="btn-primary" id="save-banner-btn" style="width:auto;">Save</button>
        <button class="btn-secondary" id="cancel-banner-btn" style="width:auto;">Cancel</button>
      </div>
    `;
    document.getElementById("cancel-banner-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-banner-btn").onclick = async () => {
      try {
        const imageUrl = document.getElementById("f-image-url").value.trim();

        const payload = {
          destinationUrl: document.getElementById("f-url").value.trim(),
          position: document.getElementById("f-position").value,
          priority: Number(document.getElementById("f-priority").value) || 0,
          isEnabled: document.getElementById("f-enabled").checked,
          isVisible: true,
          imageUrl: imageUrl || "",
        };

        if (banner) {
          await updateDoc(doc(db, "banners", banner.id), payload);
        } else {
          await addDoc(collection(db, "banners"), payload);
        }
        toast("Banner saved");
        render(outlet, toast);
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
    };
  }
}
