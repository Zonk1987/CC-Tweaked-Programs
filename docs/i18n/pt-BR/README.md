> [!WARNING]
> 🇧🇷 **pt-BR / Português (Brasil)**
> 
> ⚠️ **Nota**: Este README foi traduzido automaticamente por uma IA (Antigravity) e pode conter erros de tradução ou imprecisões. Para a documentação mais precisa e atualizada, consulte o [README.md](../../../README.md) original em inglês.

<div align="center">

# Zonk's CC:Tweaked Automation Suite 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality)
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

1. Baixe o arquivo `install.lua` do repositório:
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Execute o arquivo `install.lua`:
```bash
install.lua
```

---

## 📦 Pacotes Disponíveis

| ID | Nome | Descrição | Principais Recursos |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | Seletor de portal touchscreen premium. | UI móvel, listras de acento, redefinição de página. |
| `mekanism_recall_sender`| **Portal Recall Sender** | Disparador remoto sem fio. | Diagnóstico de hardware, monitoramento de status ao vivo. |
| `create_crafter` | **Mechanical Crafter** | Automação de crafting em grade. | Gravação e calibração, receitas de várias etapas. |
| `powah_orb` | **Energizing Orb** | Automação de crafting em paralelo. | Integração ME Bridge, recuperação automática. |
| `developer_suite` | **CC Developer Suite** | Kit de ferramentas de diagnóstico. | Sniffer de eventos, inspetor de periféricos. |

---

## 🏗️ Arquitetura: Feature-Core Skeleton

Este repositório foi construído para facilidade de manutenção e alto desempenho utilizando um esqueleto modular.

### **Módulos Core (`lib/core`)**
Utilitários genéricos são extraídos em pacotes core ocultos para reduzir a duplicação:
- **`core.base`**: Lógica fundamental como `ConfigStore` (persistência JSON).
- **`core.peripherals`**: Descoberta e encapsulamento seguros de periféricos (`PeripheralScanner`).
- **`core.network`**: Protocolos de comunicação padronizados (`RednetProtocol`).
- **`core.redstone`**: Auxiliares de interação com redstone (`RedstoneController`).
- **`core.ui`**: Componentes de interface de usuário reutilizáveis (`ButtonGrid`).
- **`core.inventory`**: Manuseio de inventário padronizado (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: Armazenamento de receitas baseado em JSON (`RecipeStore`).

### **Resolução de Dependências**
O instalador resolve dependências recursivamente de forma automática. Por exemplo, instalar `create_crafter` baixará automaticamente os módulos necessários `core.inventory` e `core.redstone`. Os arquivos da aplicação são colocados no diretório raiz, enquanto as bibliotecas core são mantidas na hierarquia `lib/core/` (acessível através de caminhos de pacotes ajustados no `startup.lua`).

---

## 🛠️ Diretrizes de Desenvolvimento

### **Adicionando um Novo Aplicativo**
1. Crie a pasta do seu aplicativo (ex: `Meu Novo App`).
2. Implemente sua lógica, aproveitando os módulos existentes da `lib/core`.
3. Registre seu aplicativo em `manifest.lua`.
4. Adicione dependências se você usar módulos core.

### **Adicionando um Módulo Core**
1. Coloque o módulo em `lib/core/<categoria>/ModuleName.lua`.
2. Registre-o como um pacote oculto (`hidden = true`) no `manifest.lua`.

---

## ⚖️ Segurança & Regras

Todo o código neste repositório é regido pelo **[AGENTS.md](./AGENTS.md)**.
- **Modo Estrito**: Scripts de aplicação e arquivos de entrada usam um ambiente estrito para evitar globais acidentais (bibliotecas core atualmente ignoram isso para reduzir código redundante de localização).
- **Sem Exclusão**: O instalador nunca exclui arquivos de usuário existentes (exceto para limpar seus próprios arquivos temporários como `manifest.lua` e `install.lua` após a conclusão, ou substituir versões antigas durante uma atualização).
- **Cache de Estado de Instalação**: O instalador cria um arquivo oculto `.install_state.json` para lembrar quais versões de arquivos foram instaladas. Isso acelera execuções futuras pulando arquivos que não foram alterados (mostrados como `CACHED`). É seguro excluir este arquivo a qualquer momento — a próxima instalação simplesmente baixará tudo novamente.
- **Sem Reinicialização Automática**: O instalador pergunta antes de executar arquivos de entrada e nunca reinicia o sistema sem permissão.
- **Política de App Único**: Apenas **um** aplicativo é suportado por Computador Avançado. Instalar vários aplicativos no mesmo computador causará colisões de arquivos e substituirá arquivos críticos como `startup.lua` ou `Dashboard.lua`.

---

## 📝 Créditos & Resolução de Problemas

Desenvolvido por **Antigravity** como parte da iniciativa Advanced Agentic Coding.
Se você encontrar problemas:
1. Certifique-se de estar usando um **Computador Avançado**.
2. Execute `install.lua --validate` para verificar se há erros no manifesto.
3. Verifique o `README.md` na pasta de cada aplicativo para obter a configuração de hardware específica.

**[LICENSE](./LICENSE)**: MIT
