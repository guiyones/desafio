# Desafio — RPG (skills + visual) — design

Segunda versão do Desafio (a v1 está em `2026-10-16-desafio-design.md`, PR #1). Dois objetivos:

1. **Visual com cara de game**, estilo RPG pixel, em CSS e JS puros (sem framework, sem build).
2. **Skills (proficiências)** que sobem de XP e nível conforme os desafios ligados a elas são cumpridos.

## Por quê

O user abre o app todo dia pra ver **como está a evolução**. A v1 funciona, mas o visual é cru e
o progresso é só número. As skills dão um sentido pro progresso: "fazer jejum de 16h" treina a
skill **Jejum**, e ver o Jejum subir de nível é a recompensa diária.

## Decidido com o user

- Estilo **A · RPG pixel** (escolhido entre Caderno/Placar/Leve e depois entre RPG/Mapa/Arcade).
- Dias na grade são **corações pixel** (escolhido entre blocos com relevo, moedas, corações):
  verde = cumprido, apagado = vacilo, escuro = futuro. Tamanho fixo, não estica com a tela.
- Skills são **do personagem**, não do projeto: o XP continua acumulando entre projetos.
- **Vários desafios podem treinar a mesma skill.**
- **Vacilo só deixa de dar XP naquele dia**, sem punição extra. Como o XP é derivado e o dia conta
  como cumprido até o vacilo ser marcado, marcar um vacilo remove os 10 XP daquele dia — a skill
  (e o personagem) **podem cair de nível**. O user escolheu isso conscientemente em vez de persistir
  XP. Desfazer o vacilo devolve o XP; apagar desafio/grupo/projeto remove o XP que ele dava.
- CSS e JS puros.

## Calls do Claude (o user aprovou o resumo; pode mudar)

- Cada desafio treina **no máximo uma** skill. Skill é **opcional** no desafio (sem skill = sem XP).
- **XP:** 10 XP por dia cumprido (`Challenge#kept_count * 10`). Derivado, nada persistido. O dia de
  hoje já conta (coerente com o coração verde desde a manhã).
- **Curva de nível:** subir do nível L pro L+1 custa `50 * L` XP. XP acumulado pra estar no nível L
  = `25 * L * (L - 1)` (nível 1 = 0 XP, nível 2 = 50, nível 3 = 150, nível 4 = 300, nível 5 = 500…).
  Um desafio perfeito por 75 dias (750 XP) leva a skill ao nível 6.
- **Personagem:** um só (o app não tem login). Nível do personagem = mesma curva aplicada à soma do
  XP de todas as skills. Avatar fixo 🧙. Título da ficha: "PERSONAGEM".
- **Skill:** `name` (obrigatório, único) + `icon` (emoji, obrigatório, default ⭐).
- **Level up:** detectado no navegador. JS guarda em `localStorage` o último `{ level, xp }` visto de
  cada skill; se o nível subiu desde a última visita, mostra o banner "★ LEVEL UP! ★ JEJUM CHEGOU AO
  NV 3". O valor guardado é o **maior nível já visto** (high-water mark): cair e voltar ao mesmo nível
  não repete o banner; o banner só aparece ao passar do maior nível visto. Na primeira visita (sem
  nada guardado) só grava, não mostra nada. Roda na tela do projeto **e** na ficha. Se `localStorage`
  falhar, a página funciona normal sem banner.
- **Fonte:** Press Start 2P (licença OFL) servida localmente em `app/assets/fonts/` (app é local, deve
  funcionar offline). Usada em títulos, números, rótulos curtos. Notas, formulários e textos longos
  usam a fonte do sistema.

## Domínio

```
Skill      name, icon                 has_many :challenges, dependent: :nullify
Challenge  + skill_id (null)          belongs_to :skill, optional: true
```

- `Skill#xp` = soma de `kept_count * 10` de todos os desafios ligados (de qualquer projeto).
- `Skill#level`, `Skill#xp_into_level`, `Skill#xp_for_next_level` (pra barra: "70/100 XP").
- `Challenge#xp` = `kept_count * 10`.
- A lógica de nível (XP → nível, XP dentro do nível, custo do próximo) mora num lugar só e é reusada
  por `Skill` e pelo personagem. Onde exatamente fica é do builder.
- Personagem: XP total = soma do XP das skills; nível pela mesma curva.

Nada muda em `Project`, `Group`, `Slip`, nem nas regras de vacilo da v1.

## Telas

Todas no tema RPG. Barra de navegação no topo: "⚔ DESAFIO" (projetos) e "FICHA" (personagem).

### Projeto (tela principal)

- **Banner de level up** (só quando houver, via JS).
- **HUD:** avatar, nome do projeto, "FASE N · DIA X/75" (fase = bloco de 15 dias, 1 a 5), barra de
  progresso do projeto, "⭐ N DIAS PERFEITOS · ✖ N VACILOS". Antes de começar / depois de terminar,
  usa os textos que a v1 já tem ("começa em…", "terminou em…").
- **Grupos** continuam como seções. Cada desafio é uma **missão**: nome, etiqueta da skill (ícone +
  nome) se tiver, "+N XP" acumulado no projeto, e a grade de corações.
- **Grade:** 75 corações, **15 por linha** (cada linha = uma fase). 18px no desktop, 16px em tela
  estreita, para caber 15 por linha num celular de 375px.
  - Cumprido: coração verde, é botão (toque = marcar vacilo).
  - Vacilo: coração apagado/vermelho, é link para a tela da nota.
  - Futuro: coração escuro, não clicável.
  - Hoje: brilho dourado + pulinho em loop (respeitar `prefers-reduced-motion`).
  - Ao marcar vacilo, o coração novo entra com uma animação curta de "quebrar" (CSS, disparada por
    uma classe no HTML que o turbo_stream insere — sem JS).
- Mantém os aria-labels da v1 ("Dia N: marcar vacilo", "Dia N: vacilo, editar", "Dia N: futuro").

### Ficha do personagem (`/skills`)

- HUD do personagem: avatar, "PERSONAGEM NV N", XP total.
- Lista de skills: ícone, nome, nível, barra de XP ("70/100 XP"), quantas missões ativas treinam a
  skill (desafio de projeto com status `:active`). Link pra editar.
- "+ NOVA SKILL".
- Sem skills: mensagem convidando a criar a primeira.

### Formulários

- Skill: nome + ícone (campo de texto pra colar/digitar um emoji; mostrar alguns sugeridos clicáveis
  é opcional, a critério do builder).
- Desafio (novo/editar): ganha um select "Skill" com "— nenhuma —" + skills existentes.
- Apagar skill: os desafios ficam sem skill (`nullify`), o histórico de vacilos não muda.

### Resultado e demais telas

Mesmo tema. Resultado ganha a coluna/linha de XP por desafio. Sem mudança de conteúdo além disso.

## Visual (referência: mockups do brainstorm, `.superpowers/brainstorm/`)

- Fundo `#1a1c2c`; caixas `#262b44` com borda 3px `#566c86`; HUD `#29366f` com borda clara e sombra
  dura `4px 4px 0 #000`.
- Dourado `#ffcd75` (títulos/destaques), verde `#38b764`/`#a7f070` (cumprido/XP), vermelho
  `#b13e53`/`#ef7d57` (vacilo), azul `#3b5dc9`/`#41a6f6` (skill/progresso), texto `#f4f4f4`,
  secundário `#94b0c2`, apagado `#333c57`.
- Coração: SVG pixel 9×8 usado como `mask` (forma no mockup `tiles.html`).
- Botões: borda grossa, sombra dura que some e desloca 2px no `:active`.
- Uma folha de estilos organizada por componente (37signals: arquivos CSS por componente são ok);
  variáveis CSS pra paleta. Sem tema claro (o jogo é escuro por definição).
- JS: um arquivo por comportamento, como controllers Stimulus (o app já tem Stimulus via importmap)
  ou módulos JS puros — escolha do builder, desde que sem dependência nova.

## Não-objetivos

- Conquistas/medalhas, combos, chefões, mapa de fases.
- Sons.
- Penalidade além do XP do dia perdido; morrer; reiniciar.
- Multiusuário, nome de personagem configurável, avatar customizável.
- Tema claro.

## Anti-objetivos

- Ficar "grotesco": nada de elementos que esticam com a largura da tela (o user reclamou disso nos
  quadrados). Tamanhos fixos para peças de jogo.
- Pixel font em texto longo (cansa ler).
- Animação que atrapalhe marcar vacilo rápido.

## Testes

- Model: curva de nível (0, 49, 50, 149, 150, 750 XP), `Skill#xp` somando desafios de projetos
  diferentes, marcar vacilo remove exatamente 10 XP da skill, skill sem desafios = nível 1 /
  0 XP, `nullify` ao apagar skill.
- Controller: CRUD de skills, select de skill no desafio salva `skill_id`.
- Views: os seletores/aria-labels da grade da v1 continuam passando; missão mostra etiqueta da skill.
- System test da v1 continua passando; um novo cobre criar skill → ligar a desafio → ver XP na ficha.
- O JS de level up é testado manualmente (comportamento simples, depende de `localStorage`).

## Deixado pro builder

- Organização dos arquivos CSS/JS e nomes de classes (mantendo as classes que os testes da v1 usam,
  ou atualizando os testes junto).
- Onde mora a lógica da curva de nível.
- Ícones sugeridos no form de skill (se houver).
- Detalhes da animação de quebrar coração e do pulinho, dentro do espírito pixel (`steps()`).
