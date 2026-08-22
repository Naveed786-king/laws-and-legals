import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc,
  query, orderBy, serverTimestamp
} from "../firebase-init.js";
import { escapeHtml } from "../ui.js";
import { createBlockEditor } from "../block-editor.js";

async function getCategories() {
  const snap = await getDocs(query(collection(db, "categories"), orderBy("order")));
  return snap.docs.map((d) => ({ id: d.id, ...d.data() }));
}

export async function render(outlet, toast) {
  const categories = await getCategories();
  const postsSnap = await getDocs(query(collection(db, "posts"), orderBy("publishedAt", "desc")));
  const posts = postsSnap.docs.map((d) => ({ id: d.id, ...d.data() }));

  outlet.innerHTML = `
    <div class="row between">
      <h1>Posts</h1>
      <button class="btn-primary" id="new-post-btn" style="width:auto;">+ New Post</button>
    </div>
    <div class="card">
      <table>
        <thead><tr><th></th><th>Title</th><th>Category</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody id="posts-tbody">
          ${posts.map((p) => `
            <tr>
              <td><img class="thumb" src="${p.imageUrl || ''}" onerror="this.style.visibility='hidden'"/></td>
              <td>${escapeHtml(p.title)}</td>
              <td>${escapeHtml((p.categoryNames && p.categoryNames.length > 0) ? p.categoryNames.join(', ') : (p.categoryName || ''))}</td>
              <td><span class="status-pill status-${p.status || 'draft'}">${p.status || 'draft'}</span></td>
              <td>
                <button class="btn-secondary edit-btn" data-id="${p.id}">Edit</button>
                <button class="btn-secondary duplicate-btn" data-id="${p.id}">Duplicate</button>
                <button class="btn-danger delete-btn" data-id="${p.id}">Delete</button>
              </td>
            </tr>
          `).join("") || `<tr><td colspan="5">No posts yet.</td></tr>`}
        </tbody>
      </table>
    </div>
    <div class="card hidden" id="post-form-card"></div>
  `;

  document.getElementById("new-post-btn").onclick = () => showForm(null);
  outlet.querySelectorAll(".edit-btn").forEach((btn) => {
    btn.onclick = () => {
      showForm(posts.find((p) => p.id === btn.dataset.id));
      document.getElementById("post-form-card").scrollIntoView({ behavior: "smooth", block: "start" });
    };
  });
  outlet.querySelectorAll(".duplicate-btn").forEach((btn) => {
    btn.onclick = () => {
      const original = posts.find((p) => p.id === btn.dataset.id);
      if (!original) return;
      const copy = { ...original, title: original.title + " (Copy)", status: "draft" };
      delete copy.id;
      showForm(copy);
      document.getElementById("post-form-card").scrollIntoView({ behavior: "smooth", block: "start" });
    };
  });
  outlet.querySelectorAll(".delete-btn").forEach((btn) => {
    btn.onclick = async () => {
      if (!confirm("Delete this post?")) return;
      await deleteDoc(doc(db, "posts", btn.dataset.id));
      toast("Post deleted");
      render(outlet, toast);
    };
  });

  function showForm(post) {
    const card = document.getElementById("post-form-card");
    card.classList.remove("hidden");
    card.innerHTML = `
      <h3>${post ? "Edit Post" : "New Post"}</h3>
      <label class="field-label">Title</label>
      <input id="f-title" value="${post ? escapeHtml(post.title) : ""}" />
      <label class="field-label">Excerpt (short summary shown in lists)</label>
      <textarea id="f-excerpt">${post ? escapeHtml(post.excerpt) : ""}</textarea>
      <label class="field-label">Content</label>
      <div id="content-editor-mount"></div>
      <label class="field-label" style="margin-top:16px;">Author</label>
      <input id="f-author" value="${post ? escapeHtml(post.author) : ""}" />
      <label class="field-label">Categories (select one or more)</label>
      <div id="f-categories-checkboxes" style="margin-bottom:12px;">
        ${categories.map((c) => `
          <label style="display:block;font-weight:normal;margin-bottom:4px;">
            <input type="checkbox" class="f-category-checkbox" value="${c.id}" data-name="${escapeHtml(c.name)}"
              style="width:auto;display:inline;margin-right:6px;"
              ${post && (post.categoryIds || [post.categoryId]).includes(c.id) ? "checked" : ""} />
            ${escapeHtml(c.name)}
          </label>
        `).join("")}
      </div>
      <label class="field-label">Status</label>
      <select id="f-status">
        <option value="published" ${post && post.status === "published" ? "selected" : ""}>Published</option>
        <option value="draft" ${!post || post.status === "draft" ? "selected" : ""}>Draft</option>
      </select>
      <label class="field-label">Featured Image URL</label>
      <input id="f-image-url" value="${post ? escapeHtml(post.imageUrl || "") : ""}" placeholder="https://... (paste any image URL)" />
      ${post && post.imageUrl ? `<img class="thumb" src="${post.imageUrl}" style="width:120px;height:80px;margin-top:8px;" onerror="this.style.display='none'" />` : ""}
      <div class="row" style="margin-top:16px;">
        <button class="btn-primary" id="save-post-btn" style="width:auto;">Save</button>
        <button class="btn-secondary" id="cancel-post-btn" style="width:auto;">Cancel</button>
      </div>
    `;

    const initialBlocks = post && post.blocks && post.blocks.length > 0
      ? post.blocks
      : (post && post.content ? [{ type: "paragraph", html: post.content.replace(/<[^>]+>/g, "") }] : []);
    const editor = createBlockEditor(document.getElementById("content-editor-mount"), initialBlocks);

    document.getElementById("cancel-post-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-post-btn").onclick = async () => {
      const saveBtn = document.getElementById("save-post-btn");
      saveBtn.disabled = true;
      saveBtn.textContent = "Saving...";
      try {
        const checkedBoxes = Array.from(document.querySelectorAll(".f-category-checkbox:checked"));
        if (checkedBoxes.length === 0) {
          alert("Please select at least one category.");
          saveBtn.disabled = false;
          saveBtn.textContent = "Save";
          return;
        }
        const categoryIds = checkedBoxes.map((cb) => cb.value);
        const categoryNames = checkedBoxes.map((cb) => cb.dataset.name);
        const imageUrl = document.getElementById("f-image-url").value.trim();

        const payload = {
          title: document.getElementById("f-title").value.trim(),
          excerpt: document.getElementById("f-excerpt").value.trim(),
          content: editor.toHtml(),
          blocks: editor.toBlocks(),
          author: document.getElementById("f-author").value.trim(),
          categoryId: categoryIds[0],
          categoryName: categoryNames[0],
          categoryIds,
          categoryNames,
          status: document.getElementById("f-status").value,
          imageUrl: imageUrl || "",
          updatedAt: serverTimestamp(),
        };

        if (post) {
          await updateDoc(doc(db, "posts", post.id), payload);
        } else {
          payload.publishedAt = serverTimestamp();
          payload.tags = [];
          await addDoc(collection(db, "posts"), payload);
          // Notify anyone with the app open right now, only for genuinely
          // new posts (not edits) that are published immediately.
          if (payload.status === "published") {
            await addDoc(collection(db, "notifications"), {
              title: "नई खबर",
              body: payload.title,
              createdAt: serverTimestamp(),
            });
          }
        }
        toast("Post saved");
        render(outlet, toast);
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err) +
          "\n\nIf this says permission-denied, the Firestore security rules haven't been published in Firebase Console yet.");
        saveBtn.disabled = false;
        saveBtn.textContent = "Save";
      }
    };
  }
}
