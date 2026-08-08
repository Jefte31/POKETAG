# PokeTag — Frankenstein local-first

O PokeTag usa três bases existentes e tenta aproveitar o melhor de cada uma sem reescrever o jogo do zero:

- **PDA By Slicer 2.9**: conteúdo principal do jogo, mapa, scripts, banco SQLite e servidor já compatível com o datapack.
- **sirninja/PokeTibia**: fonte aberta do The Forgotten Server 0.3.6 para protocolo **8.54**, usada como referência/backup de engine para a futura migração nativa Linux.
- **OTClient OpenTibiaBR**: cliente moderno que será a base definitiva do cliente; os assets 8.54 do PDA já foram ligados a ele em `data/things/854/`.

A primeira meta é deliberadamente **local e individual**: cada pessoa mantém a própria jornada e o próprio banco. Multiplayer só entra depois que essa base estiver estável.

## Teste rápido no Google Cloud Shell

Clone/atualize o repositório e mude para a branch de integração enquanto ela estiver em validação:

```bash
git clone https://github.com/Jefte31/PokeTag.git
cd PokeTag
git checkout frankenstein-local-v1
```

Se você já tinha clonado:

```bash
cd ~/PokeTag
git fetch origin
git checkout frankenstein-local-v1
git pull
```

Confira se as três bases necessárias estão presentes:

```bash
bash poketag.sh doctor
```

Instale uma vez as dependências do desktop virtual/Wine:

```bash
bash poketag.sh install
```

Depois inicie o jogo:

```bash
bash poketag.sh run
```

No Cloud Shell abra:

**Web Preview → Preview on port 6080**

O noVNC mostra o desktop virtual onde servidor e cliente são iniciados. O cliente fica apontado para `127.0.0.1:7171`, protocolo 8.54.

## Jornada persistente

O primeiro `run` cria uma cópia executável em:

```text
.poketag-runtime/
├── server/
├── client/
├── wine/
├── logs/
└── pids/
```

O banco da sua jornada fica em:

```text
.poketag-runtime/server/forgottenserver.s3db
```

Parar e iniciar novamente **não apaga** a jornada.

Para apagar somente a jornada de teste e reconstruir o runtime do zero:

```bash
bash poketag.sh reset
```

## Comandos úteis

```bash
bash poketag.sh status
bash poketag.sh logs
bash poketag.sh stop
```

## O que foi alterado no modo local

Na cópia de runtime do PDA 2.9, o launcher ajusta apenas configurações necessárias para uma experiência individual:

- servidor preso a `127.0.0.1`;
- mundo `no-pvp`;
- uma jornada por conta;
- clones desativados;
- premium liberado para não bloquear conteúdo durante a validação;
- timeout de inatividade elevado para permitir sessões AFK longas;
- banco SQLite local preservado entre execuções.

Os arquivos originais em `upstream/` continuam disponíveis como referência.

## Cliente moderno

Os arquivos `POK.dat` e `POK.spr` do PDA foram reutilizados no OTClient moderno como:

```text
upstream/otclient-opentibiabr/data/things/854/Tibia.dat
upstream/otclient-opentibiabr/data/things/854/Tibia.spr
```

O `otclientrc.lua` do cliente moderno também aponta para o servidor local 8.54. Isso prepara a segunda etapa: substituir o cliente PDA antigo pelo OTClient moderno sem trocar o conteúdo do jogo.

## AFK

Nesta primeira integração, **AFK significa que o servidor não derruba o jogador por inatividade e a jornada continua salva enquanto a sessão estiver rodando**. A automação real de caça/target/cavebot será ligada ao cliente moderno depois de validarmos login, mapa, movimentação, batalha, captura e persistência.

No Cloud Shell existe ainda uma limitação externa: a própria VM do Cloud Shell pode ser encerrada pelo Google após períodos de inatividade. Em um PC local ou servidor próprio, essa limitação não existe.

## Próxima sequência de integração

1. validar PDA 2.9 + OTClient PDA via Wine/noVNC;
2. validar o mesmo servidor com OTClient moderno e assets 8.54;
3. aproveitar o bot/automação do OTClient moderno para AFK;
4. substituir o executável Windows pelo TFS 0.3.6 compilado a partir do sirninja;
5. só então preparar contas online, servidor autoritativo e multiplayer.

## Licenças e assets

As três bases mantêm suas próprias licenças e direitos sobre código/assets. O PokeTag, nesta fase, é um workspace de integração e teste. Antes de qualquer distribuição pública/comercial, é necessário revisar licenças e direitos dos assets incluídos.
