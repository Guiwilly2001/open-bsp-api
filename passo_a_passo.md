# Passo a passo — Deploy do OpenBSP / wakit (API + UI) num projeto Supabase novo

> Guia completo para um fork do `open-bsp-api` + UI no Cloudflare conseguir
> **conectar, enviar e receber mensagens no WhatsApp** end-to-end.
>
> Os valores reais já configurados aparecem em destaque (ref `jeprrbucvrvjopxwzood`,
> domínio `ui.andre-075.workers.dev`). Substitui pelos teus se o projeto for outro.

---

## Visão geral (ordem de execução)

| # | Etapa | Onde | Tempo |
|---|-------|------|-------|
| 1 | Conectar Supabase ao fork no GitHub | Supabase Dashboard | 3 min |
| 2 | Aguardar primeiro deploy + verificar bootstrap | Supabase SQL Editor | 2 min |
| 3 | Criar os Vault secrets (`edge_functions_url` + `edge_functions_token`) | Supabase Vault | 2 min |
| 4 | Definir os secrets da Meta nas Edge Functions | Supabase Edge Functions | 2 min |
| 5 | Configurar o webhook no Meta for Developers | developers.facebook.com | 3 min |
| 6 | Habilitar Auth providers (Email + Google) | Supabase Auth + Google Cloud | 5 min |
| 7 | Definir `VITE_*` na UI e fazer redeploy | Cloudflare Pages / Workers | 2 min |
| 8 | Testar login + envio/recepção de mensagem | UI + WhatsApp | — |

---

## 1) Conectar o Supabase ao fork no GitHub

> [!TIP]
> Pré-requisito: ter feito `fork` do repositório `open-bsp-api` e ter um projeto Supabase já criado.

1. Acede a **Supabase Dashboard → Project Settings → Integrations**
2. Em **GitHub Integration**, clica em **Authorize GitHub**
3. Na página de autorização do GitHub, clica em **Authorize Supabase**
4. De volta à página **Integrations**, escolhe o teu repositório `open-bsp-api` bifurcado
5. **Working directory**: `.` (a pasta `supabase/` está na raiz do repo)
6. **Production branch**: `main`
7. Clica **Enable integration**

A partir daqui, qualquer `git push` para a `main` dispara automaticamente:

- `supabase db push` (aplica migrations, incluindo a `20260520170000_bootstrap_self_host.sql`)
- `supabase functions deploy` (publica todas as Edge Functions)

---

## 2) Verificar o que o primeiro deploy criou automaticamente

> [!IMPORTANT]
> Depois do primeiro push, **abre o SQL Editor** do Supabase Cloud e roda este
> bloco. Em projetos novos, a migration de bootstrap é quem cria as extensions
> e a tabela legada `supabase_functions.hooks` — sem isto, mensagens chegam ao
> webhook mas **não persistem** em `public.messages`.

```sql
-- Extensions necessárias
select extname, n.nspname as schema
from pg_extension e
join pg_namespace n on n.oid = e.extnamespace
where extname in ('pg_net','supabase_vault','pgcrypto','pg_cron','moddatetime')
order by extname;

-- Tabela legada usada pelos triggers
select to_regclass('supabase_functions.hooks') as hooks_table;
```

Resultado esperado: **5 linhas** na primeira query e `supabase_functions.hooks`
(não-nulo) na segunda.

Se algo faltar, abre **Project → Database → Extensions** e ativa manualmente
a extension em falta — depois re-roda a migration via novo push.

---

## 3) Criar os Vault secrets

Os triggers de banco (`public.edge_function`, `public.dispatcher_edge_function`)
e os jobs do `pg_cron` leem destes dois segredos para saber **para onde** chamar
as Edge Functions e **com que token**.

| Nome | Valor |
|------|-------|
| `edge_functions_url`   | `https://jeprrbucvrvjopxwzood.supabase.co/functions/v1` |
| `edge_functions_token` | A tua **service_role key** (ou uma `sb_secret_*` equivalente) |

**Onde achar a `service_role key`:**

Supabase Dashboard → **Project Settings → API → API Keys** → secção
**service_role** (começa por `eyJhbGciOi...` ou `sb_secret_...`).

> [!WARNING]
> A `service_role` dá acesso total ao banco. **Não** colar no frontend, **não**
> partilhar em chat público. Só no Vault.

**Como criar (Dashboard):**

1. Supabase → **Project Settings → Vault → Secrets → Add new secret**
2. Cria o primeiro:
   - **Name**: `edge_functions_url`
   - **Value**: `https://jeprrbucvrvjopxwzood.supabase.co/functions/v1`
3. Cria o segundo:
   - **Name**: `edge_functions_token`
   - **Value**: *(cola a service_role key)*
4. **Save** em cada um.

Verificação:

```sql
select name from vault.decrypted_secrets
where name in ('edge_functions_url','edge_functions_token');
```

Deve retornar **2 linhas**.

---

## 4) Secrets da Meta nas Edge Functions

**Onde**: Supabase Dashboard → **Edge Functions → Secrets** (ou
**Project Settings → Edge Functions → Manage secrets**).

Adiciona os 4 secrets abaixo (estão no teu `api/supabase/functions/.env`):

| Secret | Onde obter |
|--------|------------|
| `META_APP_ID`                   | Meta App Dashboard → App Settings → Basic → **App ID** (ex.: `2778440829171966`) |
| `META_APP_SECRET`               | Mesma tela → **App Secret** |
| `WHATSAPP_VERIFY_TOKEN`         | Uma string aleatória — vais reusar no passo 5 (ex.: `c6917070-060a-405c-a1e5-767141a77853`) |
| `META_SYSTEM_USER_ACCESS_TOKEN` | Meta Business Suite → Settings → Users → System users → **Access token** (escopo `whatsapp_business_*`) |

Opcional (apenas se vais usar fallback de envio):

- `META_SYSTEM_USER_ID`

> [!NOTE]
> **Não precisa redeploy.** O ambiente é lido na próxima invocação da Edge
> Function.

---

## 5) Configurar o webhook na app Meta

Em **developers.facebook.com → tua app → WhatsApp → Configuration → Webhooks**:

| Campo | Valor |
|-------|-------|
| Callback URL  | `https://jeprrbucvrvjopxwzood.supabase.co/functions/v1/whatsapp-webhook` |
| Verify Token  | O mesmo valor de `WHATSAPP_VERIFY_TOKEN` (passo 4) |

1. Clica **Verify and Save**
   - A Meta envia um `GET` para `/whatsapp-webhook` com `hub.verify_token`.
   - A função compara com `WHATSAPP_VERIFY_TOKEN` e responde `hub.challenge`.
   - Se bater, fica **verde** ✅.
2. Subscreve estes campos de webhook:
   - `messages` — recepção de mensagens
   - `account_update`
   - `message_template_status_update`
   - *(opcional para coexistência)* `history`, `smb_app_state_sync`, `smb_message_echoes`

---

## 6) Auth — habilitar Email + Google

### 6.1) Email/password

Supabase → **Authentication → Providers → Email** → **Enable**.
Decide se queres **Confirm email** ON ou OFF conforme política.

### 6.2) Google OAuth

> [!TIP]
> O botão já existe na UI. **Não** precisa de variáveis `VITE_GOOGLE_*` — só
> configurar Google Cloud + Supabase.

#### a) Google Cloud Console

1. [console.cloud.google.com](https://console.cloud.google.com) → escolhe/cria projeto.
2. **APIs e serviços → Credenciais → Criar credenciais → ID do cliente OAuth**.
3. **Tipo**: Aplicativo da Web.
4. Preenche:

   | Campo | Valor |
   |-------|-------|
   | Origens JavaScript autorizadas       | `https://ui.andre-075.workers.dev` *e* `http://localhost:5173` |
   | URIs de redirecionamento autorizados | `https://jeprrbucvrvjopxwzood.supabase.co/auth/v1/callback` |

5. Copia o **Client ID** e o **Client Secret**.
6. O **ecrã de consentimento OAuth** tem de estar configurado — em teste podes
   usar utilizadores de teste do Google.

#### b) Supabase

1. Supabase Dashboard → **Authentication → Providers → Google → Enable**
2. Cola o **Client ID** e o **Client Secret** do Google
3. **Save**

#### c) URLs no Supabase (crítico)

**Authentication → URL Configuration**:

| Campo | Valor (produção) |
|-------|------------------|
| Site URL     | `https://ui.andre-075.workers.dev` |
| Redirect URLs | `https://ui.andre-075.workers.dev/**` |

Para dev local, **acrescenta**:

- `http://localhost:5173`
- `http://localhost:5173/**`

---

## 7) UI no Cloudflare — variáveis e redeploy

> [!IMPORTANT]
> Vite inlina `VITE_*` no **build**. Mudar só em runtime **não** tem efeito —
> os valores antigos continuam embutidos em `assets/*.js`.

No projeto Cloudflare Pages/Workers da UI:

| Variável de build | Valor |
|-------------------|-------|
| `VITE_SUPABASE_URL`      | `https://jeprrbucvrvjopxwzood.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | A chave **anon / publishable** do mesmo projeto (**não** a service_role) |

Depois, faz **redeploy** (rebuild).

---

## 8) Testar end-to-end

### 8.1) Login com Google

1. Abre `https://ui.andre-075.workers.dev/login`
2. Clica **Continuar com Google**
3. Escolhe a conta → deves voltar à app logado.

**Erros comuns:**

| Erro | Causa provável |
|------|----------------|
| `redirect_uri_mismatch`       | URI no Google ≠ `https://jeprrbucvrvjopxwzood.supabase.co/auth/v1/callback` |
| Volta ao login sem sessão     | **Redirect URLs** no Supabase sem o domínio da UI |
| `Provider not enabled`        | Google desligado no Supabase |

### 8.2) Receber mensagem WhatsApp

1. Conecta um número via **Embedded Signup** na UI (Integrations → WhatsApp).
2. Envia uma mensagem real do teu celular para esse número.
3. Verifica no Supabase SQL Editor:

   ```sql
   select created_at, direction, contact_address, content->>'type' as type, content->>'text' as text
   from public.messages
   order by created_at desc
   limit 5;
   ```

4. Logs detalhados em **Edge Functions → whatsapp-webhook → Logs**.

### 8.3) Enviar mensagem

Pela UI, abre a conversa e envia um texto. O fluxo passa por:

`public.messages` (INSERT outgoing) → trigger `dispatcher_edge_function` →
`net.http_post` → Edge Function `whatsapp-dispatcher` → API da Meta → telemóvel.

---

## Resumo em uma frase

- **Google**: redirect só para `https://<ref>.supabase.co/auth/v1/callback`
- **Supabase**: liga provider Google com Client ID/Secret e permite redirect para `https://ui.andre-075.workers.dev/**`
- **UI**: nada extra além das `VITE_SUPABASE_*` corretas e redeploy
- **Banco**: a bootstrap migration cria extensions + `supabase_functions.hooks` automaticamente; Vault e secrets Meta são configurados uma vez via Dashboard.
