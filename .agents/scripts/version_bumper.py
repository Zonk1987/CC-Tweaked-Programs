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

    # 2. Update sizeBytes in manifest.lua
    manifest_path = "manifest.lua"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            lines = f.readlines()
        
        new_lines = []
        for line in lines:
            # Find lines containing source files
            if 'source =' in line and 'target =' in line:
                m = re.search(r'source\s*=\s*"([^"]+)"', line)
                if m:
                    src = m.group(1)
                    # Clean up Windows backslashes if running locally
                    src = src.replace('\\', '/')
                    
                    # The manifest contains URL-encoded paths (e.g. %20 for spaces)
                    local_path = urllib.parse.unquote(src)
                    
                    if os.path.exists(local_path):
                        size = os.path.getsize(local_path)
                        
                        # Calculate SHA256 hash
                        sha256_hash = hashlib.sha256()
                        with open(local_path, "rb") as bf:
                            for byte_block in iter(lambda: bf.read(4096), b""):
                                sha256_hash.update(byte_block)
                        file_hash = sha256_hash.hexdigest()
                        
                        # Remove existing sizeBytes and hash if they exist
                        line = re.sub(r',\s*sizeBytes\s*=\s*\d+', '', line)
                        line = re.sub(r',\s*hash\s*=\s*"[^"]+"', '', line)
                        
                        # Inject new sizeBytes and hash right before the closing brace
                        line = line.replace(' }', f', sizeBytes = {size}, hash = "{file_hash}" }}')
                    else:
                        print(f"Warning: Manifest source file not found: {local_path}")
            new_lines.append(line)
            
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        print("Manifest file sizes updated successfully.")

if __name__ == "__main__":
    main()
