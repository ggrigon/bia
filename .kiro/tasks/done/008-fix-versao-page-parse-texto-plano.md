# 008 - fix - Corrigir VersaoPage para consumir /api/versao como texto puro

## Modelo de Trabalho

- **Modelo:** Feature Branch
- **Branch base:** `desafio-labs/kiro-cli`
- **Branch da task:** `feature/008-fix-versao-page-parse-texto-plano`
- **Agente responsável:** `dev`

---

## Contexto

O dono do projeto reportou, via screenshot, que a tela `/versao` está sempre mostrando:

- Campos "API — Nome" e "API — Versão" como "—"
- Status "🔴 Offline"
- Erro: `⚠️ Erro ao conectar: Unexpected token 'B', "Bia 4.3.0" is not valid JSON`

Isso acontece mesmo com a API 100% saudável.

### Diagnóstico (já confirmado, não precisa reinvestigar)

- `api/controllers/versao.js` sempre respondeu (e **deve continuar respondendo**) com
  `res.send(\`Bia ${process.env.VERSAO_API || "4.3.0"}\`)` — **texto puro**, `Content-Type:
  text/html`. Confirmado ao vivo com `curl -i http://localhost:3001/api/versao`. Esse
  comportamento é histórico, não foi alterado por nenhuma task recente (incluindo a 007), e **não
  deve ser alterado por esta task** — a rota `/api/versao` **não deve virar/retornar JSON**.
- O bug está inteiramente no front, em `client/src/components/VersaoPage.jsx`, função
  `checkApiHealth` (~linha 73):
  ```js
  const versionData = await response.json();
  ```
  seguido de leituras de `apiVersion.api?.nome` (linha ~121) e `apiVersion.api?.versao` (linha
  ~129) — um formato JSON estruturado `{ api: { nome, versao } }` que a API **nunca** retornou.
  `response.json()` lança `SyntaxError: Unexpected token 'B', "Bia 4.3.0" is not valid JSON`, cai
  no `catch`, e a página exibe "Offline" com esse erro mesmo com a API saudável.
- Bug pré-existente desde a criação de `VersaoPage.jsx` (tasks 001/006), **não** foi introduzido
  pela task 007 (que só mexeu no botão "API" do Header e no botão "Voltar" da própria página).

### Decisão de produto (PO)

Para manter a simplicidade do projeto (público-alvo iniciante, conforme
`.kiro/rules/dockerfile.md` e `.kiro/rules/infraestrutura.md`), a resposta de `/api/versao` é uma
string simples (`"Bia 4.3.0"`), sem estrutura JSON. Não faz sentido manter dois campos separados
("Nome" e "Versão") extraídos por parsing frágil de string. A tela deve exibir a resposta da API
em um **único campo "Versão da API"**, mostrando a string completa retornada
(ex: `Bia 4.3.0`), sem tentar separar "nome" de "versão".

---

## Objetivo

1. Alterar `checkApiHealth` em `client/src/components/VersaoPage.jsx` para ler a resposta de
   `/api/versao` como **texto puro**, nunca como JSON.
2. Substituir os dois campos atuais "API — Nome" e "API — Versão" por um único campo **"Versão da
   API"**, exibindo o texto retornado pela API (ex.: `Bia 4.3.0`).
3. Não alterar o contrato da API: `api/controllers/versao.js` continua respondendo em texto puro —
   nenhuma mudança no backend.
4. Preservar o restante do comportamento já existente da tela (status online/offline, bloco de
   erro, botão "Atualizar", indicador de ambiente, URL da API, botão "Voltar").

A forma exata de implementação (parsing do texto, nome de variáveis, estrutura do estado React
etc.) fica a critério do `dev`, desde que os critérios de aceite abaixo sejam atendidos.

---

## Arquivos Envolvidos

- `client/src/components/VersaoPage.jsx` (único arquivo a ser alterado)

**Não alterar:**
- `api/controllers/versao.js`
- Qualquer outra rota/controller do backend

---

## Critérios de Aceite

### Consumo correto da API
- [x] A resposta de `/api/versao` é lida como texto puro (não `response.json()`).
- [x] Com a API rodando normalmente (`curl http://localhost:3001/api/versao` retornando
      `Bia 4.3.0` como texto puro), a tela `/versao` mostra status "🟢 Online" e **não** exibe o
      erro `Unexpected token ... is not valid JSON`.

### Exibição simplificada
- [x] Os campos separados "API — Nome" e "API — Versão" foram removidos.
- [x] Existe um único campo "Versão da API" que exibe a string completa retornada pela API (ex:
      `Bia 4.3.0`), sem tentar quebrar/parsear em nome + número de versão.
- [x] Enquanto a checagem está em andamento, o campo mostra "Verificando...", igual ao padrão
      atual dos demais campos da tela.
- [x] Quando a API está offline/inacessível, o campo mostra "—", igual ao padrão atual.

### Backend inalterado
- [x] `api/controllers/versao.js` não foi modificado.
- [x] `curl -i http://localhost:3001/api/versao` continua retornando texto puro (`Bia 4.3.0`),
      `Content-Type: text/html`, sem virar JSON.

### Geral
- [x] Nenhuma outra funcionalidade da tela `/versao` (status, ambiente, URL da API, botão
      "Atualizar", bloco de erro) foi quebrada — validado por revisão de diff: nenhum desses
      blocos foi tocado. *Botão "Voltar" não existe nesta branch, ver Notas do Dev.*
- [x] Testado com a API online e com a API offline (ex.: backend derrubado), confirmando os dois
      cenários (sucesso e erro) **na tela**. **Validado manualmente pelo dono do projeto,
      diretamente no navegador**, após o merge das tasks 007 e 008 em `desafio-labs/kiro-cli`
      (ver "Validação final (PO)" abaixo) — o dev não conseguiu confirmar isso por falta de
      navegador/headless no ambiente, ver Notas do Dev.
- [x] Testado visualmente em tema claro e escuro. **Validado manualmente pelo dono do projeto,
      diretamente no navegador**, após o merge das tasks 007 e 008 em `desafio-labs/kiro-cli`
      (ver "Validação final (PO)" abaixo) — não realizado pelo dev, ver Notas do Dev.

---

## Validação final (PO)

Após o merge local de `feature/007-feat-botao-api-padrao-e-voltar-versao` e
`feature/008-fix-versao-page-parse-texto-plano` em `desafio-labs/kiro-cli` (necessário porque a
rota `/versao` e o botão "API" do Header, entregues na task 007, são pré-requisito para visualizar
a correção da task 008 no navegador), o dono do projeto validou manualmente na tela `/versao`:

- Status da API alternando corretamente entre "🟢 Online" e "🔴 Offline" (com o backend
  online/offline), sem o erro `Unexpected token ... is not valid JSON`.
- Campo único "Versão da API" exibindo o valor esperado.
- Tema claro e tema escuro, ambos consistentes com o padrão visual do restante do app.

Com essa validação, os dois critérios de aceite pendentes (marcados `[ ]` na entrega original do
dev) foram confirmados e marcados como `[x]` acima. Task aceita pelo PO.

---

## Notas do Dev (implementação)

### O que foi validado
- **Backend inalterado e contrato preservado:** `api/controllers/versao.js` não foi tocado
  (confirmado por `git diff` vazio). `curl -i http://localhost:3001/api/versao` no container
  reconstruído via `docker compose up -d --build` retorna `Bia 4.3.0`, `Content-Type: text/html;
  charset=utf-8`, `HTTP/1.1 200 OK`.
- **Lógica de `checkApiHealth` validada ponta a ponta contra o backend real containerizado**,
  reproduzindo em Node a chamada `fetch` exatamente como está em `VersaoPage.jsx`:
  - Cenário online: `apiStatus = 'online'`, `apiVersion = "Bia 4.3.0"` (o valor exato que o campo
    "Versão da API" exibe), sem erro.
  - Cenário offline (com `docker compose stop server`): `apiStatus = 'offline'`, `apiVersion =
    null` (renderiza "—"), `error` sem qualquer menção a "is not valid JSON".
  - Reconexão (equivalente ao botão "Atualizar", com `docker compose start server`): volta a
    `apiStatus = 'online'` com `apiVersion = "Bia 4.3.0"`.
  - Como controle, reproduzi também o bug original (`response.json()` sobre a mesma resposta) e
    confirmei que ele gera exatamente o erro relatado pelo PO: `Unexpected token 'B', "Bia 4.3.0"
    is not valid JSON`.
- **Revisão de diff completa de `VersaoPage.jsx`:** confirmei que status, ambiente, URL da API,
  botão "Atualizar" e bloco de erro não foram alterados — apenas os dois campos "API — Nome"/"API
  — Versão" foram substituídos por um único campo "Versão da API", e `response.json()` virou
  `response.text()`.

### Bloqueio para validação visual "na tela" (não resolvido nesta task)
Não foi possível abrir `/versao` em um navegador real e confirmar visualmente (status
online/offline na tela, tema claro/escuro) pelos seguintes motivos, ambos fora do escopo desta
task:

1. **Rota `/versao` não existe em `App.jsx` nesta branch.** A branch base desta task
   (`desafio-labs/kiro-cli`) ainda não tem o `<Route path="/versao" element={<VersaoPage />} />`
   nem o link/botão "API" no `Header` — essas mudanças foram feitas no commit `8b63bff` ("feat:
   botão API com padrão visual consistente e botão de voltar na tela de versão"), que existe
   **apenas** na branch `feature/007-feat-botao-api-padrao-e-voltar-versao` e ainda não foi
   mergeado em `desafio-labs/kiro-cli`. Como consequência, nesta branch `VersaoPage.jsx` é código
   órfão (não importado por nada) e o bundle de produção gerado pelo `vite build` sequer o inclui
   (tree-shaking) — confirmei isso inspecionando o JS gerado pelo `docker compose build`, que não
   contém as strings do componente.
   - O botão "Voltar" citado nos critérios de aceite também não existe em `VersaoPage.jsx` nesta
     branch pelo mesmo motivo (foi adicionado no mesmo commit `8b63bff`).
2. **Sem ferramenta de navegador/headless disponível no ambiente** (sem chromium, puppeteer,
   playwright ou jsdom instalados) para renderizar e capturar a tela mesmo que a rota existisse.

A correção em si (`response.text()` + campo único "Versão da API") está implementada e validada
funcionalmente contra o backend real, como descrito acima. Recomendo que a validação visual final
("na tela", tema claro/escuro) seja feita pelo QA em um ambiente onde a branch `feature/007-...`
já esteja mesclada em `desafio-labs/kiro-cli` (ou testando as branches 007+008 combinadas), usando
um navegador real.

> **Atualização do PO:** esse bloqueio foi resolvido — ver seção "Validação final (PO)" acima. O
> dono do projeto validou manualmente no navegador após o merge das tasks 007 e 008 em
> `desafio-labs/kiro-cli`.

---

## Testes

- Com a API rodando normalmente, abrir `/versao` e confirmar:
  - Status "🟢 Online"
  - Campo "Versão da API" exibindo `Bia 4.3.0` (ou o valor de `VERSAO_API`, se configurado)
  - Nenhum erro no bloco de erro
- Derrubar a API (ex.: parar o container do backend) e confirmar:
  - Status "🔴 Offline"
  - Campo "Versão da API" mostrando "—"
  - Bloco de erro mostrando uma mensagem de conexão (timeout ou erro de rede), **sem** menção a
    "is not valid JSON"
- Clicar em "Atualizar" com a API online e confirmar que o campo volta a exibir o valor correto.
- Repetir os testes acima em tema claro e escuro.
- Confirmar via `curl -i http://localhost:3001/api/versao` que a resposta da API continua sendo
  texto puro, sem qualquer alteração no backend.

---

## Instruções Finais para o Agente

1. Confirmar que está no branch `feature/008-fix-versao-page-parse-texto-plano` (criar a partir de
   `desafio-labs/kiro-cli` se ainda não existir).
2. Aplicar a correção em `client/src/components/VersaoPage.jsx`, atendendo ao Objetivo e aos
   Critérios de Aceite.
3. Validar todos os critérios de aceite.
4. Fazer commit das alterações no branch da task.
5. Abrir PR apontando para `desafio-labs/kiro-cli` com título claro e descrição resumida do bug e
   da correção.
6. Notificar o PO para aceite final.
