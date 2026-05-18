> [!WARNING]
> 🇧🇷 **pt-BR / Portugues (Brasil)**
> 
> Nota: Este README foi traduzido automaticamente por um assistente de IA (Antigravidade) e pode conter erros de tradução ou imprecisões. Para obter a documentação mais precisa e atualizada, consulte o original em inglês [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Rede do Portal Mekanism (CC:Ajustado)

> Uma interface de toque profissional e de alto desempenho para **Teletransportadores Mekanism**. Apresenta uma interface de usuário com buffer duplo e sem cintilação, gerenciamento de frequência de várias páginas e um editor de frequência integrado com personalização de cores.


---

## ✨ Recursos

- **Renderização com buffer duplo** — Atualizações da interface do usuário sem cintilação usando um sistema de buffer personalizado baseado em janela.
- **Janelas de sobreposição móveis** — Arraste o menu de seleção de cores para qualquer lugar da tela para obter visibilidade ideal.
- **Indicadores de listras de destaque** — Barras verticais de alto contraste nos botões mostram cores atribuídas com bordas de sombra pretas para visibilidade em qualquer plano de fundo.
- **Dynamic Portal Grid** — Descobre automaticamente todas as frequências com paginação inteligente e **Redefinição de página** automática nas alterações da lista.
- **Monitoramento de status em tempo real** — Feedback ao vivo sobre o status do portal, frequência alvo e proprietário (com resolução Mojang UUID).
- **Modo de edição e personalização de cores** — Atribua cores específicas a frequências ou use o ciclo de cores aleatório.
- **Suporte para Recall Remoto** — Modem integrado e API Rednet para ativação remota do portal (via script Recaller).

---

## 🛠️ Configuração de hardware

![Ingame Setup](../../assets/images/hub-setup.png)


1. **Computador Avançado** — Necessário para gráficos de alta resolução e buffer duplo.
2. **Monitor Avançado**
- Tamanho recomendado: **blocos 4x3** para o melhor layout de botões.
- Conecte-se via **Modems com fio** e cabos de rede.
3. **Teletransportador de Mecanismo**
- Conecte o Teletransportador à mesma rede a cabo usando um **Modem com fio**.
- Clique com o botão direito no modem para ligá-lo **ON** (anel vermelho).
4. **Modem (opcional)**
- Conecte um modem sem fio ou com fio ao computador para ativar a funcionalidade **Remote Recall**.

---

## 🚀 Instalação

1. Baixe o arquivo install.lua do repositório
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. Execute o arquivo install.lua
```bash
install.lua
```
Selecione **Mekanism Portal Dialer Hub** no menu. O instalador baixará automaticamente os arquivos do aplicativo (`HubSystem`, `UUIDService`, `Dashboard`) e resolverá todas as dependências principais (por exemplo, `ButtonGrid`, `PeripheralScanner`).

---

## ⚙️ Configuração

Abra `startup` no computador para personalizar o comportamento do sistema:

- `gridColumns` / `gridRows`: Ajusta o número de botões por página.
- `recallChannel`: Define o canal do modem para solicitações de portal remoto (padrão: 99).

---

## ⌨️ Controles e modos

### **Modo discador (padrão)**
- **Toque em um Portal** — Mude instantaneamente a frequência do teletransportador. O botão permanecerá destacado até que o hardware confirme a alteração.
- **Próximo/Anterior** — Alterne entre as páginas se você tiver muitas frequências.

### **Modo de edição (ícone de configurações)**
1. Toque no ícone **Â¤** no canto superior direito para entrar no Modo de Edição.
2. Selecione qualquer portal para abrir **Sobreposição de cores**.
3. Escolha uma **Cor fixa** para esse portal específico ou selecione **RANDOM** para um ciclo de cores dinâmico.
4. Use a barra **MOVE** na parte superior da sobreposição para deslocar a janela caso ela bloqueie sua visualização.

---

## 📝 API de recuperação remota

O sistema escuta mensagens de modem no `recallChannel` configurado. Para acionar um portal remotamente, envie uma tabela com a seguinte estrutura:
```lua
{
    command = "RECALL",
    target = "My Base" -- Name of the frequency
}
```
Alternativamente, você pode usar o script dedicado **Mekanism Portal Recaller** em um computador de bolso portátil.

---

## 📝 Créditos
Desenvolvido como parte da iniciativa **Advanced Agentic Coding** para automação profissional do Minecraft.




