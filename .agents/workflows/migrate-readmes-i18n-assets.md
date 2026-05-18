---
description: Migrate README files and documentation assets into a clean i18n/docs structure for CC-Tweaked-Programs.
---

# Migrate README files and documentation assets

You are working in the repository `Zonk1987/CC-Tweaked-Programs`.

## Goal

- Keep exactly one English `README.md` in the repository root.
- Keep exactly one English `README.md` in each project root directory.
- Move all translated README files into `docs/i18n/<lang>/README.md`.
- Move all project translated README files into `<project>/docs/i18n/<lang>/README.md`.
- Move documentation images into `docs/assets/images/` or `<project>/docs/assets/images/`.
- Rename images to stable, lowercase, kebab-case names.
- Update Markdown links after moving README files and images.
- Support only these languages:

```txt
en
de
es
fr
pt-BR
zh-CN
ja
ko
ru
```

## Repository-specific project roots

Treat these directories as project roots:

```txt
CC Developer Suite
Create Mechanical Crafter Automation
Mekanism Portal Dialer Hub
Mekanism Portal Dialer Recall Sender
Powah Energizing Orb Automation
```

Do not treat these as project roots:

```txt
.agents
.github
.githooks
lib
docs
```

## Safety requirements

Before changing files:

1. Never delete README files or images.
2. If a destination file already exists, do not overwrite it. Instead create a conflict-safe filename and report it.
3. Preserve the English root `README.md`.
4. Preserve each English project-root `README.md`.
5. Do not move Lua source files.
6. Do not change `manifest.lua`, `install.lua`, `version.txt`, or files under `lib/core`.

## Desired final repository structure

Repository root:

```txt
README.md
docs/
  i18n/
    de/
      README.md
    es/
      README.md
    fr/
      README.md
    pt-BR/
      README.md
    zh-CN/
      README.md
    ja/
      README.md
    ko/
      README.md
    ru/
      README.md
  assets/
    images/
```

Each project root:

```txt
<Project Name>/
  README.md
  docs/
    i18n/
      de/
        README.md
      es/
        README.md
      fr/
        README.md
      pt-BR/
        README.md
      zh-CN/
        README.md
      ja/
        README.md
      ko/
        README.md
      ru/
        README.md
    assets/
      images/
```

## Final report

Prepare a concise report with:

1. Branch name.
2. Number of moved README files.
3. Number of moved image files.
4. New root documentation structure.
5. New per-project documentation structure.
6. Any conflicts created with `.conflict-N`.
7. Validation results.
