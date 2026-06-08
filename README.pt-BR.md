# ME2-Pack-Loader

> **Em desenvolvimento.**

GUI desktop em Flutter para gerenciar pacotes de mods do [ModEngine2](https://github.com/soulsmods/ModEngine2) em jogos da FromSoftware. Funciona como um wrapper do Steam — quando iniciado pelo Steam, ele permite ativar/desativar mods, reordená-los e configurar opções do ModEngine2, tudo sem editar arquivos TOML manualmente.

> Read in [English](./README.md).

> Para contribuidores / agentes de IA — comece por [AGENTS.md](./AGENTS.md).

## Jogos suportados

| Jogo | Status |
|---|---|
| Dark Souls III | 🚧 Camada de serviços pronta, UI ainda não conectada |
| Elden Ring | 🚧 Camada de serviços pronta, UI ainda não conectada |
| Dark Souls: Remastered | 🚧 Camada de serviços pronta, UI ainda não conectada |

## Funcionalidades disponíveis ao usuário hoje

- Gerenciamento de pastas de mods — adicionar, renomear, excluir
- Ativar, desativar e reordenar mods (a ordem de carregamento importa)
- Gerenciamento de DLLs externas (ex.: SeamlessCoop)
- Toggles das configurações do ModEngine2 (loose params, modo de depuração, Scylla Hide)
- Temas Material e GNOME (detectados automaticamente na inicialização)
- Alternar o idioma da UI entre inglês e português do Brasil
- Roda no Linux (Bazzite / Steam Deck / qualquer distro com Proton)

> **Importante sobre o escopo.** Troca entre jogos, mod packs nomeados, o novo wrapper do Steam e o novo seletor de pasta de dados já existem na camada de serviços + bloc + testes, mas ainda não estão expostos na UI — veja o lote de "integração da UI" em [tasks/](./tasks/). A régua para entrar na lista de funcionalidades acima é "o usuário consegue usar de ponta a ponta".

## Roadmap

As decisões que orientam os planos estão registradas em [`docs/adr/`](./docs/adr/), a terminologia do projeto em [`CONTEXT.md`](./CONTEXT.md) e as decisões autônomas de execução em [`refactor.md`](./refactor.md).

[`tasks/README.md`](./tasks/README.md) é a fonte da ordem de execução. Destaques:

### Fundação (bloqueio externo)

- [ModEngine2 empacotado](./tasks/bundled-modengine.md) — aguardando a URL do fork da comunidade.

### Lote de integração da UI (em ordem de dependência)

1. [Novo onboarding + roteamento de inicialização](./tasks/new-onboarding-and-startup-routing.md)
2. [Fluxo de ativação de múltiplos jogos](./tasks/multi-game-activation-flow.md)
3. [Lista de packs + gerenciamento](./tasks/pack-list-and-management.md)
4. [Modos de execução + wrapper do Steam](./tasks/run-modes-and-steam-wrapper.md)
5. [Auto-launch por pack](./tasks/per-pack-auto-launch.md)

Ramos paralelos (podem ser feitos após o #1):

- [Recuperação de pasta de dados ausente](./tasks/missing-data-dir-recovery.md)
- [Tela de preferências do app](./tasks/app-preferences-screen.md)

### Planejado

Objetivos futuros sem plano de implementação ainda.

- Suporte ao Windows (instalador `.msi`)
- AppImage com atualizações automáticas pelas releases do GitHub

## Bugs conhecidos

- **Barra de título da janela sem tema** — a barra de título nativa do GTK (botões de minimizar, maximizar e fechar) não adota totalmente o esquema de cores do app em todos os ambientes de desktop.

## Como funciona

Cada jogo tem um **diretório base** com suas pastas de mods e um ou mais **packs** (configurações TOML nomeadas). Um pack escolhe quais mods estão ativos e em qual ordem. Ativar um pack o espelha no `config.toml` do jogo — é esse arquivo que o ModEngine2 realmente lê, então o comando de inicialização do Steam permanece o mesmo independentemente do pack ativo.

## Requisitos

- Flutter (para compilar a partir do código-fonte)
- Linux (Bazzite / Steam Deck / qualquer distro com Proton) — suporte ao Windows em breve

O próprio ModEngine2 vem junto com o app, então você não precisa instalá-lo separadamente (veja [ModEngine2 empacotado](./tasks/bundled-modengine.md)).

## Aspectos legais

Esta é uma ferramenta não oficial, feita pela comunidade. Não é afiliada, endossada ou associada à FromSoftware, Inc., Bandai Namco Entertainment ou à equipe do ModEngine2.

*Dark Souls III* e *Elden Ring* são marcas registradas da FromSoftware, Inc. / Bandai Namco Entertainment Inc. Todos os direitos reservados.

> **Aviso sobre jogo online:** Usar mods conectado aos serviços online pode acionar o Easy Anti-Cheat e resultar em **banimento permanente**. Sempre jogue offline ao usar mods. Os autores desta ferramenta não se responsabilizam por banimentos, saves corrompidos ou qualquer instabilidade no jogo causada pelo uso de mods.

Este aplicativo não inclui, distribui ou extrai nenhum arquivo ou recurso dos jogos. Ele apenas gerencia arquivos de configuração do ModEngine2, que devem ser obtidos separadamente pelo usuário.

Os autores não se responsabilizam por danos à instalação do jogo, aos arquivos de save ou ao status da sua conta online resultantes do uso desta ferramenta ou de quaisquer mods carregados por ela.

O ModEngine2 é desenvolvido pela equipe [soulsmods](https://github.com/soulsmods/ModEngine2) e licenciado sob a Licença MIT.

## Licença

MIT
