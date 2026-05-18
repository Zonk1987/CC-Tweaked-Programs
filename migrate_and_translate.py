import os
import shutil
import sys
import subprocess

# Auto-install deep-translator if not present
try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("[*] Installing required library 'deep-translator'...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "deep-translator"])
    from deep_translator import GoogleTranslator

# Configuration
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECTS = [
    "CC Developer Suite",
    "Create Mechanical Crafter Automation",
    "Mekanism Portal Dialer Hub",
    "Mekanism Portal Dialer Recall Sender",
    "Powah Energizing Orb Automation"
]
LANGUAGES = ["de", "es", "fr", "pt-BR", "zh-CN", "ja", "ko", "ru"]

# Localized disclaimers for each language
DISCLAIMERS = {
    "de": "> [!WARNING]\n> 🇩🇪 **de / Deutsch**\n> \n> ⚠️ **Hinweis**: Diese README wurde automatisch von einer KI (Antigravity) übersetzt und kann Übersetzungsfehler oder Ungenauigkeiten enthalten. Die genaueste und aktuellste Dokumentation findest du in der englischen Original-[README.md]({eng_path}).\n\n",
    "es": "> [!WARNING]\n> 🇪🇸 **es / Español**\n> \n> ⚠️ **Nota**: Este README fue traducido automáticamente por una IA (Antigravity) y puede contener errores o imprecisiones. Para obtener la documentación más precisa y actualizada, consulta el [README.md]({eng_path}) original en inglés.\n\n",
    "fr": "> [!WARNING]\n> 🇫🇷 **fr / Français**\n> \n> ⚠️ **Remarque**: Ce fichier README a été traduit automatiquement par une IA (Antigravity) et peut contenir des erreurs de traduction ou des inexactitudes. Pour obtenir la documentation la plus précise et à jour, veuillez vous référer au [README.md]({eng_path}) original en anglais.\n\n",
    "pt-BR": "> [!WARNING]\n> 🇧🇷 **pt-BR / Português (Brasil)**\n> \n> ⚠️ **Nota**: Este README foi traduzido automaticamente por uma IA (Antigravity) e pode conter erros de tradução ou imprecisões. Para a documentação mais precisa e atualizada, consulte o [README.md]({eng_path}) original en inglês.\n\n",
    "zh-CN": "> [!WARNING]\n> 🇨🇳 **zh-CN / 简体中文**\n> \n> ⚠️ **注意**：本 README 由 AI 助手 (Antigravity) 自动翻译，可能包含翻译错误或不准确之处。如需最准确和最新的文档，请参阅英文原版 [README.md]({eng_path})。\n\n",
    "ja": "> [!WARNING]\n> 🇯🇵 **ja / 日本語**\n> \n> ⚠️ **注意**: このREADMEはAIアシスタント（Antigravity）によって自動翻訳されたものであり、翻訳エラーや不正確な内容が含まれている可能性があります。最も正確で最新のドキュメントについては、オリジナルの英語版 [README.md]({eng_path}) を参照してください。\n\n",
    "ko": "> [!WARNING]\n> 🇰🇷 **ko / 한국어**\n> \n> ⚠️ **참고**: 이 README는 AI 비서(Antigravity)에 의해 자동 번역되었으며, 번역 오류나 부정확한 내용이 포함되어 있을 수 있습니다. 가장 정확하고 최신 문서가 필요한 경우 영문 원본 [README.md]({eng_path})를 참조하십시오.\n\n",
    "ru": "> [!WARNING]\n> 🇷🇺 **ru / Русский**\n> \n> ⚠️ **Примечание**: Этот файл README был автоматически переведен ИИ-ассистентом (Antigravity) и может содержать ошибки перевода или неточности. Для получения наиболее точной и актуальной документации, пожалуйста, обратитесь к оригинальному [README.md]({eng_path}) на английском языке.\n\n"
}

IMAGE_MAPPINGS = {
    "Create Mechanical Crafter Automation": ("images/setup.png", "crafter-setup.png"),
    "Mekanism Portal Dialer Hub": ("images/setup.png", "hub-setup.png"),
    "Powah Energizing Orb Automation": ("images/setup.png", "orb-setup.png")
}

def translate_text(text, dest_lang):
    """Translate a text chunk safely using deep-translator."""
    if not text.strip():
        return text
    try:
        # Convert pt-BR / zh-CN to Google Translate equivalents
        g_lang = dest_lang
        if dest_lang == "pt-BR":
            g_lang = "pt"
        elif dest_lang == "zh-CN":
            g_lang = "zh-CN"
            
        translator = GoogleTranslator(source='en', target=g_lang)
        return translator.translate(text)
    except Exception as e:
        print(f"    [!] Translation warning: {e}")
        return text

def translate_markdown(content, dest_lang, is_project=True):
    """Translate a markdown file line-by-line while preserving structural elements."""
    lines = content.splitlines()
    translated_lines = []
    in_code_block = False
    
    for line in lines:
        stripped = line.strip()
        
        # 1. Preserve code block toggles
        if stripped.startswith("```"):
            in_code_block = not in_code_block
            translated_lines.append(line)
            continue
            
        # 2. If in code block or empty, preserve as-is
        if in_code_block or not stripped:
            translated_lines.append(line)
            continue
            
        # 3. Preserve specific markdown patterns
        if stripped.startswith("![") or stripped.startswith("["):
            # Image tags and top-level HTML tags
            translated_lines.append(line)
            continue
            
        if stripped.startswith("---") or stripped.startswith("==="):
            translated_lines.append(line)
            continue
            
        # 4. Handle Table Rows
        if stripped.startswith("|") and stripped.endswith("|"):
            cells = line.split("|")
            translated_cells = []
            for i, cell in enumerate(cells):
                if i == 0 or i == len(cells) - 1:
                    translated_cells.append("")
                elif cell.strip().startswith("---") or cell.strip().startswith(":---"):
                    translated_cells.append(cell)
                else:
                    # Translate table cell
                    translated_cells.append(" " + translate_text(cell.strip(), dest_lang) + " ")
            translated_lines.append("|".join(translated_cells))
            continue
            
        # 5. Handle Markdown Headers
        if stripped.startswith("#"):
            header_level = len(stripped) - len(stripped.lstrip('#'))
            header_text = stripped.lstrip('#').strip()
            translated_text_val = translate_text(header_text, dest_lang)
            translated_lines.append("#" * header_level + " " + translated_text_val)
            continue
            
        # 6. Handle Bullet Lists & Blockquotes
        prefix = ""
        if stripped.startswith("- "):
            prefix = "- "
            line_content = stripped[2:]
        elif stripped.startswith("* "):
            prefix = "* "
            line_content = stripped[2:]
        elif stripped.startswith("> "):
            prefix = "> "
            line_content = stripped[2:]
        else:
            line_content = line
            
        translated_val = translate_text(line_content, dest_lang)
        translated_lines.append(prefix + translated_val)
        
    return "\n".join(translated_lines)

def process_project(project):
    print(f"\n[*] Processing Project: {project}")
    project_path = os.path.join(BASE_DIR, project)
    eng_readme_path = os.path.join(project_path, "README.md")
    
    if not os.path.exists(eng_readme_path):
        print(f"  [!] English README.md not found for {project}. Skipping.")
        return
        
    # Read original English README
    with open(eng_readme_path, "r", encoding="utf-8") as f:
        eng_content = f.read()
        
    # 1. Handle Images
    if project in IMAGE_MAPPINGS:
        orig_rel, new_name = IMAGE_MAPPINGS[project]
        orig_img_path = os.path.join(project_path, orig_rel)
        target_img_dir = os.path.join(project_path, "docs", "assets", "images")
        target_img_path = os.path.join(target_img_dir, new_name)
        
        if os.path.exists(orig_img_path):
            os.makedirs(target_img_dir, exist_ok=True)
            shutil.copy2(orig_img_path, target_img_path)
            print(f"  [->] Copied setup.png to docs/assets/images/{new_name}")
            
            # Clean up old images folder if empty
            old_img_dir = os.path.dirname(orig_img_path)
            if os.path.exists(old_img_dir) and not os.listdir(old_img_dir):
                shutil.rmtree(old_img_dir)
                print("  [-] Removed empty original images directory")
        else:
            print(f"  [i] Image already migrated or not found at {orig_rel}")
            
    # 2. Generate Translations
    for lang in LANGUAGES:
        print(f"  [+] Translating to {lang}...")
        lang_dir = os.path.join(project_path, "docs", "i18n", lang)
        os.makedirs(lang_dir, exist_ok=True)
        
        # Prepend disclaimer
        disclaimer = DISCLAIMERS[lang].format(eng_path="../../../README.md")
        
        # Translate content
        translated_content = translate_markdown(eng_content, lang, is_project=True)
        
        # Update image link in translated version
        if project in IMAGE_MAPPINGS:
            _, new_name = IMAGE_MAPPINGS[project]
            # Replace absolute or project-relative link with the localized relative link
            translated_content = translated_content.replace(
                f"docs/assets/images/{new_name}",
                f"../../assets/images/{new_name}"
            )
            
        full_translated_file = disclaimer + translated_content
        target_readme = os.path.join(lang_dir, "README.md")
        
        with open(target_readme, "w", encoding="utf-8") as f:
            f.write(full_translated_file)
            
        print(f"    [✓] Wrote docs/i18n/{lang}/README.md")

def process_root():
    print(f"\n[*] Processing Repository Root")
    eng_readme_path = os.path.join(BASE_DIR, "README.md")
    
    if not os.path.exists(eng_readme_path):
        print("  [!] Root English README.md not found. Skipping.")
        return
        
    with open(eng_readme_path, "r", encoding="utf-8") as f:
        eng_content = f.read()
        
    for lang in LANGUAGES:
        print(f"  [+] Translating Root to {lang}...")
        lang_dir = os.path.join(BASE_DIR, "docs", "i18n", lang)
        os.makedirs(lang_dir, exist_ok=True)
        
        disclaimer = DISCLAIMERS[lang].format(eng_path="../../../README.md")
        translated_content = translate_markdown(eng_content, lang, is_project=False)
        
        full_translated_file = disclaimer + translated_content
        target_readme = os.path.join(lang_dir, "README.md")
        
        with open(target_readme, "w", encoding="utf-8") as f:
            f.write(full_translated_file)
            
        print(f"    [✓] Wrote docs/i18n/{lang}/README.md")

if __name__ == "__main__":
    print("=== CC:Tweaked Documentation Migration & AI Translation Tool ===")
    
    # 1. Process all projects
    for project in PROJECTS:
        process_project(project)
        
    # 2. Process root
    process_root()
    
    print("\n=== All Projects and Root successfully translated and migrated! ===")
