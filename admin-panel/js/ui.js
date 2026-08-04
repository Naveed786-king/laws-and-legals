export function toast(message, isError = false) {
  const root = document.getElementById("toast-root");
  const el = document.createElement("div");
  el.className = "toast";
  if (isError) el.style.background = "#B3261E";
  el.textContent = message;
  root.appendChild(el);
  setTimeout(() => el.remove(), 3000);
}

export function escapeHtml(str) {
  const div = document.createElement("div");
  div.textContent = str ?? "";
  return div.innerHTML;
}
