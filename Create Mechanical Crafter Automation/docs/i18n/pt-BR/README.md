> [!WARNING]
> 🇧🇷 **pt-BR / Portugues (Brasil)**
> 
> Nota: Este README foi traduzido automaticamente por um assistente de IA (Antigravidade) e pode conter erros de tradução ou imprecisões. Para obter a documentação mais precisa e atualizada, consulte o original em inglês [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Criar Automação Mecânica Crafter ðŸ› ï¸

> Sistema ComputerCraft totalmente automatizado e pronto para produção para os **Mechanical Crafters** do mod **Create**. Projetado para integração perfeita com AE2/Armazenamento Refinado no **Modo de Bloqueio**.


---

## âœ¨ Recursos

- **Gravação de receitas no jogo** — Coloque os itens nos artesãos, pressione `S` e digite um nome. Pronto. Não é necessária edição JSON.
- **Gerenciamento visual de receitas** — Pressione `M` para navegar por todas as receitas salvas, visualizar os ingredientes necessários e gerenciar padrões.
- **Calibração de rede interativa** — Detecção automática do layout exato da sua rede por meio da ativação sequencial do modem.
- **AE2 / RS Blocking Mode Ready** — Otimizado para integração de buffer chest com processamento garantido de uma única nave.
- **Detecção Inteligente de Atolamento** — Alertas em tempo real mostrando o slot exato do criador e o item que está causando o gargalo.
- **Painel ao vivo** — UI de alto desempenho com código de cores que mostra o status da grade, o histórico do trabalho e os ingredientes faltantes.

---

## ðŸ› ï¸ Configuração de hardware

![Ingame Setup](../../assets/images/crafter-setup.png)


1. **Computador Avançado** — Necessário para o painel colorido de alta resolução.
2. **Crafter Grid** — Construa seu array (por exemplo, 3×3, 5×5, 9×9).
3. **Rede (etapa crucial):**
- Conecte um **Modem com fio** a **cada** Mechanical Crafter.
- Conecte todos os modems ao computador com **Cabos de rede**.
- Clique com o botão direito nos modems até que o **anel vermelho** acenda.
- **âš ï¸ IMPORTANTE:** Você DEVE ativar os modems em **ordem de leitura** (canto superior esquerdo → canto superior direito e, em seguida, linha por linha) durante a calibração.
4. **Buffer Chest** — Conecte um baú (por exemplo, Diamond Chest) adjacente ao computador por meio de um modem com fio.
5. **Redstone Trigger** — Conecte um sinal Redstone de **qualquer lado** do computador aos Crafters.

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
3. Selecione **Criar automação do Mechanical Crafter**.
4. **Calibração**: Na primeira inicialização, siga as instruções na tela para clicar com o botão direito do mouse nos modems na ordem. Isso mapeia a grade física para o software.
5. **Modo de bloqueio**: Defina seu provedor de padrão AE2 para **"Modo de bloqueio"** voltado para o Buffer Chest.

---

## ðŸ“– Como usar

### Gravando uma nova receita
1. Coloque os ingredientes manualmente nos Artesãos Mecânicos físicos.
2. Pressione **`S`** no painel.
3. Digite um nome e pressione **ENTER**. O sistema verifica a grade e a salva instantaneamente!

### Gerenciando Receitas
1. Pressione **`M`** no painel para abrir o Gerenciador.
2. Navegue pelas receitas, veja os ingredientes e pressione **`X`** para excluir padrões antigos.

---

## ÂŒ¨ï¸ Teclas de atalho

| Chave | Ação |
|:---:|---|
| **`S`** | **Escanear/Gravar** nova receita da grade *(Cancelar pressionando ENTER com nome vazio)* |
| **`M`** | **Gerenciar** receitas salvas e visualizar padrões |
| **`R`** | **Recarregar** receitas de `crafter_recipes.json` |
| **`Q`** | **Sair** (Sair do menu Recipe Manager e retornar ao Dashboard) |

---

## Configuração

O sistema foi projetado para funcionar imediatamente. Os dados de calibração são armazenados em `crafter_mapping.json`. Exclua este arquivo para acionar uma nova calibração.

---

## ðŸ›‘ Solução de problemas

| Erro | Causa e correção |
|---|---|
| `Baú de buffer faltando!` | O modem no baú está desligado ou desconectado. |
| `Não há artesãos mecânicos!` | Nenhum modem encontrado. Verifique os cabos e os anéis vermelhos! |
| `JAMMED: Slot #X` | A elaboração não terminou. Verifique o pulso e a potência do redstone. |
| `Incompatibilidade de padrão` | Itens errados na grade ou arquivo de mapeamento estão corrompidos. Recalibre! |

---
*Desenvolvido com â¤ï¸ para Advanced Agentic Coding.*


