> [!WARNING]
> 🇧🇷 **pt-BR / Portugues (Brasil)**
> 
> Nota: Este README foi traduzido automaticamente por um assistente de IA (Antigravidade) e pode conter erros de tradução ou imprecisões. Para obter a documentação mais precisa e atualizada, consulte o original em inglês [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div align="center">

# CC da Zonk: Suíte de automação ajustada 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality%20Checks)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

Uma coleção de scripts de automação de nível profissional para Minecraft **CC:Tweaked**, apresentando uma arquitetura modular **Feature-Core**, estética de UI premium e um instalador robusto baseado em manifesto.


---

## 🚀 Instalação

Execute este comando em um **Computador Avançado**:

1. Baixe o arquivo install.lua do repositório
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Execute o arquivo install.lua
```bash
install.lua
```

---

## 📦 Pacotes Disponíveis

| EU IA | Nome | Descrição | Principais recursos |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | [**Hub do discador do portal**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/pt-BR/README.md) | Discador com tela de toque premium. | UI móvel, listras de destaque, redefinição de página. |
| `mekanism_recall_sender` | [**Remetente de recuperação do portal**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/pt-BR/README.md) | Gatilho remoto sem fio. | Diagnóstico de hardware, monitoramento de status ao vivo. |
| `criar_crafter` | [**Artesanato Mecânico**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/pt-BR/README.md) | Automação de elaboração de grade. | Gravação e calibração, receitas em várias etapas. |
| `powah_orb` | [**Orbe Energizante**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/pt-BR/README.md) | Automação de elaboração paralela. | Integração ME Bridge, recuperação automática. |
| `developer_suite` | [**CC Developer Suite**](../../../CC%20Developer%20Suite/docs/i18n/pt-BR/README.md) | Kit de ferramentas de diagnóstico. | Sniffer de eventos, inspetor de periféricos. |

---

## 🏗️ Arquitetura: esqueleto de núcleo de recursos

Este repositório foi construído para oferecer manutenção e desempenho usando um esqueleto modular.

### **Módulos principais (`lib/core`)**
Utilitários genéricos são extraídos em pacotes principais ocultos para reduzir a duplicação:
- **`core.base`**: Lógica fundamental como `ConfigStore` (persistência JSON).
- **`core.peripherals`**: descoberta e empacotamento seguro de periféricos (`PeripheralScanner`).
- **`core.network`**: Protocolos de comunicação padronizados (`RednetProtocol`).
- **`core.redstone`**: Ajudantes de interação Redstone (`RedstoneController`).
- **`core.ui`**: Componentes de UI reutilizáveis ​​(`ButtonGrid`).
- **`core.inventory`**: Manipulação de estoque padronizada (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: armazenamento de receitas baseado em JSON (`RecipeStore`).

### **Resolução de Dependências**
O instalador resolve automaticamente as dependências de forma recursiva. Por exemplo, instalar `create_crafter` irá extrair automaticamente os módulos `core.inventory` e `core.redstone` necessários. Os arquivos do aplicativo são colocados no diretório raiz, enquanto as bibliotecas principais são mantidas na hierarquia `lib/core/` (acessível através de caminhos de pacote ajustados em `startup.lua`).

---

## 🛠️ Diretrizes de Desenvolvimento

### **Adicionando um novo aplicativo**
1. Crie a pasta do seu aplicativo (por exemplo, `Meu novo aplicativo`).
2. Implemente sua lógica, aproveitando os módulos `lib/core` existentes.
3. Registre seu aplicativo em `manifest.lua`.
4. Adicione dependências se você usar módulos principais.

### **Adicionando um Módulo Principal**
1. Coloque o módulo em `lib/core/<category>/ModuleName.lua`.
2. Registre-o como um pacote `hidden = true` em `manifest.lua`.

---

## ⚖️ Segurança e regras

Todo o código neste repositório é governado por **[AGENTS.md](../../../AGENTS.md)**.
- **Modo Estrito**: Os scripts de aplicativos e arquivos de entrada usam um ambiente estrito para evitar globais acidentais (as bibliotecas principais atualmente ignoram isso para reduzir o padrão de localização).
- **Sem exclusão**: O instalador nunca exclui arquivos de usuário existentes (exceto para limpar seus próprios arquivos temporários como `manifest.lua` e `install.lua` após a conclusão ou substituir versões mais antigas durante uma atualização).
- **Install State Cache**: O instalador cria um arquivo oculto `.install_state.json` para lembrar quais versões de arquivo foram instaladas. Isso acelera execuções futuras, ignorando arquivos que não foram alterados (mostrados como `CACHED`). É seguro excluir este arquivo a qualquer momento – a próxima instalação simplesmente baixará tudo novamente.
- **Sem reinicialização automática**: O instalador pergunta antes de executar os arquivos de entrada e nunca reinicia o sistema sem permissão.
- **Política de aplicativo único**: apenas **um** aplicativo é compatível por computador avançado. A instalação de vários aplicativos no mesmo computador causará colisões de arquivos e substituirá arquivos críticos como `startup.lua` ou `Dashboard.lua`.

---

## 📝 Créditos e solução de problemas
Desenvolvido por **Antigravity** como parte da iniciativa Advanced Agentic Coding.
Se você encontrar problemas:
1. Certifique-se de estar usando um **Computador Avançado**.
2. Execute `install.lua --validate` para verificar se há erros de manifesto.
3. Verifique `README.md` na pasta de cada aplicativo para configuração específica de hardware.

**[LICENÇA](../../../LICENSE)**: MIT





