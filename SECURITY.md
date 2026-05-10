# Security Policy

## Supported Versions

Only the latest version of the scripts in the `main` branch is actively maintained and receives security-related updates.

| Version | Supported |
|---|---|
| Latest (`main`) | ✅ Yes |
| Older commits | ❌ No |

---

## Scope

These scripts run inside the **ComputerCraft / CC:Tweaked** Lua sandbox within Minecraft. They are designed to:

- Read and write local files on the in-game computer (`fs` API)
- Access peripheral devices connected via Wired Modems
- Make outbound HTTP requests to **GitHub's API** and **Pastebin** (installer only)

**Out of scope:** These scripts have no access to your real file system, operating system, network credentials, or any data outside the Minecraft / CC:Tweaked sandbox.

---

## Reporting a Vulnerability

If you discover a security issue — such as:

- The installer downloading from an unexpected or unverified source
- A script that could unintentionally overwrite or delete files on the CC computer
- Any behavior that could be exploited to cause unintended side effects

Please **do not open a public GitHub Issue** for security-sensitive reports.

Instead, contact the maintainer directly:

- **GitHub**: [@Zonk1987](https://github.com/Zonk1987) — open a private [Security Advisory](https://github.com/Zonk1987/CC-Tweaked/security/advisories/new)

You can expect an acknowledgement within **72 hours** and a fix or response within **14 days** depending on severity.

---

## Security Best Practices for Users

- Always review scripts before running them with `pastebin run` or `wget run`.
- The installer (`pastebin run vYK0cPkU`) only fetches files from this repository via the GitHub API. No other domains are contacted.
- HTTP access in CC:Tweaked can be restricted per-server in `computercraft-common.toml` if needed.
