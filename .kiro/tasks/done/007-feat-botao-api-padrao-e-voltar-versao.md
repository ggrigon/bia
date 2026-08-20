# 007 - feat - Botão "API" com padrão visual consistente e botão de voltar na tela de versão

> **REVISADA — task reprovada pelo PO na primeira entrega.** Ver seção "Correção obrigatória
> antes de reimplementar" logo abaixo antes de qualquer alteração de código.

## Modelo de Trabalho

- **Modelo:** Feature Branch
- **Branch base:** `desafio-labs/kiro-cli`
- **Branch da task:** `feature/007-feat-botao-api-padrao-e-voltar-versao` (já existe, criado na
  primeira tentativa e renomeado depois para seguir o padrão `feature/` — continue usando o mesmo
  branch, não crie um novo)
- **Agente responsável:** `dev`

### Instruções de início obrigatórias

1. Confirmar que está no branch `feature/007-feat-botao-api-padrao-e-voltar-versao`. Caso
   contrário, fazer checkout desse branch antes de iniciar (não criar um branch novo).
2. Ler a seção **"Correção obrigatória antes de reimplementar"** abaixo e executá-la **antes** de
   qualquer nova implementação.

---

## Correção obrigatória antes de reimplementar

Na primeira tentativa desta task (commit `8b63bff` no branch
`007-feat-botao-api-padrao-e-voltar-versao`), o dev entendeu o escopo errado: interpretou que o
"botão API" a ser redesenhado era o ícone circular de status (`.version-trigger`, a "bolinha"
verde/vermelha/amarela) e **fundiu status + navegação em um único elemento**
(`<Link to="/versao" className="btn">🟢 API</Link>` dentro de `VersionInfo.jsx`), removendo o
tooltip antigo e as classes CSS `.version-info`/`.version-trigger`/`.version-tooltip`/
`.version-content`/`.version-details`/`.version-link` de `client/src/index.css`. Isso **não** é o
que foi pedido — ver seção "Contexto" abaixo para o entendimento correto.

Antes de reescrever qualquer coisa, desfaça completamente essa implementação anterior, voltando
`client/src/components/VersionInfo.jsx` e `client/src/index.css` ao estado anterior à task 007
(commit `dd40170`, ou seja, o estado logo antes do commit `8b63bff`):

```bash
git checkout dd40170 -- client/src/components/VersionInfo.jsx client/src/index.css
```

Confirme com `git diff dd40170 -- client/src/components/VersionInfo.jsx client/src/index.css`
que não há mais diferença nesses dois arquivos em relação ao commit `dd40170`.

**Não desfaça** as alterações em `client/src/App.jsx` e `client/src/components/VersaoPage.jsx` —
essas partes já ficaram corretas na primeira entrega (rota `/versao` registrada e botão de voltar
implementado) e devem ser mantidas como estão.

Só depois de restaurar `VersionInfo.jsx`/`index.css` e conferir o estado do branch, releia esta
task (já corrigida) do zero antes de implementar de novo.

---

## Contexto

O dono do projeto forneceu imagens de referência do cabeçalho padrão esperado, à direita do
título "BIA 2026", com **três elementos visuais distintos, lado a lado**:

1. Um **link de texto "API"** — hoje um link simples, estilo padrão de âncora (roxo/azul,
   sublinhado), sem nenhum estilo customizado de botão.
2. Uma **bolinha de status** colorida (vermelho/verde), maior, redonda — indicador visual de
   saúde da API.
3. Um **ícone de engrenagem** (configurações) — elemento separado, **fora do escopo desta task**.

A referência visual do dono destaca claramente que o elemento a transformar em botão é o **link
de texto "API"** — não a bolinha de status e não a engrenagem. **A bolinha de status deve
continuar existindo, visualmente separada, sem ser incorporada dentro do novo botão.**

Levantamento feito no código atual (`client/src`, estado do commit `dd40170`, ou seja, antes da
primeira tentativa desta task):

- O único elemento relacionado a "API" existente hoje no `Header` (`client/src/components/Header.jsx`)
  é o `.version-trigger` dentro de `client/src/components/VersionInfo.jsx`: um **círculo pequeno
  (24x24px, `border-radius: 50%`)** com um emoji de status (🟢/🔴/🟡), estilizado em `index.css`
  na classe `.version-trigger`. Ao clicar, ele abre um **tooltip inline** (`.version-tooltip`)
  com detalhes de status/ambiente.
- **Não existe hoje, neste repositório, nem um link de texto "API" separado, nem um ícone de
  engrenagem.** O dono está usando como referência visual o cabeçalho padrão desejado — o link de
  texto "API" precisa ser **criado do zero** como elemento novo e distinto da bolinha de status.
  O ícone de engrenagem **não faz parte desta task** (não deve ser criado aqui).
- O padrão visual dos demais botões da aplicação é a classe `.btn` (`index.css`, ~linha 100):
  fundo com `var(--accent-primary)`, texto branco, `padding: 0.5rem 1rem`, `border-radius: 6px`.
  É o padrão usado, por exemplo, no botão "Adicionar" (`AddTask.jsx`,
  `className="btn btn-block success"`) e no botão "Atualizar" da própria tela de versão
  (`VersaoPage.jsx`, `className="btn"`).
- **Importante:** o componente `client/src/components/VersaoPage.jsx` (criado na task 001 e
  simplificado na task 006) já existe. Na primeira tentativa desta task, a rota `/versao` foi
  registrada corretamente em `App.jsx` e um botão de voltar (`.back-button`, mesmo padrão usado em
  `About.jsx`) foi adicionado em `VersaoPage.jsx` — **essa parte está correta e deve ser
  preservada**.
- Já existe um padrão de "botão voltar" no projeto: `client/src/components/About.jsx` usa
  `<Link to="/" className="back-button">← Voltar</Link>`, estilizado pela classe `.back-button`
  em `index.css` (~linha 389).

Ou seja, o pedido real é: criar um **botão "API"** (elemento novo, com o padrão visual `.btn`) que
navega para `/versao`, mantendo, **ao lado dele e visualmente separado**, o indicador de status já
existente (a bolinha `.version-trigger` com seu tooltip). Os dois elementos **não devem ser
fundidos** em um único componente/botão.

---

## Objetivo

1. Adicionar no `Header` um **botão "API"** com o mesmo padrão visual dos demais botões do app
   (classe `.btn`), que ao ser clicado **navega para a rota `/versao`** via React Router.
2. Manter o indicador de status (a bolinha `.version-trigger`/`VersionInfo.jsx`, com seu tooltip)
   funcionando exatamente como funcionava antes da task 007 — como um **elemento visual separado**
   do novo botão "API", renderizado ao lado dele no `Header`.
3. Confirmar que a rota `/versao` continua registrada em `App.jsx`, renderizando `VersaoPage.jsx`
   (já implementado corretamente na primeira tentativa — não precisa ser refeito).
4. Confirmar que `VersaoPage.jsx` continua com o botão/link para **voltar à página inicial** (`/`),
   reaproveitando o padrão visual `.back-button` (já implementado corretamente na primeira
   tentativa — não precisa ser refeito).

---

## Arquivos Envolvidos

- `client/src/components/Header.jsx`
- `client/src/components/VersionInfo.jsx` (restaurar ao estado pré-task-007 antes de continuar)
- `client/src/components/VersaoPage.jsx` (já correto, não alterar a menos que necessário)
- `client/src/App.jsx` (já correto, não alterar a menos que necessário)
- `client/src/index.css` (restaurar ao estado pré-task-007 antes de continuar; adicionar apenas o
  CSS novo necessário para o botão "API", se não for suficiente reaproveitar `.btn`)

---

## Critérios de Aceite

### Botão "API" novo, com padrão visual consistente
- [x] Existe um botão/link com o texto "API", visível no `Header`, ao lado do indicador de status
      existente, usando o mesmo padrão visual dos demais botões da aplicação (classe `.btn`:
      fundo com cor de destaque, texto branco, `padding`/`border-radius` iguais aos outros
      botões).
- [x] O botão "API" **não** incorpora o emoji/cor de status (🟢/🔴/🟡) nem substitui o indicador de
      status existente — é um elemento visualmente distinto, com texto simples "API".
- [x] Ao clicar no botão "API", o usuário é levado para a rota `/versao` da aplicação (navegação
      via React Router — `Link` ou `useNavigate` —, sem recarregar a página inteira).
- [x] O botão continua respeitando o tema claro/escuro (usa as variáveis `--bg-*`, `--accent-*`,
      `--text-*` já existentes, sem cores fixas incompatíveis com o dark mode).

### Indicador de status preservado como elemento separado
- [x] O indicador de status (bolinha `.version-trigger`, com emoji 🟢/🔴/🟡 conforme o status da
      API) continua existindo no `Header`, renderizado ao lado do novo botão "API", e **não** foi
      removido, substituído ou fundido dentro do botão.
- [x] O comportamento do indicador de status (checagem periódica via `fetch('/api/versao')`,
      tooltip com detalhes de ambiente/URL ao clicar) continua funcionando exatamente como antes
      da task 007.
- [x] As classes CSS `.version-info`, `.version-trigger`, `.version-tooltip`, `.version-content`,
      `.version-details` e `.version-link` em `index.css` continuam presentes e funcionais (não
      foram removidas).

### Rota `/versao` funcional (já implementado — apenas confirmar)
- [x] A rota `/versao` está registrada em `App.jsx`
      (`<Route path="/versao" element={<VersaoPage />} />`) e renderiza `VersaoPage.jsx`
      corretamente.
- [x] O comportamento já existente da tela de versão (bloco de status da API, botão "Atualizar",
      bloco de erro quando a API está offline — conforme entregue na task 006) continua
      funcionando normalmente.

### Botão de voltar na página de versão (já implementado — apenas confirmar)
- [x] Existe um botão/link "Voltar" (ou "← Voltar") na tela `/versao` que retorna o usuário para a
      página inicial (`/`).
- [x] O botão de voltar reaproveita o padrão visual `.back-button` já usado em `About.jsx`, para
      manter consistência entre as páginas internas do app.
- [x] A navegação de volta usa o React Router (`Link to="/"`), sem recarregar a aplicação inteira.

### Geral
- [x] Nenhuma funcionalidade existente da página principal (lista de tarefas, adicionar/excluir
      tarefa, toggle de tema, link "Sobre a BIA" no footer) é quebrada pelas alterações.
- [x] Testado visualmente em tema claro e escuro.

---

## Sugestão de Implementação (não vinculante, a critério do dev)

- Em `Header.jsx`, adicionar um novo elemento `<Link to="/versao" className="btn">API</Link>` ao
  lado de `<VersionInfo />` (sem remover ou alterar o `VersionInfo` restaurado), dentro de
  `header-controls`. Pode ser feito diretamente no JSX do `Header` ou extraído para um pequeno
  componente próprio (ex: `ApiButton.jsx`), a critério do dev — desde que fique claro no código
  que são dois elementos distintos.
- Não reaproveitar a lógica de status (`checkApiHealth`, `apiStatus`) dentro do novo botão "API".
  Essa lógica pertence exclusivamente ao `VersionInfo.jsx` (indicador de status).
- Em `App.jsx` e `VersaoPage.jsx`, nenhuma alteração deveria ser necessária — apenas confirmar que
  o estado atual (pós primeira tentativa, sem contar `VersionInfo.jsx`/CSS) já atende aos
  critérios de aceite correspondentes.

---

## Testes

- Abrir a página principal e confirmar que existem **dois elementos visuais distintos** no
  cabeçalho: o botão "API" (estilo `.btn`) e a bolinha de status (`.version-trigger`).
- Clicar no botão "API" e confirmar que a navegação leva para `/versao`, exibindo a tela de status
  da API.
- Clicar na bolinha de status e confirmar que o tooltip antigo (`.version-tooltip`) ainda abre
  normalmente, sem navegar para lugar nenhum.
- Na tela `/versao`, clicar no botão "Voltar" e confirmar que retorna para a página inicial (`/`),
  com a lista de tarefas preservada (sem reload completo perdendo estado desnecessariamente).
- Repetir os fluxos acima em tema claro e escuro.
- Simular API offline (ex: derrubar o backend) e confirmar que o emoji/cor de status refletido na
  bolinha `.version-trigger` muda de acordo, e que a tela `/versao` mostra o bloco de erro
  corretamente. O botão "API" não deve mudar de aparência com o status (ele é fixo, sem indicador
  de status embutido).

---

## Instruções Finais para o Agente

1. Executar a seção "Correção obrigatória antes de reimplementar" (restaurar
   `VersionInfo.jsx`/`index.css` ao estado pré-task-007) antes de qualquer nova implementação.
2. Aplicar as alterações descritas em `Header.jsx` (e, se optar por extrair, um novo componente
   próprio para o botão "API"), preservando `App.jsx` e `VersaoPage.jsx` como já estão.
3. Validar todos os critérios de aceite.
4. Fazer commit das alterações no branch `feature/007-feat-botao-api-padrao-e-voltar-versao`.
5. Abrir PR apontando para `desafio-labs/kiro-cli` com título claro e descrição resumida,
   explicando que esta é uma correção de escopo em cima da entrega anterior.
6. Notificar o PO para aceite final.
