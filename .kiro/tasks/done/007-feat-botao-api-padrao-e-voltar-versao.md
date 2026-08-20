# 007 - feat - Botão "API" com padrão visual consistente e botão de voltar na tela de versão

## Modelo de Trabalho

- **Modelo:** Feature Branch
- **Branch base:** `desafio-labs/kiro-cli`
- **Branch da task:** `007-feat-botao-api-padrao-e-voltar-versao`
- **Agente responsável:** `dev`

### Instruções de início obrigatórias

1. Verificar se está no branch `desafio-labs/kiro-cli`. Caso contrário, informar e perguntar se pode retornar antes de iniciar.
2. Após autorização:
   - Mover este arquivo para a pasta `doing`
   - Fazer commit e push no branch `desafio-labs/kiro-cli`
   - Criar e mudar para o branch `007-feat-botao-api-padrao-e-voltar-versao`

---

## Contexto

Levantamento feito no código atual (`client/src`) antes de escrever esta task:

- O botão que hoje representa a "API" na página principal é o `.version-trigger` dentro de
  `client/src/components/VersionInfo.jsx`, renderizado no `Header` (`client/src/components/Header.jsx`).
  É um **círculo pequeno (24x24px, `border-radius: 50%`)** com um emoji de status (🟢/🔴/🟡), estilizado
  em `index.css` na classe `.version-trigger`. Ao clicar, ele abre um **tooltip inline** (`.version-tooltip`)
  com detalhes de status/ambiente — não é um botão retangular como os demais botões do app.
- O padrão visual dos demais botões da aplicação é a classe `.btn` (`index.css`, ~linha 100): fundo com
  `var(--accent-primary)`, texto branco, `padding: 0.5rem 1rem`, `border-radius: 6px`. É o padrão usado, por
  exemplo, no botão "Adicionar" (`AddTask.jsx`, `className="btn btn-block success"`) e no botão "Atualizar"
  da própria tela de versão (`VersaoPage.jsx`, `className="btn"`).
- **Importante:** o componente `client/src/components/VersaoPage.jsx` (criado na task 001 e simplificado na
  task 006) **já existe, mas não está registrado em nenhuma rota** — `client/src/App.jsx` só possui as rotas
  `/` e `/about`. Ou seja, hoje **não existe navegação real** entre o botão de status da API e a página de
  versão; o tooltip do `VersionInfo` apenas mostra um link "🔗 /api/versao" que abre a URL crua da API (JSON)
  em uma nova aba (`window.open`), fora da aplicação.
- Já existe um padrão de "botão voltar" no projeto: `client/src/components/About.jsx` usa
  `<Link to="/" className="back-button">← Voltar</Link>`, estilizado pela classe `.back-button` em
  `index.css` (~linha 389).

Ou seja, para atender ao pedido do usuário ("botão API abre a página de versão" e "página de versão tem
botão de voltar"), é necessário não só redesenhar o botão, mas também **ligar o botão à rota `/versao`**,
já que essa ligação nunca foi finalizada.

---

## Objetivo

1. Substituir o ícone circular `.version-trigger` por um **botão "API"** com o mesmo padrão visual dos
   demais botões do app (classe `.btn`), que ao ser clicado **navega para a rota `/versao`** (em vez de abrir
   o tooltip atual).
2. Registrar a rota `/versao` em `App.jsx`, renderizando `VersaoPage.jsx`.
3. Adicionar em `VersaoPage.jsx` um botão/link para **voltar à página inicial** (`/`), reaproveitando o
   padrão visual `.back-button` já usado em `About.jsx`.

---

## Arquivos Envolvidos

- `client/src/components/Header.jsx`
- `client/src/components/VersionInfo.jsx`
- `client/src/components/VersaoPage.jsx`
- `client/src/App.jsx`
- `client/src/index.css`

---

## Critérios de Aceite

### Botão "API" com padrão visual consistente
- [x] O botão "API" exibido na página principal usa o mesmo padrão visual dos demais botões da aplicação
      (classe `.btn`: fundo com cor de destaque, texto branco, `padding`/`border-radius` iguais aos outros
      botões), deixando de ser o círculo pequeno atual (`.version-trigger`).
- [x] O botão exibe o texto "API" (pode manter um ícone/emoji de status ao lado, ex: 🟢 API, 🔴 API, para não
      perder a informação de status online/offline/verificando que já existia).
- [x] Ao clicar no botão "API", o usuário é levado para a rota `/versao` da aplicação (navegação via React
      Router — `Link` ou `useNavigate` —, sem recarregar a página inteira).
- [x] O botão continua respeitando o tema claro/escuro (usa as variáveis `--bg-*`, `--accent-*`, `--text-*`
      já existentes, sem cores fixas incompatíveis com o dark mode).
- [x] O tooltip antigo (`.version-tooltip`, com detalhes de ambiente/URL/cache) deixa de ser aberto pelo
      clique no botão, já que essas informações passam a ser exibidas na própria página `/versao`.

### Rota `/versao` funcional
- [x] A rota `/versao` está registrada em `App.jsx` (`<Route path="/versao" element={<VersaoPage />} />`) e
      renderiza `VersaoPage.jsx` corretamente.
- [x] O comportamento já existente da tela de versão (bloco de status da API, botão "Atualizar", bloco de
      erro quando a API está offline — conforme entregue na task 006) continua funcionando normalmente.

### Botão de voltar na página de versão
- [x] Existe um botão/link "Voltar" (ou "← Voltar para o início") na tela `/versao` que retorna o usuário
      para a página inicial (`/`).
- [x] O botão de voltar reaproveita o padrão visual `.back-button` já usado em `About.jsx`, para manter
      consistência entre as páginas internas do app.
- [x] A navegação de volta usa o React Router (`Link to="/"`), sem recarregar a aplicação inteira.

### Geral
- [x] Nenhuma funcionalidade existente da página principal (lista de tarefas, adicionar/excluir tarefa,
      toggle de tema, link "Sobre a BIA" no footer) é quebrada pelas alterações.
- [x] Testado visualmente em tema claro e escuro.

---

## Sugestão de Implementação (não vinculante, a critério do dev)

- Em `Header.jsx`, trocar o uso de `<VersionInfo />` por um `<Link to="/versao" className="btn">` (ou um
  novo componente `ApiButton`/adaptação do próprio `VersionInfo.jsx`) que mantenha a checagem de status via
  `fetch('/api/versao')` apenas para decidir o ícone/cor exibido no botão, sem renderizar mais o tooltip.
- Em `App.jsx`, adicionar `import VersaoPage from "./components/VersaoPage.jsx";` e a rota
  `<Route path="/versao" element={<VersaoPage />} />` dentro de `<Routes>`.
- Em `VersaoPage.jsx`, importar `Link` de `react-router-dom` e adicionar, por exemplo, no topo ou rodapé da
  página:
  ```jsx
  <Link to="/" className="back-button">
    ← Voltar
  </Link>
  ```
- Avaliar se a classe `.version-trigger`/`.version-tooltip` em `index.css` deve ser removida ou mantida
  (remover se o tooltip deixar de ser usado, para não deixar CSS morto).

---

## Testes

- Abrir a página principal e confirmar que o botão "API" tem o mesmo estilo visual dos outros botões do app.
- Clicar no botão "API" e confirmar que a navegação leva para `/versao`, exibindo a tela de status da API.
- Na tela `/versao`, clicar no botão "Voltar" e confirmar que retorna para a página inicial (`/`), com a
  lista de tarefas preservada (sem reload completo perdendo estado desnecessariamente).
- Repetir os dois fluxos acima em tema claro e escuro.
- Simular API offline (ex: derrubar o backend) e confirmar que o ícone/cor de status refletido no botão
  "API" muda de acordo, e que a tela `/versao` mostra o bloco de erro corretamente.

---

## Instruções Finais para o Agente

1. Aplicar as alterações descritas acima em `Header.jsx`, `VersionInfo.jsx` (ou componente equivalente),
   `App.jsx`, `VersaoPage.jsx` e `index.css`.
2. Validar todos os critérios de aceite.
3. Fazer commit das alterações no branch `007-feat-botao-api-padrao-e-voltar-versao`.
4. Abrir PR apontando para `desafio-labs/kiro-cli` com título claro e descrição resumida.
5. Notificar o PO para aceite final.
