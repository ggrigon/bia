# [004] Exibir Informações do Cliente na Rota de Versão

## Tipo
`feat`

## Resumo
Adicionar informações do cliente (frontend) à resposta da rota `/api/versao` do backend, e exibi-las também na tela de versão (`/versao`) do frontend.

---

## Contexto

Atualmente, a rota `GET /api/versao` retorna apenas uma string com a versão da API do backend — ex: `Bia 4.3.0`.

O projeto possui duas partes com versões próprias:
- **Backend (API):** `package.json` raiz → versão `4.3.0`
- **Frontend (Client):** `client/package.json` → versão `0.1.0`, nome `react-task-tracker`

O objetivo é enriquecer a resposta da rota `/api/versao` para incluir também os dados do cliente (nome e versão do frontend), tornando o endpoint mais informativo e útil para diagnóstico.

---

## Critérios de Aceite

- [x] A rota `GET /api/versao` retorna um **objeto JSON** com as seguintes informações:
  - `api.nome` — nome da aplicação backend (ex: `"bia"`)
  - `api.versao` — versão do backend (ex: `"4.3.0"`)
  - `cliente.nome` — nome do frontend (ex: `"react-task-tracker"`)
  - `cliente.versao` — versão do frontend (ex: `"0.1.0"`)
- [x] O controller `api/controllers/versao.js` lê a versão do backend a partir do `package.json` raiz (ou da variável de ambiente `VERSAO_API` como fallback)
- [x] O controller lê as informações do cliente a partir do `client/package.json`
- [x] A tela `/versao` no frontend exibe as novas informações do cliente (nome e versão)
- [x] A tela `/versao` continua exibindo corretamente as informações da API (nome e versão do backend)
- [x] O componente `VersionInfo.jsx` (tooltip do rodapé) não é quebrado pela mudança de formato da resposta — adaptar se necessário
- [x] A rota continua respondendo `200 OK` em caso de sucesso

---

## Referências Técnicas

### Backend — o que alterar

**`api/controllers/versao.js`**
- Ler `package.json` da raiz para obter `name` e `version` do backend
- Ler `client/package.json` para obter `name` e `version` do frontend
- Retornar um objeto JSON no lugar da string simples:

```json
{
  "api": {
    "nome": "bia",
    "versao": "4.3.0"
  },
  "cliente": {
    "nome": "react-task-tracker",
    "versao": "0.1.0"
  }
}
```

> **Nota:** Manter suporte à variável de ambiente `VERSAO_API` como override da versão da API, se definida.

### Frontend — o que alterar

**`client/src/components/VersaoPage.jsx`**
- Ajustar a leitura da resposta de `/api/versao` para o novo formato JSON
- Exibir bloco com dados do cliente: nome e versão

**`client/src/components/VersionInfo.jsx`**
- Ajustar a leitura da resposta de `/api/versao` para o novo formato JSON (a resposta mudou de string para objeto)

---

## Escopo

### Inclui
- Alteração no controller `api/controllers/versao.js`
- Ajuste no componente `client/src/components/VersaoPage.jsx`
- Ajuste no componente `client/src/components/VersionInfo.jsx`

### Não inclui
- Novos endpoints na API
- Alterações em banco de dados
- Alterações de layout ou estilo visual

---

## Estimativa
Pequena — leitura de arquivos JSON locais e ajuste de componentes React já existentes
