# ME2-Pack-Loader

> **Em desenvolvimento.**

GUI desktop em Flutter para gerenciar pacotes de mods do [ModEngine2](https://github.com/soulsmods/ModEngine2) em jogos da FromSoftware. Funciona como um wrapper do Steam — quando iniciado pelo Steam, ele permite ativar/desativar mods, reordená-los e configurar opções do ModEngine2, tudo sem editar arquivos TOML manualmente.

> Read in [English](./README.md).

> Para contribuidores / agentes de IA — comece por [AGENTS.md](./AGENTS.md).

## Jogos suportados

| Jogo | Status |
|---|---|
| Dark Souls III | ✅ |
| Elden Ring | ✅ |
| Dark Souls: Remastered | 🚧 Planejado |

## Funcionalidades

- Gerenciamento de pastas de mods — adicionar, renomear, excluir
- Ativar, desativar e reordenar mods (a ordem de carregamento importa)
- Gerenciamento de DLLs externas (ex.: SeamlessCoop)
- Toggles das configurações do ModEngine2 (loose params, modo de depuração, Scylla Hide)
- Temas Material e GNOME
- Roda no Linux (Bazzite / Steam Deck / qualquer distro com Proton)

## Roadmap

As decisões que orientam os planos estão registradas em [`docs/adr/`](./docs/adr/) e a terminologia do projeto em [`CONTEXT.md`](./CONTEXT.md).

### Em andamento (WIP)

Planos elaborados e prontos para execução. Cada arquivo é autossuficiente (Contexto / Objetivo / Abordagem / Arquivos / Verificação).

| Objetivo | Plano |
|---|---|
| Empacotar o ModEngine2 (sem instalação separada) | [tasks/01](./tasks/01-bundled-modengine.md) |
| Traduções (inglês + português do Brasil) | [tasks/02](./tasks/02-translations.md) |
| Gerenciamento do diretório de dados (padrão vs. disco personalizado) | [tasks/03](./tasks/03-data-dir-management.md) |
| Suporte a múltiplos jogos (Dark Souls III, Elden Ring, Dark Souls: Remastered) | [tasks/04](./tasks/04-multi-game-support.md) |
| Mod packs (TOMLs nomeados por jogo, fluxo de ativação) | [tasks/05](./tasks/05-mod-packs.md) |
| Cor de destaque vermelha no Material | [tasks/06](./tasks/06-material-red-accent.md) |
| Tema sensível ao desktop (detecção automática do destaque do GNOME) | [tasks/07](./tasks/07-desktop-aware-theme.md) |
| Comando de inicialização do Steam (copia-e-cola com instruções) | [tasks/08](./tasks/08-steam-launch-command.md) |

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

O próprio ModEngine2 vem junto com o app, então você não precisa instalá-lo separadamente (veja [tasks/01](./tasks/01-bundled-modengine.md)).

## Aspectos legais

Esta é uma ferramenta não oficial, feita pela comunidade. Não é afiliada, endossada ou associada à FromSoftware, Inc., Bandai Namco Entertainment ou à equipe do ModEngine2.

*Dark Souls III* e *Elden Ring* são marcas registradas da FromSoftware, Inc. / Bandai Namco Entertainment Inc. Todos os direitos reservados.

> **Aviso sobre jogo online:** Usar mods conectado aos serviços online pode acionar o Easy Anti-Cheat e resultar em **banimento permanente**. Sempre jogue offline ao usar mods. Os autores desta ferramenta não se responsabilizam por banimentos, saves corrompidos ou qualquer instabilidade no jogo causada pelo uso de mods.

Este aplicativo não inclui, distribui ou extrai nenhum arquivo ou recurso dos jogos. Ele apenas gerencia arquivos de configuração do ModEngine2, que devem ser obtidos separadamente pelo usuário.

Os autores não se responsabilizam por danos à instalação do jogo, aos arquivos de save ou ao status da sua conta online resultantes do uso desta ferramenta ou de quaisquer mods carregados por ela.

O ModEngine2 é desenvolvido pela equipe [soulsmods](https://github.com/soulsmods/ModEngine2) e licenciado sob a Licença MIT.

## Licença

MIT
