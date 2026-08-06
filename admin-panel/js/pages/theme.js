import { db, doc, getDoc, setDoc } from "../firebase-init.js";

const DEFAULTS = {
  primaryColor: "#0B1F3A",
  secondaryColor: "#C79A3B",
  accentColor: "#7A1F2B",
  backgroundColor: "#F7F7F5",
};

export async function render(outlet, toast) {
  const snap = await getDoc(doc(db, "theme", "config"));
  const theme = snap.exists() ? { ...DEFAULTS, ...snap.data() } : DEFAULTS;

  outlet.innerHTML = `
    <h1>Theme &amp; Colors</h1>
    <p style="color:#5C6066;">These colors control the Android app's brand palette.
    Changes take effect the next time the app fetches config (no rebuild needed).</p>
    <div class="card">
      ${Object.entries(DEFAULTS).map(([key]) => `
        <label class="field-label">${key.replace(/([A-Z])/g, " $1")}</label>
        <div class="row">
          <input type="color" id="c-${key}" value="${theme[key]}" style="width:60px;padding:2px;" />
          <input type="text" id="t-${key}" value="${theme[key]}" style="flex:1;" />
        </div>
      `).join("")}
      <button class="btn-primary" id="save-theme-btn" style="width:auto;margin-top:8px;">Save Theme</button>
    </div>
  `;

  Object.keys(DEFAULTS).forEach((key) => {
    const colorInput = document.getElementById(`c-${key}`);
    const textInput = document.getElementById(`t-${key}`);
    colorInput.oninput = () => { textInput.value = colorInput.value; };
    textInput.oninput = () => { if (/^#[0-9a-fA-F]{6}$/.test(textInput.value)) colorInput.value = textInput.value; };
  });

  document.getElementById("save-theme-btn").onclick = async () => {
    try {
      const payload = {};
      Object.keys(DEFAULTS).forEach((key) => {
        payload[key] = document.getElementById(`t-${key}`).value;
      });
      await setDoc(doc(db, "theme", "config"), payload);
      toast("Theme saved");
    } catch (err) {
      console.error(err);
      alert("Could not save: " + (err && err.message ? err.message : err));
    }
  };
}
