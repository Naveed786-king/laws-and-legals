import { storage, ref, uploadBytes, getDownloadURL } from "./firebase-init.js";

/**
 * Uploads a File object to Firebase Storage under the given folder and
 * returns its public download URL. Used by Posts and Banners forms.
 */
export async function uploadImage(file, folder) {
  if (!file) return null;
  const safeName = `${Date.now()}_${file.name.replace(/[^a-zA-Z0-9.]/g, "_")}`;
  const storageRef = ref(storage, `${folder}/${safeName}`);
  await uploadBytes(storageRef, file);
  return getDownloadURL(storageRef);
}
