""" This is not a module. """

import fnmatch
import os
import shutil

SRC = "../"
DEST = "../dist/"

EXCLUDE_PATTERNS = [
    # Itself
    "*.py",
    # VSCode related files
    "*.code-workspace",
    ".luarc.json",
    # Github repo files
    ".gitignore",
    "TODO.md",
    "README.md",
    "CHANGELOG.md",
    "SANDBOX_OPTIONS.md",
    # Blender files
    "*.blend1",
    # Lua workshop libs
    "ItemTweaker_Core.lua",
    "MF_ISMoodle.lua",
    "MF_MoodleScale.lua",
]
EXCLUDED_DIRS = [".git", ".vscode", "dist", "scripts", "blender"]

print("Generating workshop files...")

if not os.path.exists(DEST):
    os.makedirs(DEST)

for dirpath, dirnames, filenames in os.walk(SRC):
    for excluded_dir in EXCLUDED_DIRS:
        if excluded_dir in dirpath:
            print("Matched directory\t", excluded_dir)
            break
    else:  # No excluded directory found
        for filename in filenames:
            for pattern in EXCLUDE_PATTERNS:
                if fnmatch.fnmatch(filename, pattern):
                    print("Matched pattern\t", pattern)
                    break
            else:
                src_file = os.path.join(dirpath, filename)
                dest_file = os.path.join(DEST, src_file[3:])
                os.makedirs(os.path.dirname(dest_file), exist_ok=True)
                shutil.copy2(src_file, dest_file)

print("Workshop files generated successfully.")
