<h1 align="center">wakit API</h1>
<p align="center">
  <strong>Open-source WhatsApp Business Platform</strong>
</p>
<p align="center">
  Self-hostable, multi-tenant, AI-agent ready. Built with Deno 🦕 and Postgres 🐘, powered by Supabase ⚡
</p>

<p align="center">
  <a href="https://app.wakit.ai"><img src="https://img.shields.io/badge/%F0%9F%9A%80_try_it-app.wakit.ai-C26A3D" alt="Try it"></a>&nbsp;
  <a href="https://unlicense.org/"><img src="https://img.shields.io/badge/license-Unlicense-blue.svg" alt="License: Unlicense"></a>&nbsp;
  <a href="https://github.com/matiasbattocchia/wakit-api/stargazers"><img src="https://img.shields.io/github/stars/matiasbattocchia/wakit-api" alt="GitHub Stars"></a>&nbsp;
  <a href="https://github.com/matiasbattocchia/wakit-api/commits/main"><img src="https://img.shields.io/github/last-commit/matiasbattocchia/wakit-api" alt="Last Commit"></a>&nbsp;
  <a href="https://chat.whatsapp.com/Ch6AwZizSDt5quzHodcYh5"><img src="https://img.shields.io/badge/Community-25D366?logo=whatsapp&logoColor=white" alt="Community"></a>
</p>

wakit is designed for both individual businesses and service providers. You can
use it to manage your own WhatsApp messaging, or leverage its features to become
a
[Meta Business Partner](https://developers.facebook.com/docs/whatsapp/solution-providers)
and offer WhatsApp messaging services to other organizations.

🚀 **Powering production-grade AI agents at
[Mirlo.com](https://mirlo.com/agentes-ia/whatsapp)**

> [!NOTE]
> This project is now backed by <a href="https://mirlo.com">Mirlo.com</a>, where
> I work, and is undergoing a rebranding. The project name is changing from
> **OpenBSP** to **wakit**.

## User Interface

For a complete web-based interface to manage conversations check out the
companion project:

**🖥️ [wakit UI](https://github.com/matiasbattocchia/wakit-ui)** — A modern,
responsive web interface built with React and Tailwind.

https://github.com/user-attachments/assets/1ef30dde-9de1-4f5a-856a-db34ca2e3063

## Description

wakit API is a multi-tenant platform that connects to the official WhatsApp API
to receive and send messages, storing them in a Supabase-backed database.

### Core features

- 🤝 **Meta Business Partner ready**: Built to facilitate the transition to an
  official solution provider.
- 🔗 **WhatsApp account Coexistence**: Connect existing WhatsApp Business
  accounts via
  [Embedded Signup](https://developers.facebook.com/documentation/business-messaging/whatsapp/embedded-signup/onboarding-business-app-users).
- 🏢 **Multi-tenant architecture**: Native support for multiple organizations
  with isolated environments.
- 🔌 **External integration**: Seamlessly connect with external services using
  webhooks and the API.

### AI agents

Create lightweight agents or connect to external, more advanced agents using
different protocols like `a2a` and `chat-completions`. Lightweight agents can
use built-in tools:

- MCP client
- SQL client
- HTTP client
- Calculator

> [!IMPORTANT]
> This project prioritizes a decoupled architecture between communication and
> agent logic. Advanced agents built with frameworks like the OpenAI SDK or
> Google ADK should be deployed as external services.

### Media processing

Interpret and extract information from media and document files, including:

- Audio
- Images
- Video
- PDF
- Other text-based documents (CSV, HTML, TXT, etc.)

### Claude Code plugin

The wakit plugin gives Claude Code full API access and optionally bridges
WhatsApp messages in real-time. Claude can query contacts, conversations,
templates, and more via the `query` tool, and reply to WhatsApp messages via the
`reply` tool.

Install the plugin:

```
/plugin marketplace add matiasbattocchia/wakit-api
/plugin install wakit@matiasbattocchia-wakit-api
```

On first run, a browser opens for Google sign-in (same account as the web UI).
Then configure allowed contacts for the WhatsApp channel:

```
/wakit:config contacts add 5491155551234
```

No contacts are forwarded until explicitly added (secure by default). API access
works regardless of channel configuration. See
[`plugin/README.md`](plugin/README.md) for full documentation.

### MCP server

The `mcp` Edge Function exposes an [MCP](https://modelcontextprotocol.io) server
over SSE, giving agentic access to the WhatsApp API from clients like Claude
Desktop or other agent platforms.

For the hosted version at [app.wakit.ai](https://app.wakit.ai), the MCP server
URL is:

```
https://api.wakit.ai/functions/v1/mcp
```

Authentication uses the `Authorization: Bearer <API_KEY>` header. Get it from
wakit > Settings > API Keys.

Optionally, `Allowed-Contacts` and `Allowed-Accounts` headers restrict which
phone numbers the key can access.

Claude Desktop configuration (`claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "wakit": {
      "url": "https://api.wakit.ai/functions/v1/mcp",
      "headers": {
        "Authorization": "Bearer <API_KEY>"
      }
    }
  }
}
```

Available tools:

| Tool                 | Description                                                   |
| -------------------- | ------------------------------------------------------------- |
| `list_accounts`      | List connected WhatsApp accounts                              |
| `list_conversations` | Get recent active conversations                               |
| `fetch_conversation` | Fetch messages and service window status for a contact        |
| `search_contacts`    | Find contacts by name or phone number                         |
| `send_message`       | Send a text or template message (enforces 24h service window) |
| `list_templates`     | List available WhatsApp templates                             |
| `fetch_template`     | Fetch details of a specific template                          |

## Demo

A managed instance is available at **[app.wakit.ai](https://app.wakit.ai)** —
same codebase as this repo, running on Supabase. Sign up with a Google or GitHub
account.

### Quotas

| Resource      | Included         |
| ------------- | ---------------- |
| Messages      | 5,000 / month    |
| Conversations | Unlimited        |
| Storage       | 1 GB             |
| AI Credits    | $1.00 (one-time) |

AI Credits apply only when agents use the built-in LLM gateway. Configuring an
agent with your own provider API key (`AgentExtra.api_key`) bypasses credit
consumption.

### Data portability

Your data is yours. You can export your organization's data from the hosted
instance and load it into a self-hosted deployment — both run the same schema,
and all data is scoped by organization with no cross-org dependencies.

## Self-host deployment

> [!NOTE]
> **Deploy your own instance in under 15 minutes** — no local environment
> required.

1. [Fork](https://github.com/matiasbattocchia/wakit-api/fork) this repo (1 min)
2. Create a [Supabase](https://supabase.com) project (5 min)
3. Complete the **[Before your first push](#before-your-first-push-one-time-setup)**
   checklist below (5 min)
4. Connect the project to your fork via the Supabase GitHub Integration (5 min)
5. Configure the **[WhatsApp integration](#whatsapp-integration)** to receive
   real messages

You are live! 🚀 Pushes to your default branch will automatically deploy
database migrations and Edge Functions.

### Before your first push (one-time setup)

> [!IMPORTANT]
> This section consolidates **every manual step** that a fresh Supabase Cloud
> project (2025+) requires before this codebase works end-to-end. Skipping any
> of these results in **silent failures** — Edge Functions log obscure errors
> like `schema "net" does not exist` or `relation "supabase_functions.hooks"
> does not exist`, and inbound WhatsApp messages reach the webhook but are
> never persisted to `public.messages`.

The bootstrap migration `supabase/migrations/20260520170000_bootstrap_self_host.sql`
is idempotent and handles the database-side prerequisites automatically on the
first `supabase db push`:

- `pg_net`, `supabase_vault`, `pgcrypto` extensions
- The legacy `supabase_functions` schema and its `hooks` table (used by the
  built-in `public.edge_function()` and `public.dispatcher_edge_function()`
  triggers for audit + history)

You still have to provide a few **secrets** that cannot be versioned in Git.

> [!WARNING]
> **Do not commit `supabase/functions/.env`**. It is intended for **local**
> Edge Functions only (`npx supabase functions serve`). If you ever pasted real
> Meta credentials there, add the file to `.gitignore` and **rotate** the
> compromised values: reset `META_APP_SECRET` in the Meta App > Basic page, and
> revoke + regenerate `META_SYSTEM_USER_ACCESS_TOKEN` in the Business Suite >
> System users page.

Throughout this section, replace `<SUPABASE_PROJECT_ID>` with the ID of your
Supabase project (the `{project_id}` segment in
`https://supabase.com/dashboard/project/{project_id}`), and `<UI_DOMAIN>` with
the public domain of your UI deployment
(e.g. `https://my-wakit-ui.pages.dev`).

#### 1. Vault secrets (required for triggers and cron jobs)

Two secrets must exist in `vault.decrypted_secrets`. They tell the database
how to call your Edge Functions from triggers and `pg_cron` jobs. Without them,
trigger functions log
`could not find decrypted_secret for edge_functions_url` and the entire row
INSERT is reverted.

##### 1.1 Get your service role key

1. Open
   `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/settings/api-keys`
2. Find the **`service_role`** row (or `secret` row on the new API keys layout)
3. Click **`Reveal`** (eye icon) and then **`Copy`**.

##### 1.2 Create the secrets in Vault

1. Open
   `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/vault/secrets`
2. Click the blue **`+ Add new secret`** button (top right).
3. Add the first secret:

   | Field         | Value                                                              |
   | ------------- | ------------------------------------------------------------------ |
   | **Name**      | `edge_functions_url`                                               |
   | **Secret**    | `https://<SUPABASE_PROJECT_ID>.supabase.co/functions/v1`           |
   | **Description** (optional) | `Edge Functions base URL`                             |

   Click **`Save new secret`**.

4. Click **`+ Add new secret`** again and add the second:

   | Field         | Value                                                              |
   | ------------- | ------------------------------------------------------------------ |
   | **Name**      | `edge_functions_token`                                             |
   | **Secret**    | (paste the service role key copied in 1.1)                         |
   | **Description** (optional) | `Service role key for trigger HTTP calls`             |

   Click **`Save new secret`**.

> Alternative (automated): run the `Release` GitHub Actions workflow once. The
> `deploy-vault-secrets.sh` step upserts both rows from the matching repository
> secrets/variables. See
> [Alternative: deploy via GitHub Actions](#alternative-deploy-via-github-actions-optional).

##### 1.3 Verify

Open `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/sql/new` and
run:

```sql
select name, length(decrypted_secret) as len
from vault.decrypted_secrets
where name in ('edge_functions_url', 'edge_functions_token');
```

Both rows must appear with `len > 30`.

#### 2. Edge Functions secrets (Meta WhatsApp)

These tell the Edge Functions how to talk to Meta's Cloud API and how to
validate inbound webhook handshakes. Without them, `whatsapp-management/signup`
returns `META_APP_ID or META_APP_SECRET environment variable not set`, and the
Meta webhook handshake (`hub.verify_token`) fails silently with HTTP 401.

**Where to set:**
`https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/functions/secrets`
→ click **`+ New secret`** for each row below, fill **Name** and **Value**,
then **`Save`**.

| #   | Name                            | How to obtain (detail below)                                |
| --- | ------------------------------- | ----------------------------------------------------------- |
| 1   | `META_APP_ID`                   | Meta App Dashboard (§2.1)                                   |
| 2   | `META_APP_SECRET`               | Meta App Dashboard (§2.1)                                   |
| 3   | `META_SYSTEM_USER_ID`           | Meta Business Suite (§2.2)                                  |
| 4   | `META_SYSTEM_USER_ACCESS_TOKEN` | Meta Business Suite (§2.2)                                  |
| 5   | `WHATSAPP_VERIFY_TOKEN`         | You invent it (§2.3) — must match the value pasted in Meta  |

##### 2.1 `META_APP_ID` and `META_APP_SECRET`

1. Open [https://developers.facebook.com/apps](https://developers.facebook.com/apps)
2. Click the card of your Business-type app (with the WhatsApp product added —
   if you don't have one, see [WhatsApp integration > Step 1](#whatsapp-integration)).
3. Left sidebar: **App settings** > **Basic** (URL:
   `https://developers.facebook.com/apps/<META_APP_ID>/settings/basic/`).
4. **App ID**: visible at the top → **copy** → paste into the `META_APP_ID`
   secret in Supabase.
5. **App secret**: click **`Show`** (re-enter your Facebook password if asked)
   → **copy** → paste into `META_APP_SECRET`.

> To rotate a leaked secret: same page, **`Reset`** button next to App secret.
> Update the Supabase value after rotating.

##### 2.2 `META_SYSTEM_USER_ID` and `META_SYSTEM_USER_ACCESS_TOKEN`

1. Open [https://business.facebook.com/latest/settings/system_users](https://business.facebook.com/latest/settings/system_users)
2. If you have multiple portfolios, select the one that owns your App (top-left
   selector).
3. **Create the system user** (skip if you already have one):
   - Click **`Add`** > **System Username**: e.g. `wakit-system` > **Role**:
     **Admin** > **`Create system user`**.
4. Select your system user in the list. In the right-hand panel:
   - The **ID** is shown right under the name → **copy** → paste into
     `META_SYSTEM_USER_ID`.
5. Assign your App as an asset (skip if already done):
   - Click **`Add Assets`** > **Apps** > select your App > tick **Full control**
     > **`Save changes`**.
6. Generate a token:
   - **`Generate new token`** > **Select app**: your App
   - **Token expiration**: **Never** (or the longest available)
   - **Available scopes**: tick only these three:
     - `whatsapp_business_messaging`
     - `whatsapp_business_management`
     - `business_management`
   - **`Generate token`**.
7. **Copy the token immediately** (Meta shows it only once) → paste into
   `META_SYSTEM_USER_ACCESS_TOKEN`. If lost, generate a new one.

##### 2.3 `WHATSAPP_VERIFY_TOKEN`

This is a random string **you invent**. The `whatsapp-webhook` Edge Function
only accepts inbound requests whose `hub.verify_token` matches it.

Generate locally (PowerShell):

```powershell
[guid]::NewGuid().ToString()
```

Or on Linux/macOS:

```bash
uuidgen
```

1. Paste the resulting string into the `WHATSAPP_VERIFY_TOKEN` secret in
   Supabase Edge Functions.
2. **Keep a copy locally** — you'll paste the same value in Meta when
   configuring the webhook (see
   [WhatsApp integration > Step 4](#whatsapp-integration)).

##### 2.4 (Optional) LLM provider keys

Required only if you use built-in AI agents through the LLM gateway. Add the
ones you actually use:

| Name                  | Where to obtain                                                            |
| --------------------- | -------------------------------------------------------------------------- |
| `OPENAI_API_KEY`      | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) → `+ Create new secret key` |
| `ANTHROPIC_API_KEY`   | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) → `Create Key` |
| `GOOGLE_API_KEY`      | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) → `Create API key` |
| `GROQ_API_KEY`        | [console.groq.com/keys](https://console.groq.com/keys)                     |

#### 3. Supabase Auth providers

##### 3.1 Enable Email/password

1. Open
   `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/auth/providers`
2. Expand the **Email** row.
3. Toggle **`Enable Email Provider`** → **ON**.
4. **`Confirm email`**: turn **OFF** if you want immediate login for the first
   user (turn it back ON for production).
5. Leave **`Secure email change`** ON.
6. Click **`Save`** at the bottom.

##### 3.2 URL Configuration (required before any OAuth provider works)

1. Open
   `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/auth/url-configuration`
2. **Site URL**: `<UI_DOMAIN>` (e.g. `https://my-wakit-ui.pages.dev`).
3. **Redirect URLs**: click **`+ Add URL`** for each:
   - `<UI_DOMAIN>/**`
   - `http://localhost:5173/**` (for local UI dev)
   - `http://localhost:3000/**` (if you use a different port)
4. **`Save`**.

> The trailing `/**` is important — it lets Supabase accept any callback path
> under your domain.

##### 3.3 Google OAuth (optional)

**Google Cloud Console — create the OAuth client:**

1. Create or pick a project at
   [https://console.cloud.google.com/projectcreate](https://console.cloud.google.com/projectcreate).
2. Configure the consent screen (once per project):
   - [https://console.cloud.google.com/auth/branding](https://console.cloud.google.com/auth/branding)
   - **User Type**: **External** (unless you have Workspace).
   - Fill **App name**, **User support email**, **Developer contact**.
   - Skip Scopes and Test users (defaults are fine).
3. Create credentials:
   - [https://console.cloud.google.com/auth/clients](https://console.cloud.google.com/auth/clients)
     → **`+ Create client`**
   - **Application type**: **Web application**, **Name**: `wakit-supabase`.
   - **Authorized JavaScript origins** — add each on its own line:
     - `<UI_DOMAIN>`
     - `http://localhost:5173`
   - **Authorized redirect URIs**:
     `https://<SUPABASE_PROJECT_ID>.supabase.co/auth/v1/callback`
   - **`Create`** → copy the **Client ID** and **Client Secret**.

**Supabase side:**

1. Back at
   `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/auth/providers`
2. Expand **Google** > toggle **`Enable Sign in with Google`** ON.
3. Paste **Client ID** and **Client Secret**.
4. Leave **`Skip nonce checks`** OFF.
5. **`Save`**.

##### 3.4 GitHub OAuth (optional)

**GitHub — create the OAuth App:**

1. Open
   [https://github.com/settings/developers](https://github.com/settings/developers)
   → **OAuth Apps** tab → **`New OAuth App`**.
2. Fill:
   - **Application name**: `wakit-supabase`
   - **Homepage URL**: `<UI_DOMAIN>`
   - **Authorization callback URL**:
     `https://<SUPABASE_PROJECT_ID>.supabase.co/auth/v1/callback`
3. **`Register application`**.
4. On the created OAuth App page:
   - Copy the **Client ID**.
   - Click **`Generate a new client secret`** → copy the value (shown once).

**Supabase side:**

1. Same providers page > expand **GitHub** > toggle ON.
2. Paste **Client ID** and **Client Secret**.
3. **`Save`**.

#### 4. UI environment variables (Vite build-time)

The companion UI repo ([wakit-ui](https://github.com/matiasbattocchia/wakit-ui))
is a Vite app: `VITE_*` variables are **inlined into the JS bundle at build
time**. Changing them at runtime has no effect — the previous values remain
embedded in `assets/*.js`. You **must rebuild and redeploy** after every
change.

| UI build env var          | Value                                                            |
| ------------------------- | ---------------------------------------------------------------- |
| `VITE_SUPABASE_URL`       | `https://<SUPABASE_PROJECT_ID>.supabase.co`                      |
| `VITE_SUPABASE_ANON_KEY`  | Project **publishable** / **anon** key (NOT the service role)    |

Where to copy the **anon** key:
`https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/settings/api-keys`
→ row labelled **`anon`** or **`publishable`**
(`sb_publishable_...` on the new key format, or `eyJ...` on the legacy JWT
format). **Never** use the `service_role` here — it would expose write access
to the entire database.

**Cloudflare Pages / Workers** (recommended hosting):

1. Open [https://dash.cloudflare.com/](https://dash.cloudflare.com/) → your
   account → **Workers & Pages** (newer dashboards: **Compute (Workers)**).
2. Select your UI project.
3. **Settings** > **Variables and Secrets** (or **Environment variables**).
4. Click **`Add`** twice and create both variables above as **Plaintext**, in
   the **Production** environment. If you also have a **Preview** environment,
   set the same values there.
5. Force a rebuild (variable changes alone do **not** trigger one):
   - Dashboard: **Deployments** > latest deployment > `...` >
     **`Retry deployment`**, or
   - Git: `git commit --allow-empty -m "trigger rebuild" && git push`, or
   - CLI: `npx wrangler pages deploy ./dist`.

**Verify the bundle is hitting the right Supabase project** (PowerShell):

```powershell
$ui = "<UI_DOMAIN>"
$html = (Invoke-WebRequest -Uri "$ui/" -UseBasicParsing).Content
$chunk = ([regex]::Match($html, 'assets/(client-[A-Za-z0-9]+\.js)')).Groups[1].Value
$bundle = (Invoke-WebRequest -Uri "$ui/assets/$chunk" -UseBasicParsing).Content
[regex]::Matches($bundle, 'https?://[a-z0-9.-]+\.supabase\.co') |
  ForEach-Object { $_.Value } | Select-Object -Unique
if ($bundle -match 'localhost') { '⚠️  contains localhost — rebuild did not pick env vars' }
else { '✅ no localhost' }
```

The output must include your `https://<SUPABASE_PROJECT_ID>.supabase.co` and
report `✅ no localhost`.

#### 5. Sanity check (run after the first `supabase db push`)

Open the SQL editor:
`https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/sql/new`

```sql
with checks as (
  select 'ext: pg_net'         as item, exists(select 1 from pg_extension where extname='pg_net')         as ok
  union all select 'ext: supabase_vault', exists(select 1 from pg_extension where extname='supabase_vault')
  union all select 'ext: pgcrypto',       exists(select 1 from pg_extension where extname='pgcrypto')
  union all select 'ext: pg_cron',        exists(select 1 from pg_extension where extname='pg_cron')
  union all select 'ext: moddatetime',    exists(select 1 from pg_extension where extname='moddatetime')
  union all select 'table: supabase_functions.hooks',
                   to_regclass('supabase_functions.hooks') is not null
  union all select 'vault: edge_functions_url',
                   exists(select 1 from vault.decrypted_secrets where name='edge_functions_url')
  union all select 'vault: edge_functions_token',
                   exists(select 1 from vault.decrypted_secrets where name='edge_functions_token')
)
select item, case when ok then '✅' else '❌' end as status from checks;
```

All rows must show ✅.

Then visually check the Meta secrets (their values are not readable via SQL):
`https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/functions/secrets`
→ the five `META_*` / `WHATSAPP_VERIFY_TOKEN` names must all appear in the
list.

End-to-end check after you connect a number through the UI:

| Item                        | How to verify                                                                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Email provider ON           | `auth/providers` shows Email as Enabled                                                                                                                                |
| Site URL + Redirects        | `auth/url-configuration` lists `<UI_DOMAIN>`                                                                                                                           |
| Google / GitHub OAuth       | Same providers page; try the social login from the UI                                                                                                                  |
| UI envs applied             | PowerShell snippet in §4 shows no `localhost`                                                                                                                          |
| Meta webhook ✅             | Meta App Dashboard > WhatsApp > Configuration shows "Verified" next to the callback URL                                                                                |
| Inbound message stored      | Send a message to the connected number; check `https://supabase.com/dashboard/project/<SUPABASE_PROJECT_ID>/functions/whatsapp-webhook/logs` and `public.messages`     |

#### Connect via Supabase GitHub Integration

In the [Supabase Dashboard](https://supabase.com/dashboard):

1. Go to **Project Settings** > **Integrations**
2. Under **GitHub Integration**, click **Authorize GitHub**
3. On the GitHub authorization page, click **Authorize Supabase**
4. Back on the Integrations page, choose your forked **wakit-api** repository
5. Set the **Working directory** to `.` (the `supabase/` folder lives at the
   repo root)
6. Set the **Production branch** to `main`
7. Configure the remaining options as needed
8. Click **Enable integration**

<details>
<summary>
Alternative: deploy via GitHub Actions (optional)
</summary>

The repository also ships with a `Release` GitHub Actions workflow that performs
the same deployment from inside CI. The workflow is set to `workflow_dispatch:`
only — it does **not** run on push. This path is **optional** and useful if you
mirror this repo to another host (e.g. GitLab) or prefer keeping deployments
self-contained in GitHub Actions instead of relying on Supabase's integration.

##### Secrets

> [!TIP]
> Create the secrets at GitHub > Repository > Settings ⚙️ > Secrets and
> variables \*️⃣ > Actions > Secrets
>
> <!-- `https://github.com/{github_account}/wakit-api/settings/secrets/actions` -->

- **SUPABASE_ACCESS_TOKEN**: A
  [personal access token](https://supabase.com/dashboard/account/tokens)
- **SUPABASE_DB_PASSWORD**
  <!-- Get it at Supabase > Project > Database > Settings > Database password `https://supabase.com/dashboard/project/{project_id}/database/settings` -->
- **SUPABASE_SERVICE_ROLE_KEY**: you can use a secret key instead of the legacy
  service role key
  <!-- Get it at Supabase > Project > Project Settings > API keys > API Keys > Secret keys `https://supabase.com/dashboard/project/{project_id}/settings/api-keys/new` -->

##### Variables

> [!TIP]
> Create the variables at GitHub > Repository > Settings ⚙️ > Secrets and
> variables \*️⃣ > Actions > Variables
>
> <!-- `https://github.com/{github_account}/wakit-api/settings/variables/actions` -->

- **SUPABASE_PROJECT_ID**
  <!-- the `{project_id}` in `https://supabase.com/dashboard/project/{project_id}` -->
- **SUPABASE_SESSION_POOLER_HOST**: it is like
  `aws-0-us-east-1.pooler.supabase.com`
  <!-- Found at Supabase > Project > Connect 🔌 > Session pooler > View parameters > Host `https://supabase.com/dashboard/project/{project_id}/database/schemas?showConnect=true` -->

##### Release

> [!TIP]
> Go to GitHub > Repository > Actions ▶️ > Release
>
> <!-- `https://github.com/{github_account}/wakit-api/actions/workflows/release.yml` -->

1. Click **Run workflow**

</details>

## WhatsApp integration

To connect your wakit project to the WhatsApp API, you'll need to setup a Meta
App with the WhatsApp product and configure the following Edge Functions
secrets. You can set these up in two ways:

- **Direct configuration**: Add them directly in your Supabase dashboard at
  Supabase > Project > Edge Functions > Secrets.
  <!-- `https://supabase.com/dashboard/project/{project_id}/functions/secrets` -->
- **GitHub Actions**: Set them as GitHub Actions secrets in your repository
  settings and re-run the _Release_ action to automatically deploy them.

#### Secrets

- **META_SYSTEM_USER_ID**
- **META_SYSTEM_USER_ACCESS_TOKEN**
- **META_APP_ID**
- **META_APP_SECRET**
- **WHATSAPP_VERIFY_TOKEN**

Follow these steps to obtain the required credentials.

<details>
<summary>
Step 0: Overview
</summary>

There is quiet a Meta nomenclature of entities that you might want to get in
order to not to get lost in the platform.

- **Business profile** - This is the top-level entity, represents a business.
  Has users and assets.
- **User** - Real or system users. System users can have access tokens. Users
  belong to a business portfolio and can have assigned assets.
- **Asset** - WhatsApp accounts, Instagram accounts, Meta apps, among others.
  Assets belong to a business portfolio and are assigned to users.
- **App** - An asset that integrates Meta products such as the WhatsApp Cloud
  API.
- **WhatsApp Business Account (WABA)** - A WhatsApp account asset, can have many
  phone numbers.
- **Phone number** - A registered phone number within the WhatsApp Cloud API.
  Belongs to a WABA.

> For more details, refer to
> [Cloud API overview](https://developers.facebook.com/docs/whatsapp/cloud-api/overview).

</details>

<details>
<summary>
Step 1: Create a Meta app (skip if you already have one)
</summary>

1. Navigate to [My Apps](https://developers.facebook.com/apps)
2. Click **Create App**
3. Select the following options:
   - **Use case**: Other
   - **App type**: Business
4. Add the **WhatsApp** product to your app
5. Click **Add API**
6. Disregard the screen that appears next and proceed to the next step

</details>

<details>
<summary>
Step 2: Create a system user
</summary>

1. Get into the [Meta Business Suite](https://business.facebook.com). If you
   have multiple portfolios, select the one associated with your app
2. Go to Settings > Users > System users
   <!-- `https://business.facebook.com/latest/settings/system_users` -->
3. Add an **admin system user**
4. Copy the **ID** → **META_SYSTEM_USER_ID**
5. Assign your app to the user with **full control** permissions
6. Generate a token with these permissions:
   - `business_management`
   - `whatsapp_business_messaging`
   - `whatsapp_business_management`
7. Copy the **Access Token** → **META_SYSTEM_USER_ACCESS_TOKEN**

> For detailed instructions on system user setup, refer to the
> [WhatsApp Business Management API documentation](https://developers.facebook.com/docs/whatsapp/business-management-api/get-started).

</details>

<details>
<summary>
Step 3: Get the app credentials
</summary>

1. Navigate to [My Apps](`https://developers.facebook.com/apps`) > App Dashboard
   <!-- `https://developers.facebook.com/apps/{app_id}` -->
2. Go to App settings > Basic
   <!-- `https://developers.facebook.com/apps/{app_id}/settings/basic` -->
3. Copy the following values:
   - **App ID** → **META_APP_ID**
   - **App secret** → **META_APP_SECRET**

> Multiple Meta apps are supported by separating values with `|` (pipe)
> characters. For example: `META_APP_ID=app_id_1|app_id_2` and
> `META_APP_SECRET=app_secret_1|app_secret_2`.

</details>

<details>
<summary>
Step 4: Configure the WhatsApp Business Account webhook
</summary>

### Part A

1. Within the App Dashboard
2. Go to WhatsApp > Configuration
   <!-- `https://developers.facebook.com/apps/{app_id}/whatsapp-business/wa-settings` -->
3. Set the **Callback URL** to:
   `https://{SUPABASE_PROJECT_ID}.supabase.co/functions/v1/whatsapp-webhook`
4. Choose a secure token for **WHATSAPP_VERIFY_TOKEN** → Set it as the **Verify
   token**, but **do not** click **Verify and save** yet!
5. Ensure your Edge Functions environment variables are up-to-date
   - If you configured secrets directly in your Supabase dashboard, no further
     action is needed at this point
   - If you set secrets via GitHub Actions, re-run the _Release_ action now to
     deploy them to your Edge Functions
6. Click **Verify and save**
7. Disregard the screen that appears next and proceed to the next step

> Multiple Meta apps are supported by appending the query param
> `?app_id={META_APP_ID}` to the callback URL. For example:
> `https://{SUPABASE_PROJECT_ID}.supabase.co/functions/v1/whatsapp-webhook?app_id=app_id_2`.

### Part B

1. Within the App Dashboard
2. Go to WhatsApp > Configuration
   <!-- `https://developers.facebook.com/apps/{app_id}/whatsapp-business/wa-settings` -->
3. Subscribe to the following **Webhook fields**:
   - `account_update`
   - `messages`
   - `history`
   - `smb_app_state_sync`
   - `smb_message_echoes`

> Optionally, test the configuration so far. In the `messages` subscription
> section, click **Test**. You should see the request in Supabase > Project >
> Edge Functions > Functions > whatsapp-webhook > Logs.
>
> <!-- `https://supabase.com/dashboard/project/{project_id}/functions/whatsapp-webhook/logs` -->
>
> You might observe an error in the logs. This is an expected outcome at this
> stage; the simple fact that a log entry appears confirms that the webhook is
> successfully receiving events.

</details>

<details>
<summary>
Step 5: Add a phone number
</summary>

If you decide to add the **test number**,

1. Within the App Dashboard
2. Go to WhatsApp > API Setup
   <!-- `https://developers.facebook.com/apps/{app_id}/whatsapp-business/wa-dev-console` -->
3. Click **Generate access token** (you can't use the one you got from step 2
   here)
4. Copy these values:
   - **Phone number ID**
   - **WhatsApp Business Account ID**
5. Select a recipient phone number
6. Send messages with the API > **Send message**

> The test number doesn't seem to fully activate to receive messages unless you
> send a test message at least once.

In order to add a **production number**,

1. Click **Add phone number**
2. Follow the flow
3. Navigate to
   [WhatsApp Manager](https://business.facebook.com/latest/whatsapp_manager/overview)
4. Go to Account tools > Phone numbers
   <!-- `https://business.facebook.com/latest/whatsapp_manager/phone_numbers` -->
5. Copy these values:
   - **Phone number ID**
   - **WhatsApp Business Account ID**

### For any number you add

Create an organization if you haven't done that already.

```sql
insert into public.organizations (name, extra) values
  ('Default', '{ "response_delay_seconds": 0 }')
;
```

Note the **organization ID**.

Register the phone number with your organization in the system.

```sql
insert into public.organizations_addresses (address, organization_id, service, extra) values
  ('<Phone number ID>', '<Organization ID>', 'whatsapp', '{ "waba_id": "<WhatsApp Business Account ID>", "phone_number": "<Phone number>" }')
;
```

</details>

## Architecture

New to Supabase? In one sentence: it's a hosted Postgres platform that
auto-exposes your tables over a REST and realtime API, runs Deno-based Edge
Functions for server-side logic, and handles auth and file storage on top. wakit
leans heavily on those primitives — most business logic lives as SQL triggers
and Edge Functions, and clients (the web UI, the Claude Code plugin, custom
integrations) talk to Postgres directly through a
[Supabase client library](https://supabase.com/docs/guides/api/rest/client-libs)
rather than through a separate backend layer.

<img src="./architecture.png" alt="Architecture diagram" width="600">

In the image, green boxes are external services, red are Edge Functions and
blue, database tables. White boxes are clients.

The system uses a reactive, function-based architecture:

1. A request from the WhatsApp API is received by the `whatsapp-webhook`
   function.
2. `whatsapp-webhook` processes the incoming message and stores it in the
   `messages` table.
3. An insert trigger on the `messages` table forwards the message to the
   `agent-client` function (incoming trigger).
4. `agent-client` builds the conversation context and sends a request to an
   agent API using the
   [Chat Completions](https://platform.openai.com/docs/api-reference/chat)
   format.
5. `agent-client` waits for the agent's response and saves it back to the
   `messages` table.
6. An outgoing trigger on the `messages` table forwards the new message to the
   `whatsapp-dispatcher` function.
7. `whatsapp-dispatcher` processes the message and sends a request to the
   WhatsApp API to deliver it.

This event-driven flow ensures that each component is decoupled and scalable.

### Edge Functions

#### WhatsApp

- `whatsapp-webhook`: Handles incoming webhook events from the
  [WhatsApp Cloud API](https://developers.facebook.com/docs/whatsapp/cloud-api).
- `whatsapp-dispatcher`: Sends outbound messages to the WhatsApp Cloud API.
- `whatsapp-manager`: Integrates with the
  [WhatsApp Business Management API](https://developers.facebook.com/docs/whatsapp/business-management-api)
  for business and phone number management.

#### Agent

- `agent-client`: Orchestrates agent interactions, builds conversation context,
  and communicates with external agent APIs over
  [Chat Completions](https://platform.openai.com/docs/api-reference/chat) or
  [A2A](https://github.com/google/A2A) protocols.

### Database models

- **users**: Registered user in the application (mapped to Supabase Auth).
- **organizations**: Tenant entity; holds organization metadata.
- **organizations_addresses**: An organization's connected addresses per service
  — e.g. a WhatsApp phone number. Belongs to an `organization`.
- **contacts**: People associated with an `organization` — the address-book
  entry that groups one or more addresses under a name.
- **contacts_addresses**: Addresses a contact can be reached at (e.g. a phone
  number for WhatsApp). An address can exist unlinked to any contact, so
  addresses and contacts have independent lifecycles — the sync triggers in this
  table manage linking/unlinking and orphan cleanup.
- **conversations**: A conversation between an `organization_address` and a
  `contact_address` (or `group_address`) for a given service; belongs to an
  `organization`.
- **messages**: Messages within a `conversation`; carry direction, type,
  payload, status, and timestamps.
- **agents**: Human or AI agents for an `organization`; optionally linked to an
  auth `user`.
- **api_keys**: API access keys scoped to an `organization`.
- **webhooks**: Outbound webhook subscriptions per `organization`.
- **quick_replies**: Reusable response snippets scoped to an `organization`.
- **logs**: Application-level log entries (errors, warnings) written by Edge
  Functions.

## Configuration

### Organizations

```ts
export type OrganizationExtra = {
  response_delay_seconds?: number; // default: 3
  welcome_message?: string;
  authorized_contacts_only?: boolean;
  default_agent_id?: string;
  media_preprocessing?: {
    mode?: "active" | "inactive";
    model?: "gemini-2.5-pro" | "gemini-2.5-flash"; // default: gemini-2.5-flash
    api_key: string; // default GOOGLE_API_KEY env var
    language?: string;
    extra_prompt?: string;
  };
  error_messages_direction?: "internal" | "outgoing";
};
```

### Agents

The spirit of this project has been to equiparate the experience of human and AI
agents.

#### Human

Roles and privileges

- Owner — full control: manage organizations, manage integrations, invite/remove
  anyone
- Admin — operational control: manage conversations, create AI agents
- Member — standard usage: create conversations, use the chat features

#### AI

```ts
export type AgentExtra = {
  mode?: "active" | "draft" | "inactive";
  description?: string;
  api_url?: "openai" | "anthropic" | "google" | "groq" | string; // default: openai
  api_key?: string; // default: provider env var, i.e. OPENAI_API_KEY
  model?: string; // default: gpt-5-mini
  // TODO: Add responses (openai), messages (anthropic), generate-content (gemini).
  protocol?: "chat_completions" | "a2a"; // default: chat_completions
  assistant_id?: string;
  max_messages?: number;
  temperature?: number;
  max_tokens?: number;
  thinking?: "minimal" | "low" | "medium" | "high";
  instructions?: string;
  send_inline_files_up_to_size_mb?: number;
  tools?: ToolConfig[];
};
```

## Local development

Requires Node 🐢 and Docker 🐋.

### Database

```
npx supabase start
```

After editing the schema files, generate a migration

```
npx supabase db diff -f <migration_name>
```

Apply the migration to the local database

```
npx supabase migration up
```

Finally, update the types

```
npx supabase gen types typescript --local > supabase/functions/_shared/db_types.ts
```

### Edge Functions

```
npx supabase functions serve
```

### REST API docs

Fetch the OpenAPI spec from PostgREST (requires the service role key):

```
curl "https://<project-id>.supabase.co/rest/v1/" -H "apikey: <service_role_key>" > openapi.json
```

## Acknowledgments

- [@diegoparma](https://github.com/diegoparma) — for years of feedback, design
  input, and being one of the project's earliest power users.
- [@rolox05](https://github.com/rolox05) — first UI, PoC and kickstart partner.

## Community

Questions, ideas, or feedback? Join our
[WhatsApp Community](https://chat.whatsapp.com/Ch6AwZizSDt5quzHodcYh5) or open
an [issue](https://github.com/matiasbattocchia/wakit-api/issues). We'd love to
hear from you.
