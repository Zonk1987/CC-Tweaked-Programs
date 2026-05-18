import os
import re
import sys
import urllib.parse
import subprocess
import hashlib

def main():
    version_file = "version.txt"
    if not os.path.exists(version_file):
        print("Error: version.txt not found!")
        sys.exit(1)

    with open(version_file, "r") as f:
        base_version = f.read().strip()

    # Get GitHub Action variables or default to local testing values
    run_number = os.environ.get("GITHUB_RUN_NUMBER", "000")
    run_number = run_number.zfill(3)

    branch_name = os.environ.get("GITHUB_REF_NAME", "dev")
    if branch_name not in ["main", "dev"]:
        branch_name = "dev"

    full_version = f"v{base_version}.{run_number}-{branch_name}"
    print(f"Setting version to: {full_version}")

    # Get changed files from Git
    changed_files = None
    try:
        output = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1", "HEAD"], text=True)
        changed_files = [line.strip() for line in output.strip().split('\n') if line.strip()]
        print(f"Changed files in this commit: {changed_files}")
    except Exception as e:
        print(f"Warning: Could not determine changed files via Git diff, assuming all changed. ({e})")
        changed_files = None

    core_changed = False
    if changed_files is not None:
        for f in changed_files:
            # Clean paths for Windows/Linux consistency
            clean_f = f.replace('\\', '/')
            if clean_f.startswith("lib/core/") or clean_f == "manifest.lua":
                core_changed = True
                break

    # 1. Update version selectively in startup.lua files
    for root, dirs, files in os.walk("."):
        if ".git" in root or ".agents" in root:
            continue
        
        if "startup.lua" in files:
            app_dir = os.path.normpath(root).replace('\\', '/')
            if app_dir == ".": 
                continue # Skip root if there's a startup.lua there
            
            # Determine if this specific app needs a version bump
            needs_bump = False
            if changed_files is None or core_changed:
                needs_bump = True
            else:
                for f in changed_files:
                    clean_f = f.replace('\\', '/')
                    if clean_f.startswith(app_dir + "/"):
                        needs_bump = True
                        break
            
            if needs_bump:
                # Scan all .lua files in this app directory for version placeholders
                for app_root, app_dirs, app_files in os.walk(app_dir):
                    for file in app_files:
                        if file.endswith(".lua"):
                            path = os.path.join(app_root, file)
                            with open(path, "r", encoding="utf-8") as f:
                                content = f.read()
                            
                            # Only write if a placeholder or an old version string exists
                            if "v{{VERSION}}" in content or re.search(r'v\d+\.\d+\.\d+-(main|dev)', content):
                                content = re.sub(r'v\{\{VERSION\}\}', full_version, content)
                                content = re.sub(r'v\d+\.\d+\.\d+-(main|dev)', full_version, content)

                                with open(path, "w", encoding="utf-8") as f:
                                    f.write(content)
                print(f"BUMPED version for: {app_dir}")
            else:
                print(f"SKIPPED version bump for: {app_dir} (No changes)")

    # 2. Update sizeBytes and hash in manifest.lua
    manifest_path = "manifest.lua"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Regex pattern supporting both single-line and multiline files
        pattern = r'(?s)\{\s*source\s*=\s*"([^"]+)"\s*,\s*target\s*=\s*"([^"]+)"\s*,\s*sizeBytes\s*=\s*(-?\d+)\s*,\s*hash\s*=\s*"([0-9a-fA-F]{64})"\s*,?\s*\}'
        
        def repl(match):
            block = match.group(0)
            src = match.group(1)
            # Clean up Windows backslashes if running locally
            src = src.replace('\\', '/')
            
            # The manifest contains URL-encoded paths (e.g. %20 for spaces)
            local_path = urllib.parse.unquote(src)
            
            if os.path.exists(local_path):
                # Read file as binary and normalize CRLF to LF in memory
                with open(local_path, "rb") as bf:
                    content = bf.read()
                
                try:
                    text = content.decode('utf-8')
                    normalized = text.replace('\r\n', '\n')
                    normalized_bytes = normalized.encode('utf-8')
                except UnicodeDecodeError:
                    normalized_bytes = content # Keep binary as-is if not UTF-8 text
                
                size = len(normalized_bytes)
                file_hash = hashlib.sha256(normalized_bytes).hexdigest()
                
                # Update sizeBytes and hash inside the matched block
                block = re.sub(r'sizeBytes\s*=\s*-?\d+', f'sizeBytes = {size}', block)
                block = re.sub(r'hash\s*=\s*"[0-9a-fA-F]{64}"', f'hash = "{file_hash}"', block)
            else:
                print(f"Warning: Manifest source file not found: {local_path}")
            return block

        updated_content = re.sub(pattern, repl, content)
        
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(updated_content)
        print("Manifest file sizes and hashes updated successfully.")


if __name__ == "__main__":
    main()
