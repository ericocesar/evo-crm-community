# Canal WhatsApp / Evolution Go — Criação + Configurações

## Descrição
Extração completa do fluxo de **criação de canal WhatsApp via Evolution Go** e das três abas da **página de configurações do canal**:

1. **Criação** — Menu Canais → Novo Canal → WhatsApp → Evolution Go  
2. **Aba: Configurações do Canal** — Configurações básicas (nome, avatar, webhook, etc.)  
3. **Aba: Modelos de Mensagem** — CRUD de templates de mensagens  
4. **Aba: Configuração** — Status de instância, QR Code, configurações de privacidade e instância, perfil WhatsApp, connection settings  

## Screenshot / Preview
Conforme imagem anexada pelo usuário:  
- Cabeçalho com nome do canal `canal-evocrm (canal-evocrm)` + subtítulo "Configure as configurações do seu canal"  
- Abas superiores: **Configurações do Canal** (ativa/verde), Colaboradores, Horário de Funcionamento, Pesquisa de Satisfação, Modelos de Mensagem  
- Segunda linha de abas: Configuração, Configuração de Agente de IA, Moderação  
- Card "Configurações Básicas" com Avatar do Canal, Nome de Exibição, Nome do Canal, Provedor WhatsApp (Evolution Go — somente leitura)

## Funcionalidades

### Criação de Canal (New Channel)
- Seleção de canal WhatsApp no grid de canais
- Seleção do provider Evolution Go
- Formulário com: API URL (opcional — se global config), Admin Token (opcional), Nome de Exibição, Nome do Canal (auto-sanitizado), Número de Telefone
- Campos opcionais pós-verificação: Instance UUID, Instance Token
- Configurações avançadas de instância: Always Online, Reject Call, Read Messages, Ignore Groups, Ignore Status
- Health check da URL da API antes de criar
- Verificação de conexão via `EvolutionGoService.verifyConnection()`
- Cleanup automático de instância pendente em caso de falha

### Aba: Configurações do Canal (`inbox_settings`)
- Upload / remoção de avatar
- Nome de Exibição (display_name) + Nome do Canal (name — sanitizado, read-only)
- Indicador do provedor WhatsApp (WhatsAppAPIProviderName)
- Salvamento via `InboxesService.update()` ou `InboxesService.updateWithAvatar()`

### Aba: Modelos de Mensagem (`messageTemplates`)
- Listagem paginada de templates com busca e filtros
- CRUD: criar, editar, deletar templates
- Suporte a templates simples (texto) e estruturados (header/body/footer/buttons)
- Preview em tempo real dos templates
- Sincronização com provedor (quando suportado)
- Badge de status por template

### Aba: Configuração (`configuration`) — Evolution Go
- **Status da Instância**: badge de estado (open/close/connecting) + botão de gerar QR Code
- **QR Code Modal**: exibe QR Code para conectar dispositivo, com polling de status a cada 3s
- **Configurações de Perfil** (quando conectado): nome, status/descrição, foto de perfil (URL)
- **Configurações de Privacidade** (quando conectado): read receipts, visibilidade de perfil, status, online, last seen, group add
- **Configurações de Instância** (quando conectado): alwaysOnline, rejectCall, readMessages, ignoreGroups, ignoreStatus/readStatus, mensagem de rejeição de chamada
- **Connection Settings**: API URL, Admin Token (atualizáveis pós-criação)
- **Ações**: Desconectar instância

## Stack Original
- Framework: React 18 + TypeScript
- UI Library: `@evoapi/design-system` (shadcn/ui-based) + Tailwind CSS
- State: useState / useCallback / useMemo (React local state)
- Routing: React Router DOM v6
- API: REST via Axios wrapper (`@/services/core/api`)
- Forms: Hook customizado `useChannelForm` + `useChannelSubmission`
- i18n: hook `useLanguage` com chaves de tradução

## Arquivos Incluídos

| Arquivo | Descrição | Tipo |
|---------|-----------|------|
| `source/pages/NewChannel/index.tsx` | Página "Novo Canal" completa | Page |
| `source/pages/ChannelSettings.tsx` | Página "Configurações do Canal" | Page |
| `source/components/forms/whatsapp/EvolutionGoForm.tsx` | Formulário de criação Evolution Go | Component |
| `source/components/forms/whatsapp/index.tsx` | Roteador de formulários WhatsApp | Component |
| `source/components/settings/BasicSettingsForm.tsx` | Aba "Configurações do Canal" | Component |
| `source/components/settings/MessageTemplateForm.tsx` | Aba "Modelos de Mensagem" | Component |
| `source/components/settings/ConfigurationForm.tsx` | Aba "Configuração" (Evolution Go) | Component |
| `source/hooks/useChannelForm.ts` | Hook de formulário de criação de canal | Hook |
| `source/hooks/useChannelSubmission.ts` | Hook de submissão/criação de canal | Hook |
| `source/services/evolutionGoService.ts` | Service Evolution Go API | Service |
| `source/services/channelConfigurationService.ts` | Service de configuração de canal | Service |
| `source/types/inbox.ts` | Types/interfaces (Evolution Go) | Type |

## Fluxo de Funcionamento

### Criação de Canal
1. Usuário acessa `/channels` e clica em "Novo Canal"
2. `ChannelGrid` exibe os tipos de canal disponíveis
3. Usuário seleciona **WhatsApp**
4. `ProviderSelection` exibe os providers; usuário seleciona **Evolution Go**
5. Renderiza `EvolutionGoForm` com campos: API URL (se sem config global), Admin Token, Nome de Exibição, Nome do Canal, Número de Telefone, configurações de instância
6. Usuário pode clicar em "Testar Conexão" → health check + `verifyConnection`
7. Ao submeter: health check → `verifyConnection` → `InboxesService.createChannel()` → redirect para `/channels/{id}/settings`

### Configurações do Canal
1. Usuário acessa `/channels/{id}/settings`
2. `ChannelSettings` carrega dados via `InboxesService.getById()`
3. Tabs dinâmicas são exibidas baseadas no tipo/provider do inbox
4. **Tab "Configurações do Canal"**: edita `display_name`, `name`, `avatar` → salva via `InboxesService.update()`
5. **Tab "Modelos de Mensagem"**: CRUD de templates via `MessageTemplateService`
6. **Tab "Configuração"**: detecta `isEvolutionGoChannel` → renderiza `EvolutionWhatsAppConfig` → instância status, QR Code, perfil, privacidade, settings

## Observações
- O campo `name` (Nome do Canal) é sempre derivado via `sanitizeInboxName(display_name)` — é read-only no formulário
- A API URL e Admin Token do Evolution Go podem ser configurados globalmente via `GlobalConfigContext` (`hasEvolutionGoConfig`). Quando presentes, os campos são ocultados do formulário (segurança)
- O polling do status da instância ocorre a cada 3 segundos enquanto o modal QR está aberto
- `pendingInstanceRef` garante cleanup de instâncias Evolution Go criadas mas não confirmadas em caso de erro ou unmount
- A aba "Configuração" usa `EvolutionWhatsAppConfig` tanto para `evolution` quanto para `evolution_go` — as diferenças são tratadas internamente via `inbox.provider === 'evolution_go'`
- Para Evolution Go, `ignoreStatus` é o inverso de `readStatus` (conversão explícita no código)
- Para Evolution Go, `groupsIgnore` mapeia para `ignoreGroups` na API
