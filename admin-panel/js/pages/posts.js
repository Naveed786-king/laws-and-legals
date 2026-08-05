import {
  db, collection, getDocs, addDoc, updateDoc, deleteDoc, doc,
  query, orderBy, serverTimestamp
} from "../firebase-init.js";
import { uploadImage } from "../upload.js";
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
              <td>${escapeHtml(p.categoryName || '')}</td>
              <td><span class="status-pill status-${p.status || 'draft'}">${p.status || 'draft'}</span></td>
              <td>
                <button class="btn-secondary edit-btn" data-id="${p.id}">Edit</button>
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
    btn.onclick = () => showForm(posts.find((p) => p.id === btn.dataset.id));
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
      <label class="field-label">Category</label>
      <select id="f-category">
        ${categories.map((c) => `<option value="${c.id}" ${post && post.categoryId === c.id ? "selected" : ""}>${escapeHtml(c.name)}</option>`).join("")}
      </select>
      <label class="field-label">Status</label>
      <select id="f-status">
        <option value="published" ${post && post.status === "published" ? "selected" : ""}>Published</option>
        <option value="draft" ${!post || post.status === "draft" ? "selected" : ""}>Draft</option>
      </select>
      <label class="field-label">Featured Image</label>
      <input type="file" id="f-image" accept="image/*" />
      ${post && post.imageUrl ? `<img class="thumb" src="${post.imageUrl}" style="width:120px;height:80px;margin-top:8px;" />` : ""}
      <div class="row" style="margin-top:16px;">
        <button class="btn-primary" id="save-post-btn" style="width:auto;">Save</button>
        <button class="btn-secondary" id="cancel-post-btn" style="width:auto;">Cancel</button>
      </div>
    `;

    const initialBlocks = post && post.blocks && post.blocks.length > 0
      ? post.blocks
      : (post && post.content ? [{ type: "paragraph", text: post.content.replace(/<[^>]+>/g, "") }] : []);
    const editor = createBlockEditor(document.getElementById("content-editor-mount"), initialBlocks);

    document.getElementById("cancel-post-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-post-btn").onclick = async () => {
      const categoryId = document.getElementById("f-category").value;
      const category = categories.find((c) => c.id === categoryId);
      const file = document.getElementById("f-image").files[0];
      let imageUrl = post ? post.imageUrl : "";
      if (file) imageUrl = await uploadImage(file, "posts");

      const payload = {
        title: document.getElementById("f-title").value.trim(),
        excerpt: document.getElementById("f-excerpt").value.trim(),
        content: editor.toHtml(),
        blocks: editor.toBlocks(),
        author: document.getElementById("f-author").value.trim(),
        categoryId,
        categoryName: category ? category.name : "",
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
      }
      toast("Post saved");
      render(outlet, toast);
    };
  }
}
