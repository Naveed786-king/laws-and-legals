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


def insert_into_block(path: Path, block_start_pattern: str, line_to_insert: str, label: str, create_if_missing: bool = False):
    """Inserts `line_to_insert` right after the opening `{` of the first
    block whose header matches block_start_pattern. Robust to whatever
    already exists inside the block. If no such block exists and
    create_if_missing is True, appends a brand new block at end of file."""
    text = path.read_text()
    m = re.search(block_start_pattern, text)
    if not m:
        if create_if_missing:
            block_name = block_start_pattern.split(r"\s*\{")[0]
            new_text = text.rstrip() + f"\n\n{block_name} {{\n{line_to_insert}\n}}\n"
            path.write_text(new_text)
            print(f"OK: created new {block_name} block with {label} in {path}")
            return
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
    insert_into_block(app_gradle, r"dependencies\s*\{", deps_lines, "Firebase dependencies", create_if_missing=True)

    # ---- Bump Kotlin Gradle plugin version ----
    # Firebase's newer native libraries (play-services-measurement, pulled in
    # via firebase-analytics) are compiled with Kotlin metadata newer than
    # Flutter's default template's Kotlin plugin version, causing a hard
    # compileDebugKotlin failure. Bump to a version compatible with recent
    # Firebase BoM releases.
    replace_exactly_one(
        settings_gradle,
        r'(id\(?\s*"org\.jetbrains\.kotlin\.android"\s*\)?\s+version\s+)["\'][^"\']*["\']',
        r'\g<1>"2.1.0"',
        "Kotlin plugin version bump",
    )

    # ---- Relocate MainActivity to match the new package exactly ----
    # `flutter create --org com.lawandlegal --project-name laws_and_legals`
    # puts MainActivity.kt under com/lawandlegal/laws_and_legals/ with that
    # full package statement. Since applicationId/namespace were just
    # overridden to the shorter "com.lawandlegal" (no suffix) above, the
    # AndroidManifest's ".MainActivity" now resolves against the new
    # namespace and can no longer find the class at its old package/path -
    # the app installs but the launcher can't resolve any activity to open,
    # so tapping the icon does nothing at all (no crash, no error, nothing).
    kotlin_root = Path("android/app/src/main/kotlin")
    main_activity_candidates = list(kotlin_root.rglob("MainActivity.kt"))
    if not main_activity_candidates:
        raise SystemExit(f"ERROR: no MainActivity.kt found under {kotlin_root}")
    if len(main_activity_candidates) > 1:
        raise SystemExit(f"ERROR: multiple MainActivity.kt found: {main_activity_candidates}")
    old_main_activity = main_activity_candidates[0]

    new_dir = kotlin_root / Path(PACKAGE_NAME.replace(".", "/"))
    new_main_activity = new_dir / "MainActivity.kt"

    text = old_main_activity.read_text()
    text, count = re.subn(r'^package\s+[\w.]+', f'package {PACKAGE_NAME}', text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise SystemExit(f"ERROR: could not find/replace package statement in {old_main_activity}")

    new_dir.mkdir(parents=True, exist_ok=True)
    new_main_activity.write_text(text)
    print(f"OK: wrote {new_main_activity} with package {PACKAGE_NAME}")

    if old_main_activity != new_main_activity:
        old_main_activity.unlink()
        # Clean up now-empty parent directories left behind (e.g. the old
        # .../com/lawandlegal/laws_and_legals/ folder).
        parent = old_main_activity.parent
        while parent != kotlin_root and not any(parent.iterdir()):
            empty_dir = parent
            parent = parent.parent
            empty_dir.rmdir()
        print(f"OK: removed stale {old_main_activity}")

    # ---- Fix the generated smoke test (references a template class name
    # that doesn't exist in this project) ----
    test_file = Path("test/widget_test.dart")
    if test_file.is_file():
        test_file.write_text(
            "import 'package:flutter_test/flutter_test.dart';\n"
            "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import 'package:laws_and_legals/main.dart';\n\n"
            "void main() {\n"
            "  testWidgets('App builds without crashing', (tester) async {\n"
            "    await tester.pumpWidget(\n"
            "      const ProviderScope(child: LawsAndLegalsApp()),\n"
            "    );\n"
            "    expect(find.byType(LawsAndLegalsApp), findsOneWidget);\n"
            "  });\n"
            "}\n"
        )
        print(f"OK: replaced {test_file} with a working smoke test")

    print("\n=== Android platform folder patched successfully ===")


if __name__ == "__main__":
    main()
