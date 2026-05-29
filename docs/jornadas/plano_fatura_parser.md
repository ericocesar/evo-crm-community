# Plano: Ferramenta de Leitura de Faturas de Energia (PDF/Imagem)

## Problema

Ao enviar uma fatura de energia em PDF via chat, o agente SDR não respondeu e retornou erro.  
**Causa:** Modelos multimodais como Gemini e GPT-4o aceitam imagens (PNG/JPEG), mas ao receber um PDF com `mime_type: application/pdf` a inferência falha — seja por falta de suporte ao MIME type, seja por tamanho, seja por ausência de extração de texto estruturado.

## Solução Proposta: Tool Nativa Python no Processador

Criar uma **ferramenta ADK nativa** (`parse_fatura_energia`) que o agente pode chamar quando receber um anexo de fatura.  
A tool recebe a URL ou base64 do arquivo, extrai o texto/dados e retorna JSON estruturado com os campos necessários para qualificação.

---

## Arquitetura da Solução

```
parse_fatura_energia(url_ou_base64, content_type)
         │
         ├── PDF → pdfplumber → extrair texto bruto
         │         (fallback: pymupdf render → imagem → LLM vision)
         │
         └── Imagem (PNG/JPEG) → httpx fetch → base64 → LLM vision
                   
         → regex + LLM extraction → JSON estruturado
```

### Campos Extraídos

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| `concessionaria` | Nome da distribuidora | "CEMIG", "ENEL-SP", "LIGHT", "CELPE" |
| `numero_cliente` | Código do cliente / instalação | "1234567-8" |
| `vencimento` | Data de vencimento | "2025-07-10" |
| `valor_total` | Valor total a pagar (R$) | 245.80 |
| `consumo_kwh` | Consumo do período em kWh | 380 |
| `classe_consumidor` | Residencial / Comercial / Industrial | "Residencial" |
| `endereco` | Endereço de fornecimento | "Rua X, 100 - Bairro - Cidade/UF" |
| `numero_fatura` | Número/ID da fatura | "202506001234" |
| `periodo_consumo` | Período de referência | "MAI/2025 - JUN/2025" |
| `raw_text` | Texto bruto extraído (para debug/LLM) | "..." |

---

## Abordagens de Extração

### Opção A (Principal): pdfplumber → regex

- **Vantagens:** rápido, sem chamada adicional ao LLM, offline, determinístico
- **Desvantagens:** falha com PDFs baseados em imagem (scanned)
- **Biblioteca:** `pdfplumber`

### Opção B (Fallback): pymupdf → PNG → LLM vision

- **Quando usar:** quando Opção A não extrai texto suficiente (PDF escaneado)
- **Fluxo:** `fitz.open(pdf)` → render página como PNG → enviar ao modelo multimodal
- **Biblioteca:** `pymupdf` (fitz)

### Opção C (Imagens diretas): httpx fetch → base64 → LLM

- **Quando usar:** quando o arquivo já é uma imagem (PNG/JPEG/WEBP)
- **Fluxo:** fazer download → base64 → enviar para o modelo com prompt estruturado

---

## Plano de Implementação

### 1. Dependências — `pyproject.toml`

```toml
"pdfplumber==0.11.4",
"pymupdf==1.26.1",   # fitz — para PDF escaneados (fallback visual)
```

### 2. Estrutura de Arquivos

```
src/services/adk/tools/fatura_energia/
├── __init__.py
├── parser.py          # Lógica de extração (pdfplumber + regex)
└── tool.py            # Factory create_parse_fatura_tool()
```

### 3. Registro no `tool_builder.py`

```python
# Flag simples no agent.config
if agent_config.get("enable_fatura_parser", False):
    from src.services.adk.tools.fatura_energia import create_parse_fatura_tool
    self.tools.append(create_parse_fatura_tool())
```

### 4. Exportar em `tools/__init__.py`

```python
from .fatura_energia import create_parse_fatura_tool
```

### 5. Configuração no Agente SDR

No campo `config` do agente, adicionar:
```json
{
  "enable_fatura_parser": true
}
```

Ou via integração customizada na UI.

### 6. System Prompt do SDR — Instrução de uso

Adicionar ao prompt do agente SDR:

```
Quando o usuário enviar uma imagem ou PDF de fatura de energia:
1. Chame IMEDIATAMENTE a ferramenta `parse_fatura_energia` com a URL ou base64 do arquivo.
2. Use os dados retornados para preencher os campos de qualificação automaticamente.
3. Confirme os dados com o usuário antes de prosseguir.
4. Se `valor_total` estiver disponível, calcule a economia estimada (10% e 15%).
```

---

## Fluxo Completo de Uso

```
Usuário envia PDF/foto da fatura
        ↓
Agente SDR detecta anexo no contexto
        ↓
Chama parse_fatura_energia(url_ou_base64, content_type)
        ↓
Tool extrai: concessionaria, valor_total, consumo_kwh, vencimento, etc.
        ↓
SDR confirma dados com usuário: "Encontrei sua fatura da CEMIG, valor R$ 245. Está correto?"
        ↓
SDR chama update_contact_attributes com campos preenchidos
        ↓
SDR calcula economia e continua qualificação
```

---

## Considerações de Segurança

- **Validar MIME type** antes de processar (aceitar apenas `application/pdf`, `image/png`, `image/jpeg`, `image/webp`)
- **Limite de tamanho:** rejeitar arquivos > 10MB  
- **Nenhum dado da fatura é armazenado persistentemente** pela tool — ela apenas retorna o JSON para o agente
- **URLs externas:** usar `httpx` com timeout agressivo (15s) e sem seguir redirects de domínios arbitrários

---

## Status

- [ ] `pyproject.toml` — adicionar pdfplumber + pymupdf
- [ ] `src/services/adk/tools/fatura_energia/parser.py` — criar
- [ ] `src/services/adk/tools/fatura_energia/tool.py` — criar
- [ ] `src/services/adk/tools/fatura_energia/__init__.py` — criar
- [ ] `src/services/adk/tools/__init__.py` — exportar
- [ ] `src/services/adk/tool_builder.py` — registrar
- [ ] System prompt SDR — atualizar com instrução da tool
- [ ] `docs/jornadas/instrucoes_agentes_cleve.md` — atualizar com novo fluxo
