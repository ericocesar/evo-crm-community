# Dependências e Pré-requisitos

## Pacotes Necessários

| Pacote | Versão | Obrigatório | Propósito |
|--------|--------|-------------|-----------|
| `react` | ^18 | Sim | Framework UI |
| `react-router-dom` | ^6 | Sim | Routing (`useParams`, `useNavigate`) |
| `sonner` | ^1 | Sim | Toast notifications |
| `lucide-react` | ^0.400 | Sim | Ícones (QrCode, Settings, Shield, etc.) |
| `@evoapi/design-system` | workspace | Sim | Componentes UI (Card, Button, Input, Dialog, Badge, Switch, Select, Tabs, Skeleton, Textarea, Table) |

## Serviços / Contextos Internos Necessários

| Recurso | Caminho | Propósito |
|---------|---------|-----------|
| `InboxesService` | `@/services/channels/inboxesService` | CRUD de inboxes |
| `EvolutionGoService` | `@/services/channels/evolutionGoService` | API Evolution Go |
| `EvolutionApiService` | `@/services/channels/channelConfigurationService` | Settings, QR, Privacy, Profile da instância |
| `MessageTemplateService` | `@/services/channels/messageTemplatesService` | CRUD de message templates |
| `useLanguage` | `@/hooks/useLanguage` | i18n (traduções) |
| `useGlobalConfig` | `@/contexts/GlobalConfigContext` | Config global (hasEvolutionGoConfig) |
| `PhoneInput` | `@/components/shared/PhoneInput` | Input de telefone com bandeira |
| `sanitizeInboxName` | `@/utils/sanitizeName` | Sanitiza nome do canal |
| `useAppDataStore` | `@/store/appDataStore` | Store Zustand (addInbox) |
| `useChannelValidation` | `@/hooks/channels/useChannelValidation` | Validação de formulários por provider |
| `TemplatePreview` | `@/components/channels/settings/TemplatePreview` | Preview de message templates |
| `getStatusBadgeKey` | `@/components/chat/message-template/templateStatus` | Status badge para templates |

## Comando de Instalação
```bash
# pnpm (projeto usa pnpm)
pnpm add sonner lucide-react react-router-dom
```

## Configurações Necessárias

### Variáveis de Ambiente / GlobalConfig
```typescript
// GlobalConfigContext deve expor:
{
  hasEvolutionGoConfig: boolean;  // true se Evolution Go está configurado globalmente
  hasEvolutionConfig: boolean;    // true se Evolution API está configurada globalmente
}
```

### Rotas
```typescript
// Rotas necessárias no projeto destino:
'/channels'              // Listagem de canais
'/channels/new'          // Criação de novo canal
'/channels/:id/settings' // Configurações do canal
```

### Backend
- Endpoint `POST /evolution_go/authorization` — verifica/cria instância Evolution Go
- Endpoint `POST /evolution_go/qrcode` — gera QR Code
- Endpoint `POST /evolution_go/settings` — atualiza settings da instância
- Endpoint `POST /evolution_go/proxy` — configura proxy
- Endpoints Evolution Go para privacidade, perfil, status, logout
- Endpoints padrão de inbox: `GET/POST/PATCH /inboxes`, `GET/POST/PATCH /message_templates`

## Dependências do Projeto Origem (contexto)
- Framework: React 18 + TypeScript
- Build: Vite 5
- Package manager: pnpm
- Design System: `@evoapi/design-system` (interno, baseado em shadcn/ui + Tailwind CSS 3)
- State management: Zustand (`useAppDataStore`)
- HTTP client: Axios (wrapper em `@/services/core/api`)
