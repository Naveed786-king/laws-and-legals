import {
  auth, onAuthStateChanged, signInWithEmailAndPassword, signOut
} from "./firebase-init.js";
import { toast } from "./ui.js";

import * as PostsPage from "./pages/posts.js";
import * as BannersPage from "./pages/banners.js";
import * as PagesPage from "./pages/pages-cms.js";
import * as SectionsPage from "./pages/sections.js";
import * as ThemePage from "./pages/theme.js";
import * as SplashPage from "./pages/splash.js";

const routes = {
  posts: PostsPage,
  banners: BannersPage,
  pages: PagesPage,
  sections: SectionsPage,
  theme: ThemePage,
  splash: SplashPage,
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
  return routes[hash] ? hash : "posts";
}

function handleRoute() {
  const routeName = currentRouteName();
  document.querySelectorAll("#nav-links a").forEach((a) => {
    a.classList.toggle("active", a.dataset.route === routeName);
  });
  outlet.innerHTML = "Loading...";
  routes[routeName].render(outlet, toast);
}

window.addEventListener("hashchange", handleRoute);

if (!window.location.hash) window.location.hash = "#/posts";
