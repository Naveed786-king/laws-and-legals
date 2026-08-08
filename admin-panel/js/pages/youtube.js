import { db, doc, getDoc, setDoc } from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const configDoc = await getDoc(doc(db, "youtube", "config"));
  const config = configDoc.exists() ? configDoc.data() : { channelId: "", apiKey: "", videos: [] };
  let videos = config.videos || [];

  function renderPage() {
    outlet.innerHTML = `
      <h1>YouTube Channel</h1>
      <p style="color:#5C6066;">Shows as a "चैनल" section on the app's home page (second-to-last section).
      Add videos manually below, or fill in the API fields for future automatic syncing.</p>

      <div class="card">
        <h3>API Configuration (optional, for future automatic sync)</h3>
        <label class="field-label">YouTube Channel ID</label>
        <input id="f-channel-id" value="${escapeHtml(config.channelId || "")}" placeholder="UC..." />
        <label class="field-label">YouTube Data API Key</label>
        <input id="f-api-key" value="${escapeHtml(config.apiKey || "")}" placeholder="Optional - for automatic video sync later" />
      </div>

      <div class="card">
        <h3>Videos</h3>
        <table>
          <thead><tr><th></th><th>Title</th><th>Video ID</th><th>Actions</th></tr></thead>
          <tbody>
            ${videos.map((v, i) => `
              <tr>
                <td><img class="thumb" src="${v.thumbnailUrl || ''}" onerror="this.style.visibility='hidden'" /></td>
                <td>${escapeHtml(v.title)}</td>
                <td>${escapeHtml(v.videoId)}</td>
                <td><button class="btn-danger remove-video" data-i="${i}">Delete</button></td>
              </tr>
            `).join("") || `<tr><td colspan="4">No videos added yet.</td></tr>`}
          </tbody>
        </table>
        <div id="add-video-form" style="margin-top:12px;">
          <label class="field-label">Video Title</label>
          <input id="f-video-title" placeholder="Video title" />
          <label class="field-label">YouTube Video ID</label>
          <input id="f-video-id" placeholder="e.g. dQw4w9WgXcQ (the part after v= in the URL)" />
          <label class="field-label">Thumbnail Image URL</label>
          <input id="f-video-thumb" placeholder="https://... (paste any image URL)" />
          <button class="btn-secondary" id="add-video-btn" style="width:auto;margin-top:8px;">+ Add Video</button>
        </div>
      </div>

      <button class="btn-primary" id="save-youtube-btn" style="width:auto;">Save</button>
    `;

    outlet.querySelectorAll(".remove-video").forEach((btn) => {
      btn.onclick = () => {
        videos.splice(Number(btn.dataset.i), 1);
        renderPage();
      };
    });

    document.getElementById("add-video-btn").onclick = () => {
      const title = document.getElementById("f-video-title").value.trim();
      const videoId = document.getElementById("f-video-id").value.trim();
      const thumbnailUrl = document.getElementById("f-video-thumb").value.trim();
      if (!title || !videoId) return;
      videos.push({ title, videoId, thumbnailUrl });
      renderPage();
    };

    document.getElementById("save-youtube-btn").onclick = async () => {
      try {
        await setDoc(doc(db, "youtube", "config"), {
          channelId: document.getElementById("f-channel-id").value.trim(),
          apiKey: document.getElementById("f-api-key").value.trim(),
          videos,
        });
        toast("YouTube config saved");
      } catch (err) {
        console.error(err);
        alert("Could not save: " + (err && err.message ? err.message : err));
      }
    };
  }

  renderPage();
}
