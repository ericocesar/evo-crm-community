# Guia do Sistema Evo CRM Community

> Manual completo da plataforma e guia passo a passo para criação de fluxos de atendimento ao cliente com perguntas qualificadoras e agentes de IA no WhatsApp.

---

## Sumário

1. [Visão Geral da Plataforma](#1-visão-geral-da-plataforma)
2. [Arquitetura dos Serviços](#2-arquitetura-dos-serviços)
3. [Conceitos Fundamentais](#3-conceitos-fundamentais)
4. [Fluxo de Dados End-to-End](#4-fluxo-de-dados-end-to-end)
5. [Guia: Fluxo de Atendimento com Perguntas Qualificadoras no WhatsApp](#5-guia-fluxo-de-atendimento-com-perguntas-qualificadoras-no-whatsapp)
   - [Passo 1 — Configurar o Canal WhatsApp](#passo-1--configurar-o-canal-whatsapp)
   - [Passo 2 — Criar o Agente de IA](#passo-2--criar-o-agente-de-ia)
   - [Passo 3 — Definir as Perguntas Qualificadoras](#passo-3--definir-as-perguntas-qualificadoras)
   - [Passo 4 — Configurar Caminhos por Perfil](#passo-4--configurar-caminhos-por-perfil)
   - [Passo 5 — Vincular o Agente ao Inbox WhatsApp](#passo-5--vincular-o-agente-ao-inbox-whatsapp)
   - [Passo 6 — Criar Automações de Roteamento](#passo-6--criar-automações-de-roteamento)
   - [Passo 7 — Criar a Jornada no Evo Flow](#passo-7--criar-a-jornada-no-evo-flow)
   - [Passo 8 — Testar o Fluxo Completo](#passo-8--testar-o-fluxo-completo)
6. [Referência de Variáveis e Atributos Customizados](#6-referência-de-variáveis-e-atributos-customizados)
7. [Referência das APIs Principais](#7-referência-das-apis-principais)

---

## 1. Visão Geral da Plataforma

O **Evo CRM Community** é uma plataforma de atendimento ao cliente open-source e self-hosted, orientada a automação por IA. Combina:

| Capacidade | Descrição |
|---|---|
| **Gerenciamento de conversas** | Inbox unificado multi-canal (WhatsApp, Email, Telegram, SMS, Web Widget, Instagram, Facebook) |
| **Agentes de IA** | Execução de LLMs via LangGraph + Google ADK com memória de sessão e RAG |
| **Automação de jornadas** | Fluxos visuais orquestrados via Temporal, com 20+ tipos de nós |
| **Segmentação avançada** | Computada em ClickHouse com regras em tempo real ou cron |
| **Campanhas** | Audiências, templates, A/B testing, agendamento |
| **Rastreamento de eventos** | Ingestão genérica (track, identify, page) com processamento via Kafka |

A plataforma é mantida pela [Evolution Foundation](https://github.com/EvolutionAPI) e é single-tenant por design.

---

## 2. Arquitetura dos Serviços

```
┌──────────────────────────────────────────────────────────┐
│              evo-ai-frontend-community                   │
│               React · TypeScript · Vite                  │
│                      :5173                               │
└────────────────────────┬─────────────────────────────────┘
                         │ API (Bearer JWT)
         ┌───────────────┴───────────────┐
         │                               │
┌────────▼─────────┐         ┌───────────▼──────────┐
│ evo-auth-service │         │  evo-ai-crm-community │
│   Ruby on Rails  │         │    Ruby on Rails API  │
│      :3001       │         │         :3000         │
│                  │         │                       │
│ • RBAC           │         │ • Conversas           │
│ • JWT / OAuth    │         │ • Contatos            │
│ • Roles: owner/  │         │ • Inboxes             │
│   agent          │         │ • Mensagens           │
│                  │         │ • Canais              │
│                  │         │ • Automações          │
│                  │         │ • Webhooks            │
└──────────────────┘         └───────────┬───────────┘
                                         │
              ┌──────────────────────────┼─────────────────┐
              │                          │                 │
   ┌──────────▼──────┐   ┌──────────────▼───┐   ┌────────▼────────┐
   │  evo-ai-core    │   │  evo-ai-processor │   │ evo-bot-runtime │
   │  service (Go)   │   │    (Python/       │   │    (Go/Gin)     │
   │     :5555       │   │    FastAPI) :8000 │   │     :8080       │
   │                 │   │                   │   │                 │
   │ • CRUD agentes  │   │ • LangGraph       │   │ • Debouncing    │
   │ • API keys      │   │ • Google ADK      │   │ • Pipeline exec │
   │ • Permissões    │   │ • Sessões         │   │ • Dispatch      │
   │                 │   │ • RAG / Vector DB │   │                 │
   │                 │   │ • MCP tools       │   │                 │
   └─────────────────┘   └──────────────────┘   └─────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │    evolution-api     │
                              │     (Node.js)        │
                              │                      │
                              │ • WhatsApp Baileys   │
                              │ • WhatsApp Cloud API │
                              │ • Telegram, SMS...   │
                              └──────────────────────┘

Infraestrutura compartilhada:
  PostgreSQL · Redis · ClickHouse · Kafka · Temporal · MinIO · S3
```

### Serviços em Detalhe

#### evo-auth-service (:3001)
- Autenticação centralizada e RBAC
- Emissão e validação de tokens JWT
- Roles: `account_owner` e `agent`

#### evo-ai-crm-community (:3000)
- Núcleo do CRM: conversas, contatos, inboxes, mensagens
- Real-time via ActionCable (WebSocket)
- Jobs assíncronos via Sidekiq + Redis

#### evo-ai-processor (:8000)
- Motor de execução de agentes IA
- Orquestra LangGraph + Google ADK
- Gerencia sessões com memória persistente
- RAG com Pinecone, Qdrant ou OpenSearch

#### evo-bot-runtime (:8080)
- Recebe eventos do CRM
- Faz debouncing e despacha para o processor
- Coordena respostas de volta ao CRM

#### evolution-api
- Provider de mensagens para WhatsApp
- Suporta Baileys (gratuito, sem API oficial Meta) e WhatsApp Cloud API (oficial)
- Envia webhooks ao CRM a cada evento recebido

#### evo-flow (NestJS)
- Motor de automação: jornadas, campanhas, segmentos, eventos
- Orquestrado via Temporal (workflows duráveis)

---

## 3. Conceitos Fundamentais

### Inbox
Um **Inbox** é um canal de entrada, identificado por tipo e configuração. Exemplo: "WhatsApp Suporte", "Email Comercial", "Chat do Site". Cada inbox pode ter:
- Agentes humanos atribuídos
- Um agente de IA vinculado (`AgentBotInbox`)
- Horários de operação (`WorkingHour`)

### Conversation
Cada interação com um contato gera uma **Conversation** dentro de um inbox. Toda mensagem pertence a uma conversa. Uma conversa pode ter:
- Status: `open`, `resolved`, `pending`, `snoozed`
- Labels (tags)
- Atributos customizados
- Notas internas

### Contact
Um **Contact** é o cliente. Pode estar associado a múltiplos inboxes via `ContactInbox`. Suporta atributos customizados (campos adicionais definidos pelo administrador).

### AgentBot (Agente de IA)
Um agente configurado no `evo-ai-core-service`. Quando vinculado a um inbox, o `evo-bot-runtime` intercepta mensagens recebidas e as envia ao `evo-ai-processor` para geração de resposta automatizada.

### Automation
Regras do tipo "se [condição] então [ação]". Executadas automaticamente quando conversas ou mensagens satisfazem critérios. Exemplos de ações: atribuir agente, adicionar label, enviar mensagem, disparar webhook.

### Journey (Jornada — Evo Flow)
Fluxo visual com nós de ação encadeados, orquestrado pelo Temporal. Cada contato que entra na jornada tem seu estado rastreado individualmente e de forma durável.

---

## 4. Fluxo de Dados End-to-End

```
Cliente envia mensagem no WhatsApp
        │
        ▼
evolution-api (recebe via Baileys ou Cloud API)
        │  webhook
        ▼
evo-ai-crm-community (persiste Message + Conversation)
        │  evento via ActionCable / webhook interno
        ▼
evo-bot-runtime (verifica se inbox tem agente de IA)
        │  POST /session/send_message
        ▼
evo-ai-processor (executa agente LangGraph + ADK)
        │  tool calls (MCP, RAG, APIs externas)
        ▼
Agente retorna resposta estruturada
        │
        ▼
evo-bot-runtime → evo-ai-crm-community (POST /messages)
        │
        ▼
evo-ai-crm-community → evolution-api (envia resposta)
        │
        ▼
Cliente recebe resposta no WhatsApp
        │
        ▼
CRM Frontend atualiza conversa em tempo real (ActionCable)
```

---

## 5. Guia: Fluxo de Atendimento com Perguntas Qualificadoras no WhatsApp

Este guia explica como criar um fluxo completo em que:
1. O cliente inicia contato via WhatsApp
2. Um agente de IA faz perguntas qualificadoras
3. O agente analisa as respostas e define o perfil do cliente
4. O sistema roteia o cliente para o caminho correto (suporte técnico, vendas, financeiro, etc.)

---

### Passo 1 — Configurar o Canal WhatsApp

#### 1.1. Acessar o painel de administração

Acesse o frontend em `http://seu-dominio:5173` e faça login com uma conta `account_owner`.

Vá em **Configurações → Inboxes → Nova Inbox**.

#### 1.2. Escolher o tipo de canal

Selecione **WhatsApp** e escolha o provider:

| Provider | Quando usar |
|---|---|
| **WhatsApp (Baileys)** | Ambiente de desenvolvimento, baixo volume, sem custo extra |
| **WhatsApp Business API (Meta)** | Produção, alto volume, compliance, suporte oficial Meta |

#### 1.3. Configurar a conexão Baileys

```
Nome do Inbox: Atendimento WhatsApp
Número: +55119XXXXXXXX
Evolution API URL: http://evolution-api:8080
Evolution API Key: <sua-api-key>
```

Após salvar, o sistema exibirá um **QR Code**. Escaneie com o WhatsApp do número configurado para autenticar a sessão.

> **Importante:** O número autenticado não pode ser usado simultaneamente no app WhatsApp convencional.

#### 1.4. Configurar via API (alternativa)

```bash
# Criar a instância no evolution-api
curl -X POST http://evolution-api:8080/instance/create \
  -H "apikey: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "atendimento-principal",
    "qrcode": true,
    "integration": "WHATSAPP-BAILEYS"
  }'

# Configurar webhook para o CRM
curl -X POST http://evolution-api:8080/webhook/set/atendimento-principal \
  -H "apikey: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "http://evo-ai-crm:3000/webhooks/whatsapp",
    "webhook_by_events": false,
    "webhook_base64": false,
    "events": [
      "MESSAGES_UPSERT",
      "MESSAGES_UPDATE",
      "CONNECTION_UPDATE"
    ]
  }'
```

---

### Passo 2 — Criar o Agente de IA

O agente de IA é o componente que interpreta as mensagens do cliente, conduz as perguntas qualificadoras e define o caminho de atendimento.

#### 2.1. Criar o agente no evo-ai-core-service

Acesse **Configurações → Agentes de IA → Novo Agente**.

Preencha:

| Campo | Valor de Exemplo |
|---|---|
| **Nome** | `Qualificador de Atendimento` |
| **Descrição** | Agente responsável por qualificar leads e rotear atendimentos |
| **Modelo** | `gemini-2.0-flash` ou `gpt-4o-mini` |
| **Temperatura** | `0.3` (mais determinístico para qualificação) |

#### 2.2. Configurar o System Prompt

O system prompt define o comportamento, o roteiro de perguntas e as regras de roteamento. Escreva o prompt na seção **Instruções do Sistema**:

```
Você é o assistente virtual de atendimento da [NOME DA EMPRESA].
Sua missão é qualificar o cliente fazendo perguntas estratégicas 
e identificar o perfil de atendimento adequado.

## IDENTIDADE
- Nome: Ana
- Tom: Profissional, amigável, objetivo
- Idioma: Português do Brasil

## FLUXO OBRIGATÓRIO

### ETAPA 1 — Boas-vindas
Sempre inicie com:
"Olá! 😊 Eu sou a Ana, assistente virtual da [EMPRESA].
Antes de direcioná-lo ao atendimento ideal, preciso fazer 
algumas perguntas rápidas. Pode ser?"

Aguarde a resposta antes de continuar.

### ETAPA 2 — Perguntas qualificadoras (uma por vez)

Faça as perguntas na seguinte ordem, aguardando a resposta de cada uma:

**PERGUNTA 1 — Motivo do contato:**
"Qual é o principal motivo do seu contato hoje?
1️⃣ Preciso de suporte técnico
2️⃣ Tenho interesse em comprar / contratar
3️⃣ Tenho uma dúvida sobre cobrança / financeiro
4️⃣ Outro motivo"

**PERGUNTA 2 — É cliente atual?**
"Você já é nosso cliente?"
(somente se a resposta anterior não for opção 2)

**PERGUNTA 3 — Urgência:**
"Qual o nível de urgência da sua situação?
🔴 Urgente — preciso resolver agora
🟡 Médio — posso aguardar algumas horas
🟢 Baixo — pode ser agendado"

### ETAPA 3 — Análise e roteamento

Com base nas respostas, defina o perfil e informe:
- Qual equipe irá atendê-lo
- Tempo estimado de espera
- Próximos passos

### REGRAS DE ROTEAMENTO

| Motivo | Cliente? | Urgência | Destino |
|---|---|---|---|
| Suporte técnico | Sim | Urgente | Suporte Tier 1 (plantão) |
| Suporte técnico | Sim | Médio/Baixo | Suporte Tier 2 (agendamento) |
| Suporte técnico | Não | Qualquer | Direcionar para vendas antes |
| Compra/Contratação | — | — | Equipe Comercial |
| Financeiro | Sim | Urgente | Financeiro Direto |
| Financeiro | Sim | Médio/Baixo | Portal de autoatendimento + fila |
| Outro | — | — | Triagem Geral |

## ATRIBUTOS A REGISTRAR

Ao final das perguntas, você DEVE registrar os seguintes atributos
do contato usando as funções disponíveis:

- `motivo_contato`: suporte_tecnico | vendas | financeiro | outro
- `e_cliente`: sim | nao | nao_informado
- `urgencia`: urgente | medio | baixo
- `perfil_atendimento`: tier1 | tier2 | comercial | financeiro_direto | portal | triagem

## RESTRIÇÕES
- Faça apenas UMA pergunta por mensagem
- Nunca responda questões técnicas ou comerciais durante a qualificação
- Se o cliente desviar do assunto, redirecione gentilmente
- Se o cliente não responder após 3 tentativas, encerre com mensagem de reengajamento
- Nunca invente informações sobre produtos, preços ou prazos
```

#### 2.3. Configurar ferramentas (Tools) do agente

Na aba **Ferramentas**, habilite as seguintes capacidades:

| Ferramenta | Finalidade |
|---|---|
| `update_contact_attributes` | Salvar os atributos qualificados no contato |
| `update_conversation_attributes` | Adicionar dados à conversa atual |
| `add_label` | Adicionar label de roteamento à conversa |
| `assign_conversation` | Atribuir conversa a uma equipe ou agente |

---

### Passo 3 — Definir as Perguntas Qualificadoras

As perguntas qualificadoras são conduzidas pelo agente via linguagem natural. Para torná-las rastreáveis no CRM, crie os **Atributos Customizados** correspondentes.

#### 3.1. Criar atributos customizados de contato

Vá em **Configurações → Atributos Customizados → Contato → Novo Atributo**.

Crie os seguintes atributos:

| Nome do Atributo | Chave | Tipo | Opções |
|---|---|---|---|
| Motivo do Contato | `motivo_contato` | Lista | suporte_tecnico, vendas, financeiro, outro |
| É Cliente | `e_cliente` | Lista | sim, nao, nao_informado |
| Nível de Urgência | `urgencia` | Lista | urgente, medio, baixo |
| Perfil de Atendimento | `perfil_atendimento` | Lista | tier1, tier2, comercial, financeiro_direto, portal, triagem |
| Data de Qualificação | `qualificado_em` | Data | — |

#### 3.2. Criar labels de roteamento

Vá em **Configurações → Labels → Nova Label** e crie:

```
qualificado-tier1        → cor: vermelho   → Suporte urgente
qualificado-tier2        → cor: laranja    → Suporte agendado
qualificado-comercial    → cor: verde      → Equipe de vendas
qualificado-financeiro   → cor: azul       → Equipe financeira
qualificado-portal       → cor: cinza      → Autoatendimento
qualificado-triagem      → cor: amarelo    → Triagem geral
em-qualificacao          → cor: roxo       → Em processo de qualificação
```

---

### Passo 4 — Configurar Caminhos por Perfil

Cada perfil de atendimento deve ter um destino diferente no CRM. Configure os times e inboxes correspondentes.

#### 4.1. Criar times de atendimento

Vá em **Configurações → Times → Novo Time** e crie:

```
Suporte Tier 1 (Plantão)
Suporte Tier 2 (Agendado)
Equipe Comercial
Equipe Financeira
Triagem Geral
```

Atribua os agentes humanos corretos a cada time.

#### 4.2. Criar Automações de roteamento

Vá em **Configurações → Automações → Nova Automação**.

**Automação 1 — Rotear para Suporte Tier 1**

```
Gatilho: Label adicionada
Condição: Label = qualificado-tier1
Ações:
  1. Atribuir time: "Suporte Tier 1 (Plantão)"
  2. Definir prioridade: Alta
  3. Enviar mensagem: "Conectando você ao suporte urgente. 
     Um agente estará com você em instantes. ⏳"
```

**Automação 2 — Rotear para Suporte Tier 2**

```
Gatilho: Label adicionada
Condição: Label = qualificado-tier2
Ações:
  1. Atribuir time: "Suporte Tier 2 (Agendado)"
  2. Definir prioridade: Média
  3. Enviar mensagem: "Vou agendar seu atendimento. Nossa equipe 
     de suporte entrará em contato em até 4 horas. 📅"
```

**Automação 3 — Rotear para Comercial**

```
Gatilho: Label adicionada
Condição: Label = qualificado-comercial
Ações:
  1. Atribuir time: "Equipe Comercial"
  2. Enviar mensagem: "Ótimo! Nossa equipe comercial vai adorar 
     falar com você. Aguarde um momento. 🤝"
```

**Automação 4 — Rotear para Financeiro Direto**

```
Gatilho: Label adicionada
Condição: Label = qualificado-financeiro
Ações:
  1. Atribuir time: "Equipe Financeira"
  2. Definir prioridade: Alta
  3. Enviar mensagem: "Transferindo para o setor financeiro. 💰"
```

**Automação 5 — Enviar para Portal de Autoatendimento**

```
Gatilho: Label adicionada
Condição: Label = qualificado-portal
Ações:
  1. Enviar mensagem: "Para resolver sua questão financeira, 
     acesse nosso portal: https://portal.suaempresa.com.br 
     Se precisar de ajuda, é só responder aqui. 🌐"
  2. Resolver conversa automaticamente após 24h (via Jornada)
```

---

### Passo 5 — Vincular o Agente ao Inbox WhatsApp

#### 5.1. Associar o agente ao inbox

Vá em **Configurações → Inboxes → [Seu Inbox WhatsApp] → Configurações → Agente de IA**.

Selecione o agente **"Qualificador de Atendimento"** criado no Passo 2 e salve.

#### 5.2. Definir comportamento de handoff

Configure quando o agente de IA deve transferir para humano:

| Configuração | Valor Recomendado |
|---|---|
| **Assumir quando** | Nova conversa criada |
| **Transferir quando** | Label de roteamento adicionada OU após N tentativas sem resposta |
| **Horário de operação** | Ativo 24h (a qualificação é sempre automática) |

#### 5.3. Validar via API

```bash
# Verificar se o agente está vinculado ao inbox
curl -X GET http://evo-ai-crm:3000/api/v1/accounts/1/inboxes \
  -H "api_access_token: SEU_TOKEN_DE_ACESSO" | \
  jq '.payload[] | select(.name == "Atendimento WhatsApp") | .agent_bot'
```

---

### Passo 6 — Criar Automações de Roteamento

As automações garantem que, assim que o agente registrar o perfil do contato (via label ou atributo), o CRM execute as ações corretas de roteamento.

#### 6.1. Automação de entrada — iniciar qualificação

```
Nome: Iniciar Qualificação Automática
Gatilho: Conversa criada
Condição:
  - Canal = WhatsApp
  - Horário: qualquer horário (ou fora do horário comercial)
Ações:
  1. Adicionar label: em-qualificacao
  2. Atribuir ao agente de IA (automático via AgentBotInbox)
```

#### 6.2. Automação pós-qualificação — remover label intermediária

```
Nome: Limpar Label de Em Qualificação
Gatilho: Label adicionada
Condição: Label contém "qualificado-"
Ações:
  1. Remover label: em-qualificacao
  2. Registrar atributo de conversa: qualificado_em = hoje
```

#### 6.3. Automação de fallback — sem resposta após 10 minutos

```
Nome: Reengajar Contato Inativo
Gatilho: Conversa criada / atualizada
Condição:
  - Label = em-qualificacao
  - Última mensagem há mais de 10 minutos
  - Sem resposta do cliente
Ações:
  1. O agente de IA envia: "Ainda está por aqui? 😊 
     Pode me responder quando quiser, estarei aguardando!"
```

---

### Passo 7 — Criar a Jornada no Evo Flow

Para fluxos mais complexos com esperas, ramificações temporais e ações multi-etapa, use o **Evo Flow** para criar uma Jornada.

#### 7.1. Acessar o Evo Flow

O Evo Flow expõe uma API REST. Você pode criar jornadas via:
- **UI do CRM** (seção Automação → Jornadas, se habilitada)
- **API direta** do serviço Evo Flow

#### 7.2. Estrutura da Jornada de Qualificação

```
[ENTRADA]
Trigger: Contato recebe mensagem WhatsApp pela primeira vez
        OU label "em-qualificacao" adicionada
         │
         ▼
[NÓ 1 — Aguardar qualificação]
Wait: até a label "qualificado-*" ser adicionada
      Timeout: 30 minutos
         │
    ┌────┴────────────────────────────────────────────────┐
    │ (qualificado) │ (timeout — não respondeu)           │
    ▼               ▼                                     │
[NÓ 2A]        [NÓ 2B — Reengajamento]                   │
Condicional    Enviar mensagem:                           │
por atributo   "Notamos que não conseguimos               │
"perfil_       falar com você agora.                      │
atendimento"   Quando quiser, é só nos                    │
    │          chamar! 😊"                                │
    │               │                                     │
    │          Resolver conversa                          │
    │                                                     │
    ├─ tier1 ──────► [NÓ 3A] Enviar confirmação + SLA    │
    │                         "Atendimento urgente:       │
    │                          ~15 min de espera"         │
    │                                                     │
    ├─ tier2 ──────► [NÓ 3B] Agendar follow-up           │
    │                Wait: 4 horas                        │
    │                Enviar: "Chegou sua vez! 🎯"         │
    │                                                     │
    ├─ comercial ──► [NÓ 3C] Enviar material de vendas   │
    │                Wait: 2 minutos                      │
    │                Enviar: link de apresentação         │
    │                Wait: 1 dia                          │
    │                Condicional: conversa resolvida?     │
    │                  Não → Enviar follow-up comercial   │
    │                                                     │
    ├─ financeiro ─► [NÓ 3D] Atribuir + SLA financeiro   │
    │                                                     │
    └─ portal ─────► [NÓ 3E] Enviar link portal          │
                     Wait: 2 dias                         │
                     Condicional: resolvido?              │
                       Não → Oferecer atendimento humano  │
```

#### 7.3. Criar a Jornada via API

```bash
# Criar a jornada no Evo Flow
curl -X POST http://evo-flow:3001/journeys \
  -H "Authorization: Bearer SEU_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Qualificação WhatsApp",
    "description": "Fluxo de qualificação automática para contatos WhatsApp",
    "trigger": {
      "type": "label_added",
      "conditions": {
        "label": "em-qualificacao",
        "channel": "whatsapp"
      }
    },
    "nodes": [
      {
        "id": "wait-qualification",
        "type": "wait",
        "config": {
          "event": "label_added",
          "label_prefix": "qualificado-",
          "timeout_minutes": 30
        }
      },
      {
        "id": "check-profile",
        "type": "condition",
        "config": {
          "attribute": "contact.perfil_atendimento",
          "branches": [
            { "value": "tier1", "next": "node-tier1" },
            { "value": "tier2", "next": "node-tier2" },
            { "value": "comercial", "next": "node-comercial" },
            { "value": "financeiro_direto", "next": "node-financeiro" },
            { "value": "portal", "next": "node-portal" }
          ],
          "default": "node-triagem"
        }
      },
      {
        "id": "node-tier1",
        "type": "send_message",
        "config": {
          "channel": "whatsapp",
          "message": "Seu atendimento urgente está sendo iniciado. Tempo estimado de espera: 15 minutos. ⏱️"
        }
      },
      {
        "id": "node-tier2",
        "type": "wait",
        "config": { "hours": 4, "next": "node-tier2-followup" }
      },
      {
        "id": "node-tier2-followup",
        "type": "send_message",
        "config": {
          "channel": "whatsapp",
          "message": "Olá! A equipe de suporte está pronta para atendê-lo agora. 🎯"
        }
      },
      {
        "id": "node-comercial",
        "type": "send_message",
        "config": {
          "channel": "whatsapp",
          "message": "Enquanto aguarda nosso especialista, confira nossa apresentação: {{contact.presentation_link}}"
        }
      }
    ]
  }'
```

---

### Passo 8 — Testar o Fluxo Completo

#### 8.1. Teste manual end-to-end

1. Envie uma mensagem de um número de WhatsApp **diferente** do número configurado no inbox
2. Aguarde a resposta automática do agente Ana
3. Responda as perguntas qualificadoras
4. Verifique no CRM (**Conversas** → **Todas**) se:
   - A conversa foi criada no inbox correto
   - O atributo `perfil_atendimento` foi preenchido no contato
   - A label de roteamento foi adicionada
   - A conversa foi atribuída ao time correto

#### 8.2. Verificar logs do agente

```bash
# Logs do processor (execução do agente)
docker logs evo-ai-processor --tail=100 -f

# Logs do bot runtime (despacho de mensagens)
docker logs evo-bot-runtime --tail=100 -f

# Logs do CRM (persistência e automações)
docker logs evo-ai-crm --tail=100 -f
```

#### 8.3. Inspecionar sessão do agente via API

```bash
# Listar sessões ativas do agente
curl -X GET http://evo-ai-processor:8000/sessions \
  -H "Authorization: Bearer SEU_JWT"

# Ver histórico de mensagens de uma sessão específica
curl -X GET http://evo-ai-processor:8000/sessions/SESSION_ID/messages \
  -H "Authorization: Bearer SEU_JWT"
```

#### 8.4. Cenários de teste recomendados

| Cenário | Entrada Esperada | Resultado Esperado |
|---|---|---|
| Cliente novo pede suporte urgente | "1 → Não → Urgente" | Label: `qualificado-tier1`, Time: Suporte Tier 1 |
| Cliente existente pede suporte baixa urgência | "1 → Sim → Baixo" | Label: `qualificado-tier2`, Time: Suporte Tier 2 |
| Lead novo interessado em comprar | "2 → (pula) → Médio" | Label: `qualificado-comercial`, Time: Comercial |
| Cliente com dúvida financeira urgente | "3 → Sim → Urgente" | Label: `qualificado-financeiro`, Time: Financeiro |
| Cliente não responde | *(sem resposta por 30 min)* | Mensagem de reengajamento + conversa resolvida |
| Resposta ambígua | "Preciso de ajuda com minha conta" | Agente pede clareza antes de classificar |

---

## 6. Referência de Variáveis e Atributos Customizados

O sistema suporta interpolação de variáveis em mensagens e system prompts usando a sintaxe `{{variável}}`.

### Variáveis de Contato

| Variável | Descrição |
|---|---|
| `{{contact.name}}` | Nome do contato |
| `{{contact.email}}` | E-mail do contato |
| `{{contact.phone}}` | Telefone do contato |
| `{{contact.company}}` | Empresa do contato |
| `{{contact.motivo_contato}}` | Atributo customizado: motivo do contato |
| `{{contact.perfil_atendimento}}` | Atributo customizado: perfil definido |
| `{{contact.urgencia}}` | Atributo customizado: urgência |

### Variáveis de Conversa

| Variável | Descrição |
|---|---|
| `{{conversation.id}}` | ID da conversa |
| `{{conversation.status}}` | Status atual (open, resolved, pending) |
| `{{conversation.assignee.name}}` | Agente atribuído |
| `{{conversation.inbox.name}}` | Nome do inbox |
| `{{conversation.created_at}}` | Data de criação |

### Variáveis de Conta

| Variável | Descrição |
|---|---|
| `{{account.name}}` | Nome da empresa/conta |
| `{{account.support_email}}` | E-mail de suporte |

---

## 7. Referência das APIs Principais

### CRM Backend (evo-ai-crm-community — :3000)

```
POST   /api/v1/accounts/:id/conversations              → Criar conversa
GET    /api/v1/accounts/:id/conversations              → Listar conversas
POST   /api/v1/accounts/:id/conversations/:id/messages → Enviar mensagem
PATCH  /api/v1/accounts/:id/conversations/:id          → Atualizar conversa
POST   /api/v1/accounts/:id/contacts                   → Criar contato
PATCH  /api/v1/accounts/:id/contacts/:id               → Atualizar contato
POST   /api/v1/accounts/:id/conversations/:id/labels   → Adicionar label
DELETE /api/v1/accounts/:id/conversations/:id/labels   → Remover label
```

**Autenticação:** Header `api_access_token: SEU_TOKEN`

### AI Processor (evo-ai-processor — :8000)

```
POST   /session/send_message     → Enviar mensagem ao agente
GET    /sessions                 → Listar sessões
GET    /sessions/:id/messages    → Histórico da sessão
DELETE /sessions/:id             → Encerrar sessão
GET    /agents                   → Listar agentes disponíveis
```

**Autenticação:** Header `Authorization: Bearer JWT`

### Evolution API (WhatsApp — :8080)

```
POST   /instance/create                     → Criar instância WhatsApp
GET    /instance/connectionState/:instance  → Status da conexão
POST   /message/sendText/:instance          → Enviar mensagem de texto
POST   /message/sendMedia/:instance         → Enviar mídia
POST   /webhook/set/:instance               → Configurar webhook
```

**Autenticação:** Header `apikey: SUA_API_KEY`

---

> **Dica de Produção:** Em ambientes de produção, configure o **HTTPS/TLS** em todos os endpoints e use variáveis de ambiente para todas as chaves de API. Nunca exponha o `evolution-api` diretamente na internet sem autenticação adequada.

> **Monitoramento:** Use o OpenTelemetry integrado no `evo-ai-processor` para rastrear execuções de agentes, latências e falhas. Configure um backend compatível como Jaeger, Grafana Tempo ou Honeycomb.
