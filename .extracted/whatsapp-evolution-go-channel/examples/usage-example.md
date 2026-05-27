# Exemplo de Uso — Canal WhatsApp Evolution Go

## Integração do Formulário de Criação

```tsx
// Em uma página "Novo Canal" que já tem o canal selecionado como 'whatsapp'
// e o provider selecionado como 'evolution_go'

import { WhatsappForms } from '@/components/forms/whatsapp';
import { useChannelForm, useChannelSubmission } from '@/hooks/channels';

function NewChannelPage() {
  const {
    selectedChannel,
    selectedProvider,
    form,
    updateForm,
    hasEvolutionGoConfig,
  } = useChannelForm();

  const { isSubmitting, isTesting, testConnection, submitCreate, healthCheckPassed } =
    useChannelSubmission(form);

  // ... seleção de canal/provider

  return (
    <WhatsappForms
      selectedProvider={selectedProvider}
      form={form}
      onFormChange={(key, value) => updateForm({ [key]: value })}
      hasEvolutionConfig={false}
      hasEvolutionGoConfig={hasEvolutionGoConfig}
      canFB={false}
    />
  );
}
```

## Integração das Abas de Configurações

```tsx
// Em uma página de configurações de canal já existente
import { BasicSettingsForm } from '@/components/settings/BasicSettingsForm';
import { MessageTemplateForm } from '@/components/settings/MessageTemplateForm';
import { ConfigurationForm } from '@/components/settings/ConfigurationForm';

// Aba "Configurações do Canal"
<BasicSettingsForm
  formData={formData}
  inboxHook={inboxHook}
  onFormChange={handleFormChange}
  onAvatarUpload={handleAvatarUpload}
  onAvatarDelete={handleAvatarDelete}
/>

// Aba "Modelos de Mensagem"
<MessageTemplateForm
  inboxId={inboxId}
  channelType={inbox?.channel_type || ''}
  onUpdate={async () => await loadChannelData()}
/>

// Aba "Configuração" (renderiza automaticamente a UI correta para evolution_go)
<ConfigurationForm
  inboxId={inboxId}
  inbox={inbox}
  onUpdate={async (data) => {
    await InboxesService.update(inboxId, data);
    await loadChannelData();
  }}
/>
```
