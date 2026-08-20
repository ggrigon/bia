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
- [ ] A resposta de `/api/versao` é lida como texto puro (não `response.json()`).
- [ ] Com a API rodando normalmente (`curl http://localhost:3001/api/versao` retornando
      `Bia 4.3.0` como texto puro), a tela `/versao` mostra status "🟢 Online" e **não** exibe o
      erro `Unexpected token ... is not valid JSON`.

### Exibição simplificada
- [ ] Os campos separados "API — Nome" e "API — Versão" foram removidos.
- [ ] Existe um único campo "Versão da API" que exibe a string completa retornada pela API (ex:
      `Bia 4.3.0`), sem tentar quebrar/parsear em nome + número de versão.
- [ ] Enquanto a checagem está em andamento, o campo mostra "Verificando...", igual ao padrão
      atual dos demais campos da tela.
- [ ] Quando a API está offline/inacessível, o campo mostra "—", igual ao padrão atual.

### Backend inalterado
- [ ] `api/controllers/versao.js` não foi modificado.
- [ ] `curl -i http://localhost:3001/api/versao` continua retornando texto puro (`Bia 4.3.0`),
      `Content-Type: text/html`, sem virar JSON.

### Geral
- [ ] Nenhuma outra funcionalidade da tela `/versao` (status, ambiente, URL da API, botão
      "Atualizar", botão "Voltar", bloco de erro) foi quebrada.
- [ ] Testado com a API online e com a API offline (ex.: backend derrubado), confirmando os dois
      cenários (sucesso e erro) na tela.
- [ ] Testado visualmente em tema claro e escuro.

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
