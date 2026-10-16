# Desafio — design

App pessoal pra acompanhar um desafio de 75 dias (hábitos alimentares), organizado em
grupos de desafios, todos ativos ao mesmo tempo. Marca-se **só os vacilos**: dia passado
sem marcação conta como cumprido.

Uso: local, no notebook, um único usuário. Sem login, sem deploy.

## Decisões

| Tema | Decisão |
|---|---|
| Estratégia de marcação | Registrar só exceções (vacilos). Dia passado ou hoje sem vacilo = cumprido |
| Marcar vários | Grade clicável; cada toque é instantâneo (Turbo Stream), então marcar N dias = N toques |
| Datas | Tudo herda do projeto: `starts_on` + 75 dias. Desafio criado depois ainda cobre os 75 dias |
| Nota | Opcional, editável depois de marcar o vacilo |
| Vacilo zera? | Não. Vacilo só conta, nunca reinicia nada |
| Hierarquia | Fixa em 3 níveis: Project → Group → Challenge (+ Slip) |

## 1. Domínio

```
Project   name, starts_on (date)                    has_many :groups
Group     project_id, name                           has_many :challenges
Challenge group_id, name                             has_many :slips
Slip      challenge_id, on (date), note (text, null) unique index [challenge_id, on]
```

Ordem de exibição de grupos e desafios: ordem de criação (`id`). Sem coluna `position`.

Todos os `has_many` com `dependent: :destroy`.

### Datas (`Project`)

- `DURATION = 75`
- `ends_on` = `starts_on + DURATION - 1`
- `days` → `starts_on..ends_on`
- `day_number(date)` → `(date - starts_on).to_i + 1` (ex.: "dia 12 de 75")
- `status` calculado, nunca salvo: `:upcoming` (hoje < início), `:active`, `:finished` (hoje > fim)
- `elapsed_days` → dias de `starts_on` até `min(Date.current, ends_on)`; vazio se `upcoming`

`config.time_zone = "America/Sao_Paulo"` e sempre `Date.current`.

### Estado de um dia (`Challenge#status_on(date)`)

- `:future` — `date > Date.current`. Não pode ser marcado.
- `:slipped` — existe `Slip` com `on: date`.
- `:kept` — `date <= Date.current` e sem `Slip`.

Hoje conta como `:kept` desde o início do dia; um vacilo à noite é marcado com um toque.

Para evitar N+1 na grade, o challenge carrega os slips uma vez e consulta um `Set` de datas
(`slipped_dates`).

### Validações do `Slip`

- `on` presente, único por challenge
- `on` dentro de `challenge.group.project.days`
- `on <= Date.current`

Depois que o projeto termina, vacilos antigos continuam editáveis (marcar, desmarcar, nota).

### Métricas (`Project::Results`, `Challenge` e `Group`; nada persistido)

Base de cálculo: `elapsed_days` (dias que já aconteceram dentro dos 75).

- **Challenge:** `slips_count`, `kept_count` (= elapsed − slips), `kept_percentage`
- **Group:** soma de `slips_count` dos seus desafios
- **Project:**
  - `slips_count` total
  - `perfect_days` — dias de `elapsed_days` em que nenhum desafio do projeto tem slip
  - `slips_timeline` — todos os slips do projeto em ordem cronológica, com desafio e nota

Projeto sem nenhum desafio: `perfect_days` = 0 (dia perfeito exige ao menos um desafio).

## 2. Telas e fluxo

### Rotas

```ruby
root "projects#index"
resources :projects do
  resource :results, only: :show, module: :projects
  resources :groups, shallow: true, except: :index do
    resources :challenges, shallow: true, except: :index
  end
end
resources :challenges, only: [] do
  resources :slips, only: [:create, :edit, :update, :destroy],
                    module: :challenges, param: :on
end
```

Slip é endereçado pela data (`/challenges/:challenge_id/slips/2026-10-20`), não pelo id.

### Home (`/`)

Lista de projetos. Se existe exatamente um, redireciona pra ele.

### Projeto (`/projects/:id`) — tela principal

- Cabeçalho: nome, "dia N de 75" (ou "começa em DD/MM" / "terminado"), dias perfeitos.
- Por grupo, cada desafio é uma linha com 75 quadradinhos.
- Cores: cumprido = verde suave, vacilo = vermelho/laranja, futuro = cinza claro, hoje = borda destacada.
- Desktop: 75 em linha (com quebra natural). Celular/janela estreita: blocos de 7 por linha.

### Marcar e desmarcar

- Quadrado `:kept` → `button_to` com `POST /challenges/:id/slips` (`on: date`). Resposta
  turbo_stream substitui aquele quadrado e o contador de dias perfeitos.
- Quadrado `:slipped` → link pra `GET /challenges/:id/slips/:on/edit`: form com campo de nota
  (salvar → `PATCH`) e botão "remover vacilo" (`DELETE`). Ambos redirecionam pro projeto.
- Quadrado `:future` → não clicável.
- Data inválida (fora do projeto, futura) → 422.

### Resultado (`/projects/:id/results`)

Disponível a qualquer momento, não só no fim.

- Totais do projeto: dias decorridos, dias perfeitos, total de vacilos.
- Por grupo e desafio: vacilos, cumpridos, %.
- Timeline: "dia 23 · Sem doce · aniversário da tia" (nota omitida se vazia).

### Configuração

CRUD simples com forms básicos: projeto (nome, data de início), grupo (nome), desafio (nome).
Criar grupo/desafio a partir da tela do projeto.

## 3. Stack e padrões

- Rails 8, SQLite, Hotwire (Turbo Streams apenas como resposta de request, sem broadcast),
  Propshaft + CSS puro (sem Tailwind), importmap.
- Padrão 37signals: controllers REST finos e aninhados (`Challenges::SlipsController`,
  `Projects::ResultsController`), lógica de data e métricas nos models/concerns.
- Roda local com `bin/dev`. Sem auth, sem jobs, sem mailer.

## 4. Testes (Minitest + fixtures)

- **Models:**
  - `Project`: `ends_on`, `days`, `day_number`, `status` nas três fases (com `travel_to`)
  - `Slip`: válido dentro do período; inválido antes do início, depois do fim, no futuro, duplicado
  - `Challenge#status_on`: future / slipped / kept, incluindo hoje
  - Métricas: `slips_count`, `kept_count`, `perfect_days` (inclui caso sem desafios), timeline
- **Controllers:** criar slip → turbo_stream; destroy; update de nota; data inválida → 422.
- **System test:** criar projeto → grupo → desafio → marcar vacilo → adicionar nota → ver no resultado.

## Fora do escopo

- Login, deploy (Basic Auth se um dia for pro celular)
- Lembretes/notificações
- Reordenação de grupos/desafios
- Multiusuário, social
- Reiniciar ao vacilar (estilo 75 Hard)
- Duração configurável (fixa em 75)
