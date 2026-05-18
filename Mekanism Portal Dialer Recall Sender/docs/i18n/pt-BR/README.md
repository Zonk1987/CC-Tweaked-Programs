> [!WARNING]
> 🇧🇷 **pt-BR / Portugues (Brasil)**
> 
> Nota: Este README foi traduzido automaticamente por um assistente de IA (Antigravidade) e pode conter erros de tradução ou imprecisões. Para obter a documentação mais precisa e atualizada, consulte o original em inglês [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

# Remetente de recall do portal Mekanism (CC: ajustado)

> Um acionador remoto dedicado para a **Rede do Portal Mekanism**. Permite que você disque remotamente para o seu portal inicial, simplesmente fornecendo um sinal redstone (botão, placa de pressão, etc.) no seu destino.


---

## ✨ Recursos

- **Diagnóstico de hardware** — Verifica todos os periféricos conectados na inicialização e fornece feedback claro sobre a presença do modem e do teletransportador.
- **Status do portal ao vivo (opcional)** — Monitoramento em tempo real do estado do portal local (por exemplo, "Pronto", "Sem energia") se um bloco Teletransportador local estiver fisicamente conectado (caso contrário, o padrão é "Apenas hub remoto").
- **Heartbeat Auto-Refresh** — Atualiza automaticamente o status a cada 2 segundos para manter a exibição sincronizada com o Hub.
- **Configuração interativa** — Não é necessária edição de código. O script solicita o local de destino na primeira execução.
- **Menu de configuração (teclas de atalho)** — Pressione `C` no terminal do computador para alterar o nome de destino ou canal.
- **Protocolo Dual-Path** — Envia comandos via API de modem padrão e Rednet para máxima confiabilidade.

---

## 🛠️ Configuração de hardware

1. **Computador de bolso ou computador pequeno** — Coloque um computador em seu destino remoto (por exemplo, Base Lunar, Posto Avançado de Mineração).
2. **Modem (sem fio ou com fio)** — Conecte um modem sem fio (ideal para locais remotos) ou um modem com fio ao computador.
3. **Redstone Trigger** — Conecte um botão, uma placa de pressão ou qualquer fonte de redstone a qualquer lado do computador.
- Quando o sinal redstone é **LIGADO**, o computador envia o comando de recall para sua base principal.

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
Selecione **Recaller do Portal Mekanism** no menu.

---

## ⚙️ Uso

1. **Primeira execução**: O computador solicitará um **Nome de destino**. Insira o *nome exato* da frequência conforme aparece em seu Portal Hub principal (por exemplo, "Base Principal").
2. **Operação normal**: A tela mostrará "Aguardando sinal Redstone...".
3. **Gatilho**: Pressione o botão. O Hub na sua base principal mudará instantaneamente para a sua localização atual.
4. **Configuração**: Se você mover o computador para uma nova base, pressione `C` no teclado para abrir o menu e alterar o nome do destino.

---

## ðŸ“¡ Detalhes Técnicos
O remetente transmite uma tabela JSON no canal configurado (padrão: 99):
```json
{
    "command": "RECALL",
    "target": "Your Destination Name"
}
```

---

## ðŸ“ Créditos
Desenvolvido para automação profissional do Minecraft.


