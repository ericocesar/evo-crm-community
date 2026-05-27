# Estrutura de Dados

## Interfaces / Types Principais

### WhatsappEvolutionGoPayload (payload de criação do canal)
```typescript
export interface WhatsappEvolutionGoPayload {
  name: string;
  display_name?: string;
  channel: {
    type: 'whatsapp';
    provider: 'evolution_go';
    phone_number: string;
    provider_config?: {
      api_url?: string;           // Opcional: omitido se hasEvolutionGoConfig
      admin_token?: string;       // Opcional: omitido se hasEvolutionGoConfig
      instance_name?: string;
      instance_uuid?: string;     // Retornado por verifyConnection
      instance_token?: string;    // Retornado por verifyConnection
      always_online?: boolean;
      reject_call?: boolean;
      read_messages?: boolean;
      ignore_groups?: boolean;
      ignore_status?: boolean;
    };
  };
}
```

### EvolutionGoConnectionParams (payload para verifyConnection)
```typescript
export interface EvolutionGoConnectionParams {
  apiUrl: string;
  adminToken: string;
  instanceName: string;
  phoneNumber: string;
  mode?: 'test' | 'create';
  instanceSettings?: {
    rejectCall?: boolean;
    msgCall?: string;
    groupsIgnore?: boolean;    // nota: API Evolution Go usa ignoreGroups
    alwaysOnline?: boolean;
    readMessages?: boolean;
    syncFullHistory?: boolean;
    readStatus?: boolean;      // nota: API Evolution Go usa ignoreStatus (inverso)
  };
}
```

### EvolutionGoAuthorizationResponse
```typescript
export interface EvolutionGoAuthorizationResponse {
  success: boolean;
  instance_uuid?: string;
  instance_token?: string;
  qrcode?: string;
  error?: string;
  reused?: boolean;   // true se a instância já existia (não cria nova)
}
```

### FormData (useChannelForm — evolution_go defaults)
```typescript
// Estado do formulário de criação (evolution_go)
{
  name: string;              // ex: 'WhatsApp Evolution Go'
  phone_number: string;
  api_url: string;           // vazio se hasEvolutionGoConfig
  admin_token: string;       // vazio se hasEvolutionGoConfig
  instance_name: string;
  alwaysOnline: boolean;     // default: true
  rejectCall: boolean;       // default: true
  readMessages: boolean;     // default: true
  ignoreGroups: boolean;     // default: false
  ignoreStatus: boolean;     // default: true
  instance_uuid: string;     // preenchido após verify
  instance_token: string;    // preenchido após verify
  display_name: string;
}
```

### ChannelSettingsData (estado do formulário de settings)
```typescript
interface ChannelSettingsData {
  name: string;
  display_name: string;
  avatar_url?: string;
  webhook_url?: string;
  website_url?: string;
  welcome_title?: string;
  welcome_tagline?: string;
  widget_color?: string;
  selected_feature_flags?: string[];
  reply_time?: string;
  locale?: string | null;
  greeting_enabled: boolean;
  greeting_message: string;
  enable_email_collect: boolean;
  allow_messages_after_resolved: boolean;
  continuity_via_email: boolean;
  lock_to_single_conversation: boolean;
  default_conversation_status?: string | null;
  sender_name_type: string;
  business_name?: string;
  portal_id?: string;
}
```

### MessageTemplate (template de mensagem)
```typescript
export interface MessageTemplate {
  id: string | number;
  name: string;
  content: string;
  language: string;
  category: 'MARKETING' | 'UTILITY' | 'AUTHENTICATION';
  template_type: 'text' | 'media' | 'interactive';
  active: boolean;
  // Structured fields (WhatsApp Cloud, etc.)
  headerFormat?: 'TEXT' | 'IMAGE' | 'VIDEO' | 'DOCUMENT';
  headerText?: string;
  bodyText?: string;
  footerText?: string;
  buttons?: Array<{
    type: 'QUICK_REPLY' | 'URL' | 'PHONE_NUMBER';
    text: string;
    url?: string;
    phoneNumber?: string;
  }>;
}
```

### Inbox (tipo do canal carregado em ChannelSettings)
```typescript
// Campos relevantes para Evolution Go:
interface Inbox {
  id: string | number;
  name: string;
  display_name: string;
  channel_type: 'Channel::Whatsapp' | string;
  provider: 'evolution_go' | 'evolution' | 'whatsapp_cloud' | string;
  phone_number?: string;
  avatar_url?: string;
  greeting_enabled: boolean;
  greeting_message: string;
  allow_messages_after_resolved: boolean;
  lock_to_single_conversation: boolean;
  default_conversation_status?: string | null;
  enable_email_collect: boolean;
  provider_config?: {
    api_url?: string;
    admin_token?: string;      // nunca pré-exibido na UI
    instance_uuid?: string;
    instance_name?: string;
    instance_token?: string;
    always_online?: boolean;
    reject_call?: boolean;
    read_messages?: boolean;
    ignore_groups?: boolean;
    ignore_status?: boolean;
    mark_as_read?: boolean;
    api_key?: string;
  };
}
```

## Formato de API Request/Response

### POST /evolution_go/authorization (verifyConnection)
```json
// Request
{
  "authorization": {
    "api_url": "https://...",       // omitido se config global
    "admin_token": "...",           // omitido se config global
    "instance_name": "canal-nome",
    "phone_number": "+5511999999999",
    "mode": "create",
    "instance_settings": {
      "alwaysOnline": true,
      "rejectCall": true,
      "readMessages": true,
      "ignoreGroups": false,
      "ignoreStatus": true
    }
  }
}

// Response
{
  "success": true,
  "instance_uuid": "uuid-aqui",
  "instance_token": "token-aqui",
  "reused": false
}
```

### GET {api_url}/server/ok (health check)
```json
// Response esperado
{ "status": "ok" }
```

### PATCH /inboxes/:id (update do canal)
```json
// Request (Configurações do Canal)
{
  "id": "123",
  "name": "canal-nome",
  "display_name": "Canal Nome",
  "greeting_enabled": false,
  "greeting_message": "",
  "lock_to_single_conversation": false,
  "default_conversation_status": null
}

// Request (Configuração — connection settings)
{
  "channel": {
    "provider_config": {
      "api_url": "https://...",
      "admin_token": "..."   // omitido se não alterado
    }
  }
}
```

### POST /evolution_go/settings (update de settings da instância)
```json
// Request
{
  "api_url": "...",
  "api_hash": "...",
  "instance_name": "uuid-ou-nome",
  "instance_settings": {
    "rejectCall": true,
    "msgCall": "Não aceito chamadas",
    "ignoreGroups": false,
    "alwaysOnline": true,
    "readMessages": true,
    "ignoreStatus": false
  }
}
```

## Relações entre Entidades

```
Inbox (Canal)
  └── provider_config (Evolution Go specific)
        ├── instance_uuid  → identificador principal para APIs Evolution Go
        ├── instance_token → autenticação da instância
        ├── api_url        → URL da instância Evolution Go
        └── admin_token    → token admin (nunca exibido)

MessageTemplate
  └── inbox_id (pertence a um Inbox)

EvolutionGoInstance (via API externa)
  ├── instance.state: 'open' | 'close' | 'connecting'
  ├── privacy settings
  └── instance settings (alwaysOnline, rejectCall, etc.)
```
