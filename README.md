# PokeTag — workspace de integração

Este repositório reúne, como **submódulos Git fixados em commits específicos**, três projetos de referência para o desenvolvimento do PokeTag:

- `upstream/PDA-By-Slicer` → https://github.com/nogenem/PDA-By-Slicer
- `upstream/poketibia-sirninja` → https://github.com/sirninja/poketibia
- `upstream/otclient-opentibiabr` → https://github.com/opentibiabr/otclient

## Clonar no Google Cloud Shell

```bash
git clone --recurse-submodules https://github.com/Jefte31/PokeTag.git
cd PokeTag
```

Se o repositório já tiver sido clonado sem os submódulos:

```bash
git submodule update --init --recursive
```

Para atualizar posteriormente cada referência upstream:

```bash
git submodule update --remote --recursive
```

## Estrutura

```text
PokeTag/
├── upstream/
│   ├── PDA-By-Slicer/
│   ├── poketibia-sirninja/
│   └── otclient-opentibiabr/
├── .gitmodules
└── README.md
```

## Por que submódulos?

Isso mantém os projetos completos e separados, preserva sua origem e histórico, evita misturar milhares de arquivos de engines diferentes e permite atualizar cada base de forma controlada. Também facilita comparar e portar sistemas para uma implementação própria do PokeTag.

## Observação sobre licenças e assets

Cada projeto upstream mantém sua própria licença e seus próprios termos. Código open source e assets de terceiros não devem ser tratados como se tivessem a mesma licença. Antes de publicar ou distribuir uma versão final do PokeTag, revise as licenças e substitua qualquer conteúdo de terceiros cuja redistribuição não esteja claramente autorizada.
