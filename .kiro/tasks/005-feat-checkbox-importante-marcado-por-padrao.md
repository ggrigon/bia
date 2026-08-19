# 005 - feat - Checkbox "Importante" marcado por padrão ao cadastrar tarefa

## Modelo de Trabalho

- **Modelo:** Feature Branch
- **Branch base:** `desafio-labs/kiro-cli`
- **Branch da task:** `005-feat-checkbox-importante-marcado-por-padrao`
- **Agente responsável:** `dev`

### Instruções de início obrigatórias

1. Verificar se está no branch `desafio-labs/kiro-cli`. Caso contrário, informar e perguntar se pode retornar antes de iniciar.
2. Após autorização:
   - Mover este arquivo para a pasta `doing`
   - Fazer commit e push no branch `desafio-labs/kiro-cli`
   - Criar e mudar para o branch `005-feat-checkbox-importante-marcado-por-padrao`

---

## Contexto

No formulário de cadastro de nova tarefa (`AddTask.jsx`), o checkbox "Importante" está desmarcado por padrão (`useState(false)`). A necessidade é que ele venha **marcado por padrão** ao abrir o formulário, bem como após o envio de uma nova tarefa (reset do formulário).

---

## Objetivo

Alterar o componente `AddTask.jsx` para que o checkbox "Importante" esteja marcado (`true`) por padrão ao inicializar o formulário e ao resetar após o envio.

---

## Arquivos Envolvidos

- `client/src/components/AddTask.jsx`

---

## Critérios de Aceite

- [ ] Ao abrir o formulário de adicionar tarefa, o checkbox "Importante" deve estar marcado por padrão.
- [ ] Após submeter uma nova tarefa com sucesso, o formulário deve ser resetado com o checkbox "Importante" marcado novamente (não desmarcado).
- [ ] O comportamento do checkbox continua funcionando normalmente (o usuário pode desmarcar antes de submeter).
- [ ] Nenhuma outra funcionalidade do formulário é afetada.

---

## Implementação

### Arquivo: `client/src/components/AddTask.jsx`

**Alteração 1 — Inicialização do estado:**
```js
// Antes
const [importante, setImportante] = useState(false);

// Depois
const [importante, setImportante] = useState(true);
```

**Alteração 2 — Reset após submit:**
```js
// Antes
setImportante(false);

// Depois
setImportante(true);
```

---

## Testes

- Abrir o formulário de adicionar tarefa e confirmar que o checkbox já aparece marcado.
- Desmarcar o checkbox, preencher o título e submeter → tarefa criada sem "Importante".
- Após o submit, confirmar que o formulário volta com o checkbox marcado.
- Marcar o checkbox (já está marcado), preencher o título e submeter → tarefa criada como "Importante".

---

## Instruções Finais para o Agente

1. Aplicar as duas alterações descritas acima em `client/src/components/AddTask.jsx`.
2. Validar manualmente (ou via teste) os critérios de aceite.
3. Fazer commit das alterações no branch `005-feat-checkbox-importante-marcado-por-padrao`.
4. Abrir PR apontando para `desafio-labs/kiro-cli` com título claro e descrição resumida.
5. Notificar o PO para aceite final.
