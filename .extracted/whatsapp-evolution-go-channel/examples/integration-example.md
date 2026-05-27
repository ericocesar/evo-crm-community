# Exemplo de Integração — Projeto Destino

## Estrutura de Arquivos a Criar no Destino

```
src/
├── pages/
│   ├── NewChannel/
│   │   └── index.tsx              ← copiar de source/pages/NewChannel/index.tsx
│   └── ChannelSettings.tsx        ← copiar de source/pages/ChannelSettings.tsx
├── components/
│   ├── channels/
│   │   └── forms/
│   │       └── whatsapp/
│   │           ├── EvolutionGoForm.tsx   ← copiar de source/components/forms/whatsapp/
│   │           └── index.tsx             ← copiar de source/components/forms/whatsapp/
│   └── settings/
│       ├── BasicSettingsForm.tsx         ← copiar de source/components/settings/
│       ├── MessageTemplateForm.tsx        ← copiar de source/components/settings/
│       └── ConfigurationForm.tsx         ← copiar de source/components/settings/
├── hooks/
│   ├── useChannelForm.ts          ← copiar de source/hooks/
│   └── useChannelSubmission.ts    ← copiar de source/hooks/
└── services/
    ├── evolutionGoService.ts              ← copiar de source/services/
    └── channelConfigurationService.ts    ← copiar de source/services/
```

## Ajustes Necessários nos Import Paths

Substituir em todos os arquivos copiados:
```
@/services/channels/inboxesService   → adaptar ao path do destino
@/services/channels/evolutionGoService → adaptar
@/services/channels/channelConfigurationService → adaptar
@/services/channels/messageTemplatesService → adaptar
@/hooks/useLanguage                  → adaptar ao i18n do destino
@/contexts/GlobalConfigContext       → adaptar ao contexto de config do destino
@/services/core/api                  → adaptar ao cliente HTTP do destino
@/store/appDataStore                 → adaptar ao store do destino
@/hooks/channels/useChannelValidation → adaptar/criar validações
@/utils/sanitizeName                 → reusar ou criar `sanitizeInboxName`
@/components/shared/PhoneInput       → adaptar ao componente de telefone do destino
@evoapi/design-system                → substituir pelo design system do destino
```

## Registrar Rotas no Destino

```tsx
// react-router-dom v6
import { Routes, Route } from 'react-router-dom';

<Routes>
  <Route path="/channels/new" element={<NewChannel />} />
  <Route path="/channels/:id/settings" element={<ChannelSettings />} />
</Routes>
```

## Adicionar Chaves i18n Necessárias

Namespace `channels`:
- `settings.tabs.inbox_settings`
- `settings.tabs.messageTemplates`
- `settings.tabs.configuration`
- `settings.basicSettings.*`
- `settings.configuration.whatsapp.instance.*`
- `settings.messageTemplates.*`

Namespace `whatsapp`:
- `evolutionGoForm.fields.*`
- `evolutionGoForm.sections.instance.*`
- `evolutionGoForm.help.*`
