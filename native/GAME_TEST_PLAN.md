# PokeTag — Plano de Teste Jogável v1

Objetivo: validar o jogo de ponta a ponta usando o servidor Linux nativo e o cliente 8.54 antes de qualquer merge na `main`.

## Preparação

```bash
cd ~/PokeTag
git fetch origin
git switch gameplay-test-v1
git pull origin gameplay-test-v1

bash native/poketag-play.sh doctor
bash native/poketag-play.sh start
bash native/poketag-play.sh credentials
```

No Google Cloud Shell, abra **Web Preview → Preview on port 6080**. No noVNC, conecte e use o OTClient.

## 1. Cliente e login

- [ ] OTClient abre sem encerrar sozinho.
- [ ] Cliente mostra protocolo/servidor 8.54 local.
- [ ] Login em `127.0.0.1:7171` responde.
- [ ] Lista de personagens aparece.
- [ ] Personagem conecta pela porta 7172.
- [ ] Não aparece erro de versão, RSA, XTEA ou checksum.

**Resultado esperado:** entrar no jogo e enxergar o mapa.

## 2. Mapa e personagem

- [ ] Mapa carrega sem quadrados pretos/tiles ausentes.
- [ ] Sprite do personagem aparece corretamente.
- [ ] Movimento em 8 direções funciona.
- [ ] Mudança de andar/escadas funciona.
- [ ] Colisão com paredes/objetos funciona.
- [ ] Minimap/visão atualizam durante o movimento.

## 3. Pokémon básico

- [ ] Pokémon do personagem pode ser chamado.
- [ ] Pokémon aparece com sprite correto.
- [ ] Segue o jogador.
- [ ] Comando de ataque funciona.
- [ ] Ordem/movimentação do Pokémon funciona.
- [ ] Pokémon retorna/recolhe corretamente.
- [ ] HP/status do Pokémon atualiza.

## 4. Combate

- [ ] Pokémon selvagens aparecem no mapa.
- [ ] É possível selecionar alvo.
- [ ] Ataques causam dano.
- [ ] Tipos/efeitos visuais não quebram o cliente.
- [ ] Pokémon inimigo pode morrer.
- [ ] Experiência é concedida.
- [ ] Loot/corpo é criado corretamente.

## 5. Captura e sistemas Pokémon

- [ ] Poké Ball pode ser usada.
- [ ] Tentativa de captura executa animação/resultado.
- [ ] Pokémon capturado vai para o local correto.
- [ ] Revive funciona.
- [ ] Pokédex abre/consulta corretamente.
- [ ] Fishing funciona.
- [ ] Ride funciona, se disponível para o Pokémon.
- [ ] Fly funciona, se disponível para o Pokémon.
- [ ] Cut/Dig/Rock Smash e outras orders funcionam onde aplicável.

## 6. Inventário e itens

- [ ] Abrir/fechar backpack.
- [ ] Mover itens entre slots/containers.
- [ ] Usar item no personagem.
- [ ] Usar item no mapa.
- [ ] Stack/quantidade de itens atualiza.
- [ ] Dinheiro/itens persistem após relog.

## 7. NPCs, quests e diálogo

- [ ] NPCs aparecem.
- [ ] `hi`/conversa com NPC funciona.
- [ ] Compra/venda funciona em pelo menos um NPC.
- [ ] Pelo menos uma quest pode ser iniciada.
- [ ] Storage/estado de quest persiste após relog.

## 8. Persistência

Faça alguma alteração visível no personagem e então:

```bash
bash native/poketag-play.sh stop
bash native/poketag-native.sh stop
bash native/poketag-play.sh start
```

- [ ] Personagem volta à posição esperada.
- [ ] Level/experiência persistem.
- [ ] Inventário persiste.
- [ ] Pokémon persistem.
- [ ] Quest/storage persiste.

O banco usado pelo teste fica em `.poketag-native-state/forgottenserver.s3db` e não deve ser apagado por rebuilds normais.

## 9. Reconexão e estabilidade

- [ ] Logout normal funciona.
- [ ] Login novamente funciona.
- [ ] Fechar o cliente não derruba o servidor.
- [ ] Reabrir o cliente reconecta.
- [ ] Servidor permanece online por pelo menos 15 minutos de jogo.
- [ ] Não há crash durante movimentação/combate.

## Se algo falhar

Não tente corrigir manualmente dentro do runtime. Rode:

```bash
bash native/poketag-play.sh status
bash native/poketag-play.sh logs
```

Para acompanhar em tempo real o servidor:

```bash
bash native/poketag-native.sh follow
```

Informe o item do checklist que falhou e cole as últimas linhas relevantes do log. Assim a correção pode ser feita na branch e repetida de maneira controlada.
