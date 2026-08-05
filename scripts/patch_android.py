#!/usr/bin/env python3
"""
Patches the Android platform folder that `flutter create` just generated:
- Sets applicationId/namespace to exactly "com.lawandlegal" (Firebase's
  registered package name), regardless of whether Flutter generated Groovy
  (.gradle) or Kotlin DSL (.gradle.kts) files, and regardless of exact
  surrounding template text (which changes across Flutter SDK versions).
- Wires in the Google Services Gradle plugin + Firebase dependencies.
- Copies the committed google-services.json into place.

Designed to fail loudly with a clear message if a pattern isn't found,
instead of silently doing nothing (which is what the old sed-based
approach did and why this script exists).
"""
import re
import shutil
import sys
from pathlib import Path

ANDROID = Path("android")
PACKAGE_NAME = "com.lawandlegal"


def find_one(candidates):
    for c in candidates:
        p = Path(c)
        if p.is_file():
            return p
    raise SystemExit(f"ERROR: none of these files exist: {candidates}")


def replace_exactly_one(path: Path, pattern: str, replacement: str, label: str):
    text = path.read_text()
    new_text, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        print(f"--- {path} content ---")
        print(text)
        raise SystemExit(f"ERROR: expected exactly 1 match for {label} in {path}, found {count}")
    path.write_text(new_text)
    print(f"OK: patched {label} in {path}")


def insert_into_block(path: Path, block_start_pattern: str, line_to_insert: str, label: str):
    """Inserts `line_to_insert` right after the opening `{` of the first
    block whose header matches block_start_pattern. Robust to whatever
    already exists inside the block."""
    text = path.read_text()
    m = re.search(block_start_pattern, text)
    if not m:
        print(f"--- {path} content ---")
        print(text)
        raise SystemExit(f"ERROR: could not find block '{block_start_pattern}' in {path} for {label}")
    insert_at = m.end()
    new_text = text[:insert_at] + "\n" + line_to_insert + text[insert_at:]
    path.write_text(new_text)
    print(f"OK: inserted {label} into {path}")


def main():
    app_gradle = find_one(["android/app/build.gradle.kts", "android/app/build.gradle"])
    settings_gradle = find_one(["android/settings.gradle.kts", "android/settings.gradle"])
    manifest = Path("android/app/src/main/AndroidManifest.xml")
    is_kts = app_gradle.suffix == ".kts"

    # ---- applicationId / namespace ----
    replace_exactly_one(
        app_gradle,
        r'applicationId\s*=?\s*["\'][^"\']*["\']',
        f'applicationId = "{PACKAGE_NAME}"' if is_kts else f'applicationId "{PACKAGE_NAME}"',
        "applicationId",
    )
    replace_exactly_one(
        app_gradle,
        r'namespace\s*=?\s*["\'][^"\']*["\']',
        f'namespace = "{PACKAGE_NAME}"' if is_kts else f'namespace "{PACKAGE_NAME}"',
        "namespace",
    )

    # ---- app label ----
    if manifest.is_file():
        text = manifest.read_text()
        new_text = re.sub(r'android:label="[^"]*"', 'android:label="Laws And Legals"', text, count=1)
        manifest.write_text(new_text)
        print(f"OK: patched app label in {manifest}")

    # ---- google-services.json ----
    shutil.copy("firebase-config/google-services.json", "android/app/google-services.json")
    print("OK: copied google-services.json")

    # ---- Google Services Gradle plugin: settings-level plugin declaration ----
    gservices_settings_line = (
        '    id("com.google.gms.google-services") version "4.4.2" apply false'
        if settings_gradle.suffix == ".kts"
        else '    id "com.google.gms.google-services" version "4.4.2" apply false'
    )
    insert_into_block(settings_gradle, r"plugins\s*\{", gservices_settings_line, "google-services plugin (settings)")

    # ---- Google Services Gradle plugin: app-level apply ----
    gservices_app_line = (
        '    id("com.google.gms.google-services")' if is_kts else '    id "com.google.gms.google-services"'
    )
    insert_into_block(app_gradle, r"plugins\s*\{", gservices_app_line, "google-services plugin (app)")

    # ---- Firebase dependencies ----
    if is_kts:
        deps_lines = (
            '    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))\n'
            '    implementation("com.google.firebase:firebase-analytics")\n'
            '    implementation("com.google.firebase:firebase-messaging")'
        )
    else:
        deps_lines = (
            "    implementation platform('com.google.firebase:firebase-bom:33.5.1')\n"
            "    implementation 'com.google.firebase:firebase-analytics'\n"
            "    implementation 'com.google.firebase:firebase-messaging'"
        )
    insert_into_block(app_gradle, r"dependencies\s*\{", deps_lines, "Firebase dependencies")

    print("\n=== Android platform folder patched successfully ===")


if __name__ == "__main__":
    main()
