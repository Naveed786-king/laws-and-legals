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
    <div class="card" style="background:#FFF8E1;">
      <h3>Quick Setup</h3>
      <p style="color:#5C6066;">One click to add one sample published post to each existing category,
      so the app has real content to show immediately. Written as placeholder text for you to edit -
      not copied from anywhere. Skips any category that already has a post.</p>
      <button class="btn-primary" id="seed-posts-btn" style="width:auto;" ${categories.length === 0 ? "disabled" : ""}>
        Add One Sample Post Per Category
      </button>
      ${categories.length === 0 ? '<p style="color:#B3261E;font-size:13px;">Create categories first (Home Sections tab).</p>' : ""}
    </div>

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

  document.getElementById("seed-posts-btn").onclick = async () => {
    try {
      const categoriesWithPosts = new Set(posts.map((p) => p.categoryId));
      let count = 0;
      for (const cat of categories) {
        if (categoriesWithPosts.has(cat.id)) continue;
        const sampleTitle = `${cat.name} - सैंपल पोस्ट (इसे संपादित करें)`;
        await addDoc(collection(db, "posts"), {
          title: sampleTitle,
          excerpt: "यह एक सैंपल पोस्ट है। इसे एडिट करके असली खबर डालें, या डिलीट करके नई पोस्ट बनाएं।",
          content: `<p>यह ${cat.name} कैटेगरी के लिए एक सैंपल पोस्ट है, ताकि ऐप में यह कैटेगरी तुरंत दिखे। कृपया इसे एडिट पर टैप करके असली सामग्री से बदलें।</p>`,
          blocks: [{ type: "paragraph", text: `यह ${cat.name} कैटेगरी के लिए एक सैंपल पोस्ट है, ताकि ऐप में यह कैटेगरी तुरंत दिखे। कृपया इसे एडिट पर टैप करके असली सामग्री से बदलें।` }],
          author: "Admin",
          categoryId: cat.id,
          categoryName: cat.name,
          status: "published",
          imageUrl: "",
          tags: [],
          publishedAt: serverTimestamp(),
          updatedAt: serverTimestamp(),
        });
        count++;
      }
      toast(count > 0 ? `Added ${count} sample post(s)` : "Every category already has a post");
      render(outlet, toast);
    } catch (err) {
      console.error(err);
      alert("Could not add sample posts: " + (err && err.message ? err.message : err));
    }
  };

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
      : (post && post.content ? [{ type: "paragraph", text: post.content.replace(/<[^>]+>/g, "") }] : []);
    const editor = createBlockEditor(document.getElementById("content-editor-mount"), initialBlocks);

    document.getElementById("cancel-post-btn").onclick = () => card.classList.add("hidden");
    document.getElementById("save-post-btn").onclick = async () => {
      const saveBtn = document.getElementById("save-post-btn");
      saveBtn.disabled = true;
      saveBtn.textContent = "Saving...";
      try {
        const categoryId = document.getElementById("f-category").value;
        const category = categories.find((c) => c.id === categoryId);
        const imageUrl = document.getElementById("f-image-url").value.trim();

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
