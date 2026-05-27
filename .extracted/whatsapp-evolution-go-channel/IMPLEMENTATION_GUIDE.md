# Guia de Implementação para IA

## INSTRUÇÕES PARA O AGENTE DE IA
Você está recebendo um pacote de componentes extraído do projeto **evo-ai-frontend-community** (React + TypeScript + @evoapi/design-system).

Este pacote contém o fluxo completo de **Canal WhatsApp / Evolution Go**:
1. Criação de canal (Novo Canal → WhatsApp → Evolution Go)
2. Aba "Configurações do Canal" (BasicSettingsForm)
3. Aba "Modelos de Mensagem" (MessageTemplateForm)
4. Aba "Configuração" (ConfigurationForm — Evolution Go)

---

## Pré-requisitos
- [ ] `@evoapi/design-system` disponível com: Card, Button, Input, Select, Dialog, Badge, Switch, Tabs, Skeleton, Textarea, Table, Toast
- [ ] `lucide-react` instalado
- [ ] `sonner` instalado
- [ ] `react-router-dom` v6+ instalado
- [ ] Hook `useLanguage` disponível com as chaves de i18n dos namespaces `channels` e `whatsapp`
- [ ] `GlobalConfigContext` expondo `hasEvolutionGoConfig: boolean`
- [ ] `InboxesService` com métodos: `getById`, `create`, `update`, `updateWithAvatar`
- [ ] `EvolutionGoService` com métodos: `healthCheck`, `verifyConnection`, `deleteInstance`, `refreshQrCode`, `setSettings`
- [ ] `EvolutionApiService` (em `channelConfigurationService`) com métodos: `getSettings`, `updateSettings`, `getInstances`, `getQRCode`, `logout`, `fetchPrivacySettings`, `updatePrivacySettings`, `updateProfileName`, `updateProfileStatus`, `updateProfilePicture`, `removeProfilePicture`
- [ ] `MessageTemplateService` com CRUD de templates
- [ ] `sanitizeInboxName` utilitário disponível
- [ ] `PhoneInput` componente disponível

---

## Ordem de Implementação

1. **Types** — `DATA_STRUCTURE.md`: implementar/verificar interfaces `WhatsappEvolutionGoPayload`, `EvolutionGoConnectionParams`, `EvolutionGoAuthorizationResponse`
2. **Services** — copiar/adaptar `evolutionGoService.ts` e as partes `EvolutionApiService` de `channelConfigurationService.ts`
3. **Hook `useChannelForm`** — adicionar o case `evolution_go` nos defaults de `handleProviderSelect`
4. **Hook `useChannelSubmission`** — adicionar o case `evolution_go` em `testConnection()` e `submitCreate()`
5. **Componente `EvolutionGoForm`** — formulário de criação
6. **Componente `WhatsappForms/index`** — roteador que renderiza `EvolutionGoForm` para `provider.id === 'evolution_go'`
7. **Componente `BasicSettingsForm`** — aba "Configurações do Canal" (provavelmente já existe no destino)
8. **Componente `MessageTemplateForm`** — aba "Modelos de Mensagem"
9. **Componente `ConfigurationForm`** — adicionar o case `evolution_go` (`EvolutionWhatsAppConfig` + `EvolutionPrivacySettings`)
10. **Página `ChannelSettings`** — adicionar `evolution_go` nas flags `isAWhatsAppEvolutionGoChannel` e configurar tab "Configuração"
11. **Página `NewChannel`** — garantir fluxo WhatsApp → Evolution Go funcional

---

## Mapeamento de Adaptação

| Original (Projeto Origem) | Adaptar Para (Projeto Destino) |
|---------------------------|-------------------------------|
| `@evoapi/design-system` | Substituir pelo design system do destino |
| `@/hooks/useLanguage` | Adaptar ao sistema de i18n do destino |
| `@/contexts/GlobalConfigContext` | Adaptar ao contexto de config global do destino |
| `@/services/core/api` | Adaptar ao cliente HTTP do destino |
| `@/store/appDataStore` | Adaptar ao state manager do destino |
| `@/utils/sanitizeName` | Reusar ou recriar a função |
| `useChannelValidation` | Adaptar validações ao destino |
| Import paths `@/` | Ajustar para o path alias do destino |

---

## Pontos de Atenção

### Segurança
- **NUNCA** pré-popular o campo `adminToken` com o valor salvo no backend — risco de exposição do segredo no DOM
- Apenas enviar `api_url` e `admin_token` no payload quando `hasEvolutionGoConfig === false`
- O campo `name` (Nome do Canal) deve ser sempre gerado via `sanitizeInboxName(display_name)` e readonly

### Evolution Go vs Evolution (normal)
- `getIdentifier()`: Evolution Go usa `instance_uuid`, Evolution usa `instance_name`
- `ignoreStatus` é o **inverso** de `readStatus` na UI (ver RN-014)
- `groupsIgnore` (frontend) → `ignoreGroups` (API Evolution Go)
- Evolution Go **não tem** campo `syncFullHistory`
- `msgCall` não é usado no Evolution Go (mas pode ser mantido no estado)
- Privacy settings: Evolution Go tem conjunto menor de opções (sem `contact_blacklist`)

### Cleanup de instância pendente
- Manter o `pendingInstanceRef` para garantir que instâncias criadas no Evolution Go mas sem inbox correspondente no CRM sejam deletadas
- O cleanup deve ocorrer em: unmount, `beforeunload`, erro no `createChannel`

### Polling de status
- O polling de status (a cada 3s) só ocorre quando `showQrModal === true`
- Fechar o modal cancela o polling automaticamente via cleanup do `useEffect`

---

## Regras de Negócio Críticas
→ Ver `BUSINESS_RULES.md` — especialmente RN-001 a RN-020

---

## Código de Referência Pronto para Copiar

### Detecção do provider Evolution Go no ChannelSettings
```typescript
const isAWhatsAppEvolutionGoChannel =
  channelType === 'Channel::Whatsapp' && provider === 'evolution_go';
```

### getIdentifier() para Evolution Go
```typescript
const getIdentifier = () => {
  const providerConfig = inbox?.provider_config || {};
  if (inbox?.provider === 'evolution_go') {
    return (
      providerConfig.instance_uuid ||
      providerConfig.instance_id ||
      providerConfig.instanceId ||
      providerConfig.instance_name ||
      null
    );
  }
  return providerConfig.instance_name || providerConfig.instanceName || inbox?.name || null;
};
```

### Conversão ignoreStatus ↔ readStatus
```typescript
// Ao carregar (API → UI):
readStatus: !ignoreStatus  // inverte

// Ao salvar (UI → API):
ignoreStatus: !instanceSettings.readStatus  // inverte

// groupsIgnore → ignoreGroups:
ignoreGroups: instanceSettings.groupsIgnore
```

### Payload de criação Evolution Go
```typescript
const providerConfig: any = {
  instance_name: getStr(form, 'instance_name') || getStr(form, 'name'),
  instance_uuid: verify?.instance_uuid || getStr(form, 'instance_uuid'),
  instance_token: verify?.instance_token || getStr(form, 'instance_token'),
  always_online: !!form.alwaysOnline,
  reject_call: !!form.rejectCall,
  read_messages: !!form.readMessages,
  ignore_groups: !!form.ignoreGroups,
  ignore_status: !!form.ignoreStatus,
};
// Apenas se !hasEvolutionGoConfig:
if (!useGlobalConfig) {
  providerConfig.api_url = getStr(form, 'api_url');
  providerConfig.admin_token = getStr(form, 'admin_token');
}
```

### Privacy options Evolution Go
```typescript
const privacyFieldOptions = {
  readreceipts: [{ value: 'all' }, { value: 'none' }],
  profile:      [{ value: 'all' }, { value: 'contacts' }, { value: 'none' }],
  status:       [{ value: 'all' }, { value: 'contacts' }, { value: 'none' }],
  online:       [{ value: 'all' }, { value: 'match_last_seen' }],
  last:         [{ value: 'all' }, { value: 'contacts' }, { value: 'none' }],
  groupadd:     [{ value: 'all' }, { value: 'contacts' }, { value: 'none' }],
};
```

### Tab de Configuração condicional para WhatsApp/Evolution Go
```typescript
if (
  isATwilioChannel || isALineChannel || isAPIInbox ||
  (isAnEmailChannel && !inbox?.provider) ||
  isAWhatsAppChannel || isAWebWidgetInbox
) {
  baseTabs.push({ key: 'configuration', name: 'Configuração', icon: Settings });
}
```
