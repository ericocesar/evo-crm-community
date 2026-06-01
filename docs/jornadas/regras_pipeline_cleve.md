# Regras de Configuração do Pipeline CLeve

Copie e cole as instruções abaixo exatamente nos campos de configuração de regras de pipeline do seu agente no painel do servidor remoto.

---

### 📋 1. Instruções Gerais (quando e o que fazer)
* **Limite de caracteres:** 500
* **Texto a copiar:**
```text
Gerencie o card do cliente no pipeline CLeve. Adicione a conversa ao pipeline no início do chat. Atualize o card movendo-o pelas colunas à medida que o cliente progredir: 'Novo' no primeiro contato, 'Qualificado' ao validar fatura >= R$ 200, 'Formalização' quando confirmar interesse e for transferido ao Agente 2, ou 'Finalizado' se for inelegível (fatura < 200) ou desistir. Salve os atributos personalizados do contato assim que identificados.
```

---

### 🏷️ 2. Regras de Atribuição por Estágio
* **Limite de caracteres por estágio:** 255

#### Estágio: **Novo**
```text
Adicione a conversa a este estágio no início da interação com o cliente (primeiro contato) para criar o card correspondente no pipeline CLeve.
```

#### Estágio: **Qualificado**
```text
Mova o card para este estágio quando o cliente informar que o valor médio da sua fatura de energia é igual ou superior a R$ 200,00.
```

#### Estágio: **Formalização**
```text
Mova o card para este estágio quando o cliente confirmar interesse real em prosseguir para a proposta/contratação e for transferido para o Agente 2.
```

#### Estágio: **Finalizado**
```text
Mova o card para este estágio para encerrar o caso: por desqualificação (fatura < R$ 200,00) ou desistência/sem interesse do cliente.
```

---

### 👤 3. Regras de Transferência para Atendente Humano
* **Limite de caracteres:** 255
* **Texto a copiar:**
```text
Transfira a conversa para um atendente humano se o cliente pedir explicitamente para falar com um humano/atendente, fizer perguntas complexas fora do escopo de qualificação de energia solar, ou demonstrar irritação, insatisfação ou reclamação formal.
```

