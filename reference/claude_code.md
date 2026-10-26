# Claude Code Cheat Sheet

Commands are checked against the official Claude Code docs (code.claude.com, 2026-10-21). The repo
commands are this project's own (`arvig_dataform`).

## Pause and resume a session

You can always just leave the terminal open. To close it and come back later:

| Goal | Command (run from the repo folder) |
|---|---|
| Resume the most recent session in this folder | `claude -c` (same as `claude --continue`) |
| Pick any past session from a list | `claude -r` (same as `claude --resume`) |
| Resume a specific session by name or ID | `claude -r "<name-or-id>"` |
| Switch sessions while inside Claude | `/resume` (or `/resume <name>`) |
| Give the current session a name you can resume by | `/rename <name>` |

- **Sessions are per folder.** Run `cd ~/arvig/arvig_dataform` first. In the `claude -r` picker,
  press **Ctrl+A** to see sessions from every folder.
- **Picker keys:** arrows to move, **Enter** to open, **/** or start typing to search, **Ctrl+R**
  to rename.
- **History is saved on disk** as you work (`~/.claude/projects/...`) and kept 30 days by default.
  Closing the terminal doesn't lose it. `/clear` starts fresh, but the old session stays in
  `/resume`.
- **On resume, background jobs don't restart.** Any background command or agent that was running
  when you quit has to be restarted.
- **This session (FCC + school-partnership reviews):** ID `87603bda-79ab-48ed-90c9-b580a6b1ed03`.
  Resume it with `cd ~/arvig/arvig_dataform && claude -r 87603bda-79ab-48ed-90c9-b580a6b1ed03`.
  Tip: run `/rename fcc-isp-reviews` once inside it, then later use
  `claude -r "fcc-isp-reviews"`.

## Most useful slash commands

| Command | What it does |
|---|---|
| `/btw <question>` | Ask a side question without derailing the current work. It isn't added to the conversation, works while Claude is busy, and uses no tools. Press `x` to dismiss. |
| `/clear` | Start a fresh conversation. Use it for unrelated new work; it's cheaper and more focused. |
| `/compact [focus]` | Summarize a long conversation to free up room, optionally saying what to keep. |
| `/context` | Show how full the conversation's memory is. |
| `/usage` | Session cost and plan limits (also `/cost`). |
| `/rewind` | Undo back to an earlier point, for the conversation and/or code (also **Esc Esc** on an empty prompt). |
| `/plan <task>` | Plan first: Claude reads and proposes, but changes nothing until you approve. |
| `/tasks` | See background commands and agents running in this session. |
| `/model` | Switch model. |
| `/memory` | Edit CLAUDE.md or memory settings. |
| `/permissions` | Manage what Claude may do without asking. |
| `/export [file]` | Save the conversation as text. |
| `/doctor` | Check your Claude Code setup. |
| `/help` | List all commands. |
| `/exit` | Quit. |

## Keyboard shortcuts

| Key | Action |
|---|---|
| **Esc** | Stop Claude mid-step. Work done so far is kept. |
| **Esc Esc** | With an empty prompt, open the rewind menu. With text, clear it (Up recalls it). |
| **Shift+Tab** | Cycle modes: Manual → accept edits → plan → auto. |
| **Ctrl+B** | Send a running command or agent to the background. |
| **Ctrl+T** | Show or hide Claude's to-do checklist. |
| **Ctrl+O** | Show detailed tool output and the transcript. |
| **Ctrl+R** | Search your previous prompts. |
| **\\ then Enter** (or **Ctrl+J**) | New line without sending. |
| **Ctrl+G** | Write the prompt in your text editor. |
| **Ctrl+C** twice, or **Ctrl+D** twice | Exit. |
| **?** on an empty prompt | Shortcut help. |

## Input prefixes

| Prefix | Meaning |
|---|---|
| `/` | Run a command or skill, e.g. `/handoff`. Only works at the start of the message. |
| `!` | Run a shell command in the session; Claude sees the output. Example: `! gcloud auth login`. |
| `@` | Attach a file by path, e.g. `@docs/REPORT_CATALOG.md`. |

To save a preference permanently, just say **"remember that …"**.

## This repo's commands (arvig_dataform)

| Command | What it does |
|---|---|
| `/handoff [slug]` | Save the session's state (decisions, open items, PRs) to `docs/memory/` so a later session or teammate can pick it up. |
| `/create-pr` | Open a PR from the current branch into `non_prod`, with the required reviews. |
| `/merge-to-prod` | Promote `non_prod` to `production`. |
| `/new-model` | Guided interview that scaffolds a new Dataform model. |
| `/git-tidy` | Clean up local branches that are merged or gone, keeping unmerged work. |
| `/whats-here` | List the agents, commands, skills and hooks available. |
| `/setup` | Check and fix your local environment. |
| `/branch-dataset-janitor` | List old branch-suffixed BigQuery datasets for you to approve deleting. |
| `/memory-gardener` | Tidy the team memory layer (`docs/memory/`). |
| `/routine-fleet-audit` | Check that every scheduled routine is actually firing. |

## Prompts that work well

- **Start fresh work:** "Create branch `<name>` from non_prod. Files are at `<path>`. Build what's
  needed and open a PR."
- **Pick up a handoff:** "Pick up the FCC work. Read
  `docs/memory/handoffs/2026-10-21-fcc-reporting.md` first."
- **Act on a review:** "Read Casey's review **and all comments** on PR #N and make the items I
  marked Now." Reviews and comments are separate places, so ask for both.
- **Get progress without much chatter:** "Give me brief, minimal updates with time estimates."
- **Check state before trusting it:** "Check the PR's review status and comments before telling
  me it's ready."
- **When unsure if work is still running:** `/tasks`, or just ask "status?".

## Habits that save time

- Use **one session per workstream**, and `/clear` (or a new terminal) for unrelated work.
- Run **`/handoff` before ending** a big session.
- Don't **switch branches** in the repo while Claude has work running.
- Keep the **computer awake and online** while long jobs run. The work runs from this machine.
- **GitHub login:** your active `gh` account (btruss13) can't see the Arvig repo. Claude uses the
  `briean-arvig` login per command. To make it the default: `! gh auth switch -u briean-arvig`.
