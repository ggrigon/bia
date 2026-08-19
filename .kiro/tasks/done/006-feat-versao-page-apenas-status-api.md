# 006 - feat - Tela de versão exibe apenas status da API

## Modelo de Trabalho

- **Modelo:** Feature Branch
- **Branch base:** `desafio-labs/kiro-cli`
- **Branch da task:** `006-feat-versao-page-apenas-status-api`
- **Agente responsável:** `dev`

### Instruções de início obrigatórias

1. Verificar se está no branch `desafio-labs/kiro-cli`. Caso contrário, informar e perguntar se pode retornar antes de iniciar.
2. Após autorização:
   - Mover este arquivo para a pasta `doing`
   - Fazer commit e push no branch `desafio-labs/kiro-cli`
   - Criar e mudar para o branch `006-feat-versao-page-apenas-status-api`

---

## Contexto

A tela de versão (`VersaoPage.jsx`) atualmente exibe quatro blocos:

1. **Status da API** — nome, versão, status, ambiente, URL
2. **Frontend** — informações do cliente (nome e versão vindas de `apiVersion.cliente`)
3. **Erro** — bloco de erro quando a API está offline
4. **Cache** — configurações do cache (`/api/cache-config`)

A solicitação é simplificar a tela, mantendo **apenas os dados de status da API**.

---

## Objetivo

Remover os blocos de **Frontend** e **Cache** do componente `VersaoPage.jsx`, mantendo apenas:
- Bloco de **Status da API** (nome, versão, status, ambiente, URL)
- Bloco de **Erro** (exibido condicionalmente quando `apiStatus === 'offline'`)

---

## Arquivos Envolvidos

- `client/src/components/VersaoPage.jsx`

---

## Critérios de Aceite

- [x] O bloco "Frontend" (`apiVersion.cliente`) não é mais exibido na tela.
- [x] O bloco "Cache" (`cacheConfig`) não é mais exibido na tela.
- [x] O bloco de Status da API continua exibindo: nome, versão, status, ambiente e URL da API.
- [x] O bloco de erro continua aparecendo quando a API está offline.
- [x] O botão "Atualizar" continua funcionando normalmente.
- [x] A lógica de buscar `/api/cache-config` pode ser removida, já que o dado não é mais exibido.
- [x] O estado `cacheConfig` e a chamada fetch para cache podem ser removidos para limpeza do código.

---

## Implementação

### Arquivo: `client/src/components/VersaoPage.jsx`

**1. Remover o estado `cacheConfig`:**
```js
// Remover esta linha
const [cacheConfig, setCacheConfig] = useState(null);
```

**2. Remover a chamada fetch para `/api/cache-config`** dentro de `checkApiHealth`:
```js
// Remover este bloco inteiro
try {
  const cacheRes = await fetch(`${apiUrl}/api/cache-config`, { cache: 'no-cache' });
  if (cacheRes.ok) {
    setCacheConfig(await cacheRes.json());
  }
} catch {
  // cache-config opcional, ignora erro
}
```

**3. Remover o bloco JSX do Frontend:**
```jsx
// Remover este bloco inteiro
{apiVersion && apiVersion.cliente && (
  <div className="task" style={{ marginBottom: '0.75rem' }}>
    ...
  </div>
)}
```

**4. Remover o bloco JSX do Cache:**
```jsx
// Remover este bloco inteiro
{cacheConfig && cacheConfig.enabled && (
  <div className="task">
    ...
  </div>
)}
```

---

## O que deve permanecer

```jsx
{/* Status da API */}
<div className="task" style={{ marginBottom: '0.75rem' }}>
  ... nome, versão, status, ambiente, URL ...
</div>

{/* Erro */}
{error && apiStatus === 'offline' && (
  <div className="task" ...>
    ...
  </div>
)}
```

---

## Testes

- Abrir a tela de versão e confirmar que apenas o bloco de Status da API é exibido.
- Confirmar que não aparecem seções de "Frontend" nem "Cache".
- Confirmar que o botão "Atualizar" continua funcionando.
- Simular API offline (ex: URL errada) e confirmar que o bloco de erro aparece.

---

## Instruções Finais para o Agente

1. Aplicar as alterações descritas acima em `client/src/components/VersaoPage.jsx`.
2. Validar os critérios de aceite.
3. Fazer commit das alterações no branch `006-feat-versao-page-apenas-status-api`.
4. Abrir PR apontando para `desafio-labs/kiro-cli` com título claro e descrição resumida.
5. Notificar o PO para aceite final.
