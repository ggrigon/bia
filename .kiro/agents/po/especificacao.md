# Especificação do PO — Fluxo de Tarefas

## Criação de Tarefas

Sempre que for pedida uma nova atividade, o resultado será a criação de um arquivo markdown `.md`.

### Formato do arquivo
`[025]-[feat]-[resumo].md`

Onde:
- `[025]` — número sequencial da tarefa, sempre com 3 dígitos
- `[feat]` — tipo da tarefa: `feat`, `fix` ou `test`
- `[resumo]` — resumo curto da tarefa, separado por hífens

### Controle sequencial
- Gerenciado pelo arquivo `sequencial.md`
- Nesse arquivo será registrada a última task e a numeração da tarefa
- Usar sempre o número seguinte ao registrado e incrementar o valor após a criação

### Local de criação
- Pasta: `.kiro/tasks/`
- Tarefas finalizadas são movidas para: `.kiro/tasks/done/`

## Nomenclatura de branch

Toda task criada deve especificar o branch da task no formato: `feature/[025]-[feat]-[resumo]` —
ou seja, o mesmo nome do arquivo da task (número sequencial + tipo + resumo), com o prefixo
obrigatório `feature/`. Nunca crie/instrua a criação de um branch de task sem esse prefixo.

## Fluxo de Revisão

1. **Criar a tarefa** na pasta `.kiro/tasks/`
2. **Sinalizar ao usuário** para revisão
3. **Após aprovação**, perguntar se pode fazer o commit e push (incluir task + sequencial)

## Fluxo de Finalização (após implementação concluída e validada)

### Pré-PR (na branch da feature)

1. **Verificar se está na branch da feature** (`git branch --show-current`)
2. **Mover o arquivo da task** para a pasta `done/` (`git mv .kiro/tasks/XXX.md .kiro/tasks/done/`)
3. **Atualizar o `sequencial.md`** se ainda não estiver atualizado
4. **Fazer commit e push** com a movimentação da task e sequencial

### Abertura do PR

5. **Abrir Pull Request** via `gh pr create --repo ggrigon/bia` com:
   - **Branch de origem:** `feature/[025]-[feat]-[resumo]`
   - **Branch de destino:** `desafio-labs/kiro-cli`
   - **Título:** O mesmo resumo da tarefa em formato legível
   - **Corpo:** Conteúdo do arquivo da task (descrição, critérios de aceite, etc.)
6. **Informar o link do PR** ao usuário para revisão final

### Pós-PR (após checks passarem e aprovação)

7. **Aguardar os checks do GitHub Actions passarem** (`gh pr checks <numero> --repo ggrigon/bia`)
8. **Fazer o merge** via `gh pr merge <numero> --repo ggrigon/bia --merge --delete-branch`
9. **Confirmar o merge** e informar ao usuário

> **Importante:** A flag `--delete-branch` já remove a branch remota automaticamente. Nunca fazer merge sem antes ter movido a task para `done/`.
