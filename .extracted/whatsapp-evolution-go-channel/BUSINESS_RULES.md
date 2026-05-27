# Regras de Negócio

## Visão Geral
Regras que governam a criação de um canal WhatsApp via Evolution Go e o gerenciamento das configurações do canal nas abas: Configurações do Canal, Modelos de Mensagem, Configuração.

---

## Regras de Criação de Canal

### RN-001: Health Check obrigatório antes de criar
- **Condição**: Quando `hasEvolutionGoConfig === false` (sem config global no admin)
- **Ação**: Executa `GET {api_url}/server/ok` e espera `{"status":"ok"}`. Se falhar, bloqueia criação.
- **Arquivo**: `hooks/useChannelSubmission.ts` — `submitCreate()` case `evolution_go`

### RN-002: Campos API URL / Admin Token opcionais com config global
- **Condição**: `hasEvolutionGoConfig === true`
- **Ação**: Os campos `api_url` e `admin_token` são ocultados do formulário e **não enviados** ao backend (segurança)
- **Arquivo**: `components/forms/whatsapp/EvolutionGoForm.tsx` — bloco `{!hasEvolutionGoConfig && ...}`

### RN-003: Nome do Canal é gerado automaticamente a partir do Nome de Exibição
- **Regra**: `name = sanitizeInboxName(display_name)` — apenas letras minúsculas, números e hífens
- **Campo**: `name` é read-only no formulário (o usuário não edita diretamente)
- **Arquivo**: `components/forms/whatsapp/EvolutionGoForm.tsx` — `handleDisplayNameChange()`

### RN-004: Verificação de conexão (verifyConnection) antes de criar inbox
- **Ação**: `EvolutionGoService.verifyConnection(payload)` com `mode: 'create'` 
- **Retorno**: `{ instance_uuid, instance_token, reused }` — esses valores são incluídos no `provider_config` do payload de criação
- **Arquivo**: `hooks/useChannelSubmission.ts`

### RN-005: Cleanup de instância pendente em caso de falha
- **Condição**: Se `verifyConnection` criou uma instância (`verify.instance_uuid` e `!verify.reused`) mas `createChannel` falhou
- **Ação**: `EvolutionGoService.deleteInstance()` é chamado para limpar a instância criada no Evolution Go
- **Arquivo**: `hooks/useChannelSubmission.ts` — `pendingInstanceRef`

### RN-006: Cleanup em unmount/beforeunload
- **Condição**: Usuário fecha a página/componente com uma instância pendente
- **Ação**: `cleanupPendingInstance()` é chamado via `useEffect` cleanup e evento `beforeunload`
- **Arquivo**: `hooks/useChannelSubmission.ts`

---

## Regras da Aba: Configurações do Canal

### RN-007: Salvamento somente disponível na aba inbox_settings
- **Condição**: `activeTab !== 'inbox_settings'`
- **Ação**: Botão "Salvar" exibe mensagem informativa ("Use o botão da aba específica"), não salva
- **Arquivo**: `pages/ChannelSettings.tsx` — `handleSave()`

### RN-008: Avatar — upload via File, remoção limpa avatar_url
- **Ação**: Upload: `InboxesService.updateWithAvatar(inboxId, payload, file)`. Remoção: `setAvatarFile(null)` + `avatar_url: undefined`
- **Arquivo**: `pages/ChannelSettings.tsx` — `handleAvatarUpload()`, `handleAvatarDelete()`

### RN-009: Nome do Canal é sanitizado ao editar Nome de Exibição
- **Regra**: Mesma que RN-003 — `name = sanitizeInboxName(display_name)`, read-only
- **Arquivo**: `components/settings/BasicSettingsForm.tsx` — `handleDisplayNameChange()`

---

## Regras da Aba: Modelos de Mensagem

### RN-010: Suporte a templates simples vs estruturados por tipo de canal
- **Regra**: `usesStructuredComponents(channelType)` determina se o canal usa templates estruturados (header/body/footer/buttons) ou simples (content text)
- **Arquivo**: `services/messageTemplatesService.ts` — `usesStructuredComponents()`

### RN-011: Validação mínima de template
- **Template simples**: `name` e `content` são obrigatórios
- **Template estruturado**: `name` e `bodyText` são obrigatórios
- **Arquivo**: `components/settings/MessageTemplateForm.tsx` — `handleSave()` do modal

### RN-012: Sincronização com provedor
- **Condição**: `supportsTemplateSync(channelType)` retorna true
- **Ação**: Botão "Sincronizar" disponível para sincronizar templates com o provedor externo
- **Arquivo**: `services/messageTemplatesService.ts`

---

## Regras da Aba: Configuração (Evolution Go)

### RN-013: Componente `EvolutionWhatsAppConfig` é compartilhado entre `evolution` e `evolution_go`
- **Regra**: `ConfigurationForm` detecta `inbox.provider === 'evolution_go'` e renderiza o mesmo componente `EvolutionWhatsAppConfig`
- **Diferenças internas**: comportamento de settings mapeado diferentemente (ver RN-014 e RN-015)
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — `ConfigurationForm` root

### RN-014: ignoreStatus é o inverso de readStatus para Evolution Go
- **Regra**: O campo da API Evolution Go chama-se `ignoreStatus`. Na UI, é apresentado como "Ignorar Status" com valor invertido
  - `ignoreStatus: true` → Switch "desativado" (não lê status)
  - `ignoreStatus: false` → Switch "ativado" (lê status)
- **Código**: Switch exibe `inbox.provider === 'evolution_go' ? !instanceSettings.readStatus : instanceSettings.readStatus`
- **Payload de update**: `ignoreStatus: !instanceSettings.readStatus`
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — `EvolutionWhatsAppConfig`

### RN-015: groupsIgnore → ignoreGroups (Evolution Go)
- **Regra**: O frontend usa `groupsIgnore` internamente, mas a API Evolution Go espera `ignoreGroups`
- **Conversão**: `ignoreGroups: instanceSettings.groupsIgnore` no payload de update
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — `handleUpdateInstanceSettings()`

### RN-016: identifier para Evolution Go é instance_uuid (não instance_name)
- **Regra**: Para `provider === 'evolution_go'`, o identificador da instância é `provider_config.instance_uuid` (fallback para `instance_id`, `instanceId`, `instance_name`)
- **Para Evolution (normal)**: identificador é `instance_name` (fallback para `instanceName`, `instance`, `inbox.name`)
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — `getIdentifier()`

### RN-017: Polling de status a cada 3 segundos enquanto QR modal está aberto
- **Condição**: `showQrModal === true`
- **Ação**: `setInterval(loadInstanceStatus, 3000)` — verifica `instance.state`
- **Auto-close**: Se `state === 'open'`, fecha modal e exibe toast de sucesso
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — segundo `useEffect` de `EvolutionWhatsAppConfig`

### RN-018: Perfil e Privacidade só disponíveis quando conectado
- **Condição**: `instanceStatus === 'open'`
- **Seções condicionais**: Profile Settings, Privacy Settings, Instance Settings
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — JSX condicional `{instanceStatus === 'open' && ...}`

### RN-019: Admin Token nunca é pré-populado na UI
- **Regra**: O campo `adminToken` no `connectionSettings` inicia com `''` — nunca exibe o token salvo
- **Motivo**: Segurança — evita expor o segredo no atributo `value` do DOM
- **Comportamento**: Apenas enviado para o backend se o usuário digitou um novo valor
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — inicialização do `connectionSettings`

### RN-020: Privacy settings — opções diferem entre evolution e evolution_go
- **evolution_go**: `readreceipts: [all, none]`, `profile: [all, contacts, none]`, `online: [all, match_last_seen]`, `groupadd: [all, contacts, none]`
- **evolution**: inclui `contact_blacklist` em profile/status/last/groupadd
- **Arquivo**: `components/settings/ConfigurationForm.tsx` — `privacyFieldOptions` em `EvolutionPrivacySettings`

---

## Validações

| Campo | Regra | Mensagem de Erro |
|-------|-------|-----------------|
| `display_name` | Obrigatório | Campo required |
| `phone_number` | Obrigatório | Campo required |
| `api_url` | Obrigatório se `!hasEvolutionGoConfig` | "URL da API é obrigatória" |
| `admin_token` | Obrigatório se `!hasEvolutionGoConfig` | (validação no hook) |
| `api_url` health | Deve retornar `{"status":"ok"}` | "Health check falhou. Verifique se a URL da Evolution Go está correta e acessível." |
| Template `name` | Obrigatório | `settings.messageTemplates.errors.requiredFields` |
| Template `content`/`bodyText` | Obrigatório | `settings.messageTemplates.errors.requiredFields` |
| Connection `apiUrl` | Obrigatório ao atualizar | `settings.configuration.whatsapp.instance.connection.errors.apiUrlRequired` |

## Permissões e Acesso

| Ação | Condição | Arquivo |
|------|----------|---------|
| Exibir campos API URL/Token | `!hasEvolutionGoConfig` | `EvolutionGoForm` |
| Exibir botão "Testar Conexão" | Provider é `evolution_go` (ou `evolution`, `notificame`, `twilio`) | `NewChannel/index.tsx` |
| Exibir tab "Configuração" | Canal é WhatsApp, API, Email (sem provider), Twilio, Line, WebWidget | `ChannelSettings.tsx` — `tabs` useMemo |
| Exibir Profile/Privacy/Settings sections | `instanceStatus === 'open'` | `ConfigurationForm.tsx` |
| Sincronizar templates | `supportsTemplateSync(channelType)` | `MessageTemplateForm.tsx` |
