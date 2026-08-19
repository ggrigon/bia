# [005] feat: Checkbox "Importante" marcado por padrão ao cadastrar tarefa

## Descrição
Ao cadastrar uma nova tarefa, o campo **"Importante"** (checkbox) deve vir **marcado por padrão**, sem necessidade de interação do usuário. O usuário ainda pode desmarcar o campo caso queira.

## Critérios de Aceite
- [ ] O checkbox "Importante" deve estar marcado (`checked`) por padrão quando o formulário de cadastro de tarefa é aberto/renderizado.
- [ ] O usuário pode desmarcar o checkbox antes de salvar a tarefa.
- [ ] Ao salvar, o valor enviado deve refletir o estado atual do checkbox (marcado ou desmarcado).
- [ ] O comportamento dos demais campos do formulário não deve ser alterado.
- [ ] O comportamento do checkbox em telas de **edição** de tarefa existente não deve ser afetado — deve continuar exibindo o valor já salvo.

## Escopo Técnico
- Alteração restrita ao **frontend** (componente de formulário de cadastro de tarefa).
- Localizar o campo `importante` no componente de criação de tarefa e definir o valor inicial como `true`.

## Observações
- Apenas o estado inicial do checkbox deve ser alterado.
- Não alterar lógica de backend, banco de dados ou validações existentes.
- Manter a simplicidade — mudança pontual no estado inicial do componente.
