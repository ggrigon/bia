# 010 - feat - GitHub Actions para testes em PRs

## Branch
`feature/010-feat-github-actions-testes-pr`

## Descrição
Criar um workflow do GitHub Actions que execute os testes unitários automaticamente a cada Pull Request aberto contra o branch `desafio-labs/kiro-cli`.

O projeto já possui testes unitários com Jest (`tests/unit/`) que cobrem os controllers `versao` e `tarefas`. Esses testes não dependem de banco de dados (usam mocks), portanto o workflow é simples e direto.

## Contexto Técnico
- **Framework de testes:** Jest 27.5.1
- **Comando de execução:** `npm test` (executa `jest tests/unit`)
- **Arquivos de teste existentes:**
  - `tests/unit/controllers/versao.test.js` (3 testes)
  - `tests/unit/controllers/tarefas.test.js` (14 testes)
- **Dependência de infra:** Nenhuma (testes puramente unitários com mocks)

## Critérios de Aceite

- [x] Criar o arquivo `.github/workflows/tests.yml` na raiz do projeto
- [x] O workflow deve ser disparado em PRs cujo **target branch** seja `desafio-labs/kiro-cli`
- [x] O workflow deve:
  1. Fazer checkout do código
  2. Configurar Node.js (versão 20.x)
  3. Instalar dependências (`npm ci`)
  4. Executar os testes (`npm test`)
- [x] O workflow deve falhar o PR caso algum teste não passe (comportamento padrão do GitHub Actions)
- [x] Nome do workflow: `Testes Unitários`
- [x] Nome do job: `unit-tests`

## Entregável

Arquivo `.github/workflows/tests.yml` com a configuração do workflow.

## Exemplo Esperado do Workflow

```yaml
name: Testes Unitários

on:
  pull_request:
    branches:
      - desafio-labs/kiro-cli

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test
```

## Observações
- Não é necessário configurar banco de dados pois os testes usam mocks
- O cache do npm (`cache: 'npm'`) acelera execuções subsequentes
- Node 20.x é a versão LTS estável atual compatível com as dependências do projeto
