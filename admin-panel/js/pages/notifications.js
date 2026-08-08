import { db, collection, getDocs, addDoc, query, orderBy, serverTimestamp } from "../firebase-init.js";
import { escapeHtml } from "../ui.js";

export async function render(outlet, toast) {
  const snap = await getDocs(query(collection(db, "notifications"), orderBy("createdAt", "desc")));
  const notifications = snap.docs.map((d) => ({ id: d.id, ...d.data() }));

  outlet.innerHTML = `
    <h1>Notifications</h1>
    <p style="color:#5C6066;">Sends instantly to anyone with the app open right now (real-time, free).
    People who have the app fully closed won't receive it until they reopen the app - true background
    push notifications need a paid Firebase plan (Cloud Functions), which isn't set up yet.</p>

    <div class="card">
      <h3>Send Notification</h3>
      <label class="field-label">Title</label>
      <input id="f-title" placeholder="Notification title" />
      <label class="field-label">Message</label>
      <textarea id="f-body" placeholder="Notification message"></textarea>
      <button class="btn-primary" id="send-btn" style="width:auto;margin-top:8px;">Send Now</button>
    </div>

    <h3>History</h3>
    <div class="card">
      <table>
        <thead><tr><th>Title</th><th>Message</th><th>Sent</th></tr></thead>
        <tbody>
          ${notifications.map((n) => `
            <tr>
              <td>${escapeHtml(n.title)}</td>
              <td>${escapeHtml(n.body)}</td>
              <td>${n.createdAt && n.createdAt.toDate ? n.createdAt.toDate().toLocaleString() : ""}</td>
            </tr>
          `).join("") || `<tr><td colspan="3">No notifications sent yet.</td></tr>`}
        </tbody>
      </table>
    </div>
  `;

  document.getElementById("send-btn").onclick = async () => {
    try {
      const title = document.getElementById("f-title").value.trim();
      const body = document.getElementById("f-body").value.trim();
      if (!title || !body) {
        alert("Please fill in both title and message.");
        return;
      }
      await addDoc(collection(db, "notifications"), { title, body, createdAt: serverTimestamp() });
      toast("Notification sent");
      render(outlet, toast);
    } catch (err) {
      console.error(err);
      alert("Could not send: " + (err && err.message ? err.message : err));
    }
  };
}
