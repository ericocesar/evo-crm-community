# Jornada do Cliente Automatizada — Pré-Qualificação e Onboarding via WhatsApp com IA

> **Versão via Interface — Ponto de partida:** sistema em execução, instância WhatsApp já conectada.
> Este manual cobre exclusivamente a configuração pelo painel web do BChat CRM. Nenhum comando de terminal é necessário.

---

## Sumário

- [Visão Geral do Fluxo](#visão-geral-do-fluxo)
- [Parte 1 — Vincular o Canal WhatsApp ao CRM](#parte-1--vincular-o-canal-whatsapp-ao-crm)
- [Parte 2 — Estrutura de Dados do CRM](#parte-2--estrutura-de-dados-do-crm)
  - [2.1 Atributos customizados de contato](#21-atributos-customizados-de-contato)
  - [2.2 Atributos customizados de conversa](#22-atributos-customizados-de-conversa)
  - [2.3 Labels de controle de fluxo](#23-labels-de-controle-de-fluxo)
  - [2.4 Times de atendimento](#24-times-de-atendimento)
- [Parte 3 — Agente de IA (Pré-Qualificação)](#parte-3--agente-de-ia-pré-qualificação)
  - [3.1 Criar o agente no painel](#31-criar-o-agente-no-painel)
  - [3.2 System Prompt do agente qualificador](#32-system-prompt-do-agente-qualificador)
  - [3.3 Vincular o agente ao canal WhatsApp](#33-vincular-o-agente-ao-canal-whatsapp)
- [Parte 4 — Agente de IA (Onboarding)](#parte-4--agente-de-ia-onboarding)
  - [4.1 Criar o agente de onboarding](#41-criar-o-agente-de-onboarding)
  - [4.2 System Prompt do agente de onboarding](#42-system-prompt-do-agente-de-onboarding)
- [Parte 5 — Automações de Roteamento](#parte-5--automações-de-roteamento)
  - [5.1 Automação de entrada](#51-automação-de-entrada)
  - [5.2 Automação: Hot Lead](#52-automação-hot-lead)
  - [5.3 Automação: Cold Lead](#53-automação-cold-lead)
  - [5.4 Automação: Lead Desqualificado](#54-automação-lead-desqualificado)
  - [5.5 Automação: Transição para Onboarding](#55-automação-transição-para-onboarding)
- [Parte 6 — Validação e Teste](#parte-6--validação-e-teste)

---

## Visão Geral do Fluxo

```
Cliente envia 1ª mensagem pelo WhatsApp
        │
        ▼
  Agente "Ana" inicia (pré-qualificação)
  3 perguntas → análise com IA
        │
   ┌────┴────────────────┐
   │                     │
   ▼                     ▼
Hot / Warm lead       Cold / Desqualificado
   │                     │
   ▼                     ▼
Agente "Carlos"       Nurturing automático
(onboarding)          ou encerramento
```

**Onde cada configuração é feita no painel:**

| O que configurar | Menu no painel |
|---|---|
| Canal / Inbox WhatsApp | Configurações → Canais |
| Atributos de contato/conversa | Configurações → Atributos |
| Labels | Configurações → Labels |
| Times | Configurações → Times |
| Agentes de IA | Menu lateral → Agentes de IA |
| Automações | Menu lateral → Automações |

---

## Parte 1 — Vincular o Canal WhatsApp ao CRM

> **Premissa:** a instância WhatsApp já está conectada no Evolution API (estado `open`). Esta parte apenas cria o canal (inbox) no CRM apontando para ela.

**Navegue para:** `Configurações → Canais → Novo Canal`

1. Clique em **Novo Canal**
2. Selecione o tipo: **WhatsApp**
3. Escolha o provedor: **Evolution API** (Baileys) ou **WhatsApp Cloud** conforme sua instância
4. Preencha os campos:

| Campo | Valor |
|---|---|
| Nome do canal | `WhatsApp Atendimento` |
| Número do telefone | número com DDI (ex: `+5511999999999`) |
| URL da API | endereço interno da Evolution API (ex: `http://evolution-api:8080`) |
| API Key | chave da variável `EVOLUTION_API_KEY` do `.env` |
| Nome da instância | nome exato da instância conectada (ex: `atendimento-whatsapp`) |

5. Clique em **Criar Canal**
6. Na tela seguinte, em **Colaboradores**, adicione os agentes humanos que farão atendimento manual quando necessário
7. Clique em **Finalizar**

> Anote o nome do canal criado — você vai precisar dele ao configurar as automações.

---

## Parte 2 — Estrutura de Dados do CRM

### 2.1 Atributos customizados de contato

**Navegue para:** `Configurações → Atributos → Aba "Contato" → Adicionar Atributo`

Crie os seguintes atributos **um a um**. Para cada um, clique em **Adicionar Atributo**, preencha e salve:

---

**Atributo 1 — Tipo de Cliente**

| Campo | Valor |
|---|---|
| Nome de exibição | `Tipo de Cliente` |
| Chave | `tipo_cliente` (preenchida automaticamente) |
| Tipo | Lista |
| Opções da lista | `empresa`, `autonomo`, `pessoa_fisica`, `parceiro` |

---

**Atributo 2 — Porte da Empresa**

| Campo | Valor |
|---|---|
| Nome de exibição | `Porte da Empresa` |
| Chave | `porte_empresa` |
| Tipo | Lista |
| Opções | `micro`, `pequena`, `media`, `grande`, `nao_se_aplica` |

---

**Atributo 3 — Segmento**

| Campo | Valor |
|---|---|
| Nome de exibição | `Segmento` |
| Chave | `segmento` |
| Tipo | Texto |

---

**Atributo 4 — Interesse Principal**

| Campo | Valor |
|---|---|
| Nome de exibição | `Interesse Principal` |
| Chave | `interesse_principal` |
| Tipo | Lista |
| Opções | `produto_a`, `produto_b`, `consultoria`, `parceria`, `outro` |

---

**Atributo 5 — Score de Qualificação**

| Campo | Valor |
|---|---|
| Nome de exibição | `Score de Qualificação` |
| Chave | `score_qualificacao` |
| Tipo | Número |

---

**Atributo 6 — Perfil de Atendimento**

| Campo | Valor |
|---|---|
| Nome de exibição | `Perfil de Atendimento` |
| Chave | `perfil_atendimento` |
| Tipo | Lista |
| Opções | `hot_lead`, `warm_lead`, `cold_lead`, `onboarding`, `suporte`, `parceiro` |

---

**Atributo 7 — CNPJ / CPF**

| Campo | Valor |
|---|---|
| Nome de exibição | `CNPJ / CPF` |
| Chave | `documento` |
| Tipo | Texto |

---

**Atributo 8 — Nome da Empresa**

| Campo | Valor |
|---|---|
| Nome de exibição | `Nome da Empresa` |
| Chave | `nome_empresa` |
| Tipo | Texto |

---

**Atributo 9 — Cargo**

| Campo | Valor |
|---|---|
| Nome de exibição | `Cargo` |
| Chave | `cargo` |
| Tipo | Texto |

---

**Atributo 10 — Qualificado Em**

| Campo | Valor |
|---|---|
| Nome de exibição | `Qualificado Em` |
| Chave | `qualificado_em` |
| Tipo | Data |

---

**Atributo 11 — Etapa do Onboarding**

| Campo | Valor |
|---|---|
| Nome de exibição | `Etapa do Onboarding` |
| Chave | `etapa_onboarding` |
| Tipo | Lista |
| Opções | `nao_iniciado`, `dados_coletados`, `conta_ativa`, `treinamento`, `concluido` |

---

### 2.2 Atributos customizados de conversa

**Navegue para:** `Configurações → Atributos → Aba "Conversa" → Adicionar Atributo`

---

**Atributo 1 — Motivo do Contato**

| Campo | Valor |
|---|---|
| Nome de exibição | `Motivo do Contato` |
| Chave | `motivo_contato` |
| Tipo | Lista |
| Opções | `pre_qualificacao`, `onboarding`, `suporte`, `comercial`, `financeiro`, `outro` |

---

**Atributo 2 — Fase da Conversa**

| Campo | Valor |
|---|---|
| Nome de exibição | `Fase da Conversa` |
| Chave | `fase_conversa` |
| Tipo | Lista |
| Opções | `qualificacao`, `onboarding`, `atendimento_humano`, `nurturing`, `encerrado` |

---

### 2.3 Labels de controle de fluxo

**Navegue para:** `Configurações → Labels → Nova Label`

Crie cada label com o nome, descrição e cor indicados:

| Nome | Descrição | Cor sugerida |
|---|---|---|
| `em-qualificacao` | Contato em qualificação automática | Roxo `#9C27B0` |
| `hot-lead` | Lead quente — alta intenção de compra | Vermelho `#F44336` |
| `warm-lead` | Lead morno — interesse moderado | Laranja `#FF9800` |
| `cold-lead` | Lead frio — baixa intenção imediata | Azul `#2196F3` |
| `em-onboarding` | Em processo de onboarding automatizado | Verde `#4CAF50` |
| `onboarding-concluido` | Onboarding concluído com sucesso | Ciano `#00BCD4` |
| `aguardando-humano` | Aguardando atendimento humano | Laranja escuro `#FF5722` |
| `nurturing` | Em fluxo de nurturing automatizado | Cinza `#607D8B` |
| `lead-desqualificado` | Lead fora do perfil de cliente | Cinza claro `#9E9E9E` |

Para cada label: clique em **Nova Label** → preencha o **Nome**, a **Descrição** → escolha a **Cor** → ative **Mostrar na barra lateral** se desejar → **Salvar**.

---

### 2.4 Times de atendimento

**Navegue para:** `Configurações → Times → Novo Time`

Crie os quatro times abaixo:

| Nome | Descrição |
|---|---|
| `Comercial — Hot Leads` | Recebe leads quentes para fechamento rápido |
| `Comercial — Warm Leads` | Recebe leads mornos para nutrição ativa |
| `Onboarding` | Acompanha novos clientes no processo de cadastro |
| `Suporte Técnico` | Atendimento pós-venda e suporte |

Para cada time:
1. Clique em **Novo Time**
2. Preencha **Nome** e **Descrição**
3. Clique em **Criar Time**
4. Na tela seguinte, adicione os **colaboradores** responsáveis por cada time
5. Clique em **Adicionar Colaboradores**

---

## Parte 3 — Agente de IA (Pré-Qualificação)

### 3.1 Criar o agente no painel

**Navegue para:** Menu lateral → `Agentes de IA → Novo Agente`

Preencha o formulário com:

| Campo | Valor |
|---|---|
| Nome | `Ana — Qualificadora de Leads` |
| Descrição | `Agente de pré-qualificação: conduz perguntas estratégicas, analisa o perfil do lead e roteia para o atendimento correto` |
| Provedor LLM | `Google Gemini` (ou OpenAI, Anthropic — conforme suas credenciais) |
| Modelo | `gemini-2.0-flash` |
| Temperatura | `0.2` |

Na aba **Ferramentas**, habilite as seguintes tools:

| Tool | Finalidade |
|---|---|
| `update_contact_attributes` | Salva tipo_cliente, score, perfil no contato |
| `update_conversation_attributes` | Salva fase_conversa, motivo_contato |
| `add_label` | Adiciona hot-lead, warm-lead, cold-lead etc. |
| `get_contact_info` | Lê dados existentes (evita repetir perguntas) |

Clique em **Salvar Agente**.

---

### 3.2 System Prompt do agente qualificador

Na aba **Instruções do Sistema** do agente "Ana", cole o texto abaixo.
Substitua os valores entre `[COLCHETES]` pelos dados reais da sua empresa:

```
# IDENTIDADE
Você é Ana, assistente virtual de pré-qualificação da [NOME DA EMPRESA].
Seu único objetivo nesta conversa é qualificar o contato e identificar
o perfil de atendimento adequado.

Tom: profissional, amigável, objetivo e empático.
Idioma: português do Brasil.
Limite de mensagem: UMA mensagem por resposta, máximo 3 linhas.
Não use asteriscos para negrito. Use linguagem simples.

# CONTEXTO DO CLIENTE
- Empresa: [NOME DA EMPRESA]
- Produtos/serviços: [DESCREVA BREVEMENTE O QUE A EMPRESA OFERECE]
- Perfil ideal de cliente: [DESCREVA O ICP — ex: "empresas B2B com 10+ funcionários no setor de varejo"]

# FLUXO OBRIGATÓRIO (siga rigorosamente esta ordem)

## ETAPA 0 — Boas-vindas
Na PRIMEIRA mensagem do contato, sempre responda com:
"Olá! Sou a Ana, assistente da [EMPRESA]. Para te direcionar ao atendimento certo, preciso fazer 3 perguntinhas rápidas. Pode ser? 😊"

Aguarde a resposta antes de continuar.

## ETAPA 1 — Identificar o tipo de contato
Após receber confirmação ou qualquer resposta positiva, pergunte:
"Você representa uma empresa ou está entrando em contato como pessoa física?"

Aguarde. Interprete variações: "empresa", "negócio", "CNPJ", "firma" = empresa.
"eu mesmo", "pessoal", "CPF", "freelancer", "autônomo" = pessoa física.

## ETAPA 2 — Entender a necessidade
Com base na resposta anterior, pergunte:
- Se EMPRESA: "Qual é o principal desafio que sua empresa enfrenta hoje em [ÁREA RELEVANTE AO PRODUTO]?"
- Se PESSOA FÍSICA: "O que te levou a nos contatar hoje? O que você está buscando?"

Aguarde a resposta. Interprete livremente — não force escolhas pré-definidas.

## ETAPA 3 — Avaliar o momento de compra
Pergunte:
"Você está avaliando soluções para implementar em quanto tempo?
1 — Agora, tenho urgência
2 — Nos próximos 1 a 3 meses
3 — Estou apenas pesquisando por enquanto"

Aceite número ou texto equivalente.

## ETAPA 4 — Análise e classificação

Com base nas 3 respostas, classifique o lead:

HOT LEAD (score 80-100):
- Representa empresa E tem problema claro relacionado ao nosso produto E urgência imediata
- Ou menciona orçamento aprovado, decisor, prazo definido

WARM LEAD (score 50-79):
- Representa empresa OU tem necessidade clara E prazo de 1-3 meses
- Mostra interesse genuíno mas sem urgência imediata

COLD LEAD (score 10-49):
- Apenas pesquisando, sem prazo definido
- Pessoa física sem fit claro com o ICP
- Necessidade vaga ou sem relação com nosso produto

DESQUALIFICADO (score 0-9):
- Concorrente, estudante pesquisando, imprensa, parceiro (tratar separado)
- Não tem o problema que resolvemos

## ETAPA 5 — Resposta de fechamento

Após classificar, envie UMA mensagem de fechamento E registre os atributos.

Para HOT LEAD:
"Ótimo! Com base no que você me contou, vou conectar você diretamente com
nosso especialista. Ele entrará em contato em até [X minutos/horas]. 🚀"

Para WARM LEAD:
"Entendido! Vou encaminhar seu contato para nossa equipe comercial que
entrará em contato em breve com informações relevantes para você. 😊"

Para COLD LEAD:
"Obrigada pelas informações! Vou te enviar nosso material de apresentação
para você conhecer melhor o que fazemos. Qualquer dúvida, é só chamar! 📚"

Para DESQUALIFICADO:
"Obrigada por entrar em contato! No momento não temos um produto específico
para sua necessidade, mas vou registrar seu contato para futuras novidades. 🙏"

# REGISTRO OBRIGATÓRIO DE ATRIBUTOS

Ao final da qualificação, SEMPRE registre usando as ferramentas disponíveis:

update_contact_attributes:
  - tipo_cliente: "empresa" | "autonomo" | "pessoa_fisica"
  - interesse_principal: resumo da necessidade identificada (texto livre, máx 50 chars)
  - score_qualificacao: número de 0 a 100 conforme classificação
  - perfil_atendimento: "hot_lead" | "warm_lead" | "cold_lead" | "desqualificado"
  - qualificado_em: data de hoje (formato ISO: YYYY-MM-DD)

update_conversation_attributes:
  - motivo_contato: "pre_qualificacao"
  - fase_conversa: "qualificacao"

add_label: conforme classificação
  - hot_lead → label "hot-lead"
  - warm_lead → label "warm-lead"
  - cold_lead → label "cold-lead"
  - desqualificado → label "lead-desqualificado"

# REGRAS CRÍTICAS

1. Faça UMA pergunta por mensagem — nunca duas ao mesmo tempo
2. Se o contato desviar do assunto, redirecione gentilmente:
   "Entendo! Vou anotar isso. Mas para te ajudar melhor, preciso terminar
   essas perguntinhas rápidas. [RETOME A PERGUNTA ATUAL]"
3. Se a resposta for ambígua, peça esclarecimento uma vez. Se não conseguir
   classificar, use "warm_lead"
4. NUNCA forneça preços, prazos ou informações técnicas
5. Após 2 mensagens sem resposta do contato, envie:
   "Ainda por aí? 😊 Pode me responder quando quiser!"
6. Após 3 tentativas sem resposta, encerre como "cold_lead":
   "Sem problemas! Se quiser continuar, é só nos chamar novamente."
```

Clique em **Salvar** após colar o prompt.

---

### 3.3 Vincular o agente ao canal WhatsApp

**Navegue para:** `Configurações → Canais → (clique no canal WhatsApp criado) → Configuração de Agente de IA`

1. Clique na aba **Configuração de Agente de IA**
2. Em **Agente de IA**, selecione `Ana — Qualificadora de Leads`
3. Configure:

| Opção | Valor |
|---|---|
| Status da conversa para ativar o bot | `Pendente` e `Aberto` |
| Tempo de debounce | `3000` ms (aguarda 3s após última mensagem antes de processar) |

4. Clique em **Salvar configurações**

---

## Parte 4 — Agente de IA (Onboarding)

### 4.1 Criar o agente de onboarding

**Navegue para:** `Agentes de IA → Novo Agente`

| Campo | Valor |
|---|---|
| Nome | `Carlos — Onboarding` |
| Descrição | `Agente de onboarding: coleta dados de cadastro, explica próximos passos e ativa a conta do cliente` |
| Provedor LLM | mesmo do agente Ana |
| Modelo | `gemini-2.0-flash` |
| Temperatura | `0.15` |

Na aba **Ferramentas**, habilite:

| Tool | Finalidade |
|---|---|
| `update_contact_attributes` | Salva nome, email, empresa, CNPJ, cargo |
| `update_conversation_attributes` | Atualiza fase_conversa para "onboarding" |
| `add_label` | Adiciona "em-onboarding", "onboarding-concluido" |
| `get_contact_info` | Lê dados já coletados pela Ana (não repete perguntas) |

Clique em **Salvar Agente**.

---

### 4.2 System Prompt do agente de onboarding

Na aba **Instruções do Sistema** do agente "Carlos":

```
# IDENTIDADE
Você é Carlos, especialista de onboarding da [NOME DA EMPRESA].
Sua missão é guiar o novo cliente pelo processo de cadastro de forma
simples, rápida e humanizada.

Tom: acolhedor, paciente, celebrativo em marcos.
Idioma: português do Brasil.
Uma mensagem por resposta, objetiva e clara.

# CONTEXTO
Este cliente já foi pré-qualificado como lead quente ou morno.
Dados já coletados estão disponíveis nos atributos do contato —
NUNCA peça informações que já estão preenchidas.

Antes de iniciar, use get_contact_info para verificar o que já
existe no cadastro do contato.

# FLUXO DE ONBOARDING

## ETAPA 0 — Boas-vindas
"Olá, {{contact.name}}! Sou o Carlos, do time de onboarding da [EMPRESA]. 
Vou te ajudar a configurar tudo rapidinho para você começar a usar 
nosso [PRODUTO/SERVIÇO]. Tudo bem?"

## ETAPA 1 — Confirmação de dados básicos
Verifique get_contact_info. Pergunte somente o que estiver VAZIO:

Se nome não preenchido:
"Qual é o seu nome completo?"

Se e-mail não preenchido:
"Qual e-mail você usará para acessar a plataforma?"

## ETAPA 2 — Dados da empresa (somente se tipo_cliente = "empresa")
Somente pergunte o que não estiver preenchido:

Se nome_empresa vazio: "Qual é o nome da sua empresa?"
Se documento (CNPJ) vazio: "Qual o CNPJ da empresa? (pode pular respondendo 'pular')"
Se cargo vazio: "Qual é o seu cargo na empresa?"

## ETAPA 3 — Confirmação do interesse
"Para personalizar sua experiência, você está interessado principalmente em:
1 — [FUNCIONALIDADE/PRODUTO A]
2 — [FUNCIONALIDADE/PRODUTO B]
3 — [FUNCIONALIDADE/PRODUTO C]
4 — Gostaria de uma demonstração completa primeiro"

## ETAPA 4 — Próximos passos

Se interesse 1, 2 ou 3 (produto específico):
"Perfeito! Vou criar seu acesso agora. Em instantes você receberá
um e-mail em [e-mail do cliente] com seus dados de acesso."

Se interesse 4 (demonstração):
"Ótimo! Qual o melhor horário: manhã (9h-12h), tarde (13h-17h) ou noite (17h-19h)?"
→ "E qual o melhor dia — essa semana ou semana que vem?"
→ Registrar em update_conversation_attributes: agendamento = "[dia] às [horário]"
→ "Anotado! [Nome do responsável] entrará em contato para confirmar."

## ETAPA 5 — Conclusão

"Pronto, {{contact.name}}! 🎉 Seu cadastro está completo.
✅ Dados básicos registrados
✅ Interesse: [interesse_identificado]
✅ Próximo passo: [ação específica]

Nosso time está disponível em [número de suporte] ou [suporte@empresa.com].
Bem-vindo(a) à família [EMPRESA]! 🚀"

# REGISTRO OBRIGATÓRIO

Após cada dado coletado, salve com update_contact_attributes:
- nome, email, nome_empresa, documento (ou null), cargo, interesse_principal
- etapa_onboarding: "dados_coletados" → "conta_ativa" ao finalizar

Ao concluir:
- update_conversation_attributes: fase_conversa = "onboarding"
- add_label: "onboarding-concluido"

# REGRAS

1. Nunca repita perguntas de dados já preenchidos
2. Se o cliente responder "pular" a qualquer campo opcional, aceite e avance
3. NUNCA forneça senhas ou links de acesso via WhatsApp — envie por e-mail
```

Clique em **Salvar**.

> **Nota:** O agente Carlos não é vinculado diretamente ao canal. Ele é ativado pela automação de transição (Parte 5.5), que troca o agente do inbox quando a label `hot-lead` ou `warm-lead` é adicionada.

---

## Parte 5 — Automações de Roteamento

**Navegue para:** Menu lateral → `Automações → Nova Automação`

Cada automação abaixo representa uma regra. Crie-as na ordem indicada.

---

### 5.1 Automação de entrada

**Nome:** `[WA] Iniciar Pré-Qualificação`

| Campo | Valor |
|---|---|
| Evento | `Conversa criada` |

**Condições:**

| Atributo | Operador | Valor |
|---|---|---|
| Canal | é igual a | `WhatsApp Atendimento` (nome do canal criado) |

**Ações:**

| Ação | Parâmetro |
|---|---|
| Adicionar label | `em-qualificacao` |

Ative o toggle **Automação ativa** → **Salvar**.

---

### 5.2 Automação: Hot Lead

**Nome:** `[WA] Hot Lead → Comercial Urgente`

| Campo | Valor |
|---|---|
| Evento | `Conversa atualizada` |

**Condições:**

| Atributo | Operador | Valor |
|---|---|---|
| Label | contém | `hot-lead` |

**Ações (nesta ordem):**

| Ação | Parâmetro |
|---|---|
| Remover label | `em-qualificacao` |
| Atribuir time | `Comercial — Hot Leads` |
| Atribuir agente disponível | *(sem parâmetro)* |

Ative → **Salvar**.

---

### 5.3 Automação: Cold Lead

**Nome:** `[WA] Cold Lead → Nurturing`

| Campo | Valor |
|---|---|
| Evento | `Conversa atualizada` |

**Condições:**

| Atributo | Operador | Valor |
|---|---|---|
| Label | contém | `cold-lead` |

**Ações:**

| Ação | Parâmetro |
|---|---|
| Remover label | `em-qualificacao` |
| Adicionar label | `nurturing` |
| Adiar conversa | *(sem parâmetro — usa o padrão do sistema)* |

Ative → **Salvar**.

---

### 5.4 Automação: Lead Desqualificado

**Nome:** `[WA] Lead Desqualificado → Resolver`

| Campo | Valor |
|---|---|
| Evento | `Conversa atualizada` |

**Condições:**

| Atributo | Operador | Valor |
|---|---|---|
| Label | contém | `lead-desqualificado` |

**Ações:**

| Ação | Parâmetro |
|---|---|
| Remover label | `em-qualificacao` |
| Resolver conversa | *(sem parâmetro)* |

Ative → **Salvar**.

---

### 5.5 Automação: Transição para Onboarding

**Nome:** `[WA] Transição → Onboarding`

| Campo | Valor |
|---|---|
| Evento | `Conversa atualizada` |

**Condições:**

| Atributo | Operador | Operador lógico | Atributo | Operador | Valor |
|---|---|---|---|---|---|
| Label | contém | OU | Label | contém | `warm-lead` |
| `hot-lead` | | | | | |

*(Adicione duas condições com operador "OU" entre elas: label contém `hot-lead` OU label contém `warm-lead`)*

**Ações:**

| Ação | Parâmetro |
|---|---|
| Adicionar label | `em-onboarding` |
| Atribuir time | `Onboarding` |
| Trocar agente de IA | `Carlos — Onboarding` |

Ative → **Salvar**.

> **Sobre "Trocar agente de IA":** se esta ação não estiver disponível diretamente na automação, use a alternativa do agente unificado descrita abaixo.

---

**Alternativa: Agente Unificado**

Crie um único agente chamado `Atendimento Integrado` e adicione no início do seu System Prompt a verificação de fase:

```
# VERIFICAÇÃO DE FASE — executar SEMPRE no início

Use get_contact_info e verifique "perfil_atendimento" e "fase_conversa".

SE perfil_atendimento = null:
  → Executar FLUXO ANA (pré-qualificação)

SE perfil_atendimento = "hot_lead" OU "warm_lead" E fase_conversa ≠ "onboarding":
  → Executar FLUXO CARLOS (onboarding)

SE fase_conversa = "onboarding" E etapa_onboarding = "dados_coletados":
  → Retomar onboarding do ponto onde parou

SE fase_conversa = "atendimento_humano":
  → "Um momento, vou verificar com nossa equipe."
  → add_label "aguardando-humano"

[Cole aqui na sequência o System Prompt completo da Ana, depois o da Carlos]
```

Vincule este agente unificado ao canal WhatsApp (conforme seção 3.3) e use apenas uma automação de entrada (5.1).

---

## Parte 6 — Validação e Teste

### Checklist antes de ativar

```
CANAL
[ ] Canal WhatsApp aparece em Configurações → Canais com status ativo
[ ] Agente "Ana" está vinculado ao canal (aba Configuração de Agente de IA)

ATRIBUTOS
[ ] 11 atributos de contato criados (Configurações → Atributos → Contato)
[ ] 2 atributos de conversa criados (Configurações → Atributos → Conversa)

LABELS
[ ] 9 labels criadas (Configurações → Labels)

TIMES
[ ] 4 times criados com colaboradores atribuídos (Configurações → Times)

AGENTES
[ ] Agente "Ana" salvo com system prompt e ferramentas
[ ] Agente "Carlos" salvo com system prompt e ferramentas

AUTOMAÇÕES
[ ] 5 automações ativas (Automações — verificar toggle verde)
```

### Teste end-to-end

1. Envie `"Olá"` para o número do WhatsApp configurado
2. Aguarde a resposta da Ana (~5 segundos)
3. Responda como empresa com necessidade clara e urgência imediata
4. Verifique no CRM:
   - Contato criado com atributos `tipo_cliente`, `score_qualificacao`, `perfil_atendimento` preenchidos
   - Label `hot-lead` adicionada, `em-qualificacao` removida
   - Conversa atribuída ao time `Comercial — Hot Leads`

**Onde verificar no painel:**
- Conversa: clique nela → painel lateral direito → seção **Atributos da Conversa** e **Atributos do Contato**
- Contato: clique no nome do contato → aba **Atributos**
- Labels aplicadas: visíveis na lista de conversas e no topo da conversa aberta

### Problemas comuns

| Sintoma | Verificar |
|---|---|
| Agente não responde | `Agentes de IA → (agente) → Logs` — verificar erro de API key do LLM |
| Atributos não salvos | `Agentes de IA → (agente) → Ferramentas` — confirmar tools habilitadas |
| Automação não dispara | `Automações → (automação)` — confirmar toggle ativo e nome do canal correto na condição |
| Label não aparece | `Configurações → Labels` — confirmar que a label foi salva com exatamente o mesmo nome usado no system prompt |
| Agente Ana não inicia | `Configurações → Canais → (canal) → Configuração de Agente de IA` — confirmar agente selecionado e status "Pendente" ativado |

