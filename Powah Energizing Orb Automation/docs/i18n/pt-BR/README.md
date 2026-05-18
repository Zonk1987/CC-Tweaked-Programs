> [!WARNING]
> 🇧🇷 **pt-BR / Portugues (Brasil)**
> 
> Nota: Este README foi traduzido automaticamente por um assistente de IA (Antigravidade) e pode conter erros de tradução ou imprecisões. Para obter a documentação mais precisa e atualizada, consulte o original em inglês [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Powah Energizing Orb Automation (CC:Ajustado)

> Sistema ComputerCraft totalmente automatizado e pronto para produção para os **Energizing Orbs** do mod **Powah**. Suporta processamento paralelo, integração AE2 avançada e compatibilidade inteligente com modpack.


---

## âœ¨ Recursos

- **Suporte Multi-Orb** — Descobre automaticamente todos os Orbs Energizantes e artesanatos conectados em paralelo.
- **Integração ME Bridge (Obrigatório)** — Usa `meBridge` de Periféricos Avançados para ler dados detalhados do padrão AE2 (entradas, saídas, quantidades).
- **Acesso direto ao provedor (opcional)** — Suporte completo para o mod **`ae2communicate`**. Quando emparelhado com o ME Bridge, ele permite filtrar receitas por **Provedores de padrões nomeados**, eliminando a necessidade de pesquisar em grandes redes.
- **Precisão e Inteligência** — Manuseio automático de multiplicadores e validação exata de ingredientes com base em ID durante a importação.
- **Compatibilidade com Modpack** — Alterne entre "Somente Powah" ou "Todos os Mods" (Tecla `M`) para suportar receitas de qualquer mod usando o Energizing Orb.
- **Recuperação Automática** — Recuperação automatizada de itens e redefinição de orbe em caso de travamento de fabricação ou falta de energia.

---

## ðŸ› ï¸ Configuração de hardware

![Ingame Setup](../../assets/images/orb-setup.png)


1. **Computador Avançado** — Necessário para o painel colorido de alta resolução.
2. **Buffer Chest** — Conecte qualquer baú (por exemplo, Diamond Chest) adjacente ao computador ou através da rede.
3. **Energizing Orbs** — Conecte todos os Orbs via **Cabos de rede** e **Modems com fio**.
4. **ME Bridge (Obrigatório):** Conecte uma **ME Bridge** à rede para permitir que o sistema leia dados detalhados do padrão.
5. **Recurso opcional de qualidade de vida (ae2communicate):**
- Instale o mod **`ae2communicate`**.
- Coloque um **Modem com fio** diretamente em uma **Interface AE2** (reconhecida como `ae2_scanner`).
- Nomeie seus provedores de padrões em seu sistema AE2 (por exemplo, "Powah Orb").
- **Benefício:** Filtra os dados do ME Bridge para mostrar apenas padrões deste provedor específico!

---

## ðŸš€ Instalação e uso

1. Baixe o arquivo install.lua do repositório
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Execute o arquivo install.lua
```bash
install.lua
```
3. Selecione **Powah Automation** no menu.
4. O sistema detecta automaticamente seus periféricos na inicialização.
5. **Importante**: Defina seus Provedores de Padrão AE2 para **"Modo de Bloqueio"** e aponte-os para o Buffer Chest.

---

## ðŸ“– Importação de receita AE2

O sistema possui um menu de importação inteligente (Tecla **`I`**):

### Cenário A: Com scanner AE2 opcional
1. Pressione **`I`**.
2. Selecione o **Provedor de padrão nomeado** do qual deseja importar.
3. Navegue pelas receitas filtradas e pressione **`ENTER`** para importar.

### Cenário B: Padrão (somente ponte ME)
1. Pressione **`I`**.
2. Navegue por todos os padrões disponíveis na rede.
3. Use **`M`** para alternar entre **Powah Only** e **All Mods**.
4. Pressione **`ENTER`** para importar.

---

## ÂŒ¨ï¸ Teclas de atalho

| Chave | Ação |
|:---:|---|
| **`R`** | **Recarregue** receitas sem reiniciar |
| **`Eu`** | **Menu Importar** (Navegar e adicionar padrões AE2) |
| **`M`** | **Mod Toggle** (dentro do menu de importação: Powah vs. All. *Disponível apenas se o mod 'ae2communicate' NÃO for usado*) |
| **`B`** | **Voltar** (dentro do menu Importar: voltar para a seleção do provedor) |
| **`X`** | **Excluir** (Remover uma receita importada do sistema) |
| **`Q`** | **Sair** (Sair do Menu Importar e retornar ao Painel) |

---

## Configuração

O sistema foi projetado para funcionar imediatamente. Se precisar de ajustes manuais, verifique `startup.lua`:
```lua
local system = PowahSystem.new({
    chestName = "left", -- Or use auto-detection variable
    recipeFile = "powah_recipes.json",
    meBridgeName = "right", -- Required for imports: ME Bridge peripheral name
    aeScannerName = "top" -- Optional: ae2communicate scanner peripheral name
})
```

---

## ðŸ›‘ Solução de problemas

| Erro | Causa e correção |
|---|---|
| `Nenhuma ponte ME encontrada!` | Verifique o status dos cabos e do modem. |
| `Scanner AE: Nenhum` | Normal se você não tiver o mod. O modo clássico será usado. |
| `Tempo limite no Orbe...` | A elaboração demorou mais de 60 anos. Itens devolvidos ao baú. Verifique a potência! |
| `Nome duplicado` | Você está tentando importar uma receita que já existe. |

---
*Desenvolvido com â¤ï¸ para Advanced Agentic Coding.*

