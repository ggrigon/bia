# [001] Tela de Versão da API

## Tipo
`feat`

## Resumo
Criar uma página dedicada no frontend para exibir as informações retornadas pela rota `/api/versao`, seguindo o mesmo padrão visual e estrutural da tela de Tarefas.

---

## Contexto

Atualmente, a rota `/api/versao` já existe no backend e retorna uma string com a versão da aplicação (ex: `Bia 4.3.0`). No frontend, essas informações são consumidas apenas pelo componente `VersionInfo.jsx`, que exibe um pequeno tooltip no rodapé — sem uma página dedicada e navegável.

O objetivo desta tarefa é criar uma tela acessível via rota no React Router, que apresente os dados de versão de forma expandida, com o mesmo layout, componentes e estilo visual já usados na tela de Tarefas (`/`).

---

## Critérios de Aceite

- [x] Existe uma nova rota no React Router em `/versao`
- [x] A rota `/versao` é acessível a partir de um link no `Header`
- [x] A tela exibe o retorno da API `/api/versao` (string de versão)
- [x] A tela exibe o status atual da API (online/offline/verificando), igual ao `VersionInfo`
- [x] A tela exibe o ambiente detectado (Local, IP Direto, ALB, Produção), igual ao `VersionInfo`
- [x] A tela exibe a URL da API configurada (`VITE_API_URL`)
- [x] Quando a configuração de cache estiver presente (`/api/cache-config`), exibir os dados do cache (endpoint, porta, TTL)
- [x] O layout da tela segue o mesmo padrão visual da tela de Tarefas: usa as mesmas classes CSS, tipografia e estrutura de container
- [x] Há um botão "Atualizar" que faz nova consulta à API ao ser clicado
- [x] A tela trata o estado de carregamento (loading) e de erro (API offline)

---

## Referências Técnicas

### Backend
- **Rota:** `GET /api/versao`
- **Controller:** `api/controllers/versao.js`
- **Retorno:** string simples — ex: `Bia 4.3.0`
- **Rota de cache:** `GET /api/cache-config` — retorna `{ enabled, endpoint, port, ttl }`

### Frontend — arquivos relacionados
- **Componente existente com lógica de versão:** `client/src/components/VersionInfo.jsx`
  - Já contém: `getApiUrl()`, `checkApiHealth()`, `getStatusIcon()`, `getStatusText()`, `getEnvironmentInfo()`
  - Lógica deve ser **reutilizada ou extraída** para o novo componente de página
- **Tela de referência visual:** `client/src/components/Tasks.jsx`
  - Usar o mesmo padrão de container, cards e classes CSS existentes
- **Roteamento:** `client/src/App.jsx`
  - Adicionar `<Route path="/versao" element={<VersaoPage />} />` dentro do `<Routes>`
- **Navegação:** `client/src/components/Header.jsx`
  - Adicionar link de navegação para `/versao`

### Novo arquivo a criar
- `client/src/components/VersaoPage.jsx` — componente da página de versão

---

## Escopo

### Inclui
- Novo componente `VersaoPage.jsx`
- Nova rota `/versao` no `App.jsx`
- Link de navegação no `Header.jsx`

### Não inclui
- Alterações no backend
- Alterações no `VersionInfo.jsx` (o tooltip existente deve continuar funcionando normalmente)
- Novo endpoint na API

---

## Estimativa
Pequena — componente simples com reutilização de lógica já existente no `VersionInfo.jsx`
