import {
  auth, onAuthStateChanged, signInWithEmailAndPassword, signOut
} from "./firebase-init.js";
import { toast } from "./ui.js";

// Lazy-loaded per route instead of all six up front - cuts initial load
// time since only the page you're actually viewing gets fetched/parsed.
const routeLoaders = {
  posts: () => import("./pages/posts.js"),
  banners: () => import("./pages/banners.js"),
  pages: () => import("./pages/pages-cms.js"),
  sections: () => import("./pages/sections.js"),
  theme: () => import("./pages/theme.js"),
  splash: () => import("./pages/splash.js"),
};

const loginScreen = document.getElementById("login-screen");
const appShell = document.getElementById("app-shell");
const outlet = document.getElementById("page-outlet");

// ---------- Auth gate ----------
document.getElementById("login-form").addEventListener("submit", async (e) => {
  e.preventDefault();
  const email = document.getElementById("login-email").value.trim();
  const password = document.getElementById("login-password").value;
  const errorEl = document.getElementById("login-error");
  errorEl.textContent = "";
  try {
    await signInWithEmailAndPassword(auth, email, password);
  } catch (err) {
    errorEl.textContent = "Sign in failed. Check your email/password.";
  }
});

document.getElementById("logout-link").addEventListener("click", async (e) => {
  e.preventDefault();
  await signOut(auth);
});

onAuthStateChanged(auth, (user) => {
  if (user) {
    loginScreen.classList.add("hidden");
    appShell.classList.remove("hidden");
    handleRoute();
  } else {
    loginScreen.classList.remove("hidden");
    appShell.classList.add("hidden");
  }
});

// ---------- Hash router ----------
function currentRouteName() {
  const hash = window.location.hash.replace(/^#\//, "");
  return routeLoaders[hash] ? hash : "posts";
}

async function handleRoute() {
  const routeName = currentRouteName();
  document.querySelectorAll("#nav-links a").forEach((a) => {
    a.classList.toggle("active", a.dataset.route === routeName);
  });
  outlet.innerHTML = '<p style="color:#5C6066;">Loading...</p>';
  try {
    const page = await routeLoaders[routeName]();
    await page.render(outlet, toast);
  } catch (err) {
    console.error(err);
    outlet.innerHTML = `
      <div class="card">
        <h3 style="color:#B3261E;">Couldn't load this page</h3>
        <p>${(err && err.message) ? err.message : "Unknown error"}</p>
        <p style="color:#5C6066;font-size:13px;">
          If this says "permission-denied", the Firestore security rules
          haven't been deployed yet, or you're not signed in as an admin user.
        </p>
        <button class="btn-secondary" onclick="location.reload()">Retry</button>
      </div>`;
  }
}

window.addEventListener("hashchange", handleRoute);

if (!window.location.hash) window.location.hash = "#/posts";
