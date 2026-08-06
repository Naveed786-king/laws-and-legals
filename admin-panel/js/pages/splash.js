import { db, doc, getDoc, setDoc } from "../firebase-init.js";

export async function render(outlet, toast) {
  const snap = await getDoc(doc(db, "splash", "config"));
  const splash = snap.exists() ? snap.data() : {
    logoUrl: "", backgroundColor: "#0B1F3A", durationMs: 1800, text: "Hindi Legal News",
  };

  outlet.innerHTML = `
    <h1>Splash Screen</h1>
    <p style="color:#5C6066;">Controls the app's launch screen: logo, background, duration, and tagline text.</p>
    <div class="card">
      <label class="field-label">Logo URL</label>
      <input id="f-logo-url" value="${splash.logoUrl || ""}" placeholder="https://... (paste any image URL)" />
      ${splash.logoUrl ? `<img class="thumb" src="${splash.logoUrl}" style="width:80px;height:80px;margin-top:8px;" onerror="this.style.display='none'" />` : ""}
      <label class="field-label">Background Color</label>
      <input type="color" id="f-bg" value="${splash.backgroundColor}" style="width:60px;padding:2px;" />
      <label class="field-label">Duration (milliseconds)</label>
      <input type="number" id="f-duration" value="${splash.durationMs}" />
      <label class="field-label">Tagline Text</label>
      <input id="f-text" value="${splash.text || ""}" />
      <button class="btn-primary" id="save-splash-btn" style="width:auto;margin-top:8px;">Save</button>
    </div>
  `;

  document.getElementById("save-splash-btn").onclick = async () => {
    try {
      const logoUrl = document.getElementById("f-logo-url").value.trim();

      await setDoc(doc(db, "splash", "config"), {
        logoUrl,
        backgroundColor: document.getElementById("f-bg").value,
        durationMs: Number(document.getElementById("f-duration").value) || 1800,
        text: document.getElementById("f-text").value.trim(),
      });
      toast("Splash config saved");
    } catch (err) {
      console.error(err);
      alert("Could not save: " + (err && err.message ? err.message : err));
    }
  };
}
