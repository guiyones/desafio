# Desafio RPG Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar skills com XP/nível derivados dos dias cumpridos e trocar todo o visual pelo tema RPG pixel com grade de corações.

**Architecture:** `Skill` é o único model novo (nome + emoji); XP e nível são calculados na hora a partir de `Challenge#kept_count` via um value object `Level`. O visual é CSS puro dividido por componente (Propshaft carrega todos os arquivos de `app/assets/stylesheets/`), fonte pixel servida localmente, e um único controller Stimulus (já instalado, sem dependência nova) pro banner de level up.

**Tech Stack:** Rails 8.1, SQLite, Propshaft, importmap, Turbo, Stimulus, CSS puro, Minitest + fixtures, Capybara/Selenium.

**Spec:** `docs/superpowers/specs/2026-10-16-desafio-rpg-design.md` (e a v1: `docs/superpowers/specs/2026-10-16-desafio-design.md`)

## Global Constraints

- Nenhuma gem nem pacote JS novo. JS só em controllers Stimulus em `app/javascript/controllers/`.
- Estilo 37signals/omakase: privados indentados, `[ :x ]`, `params.expect`, strict locals, `:unprocessable_content`, `status: :see_other` em destroy.
- XP: **10 por dia cumprido** (`Challenge::XP_PER_DAY = 10`). Nada de XP persistido.
- Curva: XP acumulado pra estar no nível L = `25 * L * (L - 1)`; subir de L pra L+1 custa `50 * L`. Nível mínimo 1.
- Personagem: um só, avatar 🧙, título "PERSONAGEM", nível = mesma curva sobre a soma do XP das skills.
- Skill: `name` obrigatório e único (sem diferenciar maiúsculas); `icon` obrigatório, default `"⭐"`.
- Desafio: `skill` opcional; apagar skill → `nullify`.
- Paleta (variáveis CSS): fundo `#1a1c2c`; caixa `#262b44` borda 3px `#566c86`; HUD `#29366f` borda `#f4f4f4` sombra `4px 4px 0 #000`; dourado `#ffcd75`; verde `#38b764`/`#a7f070`; vermelho `#b13e53`/`#ef7d57`; azul `#3b5dc9`/`#41a6f6`; texto `#f4f4f4`; secundário `#94b0c2`; apagado `#333c57`.
- Fonte Press Start 2P (OFL) servida de `app/assets/fonts/`, só em títulos, números e rótulos curtos. Texto longo, notas e campos de formulário usam `system-ui`.
- **Sem `text-transform`** em texto que os testes conferem (Selenium devolve o texto transformado e quebra `assert_text`). Caixa alta, quando desejada, vai escrita no próprio texto.
- Peças de jogo com tamanho fixo (nunca esticam com a largura). Corações: 18px, 16px abaixo de 40rem; 15 por linha.
- Todas as animações desligadas em `@media (prefers-reduced-motion: reduce)`. Animações em `steps()`.
- Sem tema claro.
- Seletores que os testes da v1 usam continuam existindo: `.day--kept button`, `.day--slipped a`, `.day--future span`, `.day--today`, `#perfect_days` (texto "N dias perfeitos"), aria-labels "Dia N: marcar vacilo" / "Dia N: vacilo, editar" / "Dia N: futuro".

## Review Focus

1. Nome longo de desafio/skill em fonte pixel num celular de 375px → quebra de linha, nunca rolagem horizontal (`overflow-wrap: anywhere` nos títulos de missão/skill). Verificado no screenshot de 375px da Task 3.
2. Emoji com vários code points (👨‍🍳, 🏋️‍♂️) como ícone de skill → aceito e exibido inteiro. Teste na Task 1.
3. "Jejum" e "jejum" → mesma skill, segunda é rejeitada. Teste na Task 1.
4. `localStorage` indisponível ou com JSON corrompido → página funciona, sem banner, sem erro no console. Teste manual na Task 5 (JSON inválido gravado à mão).
5. Projeto que ainda não começou (`:upcoming`) → missões mostram "+0 XP", skills não ganham XP de dias futuros. Teste na Task 1.

## File Structure

```
app/models/level.rb                    Level = Data.define(:number, :xp_into, :xp_needed); Level.for(xp)
app/models/skill.rb                    Skill: name, icon, xp, level, active_challenges_count
app/models/character.rb                Character (PORO): skills, xp, level
app/models/challenge.rb                + belongs_to :skill (optional), XP_PER_DAY, #xp
app/models/project.rb                  + PHASE_LENGTH = 15, #phase_on(date)
app/controllers/skills_controller.rb   index (ficha), new, create, edit, update, destroy
app/helpers/skills_helper.rb           level_up_banner(skills)
app/javascript/controllers/level_up_controller.js
app/assets/fonts/PressStart2P-Regular.ttf, OFL.txt
app/assets/stylesheets/application.css   tokens, @font-face, reset, tipografia, links
app/assets/stylesheets/layout.css        nav do topo, main, seções
app/assets/stylesheets/boxes.css         .box, .hud, .muted
app/assets/stylesheets/buttons.css       botões, button_to, .danger
app/assets/stylesheets/forms.css         labels, inputs, select, erros
app/assets/stylesheets/missions.css      .mission, .skill-tag, xp
app/assets/stylesheets/hearts.css        .days, .day--*, animações
app/assets/stylesheets/skills.css        ficha: .skill-card, barras
app/assets/stylesheets/level_up.css      banner
app/assets/stylesheets/results.css       tabela e timeline
app/views/skills/{index,new,edit,_form,_skill}.html.erb
app/views/shared/_level_up.html.erb
```

Os arquivos `.keep` / `hello_controller.js` gerados podem ser removidos.

---

### Task 1: Skill, curva de nível e XP

**Files:**
- Create: `db/migrate/*_create_skills.rb`, `db/migrate/*_add_skill_to_challenges.rb`
- Create: `app/models/level.rb`, `app/models/skill.rb`, `app/models/character.rb`
- Modify: `app/models/challenge.rb`, `app/models/project.rb`
- Create: `test/fixtures/skills.yml`; Modify: `test/fixtures/challenges.yml`
- Test: `test/models/level_test.rb`, `test/models/skill_test.rb`, `test/models/character_test.rb`, `test/models/challenge_test.rb`, `test/models/project_test.rb`

**Interfaces:**
- Produces:
  - `Level.for(xp: Integer) -> Level` com `#number`, `#xp_into` (XP dentro do nível), `#xp_needed` (custo do próximo nível); `Level.threshold(number) -> Integer` (= `25 * n * (n - 1)`).
  - `Challenge::XP_PER_DAY = 10`; `Challenge#xp -> Integer` (= `kept_count * XP_PER_DAY`); `Challenge#skill` (opcional).
  - `Skill#xp -> Integer` (soma de `challenges.sum(&:xp)`); `Skill#level -> Level`; `Skill#active_challenges_count -> Integer` (desafios cujo projeto tem `status == :active`).
  - `Character.new(skills = Skill.all)` com `#skills`, `#xp -> Integer`, `#level -> Level`.
  - `Project::PHASE_LENGTH = 15`; `Project#phase_on(date) -> Integer` (1..5, `((day_number(date) - 1) / 15) + 1`, limitado a 1..5).

- [ ] **Step 1: Migrations**

`bin/rails g model Skill name:string icon:string` — `name` e `icon` `null: false`, `icon` com `default: "⭐"`, índice único em `name`.
`bin/rails g migration AddSkillToChallenges skill:references` — `null: true`, `foreign_key: true`.
Run: `bin/rails db:migrate` → `db/schema.rb` ganha `skills` e `challenges.skill_id`.

- [ ] **Step 2: Fixtures**

`test/fixtures/skills.yml`:

```yaml
controle:
  name: Controle
  icon: "🛡"

resistencia:
  name: Resistência
  icon: "🚶"

jejum:
  name: Jejum
  icon: "⏳"
```

Em `test/fixtures/challenges.yml`: `refri` e `doce` ganham `skill: controle`; `caminhada` ganha `skill: resistencia`. `jejum` fica sem desafios.

Cenário em 2026-10-12: refri 11 dias cumpridos (110 XP), doce 10 (100 XP), caminhada 12 (120 XP) → Controle 210 XP (nível 3, 60/150), Resistência 120 XP (nível 2, 70/100), Jejum 0 XP (nível 1, 0/50). Personagem 330 XP → nível 4 (30/200).

- [ ] **Step 3: Testes que falham**

`test/models/level_test.rb`:

```ruby
require "test_helper"

class LevelTest < ActiveSupport::TestCase
  test "thresholds follow 25 * n * (n - 1)" do
    assert_equal [ 0, 50, 150, 300, 500 ], (1..5).map { Level.threshold(it) }
  end

  test "levels by xp" do
    assert_equal [ 1, 1, 2, 2, 3, 6 ], [ 0, 49, 50, 149, 150, 750 ].map { Level.for(it).number }
  end

  test "progress inside the level" do
    level = Level.for(120)
    assert_equal 2, level.number
    assert_equal 70, level.xp_into
    assert_equal 100, level.xp_needed
  end
end
```

`test/models/skill_test.rb`:

```ruby
require "test_helper"

class SkillTest < ActiveSupport::TestCase
  setup { travel_to_day Date.new(2026, 10, 12) }

  test "xp sums every challenge that trains it" do
    assert_equal 210, skills(:controle).xp
    assert_equal 3, skills(:controle).level.number
  end

  test "a skill without challenges is level 1 with no xp" do
    assert_equal 0, skills(:jejum).xp
    assert_equal 1, skills(:jejum).level.number
  end

  test "xp keeps adding up across projects" do
    other = Project.create!(name: "Antes", starts_on: Date.new(2026, 7, 1))
    other.groups.create!(name: "G").challenges.create!(name: "Sem refri de novo", skill: skills(:controle))
    assert_equal 210 + 750, skills(:controle).xp
  end

  test "marking a slip removes exactly that day's xp" do
    assert_difference -> { skills(:controle).reload.xp }, -10 do
      challenges(:refri).slips.create!(day: Date.new(2026, 10, 10))
    end
  end

  test "upcoming projects give no xp" do
    future = Project.create!(name: "Depois", starts_on: Date.new(2026, 11, 1))
    future.groups.create!(name: "G").challenges.create!(name: "Jejum 16h", skill: skills(:jejum))
    assert_equal 0, skills(:jejum).xp
  end

  test "counts challenges in active projects" do
    assert_equal 2, skills(:controle).active_challenges_count
  end

  test "name is unique ignoring case" do
    assert_not Skill.new(name: "jejum", icon: "⏳").valid?
  end

  test "accepts multi codepoint emoji as icon" do
    assert Skill.new(name: "Cozinhar", icon: "👨‍🍳").valid?
  end

  test "destroying a skill keeps its challenges" do
    assert_no_difference -> { Challenge.count } do
      skills(:controle).destroy
    end
    assert_nil challenges(:refri).reload.skill
  end
end
```

`test/models/character_test.rb`:

```ruby
require "test_helper"

class CharacterTest < ActiveSupport::TestCase
  test "sums all skills and levels with the same curve" do
    travel_to_day Date.new(2026, 10, 12)
    character = Character.new

    assert_equal 330, character.xp
    assert_equal 4, character.level.number
  end
end
```

Acrescentar a `ChallengeTest`: `assert_equal 110, @challenge.xp` (em 2026-10-12, refri) e um desafio sem skill continua válido (`challenges(:caminhada).update!(skill: nil)`).
Acrescentar a `ProjectTest`: `phase_on` dá 1 no dia 1 e no dia 15, 2 no dia 16, 5 no dia 75.

- [ ] **Step 4: Rodar e ver falhar**

Run: `bin/rails test test/models`
Expected: ERRORs `uninitialized constant Level` / `Skill` / `Character`, `undefined method 'xp'`, `'phase_on'`.

- [ ] **Step 5: Implementar**

- `app/models/level.rb`: `Level = Data.define(:number, :xp_into, :xp_needed)` com `self.threshold(number)` e `self.for(xp)`. `for` sobe `number` a partir de 1 enquanto `threshold(number + 1) <= xp`; `xp_into = xp - threshold(number)`; `xp_needed = 50 * number`.
- `app/models/skill.rb`: `has_many :challenges, dependent: :nullify`; validações de presença em `name`/`icon`, `uniqueness: { case_sensitive: false }` em `name`; `xp`, `level` (`Level.for(xp)`), `active_challenges_count` (`challenges.count { it.project.status == :active }`).
- `app/models/character.rb`: PORO com `attr_reader :skills`, `initialize(skills = Skill.all)`, `xp` (`skills.sum(&:xp)`), `level`.
- `app/models/challenge.rb`: `belongs_to :skill, optional: true`; `XP_PER_DAY = 10`; `xp`.
- `app/models/project.rb`: `PHASE_LENGTH = 15`; `phase_on(date)` com `.clamp(1, DURATION / PHASE_LENGTH)`.

- [ ] **Step 6: Rodar e ver passar**

Run: `bin/rails test`
Expected: tudo verde (modelos novos + suíte da v1).

- [ ] **Step 7: Commit**

`git commit -m "feat: skills with xp and levels derived from kept days"`

---

### Task 2: Tema base (fonte, tokens, layout, botões, formulários)

Visual de todas as telas genéricas: navegação, caixas, botões, formulários, índice de projetos, telas de edição. A tela do projeto (Task 3), a ficha (Task 4) e o resultado (Task 6) usam essa base.

**Files:**
- Create: `app/assets/fonts/PressStart2P-Regular.ttf`, `app/assets/fonts/OFL.txt`
- Modify: `app/assets/stylesheets/application.css` (vira só tokens + `@font-face` + base)
- Create: `app/assets/stylesheets/{layout,boxes,buttons,forms}.css`
- Modify: `app/views/layouts/application.html.erb`, `app/views/projects/{index,new,edit}.html.erb`, `app/views/groups/{new,edit}.html.erb`, `app/views/challenges/{new,edit}.html.erb`, `app/views/challenges/slips/edit.html.erb`, `app/views/shared/_errors.html.erb`
- Delete: `app/javascript/controllers/hello_controller.js`

**Interfaces:**
- Produces (classes CSS que as próximas tasks usam): `.box` (caixa padrão), `.hud` (caixa azul de destaque), `.pixel` (aplica a fonte pixel), `.muted`, `.gold`, `.green`, `.red`, `.button` (link com cara de botão), `.button--danger`, `.stack` (espaçamento vertical entre filhos), `.section-title` (título de seção "▶ ...").
- Layout: `<nav class="topbar">` com "⚔ DESAFIO" → `root_path` e "FICHA" → `skills_path`. Adicionar `resources :skills, except: :show` em `config/routes.rb` já nesta task (o controller nasce na Task 4; o link só precisa da rota).

- [ ] **Step 1: Fonte**

Baixar `PressStart2P-Regular.ttf` e `OFL.txt` de `https://github.com/google/fonts/tree/main/ofl/pressstart2p` (raw) para `app/assets/fonts/`. `@font-face` em `application.css` com `url("PressStart2P-Regular.ttf")` (Propshaft reescreve pro caminho com digest) e `font-display: swap`.

- [ ] **Step 2: CSS base**

- `application.css`: variáveis da paleta (Global Constraints) em `:root`, `@font-face`, reset leve, `body` com fundo/texto da paleta e `font-family: system-ui`, links dourados, `.pixel { font-family: "Press Start 2P", monospace; line-height: 1.7; }`, `.muted/.gold/.green/.red`, o bloco `prefers-reduced-motion` global (`animation: none !important; transition: none !important`).
- `layout.css`: `main` max-width 42rem, padding 1rem; `.topbar` faixa com borda inferior 3px, links pixel.
- `boxes.css`: `.box` e `.hud` exatamente com as cores/bordas/sombra da paleta; `.section-title` pixel, dourado, 10px, prefixo "▶ " no próprio HTML.
- `buttons.css`: `button`, `input[type=submit]`, `.button`: fundo azul `#3b5dc9`, borda 3px `#000`, sombra `3px 3px 0 #000`, fonte pixel 10px; `:active` → `translate(2px, 2px)` e sombra `1px 1px 0`. `.button--danger` vermelho. `form.button_to` sem margem.
- `forms.css`: label pixel 9px dourado; inputs/select `system-ui` 16px, fundo `#262b44`, borda 3px `#566c86`, foco borda `#ffcd75`; `.errors` vermelho claro.

- [ ] **Step 3: Views**

Aplicar as classes nas telas listadas (projeto novo/editar, grupo, desafio, nota do vacilo, índice). Títulos `h1` com `.pixel`. Os textos de botão/label não mudam (os testes e o system test os usam).

- [ ] **Step 4: Verificar**

Run: `bin/rails test && bin/rails test:system` → verde.
Screenshot (ver "Como tirar screenshot" no fim do plano) de `/projects/new` e `/projects/1/edit` em 375px e 1200px; ler os PNGs e conferir: fonte pixel carregou nos títulos, botões com sombra dura, nada estica nem rola na horizontal.

- [ ] **Step 5: Commit**

`git commit -m "feat: rpg pixel base theme"`

---

### Task 3: Tela do projeto — HUD, missões e corações

**Files:**
- Modify: `app/views/projects/show.html.erb`, `app/views/projects/_perfect_days.html.erb`, `app/views/challenges/_challenge.html.erb`, `app/views/challenges/_day.html.erb`, `app/views/challenges/slips/create.turbo_stream.erb`, `app/controllers/projects_controller.rb`
- Create: `app/assets/stylesheets/{missions,hearts}.css`
- Test: `test/controllers/projects_controller_test.rb`, `test/controllers/challenges/slips_controller_test.rb`

**Interfaces:**
- Consumes: `Challenge#xp`, `Challenge#skill`, `Project#phase_on`, `Project::PHASE_LENGTH` (Task 1); classes `.hud`, `.box`, `.pixel`, `.section-title` (Task 2).
- Produces: partial `challenges/_day` com strict locals `(challenge:, date:, breaking: false)`; quando `breaking: true` o `div.day` ganha a classe `day--breaking`.

- [ ] **Step 1: Testes que falham**

Em `ProjectsControllerTest#show renders progress and the grid` (manter as asserções atuais) acrescentar:

```ruby
    assert_select ".hud", text: /fase 1/
    assert_select ".mission", count: 3
    assert_select ".mission .skill-tag", text: /Controle/, count: 2
    assert_select ".mission", text: /\+110 XP/
```

E um teste novo: desafio sem skill não mostra etiqueta:

```ruby
  test "a mission without skill has no tag" do
    challenges(:caminhada).update!(skill: nil)
    get project_path(@project)
    assert_select ".mission .skill-tag", count: 2
  end
```

Em `Challenges::SlipsControllerTest#marks a slip and swaps the day and the counter` acrescentar `assert_match "day--breaking", response.body`.

O `includes` do `show` precisa trazer a skill: `@project.groups.order(:id).includes(challenges: [ :slips, :skill ])`.

- [ ] **Step 2: Rodar e ver falhar**

Run: `bin/rails test test/controllers/projects_controller_test.rb test/controllers/challenges/slips_controller_test.rb`
Expected: FAIL nas asserções `.hud`, `.mission`, `day--breaking`.

- [ ] **Step 3: Implementar a tela**

- HUD (`.hud`): avatar 🧙 em quadrado dourado 52px, nome do projeto (`.pixel`), linha `fase N · <project_progress>` (fase só quando `:active`; nos outros status só `project_progress`), barra de progresso do projeto (largura = dias decorridos / 75), linha "⭐ <%= render perfect_days %> · ✖ N vacilos". Ações (Resultado, Novo grupo, Editar projeto, Novo projeto) viram `.button` pequenos abaixo do HUD.
- Grupo: `.section-title` "▶ Nome do grupo" + link editar.
- Missão (`article.mission`, mantém `id=dom_id(challenge)`): `h3` com nome + link editar, "+N XP" (`challenge.xp`) à direita em verde, etiqueta `.skill-tag` "ícone nome" (fundo `#3b5dc9`) quando houver skill, e a grade.
- `create.turbo_stream.erb` renderiza o `_day` com `breaking: true`.

- [ ] **Step 4: Corações (`hearts.css`)**

- `.days`: `grid-template-columns: repeat(15, var(--heart))`, `gap: 4px`, `--heart: 18px`; abaixo de 40rem `--heart: 16px; gap: 3px`.
- Cada `button`/`a`/`span` dentro de `.day`: `width/height: var(--heart)`, sem borda/padding/fundo, e um `::before` com a forma do coração via `mask` (SVG pixel 9×8, `shape-rendering='crispEdges'`, path `M1 0h2v1h1v1h1V1h1V0h2v1h1v3H8v1H7v1H6v1H5v1H4V7H3V6H2V5H1V4H0V1h1z`, viewBox `0 0 9 8`; use também `-webkit-mask`).
- Cores do `::before`: kept `#38b764`; slipped `#b13e53` com opacidade .55; future `#333c57`.
- `.day--today`: `filter: drop-shadow(0 0 3px #ffcd75)` + pulinho `translateY(-2px)` em `steps(2)` 1.2s infinito.
- `:focus-visible` com outline dourado 2px.
- `.day--breaking`: animação de ~400ms em `steps(4)` (tremer + escalar 1.3 → 1, ou partir em dois — escolha do implementador) rodando uma vez.
- Hover em coração kept: leve escurecida, `cursor: pointer`.

- [ ] **Step 5: Missões (`missions.css`)**

`.mission` = `.box` com padding 10px e margem 10px; `h3` pixel 10px com `overflow-wrap: anywhere`; `.skill-tag` pixel 8px; XP verde pixel.

- [ ] **Step 6: Verificar**

Run: `bin/rails test && bin/rails test:system` → verde.
Screenshot da tela do projeto (dados de demonstração) em 375px e 1200px. Conferir: 15 corações por linha cabem em 375px sem rolagem horizontal, coração tem forma de coração pixel, hoje destacado, nome longo ("Caminhar pelo menos 30 minutos todo santo dia") quebra linha.

- [ ] **Step 7: Commit**

`git commit -m "feat: rpg project screen with hearts grid"`

---

### Task 4: Ficha do personagem e skills

**Files:**
- Create: `app/controllers/skills_controller.rb`, `app/views/skills/{index,new,edit,_form,_skill}.html.erb`, `app/assets/stylesheets/skills.css`
`app/controllers/challenges_controller.rb`, `app/views/challenges/{new,edit}.html.erb`
- Test: `test/controllers/skills_controller_test.rb`, `test/controllers/challenges_controller_test.rb`

**Interfaces:**
- Consumes: `Skill`, `Character`, `Level` (Task 1); `.hud`, `.box`, `.button`, `.section-title` (Task 2).
- Produces: `skills_path` (ficha), `new_skill_path`, `edit_skill_path(skill)`; `SkillsController#index` expõe `@character` (com skills carregadas via `Skill.order(:name).includes(challenges: [ :slips, { group: :project } ])`).

- [ ] **Step 1: Testes que falham**

`test/controllers/skills_controller_test.rb`:

```ruby
require "test_helper"

class SkillsControllerTest < ActionDispatch::IntegrationTest
  setup { travel_to_day Date.new(2026, 10, 12) }

  test "character sheet shows level and skills" do
    get skills_path
    assert_response :success
    assert_select ".hud", text: /PERSONAGEM/
    assert_select ".hud", text: /NV 4/
    assert_select ".skill-card", count: 3
    assert_select ".skill-card", text: /Controle.*NV 3.*60\/150 XP.*2 missões/m
    assert_select ".skill-card", text: /Jejum.*NV 1.*0\/50 XP/m
  end

  test "empty sheet invites to create the first skill" do
    Skill.destroy_all
    get skills_path
    assert_select "p", text: /Crie sua primeira skill/
  end

  test "creates a skill" do
    assert_difference -> { Skill.count } do
      post skills_path, params: { skill: { name: "Sono", icon: "😴" } }
    end
    assert_redirected_to skills_path
  end

  test "rejects a duplicate name" do
    post skills_path, params: { skill: { name: "controle", icon: "🛡" } }
    assert_response :unprocessable_content
  end

  test "edits a skill" do
    patch skill_path(skills(:jejum)), params: { skill: { name: "Jejum intermitente" } }
    assert_redirected_to skills_path
    assert_equal "Jejum intermitente", skills(:jejum).reload.name
  end

  test "destroys a skill and frees its challenges" do
    delete skill_path(skills(:controle))
    assert_redirected_to skills_path
    assert_nil challenges(:refri).reload.skill
  end
end
```

Em `ChallengesControllerTest`: criar desafio com `skill_id: skills(:jejum).id` salva a skill; o form de novo desafio tem `select[name='challenge[skill_id]'] option`, contando 4 opções (3 skills + "— nenhuma —").

- [ ] **Step 2: Rodar e ver falhar**

Run: `bin/rails test test/controllers/skills_controller_test.rb test/controllers/challenges_controller_test.rb`
Expected: ERROR `uninitialized constant SkillsController`; falha no select.

- [ ] **Step 3: Implementar**

- `SkillsController`: CRUD padrão (mesmo formato do `GroupsController`); `index` monta `@character = Character.new(Skill.order(:name).includes(...))`; create/update/destroy redirecionam pra `skills_path`; params `params.expect(skill: [ :name, :icon ])`.
- `ChallengesController#challenge_params` permite `:skill_id`. Form de desafio: `form.collection_select :skill_id, Skill.order(:name), :id, ->(s) { "#{s.icon} #{s.name}" }, { include_blank: "— nenhuma —" }` com label "Skill".
- Ficha (`index`): `.hud` com 🧙, "PERSONAGEM", "NV N", "N XP no total"; `.section-title` "▶ SKILLS"; uma `_skill` por skill: `.skill-card` com ícone (quadrado 38px), nome, "NV N", barra (`width = xp_into * 100 / xp_needed`%), "xp_into/xp_needed XP", "N missões" (`active_challenges_count`, "1 missão"/"N missões"; 0 → "nenhuma ativa"), link editar. Sem skills: `<p>` "Crie sua primeira skill pra começar a ganhar XP." Botão "+ Nova skill".
- Form de skill (`_form`, usado por new/edit): label "Nome", label "Ícone" (text_field, sem `maxlength`, pra aceitar emoji composto) com dica abaixo "ex.: ⏳ 🛡 🚶 💧 🥗 😴 📚 💪". Botões "Criar skill" / "Salvar". Emojis clicáveis ficam fora (YAGNI).
- `skills.css`: `.skill-card` = `.box` em flex; barra 10px com borda 2px preta, preenchimento verde.

- [ ] **Step 4: Verificar**

Run: `bin/rails test && bin/rails test:system` → verde. Screenshot da ficha em 375px.

- [ ] **Step 5: Commit**

`git commit -m "feat: character sheet and skills"`

---

### Task 5: Banner de level up

**Files:**
- Create: `app/javascript/controllers/level_up_controller.js`, `app/views/shared/_level_up.html.erb`, `app/helpers/skills_helper.rb`, `app/assets/stylesheets/level_up.css`
- Modify: `app/views/projects/show.html.erb`, `app/views/skills/index.html.erb`
- Test: `test/helpers/skills_helper_test.rb`

**Interfaces:**
- Consumes: `Skill#level` (Task 1).
- Produces: `level_up_banner(skills) -> html` (renderiza `shared/_level_up` com `data-controller="level-up"` e `data-level-up-skills-value` = JSON `[{ "id": 1, "name": "Controle", "level": 3 }]`, elemento `hidden` por padrão).

- [ ] **Step 1: Teste do helper**

```ruby
require "test_helper"

class SkillsHelperTest < ActionView::TestCase
  test "banner carries each skill level as data" do
    travel_to_day Date.new(2026, 10, 12)
    html = level_up_banner([ skills(:controle) ])

    assert_includes html, 'data-controller="level-up"'
    assert_includes html, "hidden"
    assert_includes html, { id: skills(:controle).id, name: "Controle", level: 3 }.to_json.gsub('"', "&quot;")
  end
end
```

- [ ] **Step 2: Rodar e ver falhar** — `bin/rails test test/helpers/skills_helper_test.rb` → `undefined method 'level_up_banner'`.

- [ ] **Step 3: Implementar**

- Helper + partial conforme Interfaces. Na tela do projeto, `level_up_banner` recebe as skills distintas das missões do projeto (`@groups.flat_map(&:challenges).filter_map(&:skill).uniq`); na ficha, `@character.skills`.
- `level_up_controller.js` (Stimulus, `static values = { skills: Array }`), em `connect()`:
  - Lê `localStorage["desafio:max-levels"]` dentro de `try/catch`; JSON inválido ou erro → trata como `{}` e, se o erro for de acesso ao storage, sai sem fazer nada.
  - Para cada skill: se existe valor guardado e `level > guardado` → entra na lista de level ups. Se não existe valor guardado, só registra.
  - Grava `max(guardado, level)` por id (high-water mark) dentro de `try/catch`.
  - Se houver level ups: escreve "★ LEVEL UP! ★" + uma linha por skill "Nome chegou ao NV N" (via `textContent`, nunca `innerHTML`) e remove `hidden`. Clique no banner o esconde.
- `level_up.css`: caixa com borda 3px dourada, fundo `#5d275d`, texto pixel centralizado, borda piscando entre dourado e branco em `steps(2)` 1s.

- [ ] **Step 4: Verificar**

Run: `bin/rails test` → verde.
Manual (com o servidor de demonstração, ver fim do plano), no console do navegador ou via `chromium --headless` não dá; fazer no `bin/dev`:
1. Abrir a ficha → nada aparece (primeira visita grava).
2. `localStorage.setItem("desafio:max-levels", JSON.stringify({ "<id do Controle>": 2 }))` e recarregar → banner "Controle chegou ao NV 3".
3. Recarregar de novo → banner some (já visto).
4. `localStorage.setItem("desafio:max-levels", "{lixo")` e recarregar → sem banner, sem erro no console.
Se o implementador for um agente sem navegador interativo: escrever um system test temporário com `page.execute_script` cobrindo os passos 2–4, rodar, e **não commitar** (ou commitar se ficar estável — escolha do implementador, desde que verde e rápido).

- [ ] **Step 5: Commit**

`git commit -m "feat: level up banner"`

---

### Task 6: Resultado no tema, system test das skills e verificação final

**Files:**
- Modify: `app/views/projects/results/show.html.erb`, `app/controllers/projects/results_controller.rb`
- Create: `app/assets/stylesheets/results.css`, `test/system/skills_flow_test.rb`
- Test: `test/controllers/projects/results_controller_test.rb`

**Interfaces:**
- Consumes: `Challenge#xp` (Task 1), base visual (Task 2).

- [ ] **Step 1: Teste do resultado**

Trocar as regex de linha da tabela para incluir a coluna XP (nova última coluna):

```ruby
    assert_select "tr", text: /Sem refrigerante\s+1\s+11\s+92%\s+110 XP/
    assert_select "tr", text: /Sem doce\s+2\s+10\s+83%\s+100 XP/
```

Run e ver falhar.

- [ ] **Step 2: Implementar**

Coluna "XP" (`<td><%= challenge.xp %> XP</td>`, cada `td` em linha própria). Totais em `.hud`; tabela dentro de `.box` com cabeçalho pixel dourado; timeline com marcador "✖" vermelho. `includes(challenges: [ :slips, :skill ])` no controller.

- [ ] **Step 3: System test das skills**

`test/system/skills_flow_test.rb`:

```ruby
require "application_system_test_case"

class SkillsFlowTest < ApplicationSystemTestCase
  test "create a skill, train it with a challenge and see the xp on the sheet" do
    travel_to_day Date.new(2026, 10, 12)

    visit skills_path
    click_on "+ Nova skill"
    fill_in "Nome", with: "Jejum longo"
    fill_in "Ícone", with: "⏳"
    click_on "Criar skill"
    assert_text "Jejum longo"

    visit project_path(projects(:setenta))
    click_on "Novo desafio", match: :first
    fill_in "Nome", with: "Jejum 16h"
    select "⏳ Jejum longo", from: "Skill"
    click_on "Criar desafio"
    assert_text "+120 XP"

    visit skills_path
    assert_text "450 XP no total"
    within(".skill-card", text: "Jejum longo") { assert_text "70/100 XP" }
  end
end
```

(330 XP das fixtures + 120 do desafio novo, 12 dias cumpridos.)

- [ ] **Step 4: Verificação final**

Run: `bin/rails test && bin/rails test:system && bin/rubocop && bin/brakeman --no-pager -q`
Expected: tudo verde, sem offenses, sem warnings.
Screenshots finais (projeto, ficha, resultado, form de desafio) em 375px e 1200px; ler e conferir contra os mockups `skills-v2.html` e `tiles.html` (corações).

- [ ] **Step 5: Commit**

`git commit -m "feat: rpg results and skills system test"`

---

## Como tirar screenshot (Tasks 2–6)

Nunca usar o banco de desenvolvimento (o user pode já estar usando). Banco descartável:

```bash
export DATABASE_URL=sqlite3:tmp/demo.sqlite3
bin/rails db:prepare
bin/rails runner tmp/demo.rb          # dados abaixo
bin/rails server -p 3999 -d
chromium --headless --disable-gpu --hide-scrollbars --window-size=375,1600 \
  --screenshot=tmp/shot-375.png http://localhost:3999/projects/1
chromium --headless --disable-gpu --hide-scrollbars --window-size=1200,1400 \
  --screenshot=tmp/shot-1200.png http://localhost:3999/projects/1
kill "$(cat tmp/pids/server.pid)"
```

`tmp/demo.rb` (não commitar; `tmp/` já é ignorado):

```ruby
Slip.delete_all; Challenge.delete_all; Group.delete_all; Project.delete_all; Skill.delete_all
jejum = Skill.create!(name: "Jejum", icon: "⏳")
controle = Skill.create!(name: "Controle", icon: "🛡")
project = Project.create!(name: "Comer melhor", starts_on: Date.current - 11)
food = project.groups.create!(name: "Alimentação")
food.challenges.create!(name: "Jejum 16h", skill: jejum)
refri = food.challenges.create!(name: "Sem refrigerante", skill: controle)
doce = food.challenges.create!(name: "Sem doce", skill: controle)
project.groups.create!(name: "Treino").challenges.create!(name: "Caminhar pelo menos 30 minutos todo santo dia")
refri.slips.create!(day: project.starts_on + 2, note: "aniversário")
doce.slips.create!(day: project.starts_on + 2)
doce.slips.create!(day: project.starts_on + 4)
```
