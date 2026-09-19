# NadaAqui — Git Flow and PR standard

Read this before any commit. Product talk can be Portuguese. **Git is English.**

## Repos (do not mix)

| Repo | Owner of the PR | Reviewers |
|---|---|---|
| `joaofviana/nadaaqui-mobile` | Luizão (code) / Mat (tests only) | Mat, Felipe (acceptance) |
| `joaofviana/nadaaqui-backend` | Joaozinho (SQL/RPC/mock) / Gus (seed JSON/docs only) | Mat, Felipe (acceptance) |

Carol does **not** open code PRs. She delivers a UX spec; Luizão implements it.
Felipe does **not** commit. He writes the story and accepts the PR.

One PR = one repo = one specialty. Contract change: **backend PR first**, mobile PR links it.

## Branching (simplified Git Flow)

- `main` is production. Always green. Never push to `main`.
- Branch from latest `main`:
  - `feat/<area>-<slug>` — new behavior
  - `fix/<area>-<slug>` — bug
  - `chore/<area>-<slug>` — tooling/CI
  - `test/<area>-<slug>` — tests only (Mat)
  - `docs/<area>-<slug>` — docs/seed notes (Gus)
- Area examples: `android`, `home`, `auth`, `rpc`, `rls`, `seed`, `qa`
- Short-lived branches. Delete after merge.
- No `develop` branch unless João asks. Releases = tags on `main` (`v0.1.1`).

## Commits (Conventional Commits, English)

```
feat(home): load nearby places from live nearby_places RPC
fix(auth): map GoTrue 400 to Portuguese user copy
test(places): cover thumbnailUrl parse
chore(ci): run flutter analyze on pull_request
```

- Imperative, present tense, English, ≤ 72 chars on the subject.
- Body optional; explain *why* if non-obvious.
- No secrets. No generated junk (`dart_defines.json`, APKs).

## Pull requests — always English

Title: same conventional format as the commit subject.

Body must include Why / What / How to test / Out of scope.

- Description, review comments, and commit messages: **English**.
- UI copy in the app stays Portuguese.
- Link sibling PRs: `Depends on joaofviana/nadaaqui-backend#N`.
- Draft until Mat’s tests pass.
- Squash-merge to `main`. Felipe accepts product; Mat accepts quality.

Reject the PR if: mixed repos, mixed specialties, Portuguese title/body, secrets, or scope creep past Felipe’s brief.
