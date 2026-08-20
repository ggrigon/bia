- Sempre que você estiver implementando uma task, você DEVE editar o arquivo `.md` da tarefa em `.kiro/tasks/` e alterar cada critério de aceite concluído de `- [ ]` para `- [x]` usando a ferramenta de escrita de arquivos. Isso deve ser feito à medida que cada item for implementado, não apenas ao final.
    - Considere o teste como realizado, somente após fazer o build no docker compose e testado o artefato implementado.
    - Se já tiver um container rodando com o mesmo nome, pare ele, execute o que está no compose do projeto, para ter certeza que estamos rodando o container correto.
- Ao terminar todos os critérios de aceite, mova o arquivo `.md` da tarefa para `.kiro/tasks/done/`.
- Sempre ao terminar a implementação da task, me avise que tudo está pronto e sinalize qual o próximo agent que deverá ser chamado.

