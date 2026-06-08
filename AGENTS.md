# AGENTS.md — Lua / CC:Tweaked Project Rules

## Scope

These rules apply to all Lua and CC:Tweaked code in this repository.

Primary goals:

- High safety
- High modularity
- Modern Lua style
- Clear abstractions
- Object-oriented module design where useful
- Maintainable ComputerCraft / CC:Tweaked compatibility

Do not assume any specific refactor plan. Apply these rules to all future Lua code, fixes, features and reviews.

---

## Environment

- Language: Lua for CC:Tweaked / ComputerCraft.
- Runtime: Minecraft CC:Tweaked computers, turtles, monitors and peripherals.
- Do not assume external Lua libraries.
- Do not assume Lua 5.4 features.
- Prefer compatibility with Lua 5.1-style syntax unless the project clearly supports newer syntax.
- Use CC:Tweaked APIs only where appropriate:
  - `fs`
  - `http`
  - `shell`
  - `term`
  - `window`
  - `paintutils`
  - `textutils`
  - `peripheral`
  - `redstone`
  - `rednet`
  - `parallel`
  - `os`
  - `turtle`

---

## Safety Rules

- Never hardcode passwords, tokens, private URLs, API keys or secrets.
- Never print secrets, credentials, session tokens or private configuration values.
- Never read or expose `.env`, secret, credential or token files unless explicitly instructed.
- Never send local file contents to an external URL or API endpoint unless explicitly instructed.
- Never delete files or folders without explicit user approval.
- Never run destructive shell commands without explaining the command first.
- Never modify files outside the current project root.
- Never overwrite user configuration files silently.
- Before changing existing behavior, identify the behavior being changed and why.
- Prefer additive, backward-compatible changes over destructive rewrites.
- Validate all file paths before writing:
  - reject empty paths
  - reject absolute paths unless explicitly required
  - reject paths containing `..`
  - reject paths that escape the intended project or computer filesystem
- Treat network input, modem messages, rednet packets, HTTP responses and user input as untrusted.
- Validate message shape before acting on modem/rednet/network data.
- Never execute code received from network, config, modem, rednet or HTTP input.

---

## Permission Rules

Allowed without asking:

- Read project files.
- Search code.
- Explain code.
- Propose changes.
- Add small non-destructive helper functions.
- Add documentation.
- Run lightweight validation commands if available.

Ask first:

- Delete files.
- Rename or move many files.
- Change public APIs used by other modules.
- Change installer behavior.
- Change save/config formats.
- Modify startup behavior.
- Add dependencies.
- Run broad formatting across many files.
- Touch more than 5 files in one change.

Never:

- Push to a remote repository.
- Force-push.
- Commit secrets.
- Modify files outside the project.
- Wipe directories.
- Replace working app logic with an untested rewrite.

---

## Lua Style

- Use `local` for all variables and functions unless a global is intentionally required.
- Do not create accidental globals.
- Prefer explicit module tables:

```lua
local ModuleName = {}

function ModuleName.doSomething()
end

return ModuleName
```

- Prefer `local function` for private helpers.
- Keep private helpers above the public API when practical.
- Keep modules readable from top to bottom:
  1. constants
  2. dependencies
  3. private helpers
  4. constructor / public API
  5. return table
- Use meaningful names:
  - good: `recipeManager`, `portalController`, `inventoryAdapter`
  - bad: `mgr`, `tmp`, `x`, `data2`
- Avoid magic values. Use named constants.
- Avoid deeply nested control flow.
- Prefer early returns.
- Aim for maximum two levels of indentation inside functions.
- Keep functions focused.
- Prefer functions below 40 lines when practical.
- Keep modules focused on one responsibility.

---

## Object-Oriented Lua Rules

Use object-oriented style when a module manages state, lifecycle or external resources.

Preferred object pattern:

```lua
local Controller = {}
Controller.__index = Controller

function Controller.new(options)
  local self = setmetatable({}, Controller)

  self.config = options.config
  self.logger = options.logger
  self.running = false

  return self
end

function Controller:start()
  self.running = true
end

function Controller:stop()
  self.running = false
end

return Controller
```

Rules:

- Use `Module.new(...)` constructors for stateful modules.
- Use `:` method syntax for instance methods.
- Use `.` function syntax for stateless utility functions.
- Do not use inheritance chains unless clearly justified.
- Prefer composition over inheritance.
- Inject dependencies through constructors instead of hardcoding them.
- Keep object state explicit on `self`.
- Do not store hidden cross-module state in globals.
- Do not mutate constructor arguments unless documented.
- Separate object responsibilities:
  - Scanner scans.
  - Controller controls.
  - Renderer renders.
  - Repository loads/saves.
  - Adapter wraps an external API.
  - Service coordinates multiple collaborators.

---

## Abstraction Rules

Use abstractions to isolate unstable APIs and app-specific logic.

Good abstractions:

- `InventoryAdapter`
- `PeripheralScanner`
- `MonitorRenderer`
- `ButtonGrid`
- `ConfigStore`
- `RedstoneController`
- `NetworkProtocol`
- `RecipeRepository`
- `StateMachine`
- `Logger`

Rules:

- Do not abstract too early.
- Extract shared logic only when it is genuinely reusable.
- Keep abstractions small and concrete.
- Avoid “god modules”.
- Avoid generic names like `Manager` unless the responsibility is still clear.
- Do not mix UI, business logic and device I/O in the same function.
- Keep peripheral-specific code behind adapters.
- Keep protocol/message parsing separate from business actions.
- Keep rendering separate from state updates.
- Keep config loading/saving separate from runtime logic.

Preferred layering:

```text
App
  -> Services / Controllers
    -> Adapters / Repositories / Renderers
      -> CC:Tweaked APIs
```

Forbidden layering:

```text
Core utility -> App-specific module
Renderer -> Business mutation without explicit callback
Config module -> Peripheral side effects
Logger -> App control flow
```

---

## Modularity Rules

- Each file should have one clear responsibility.
- A module should expose a small public API.
- A module should hide implementation details.
- Avoid circular dependencies.
- Avoid modules that require unrelated apps.
- Avoid requiring files for side effects.
- Do not perform heavy work at module load time.
- Module load should define functions/classes, not start loops.
- Startup files should wire dependencies and start the app.
- Keep reusable code app-agnostic.
- Keep app-specific behavior in app-specific modules.
- Prefer dependency injection over hardcoded `require()` chains when it improves testability.
- Do not make every module depend on a large shared core.
- Split shared functionality by feature:
  - base
  - ui
  - inventory
  - peripherals
  - redstone
  - network
  - runtime
  - recipes

---

## Error Handling

- Prefer explicit errors over silent failure.
- Return `nil, err` or `false, err` for recoverable failures.
- Use `error()` only for programmer errors or unrecoverable invalid state.
- Include context in error messages.
- Do not swallow errors silently.
- When wrapping peripheral calls, handle missing peripherals gracefully.
- When doing item transfers, verify source, target, slot and count.
- When using network messages, reject malformed messages.
- When using config files, validate required fields before runtime starts.
- Show user-friendly messages on terminal/monitor where appropriate.
- Log technical details separately if a logger exists.

Example:

```lua
local ok, err = inventory.transfer(source, target, slot, count)

if not ok then
  logger.warn("Transfer failed: " .. tostring(err))
  return false, err
end
```

---

## CC:Tweaked Peripheral Rules

- Never assume a peripheral exists.
- Always validate peripheral names and wrapped objects.
- Prefer `peripheral.find()` or configured names depending on the app’s needs.
- If multiple peripherals are possible, make selection explicit.
- Do not hardcode side names unless config-driven.
- Treat peripheral methods as unstable across modpacks.
- Use feature detection where possible:

```lua
if type(device.getItemDetail) == "function" then
  -- safe to call
end
```

- Wrap peripheral calls where failure is possible.
- Keep mod-specific behavior outside generic core modules.

---

## UI / Monitor Rules

- Separate UI layout from business logic.
- Separate button hit-testing from button rendering.
- Do not block business logic inside rendering functions.
- Support different monitor sizes where practical.
- Use pagination when content may exceed screen size.
- Avoid flicker; use double buffering or minimal redraws when practical.
- Keep UI state explicit:
  - selected item
  - current page
  - status message
  - error message
- Touch handlers should dispatch actions, not contain large workflows.
- All monitor text should be clear and short.
- Provide useful fallback output on terminal if no monitor is found.

---

## Network / Rednet Rules

- Validate every incoming message.
- Use protocol identifiers.
- Use message types.
- Ignore unknown message types safely.
- Do not trust sender IDs blindly unless configured.
- Do not execute commands from messages directly.
- Convert network messages into validated domain actions.
- Keep protocol format documented near the protocol module.
- Always close or clean up modem/rednet resources when appropriate.
- Avoid infinite spam loops.
- Use timeouts for receive loops where practical.

Example message shape:

```lua
{
  protocol = "my_app_protocol",
  type = "recall",
  target = "base"
}
```

---

## Inventory / Item Movement Rules

- Treat inventory operations as failure-prone.
- Validate inventory peripherals before transfer.
- Validate slots before transfer.
- Validate item names before matching.
- Do not assume NBT is human-readable.
- Do not assume `displayName` is always available.
- Prefer item fingerprints when exact matching matters.
- After transfer, verify result when practical.
- Keep item matching separate from transfer execution.
- Keep recipe logic separate from inventory transfer logic.
- Do not hardcode mod-specific item names in generic inventory modules.

---

## Config Rules

- Config files must be Lua tables or clearly documented serialized formats.
- Validate config at startup.
- Provide defaults for optional fields.
- Fail clearly for missing required fields.
- Do not mutate default config tables directly.
- Do not overwrite existing config without asking.
- Keep config schema documented near the app.
- Prefer explicit config keys over positional arrays when clarity matters.
- Keep user-editable config simple.

---

## Logging Rules

- Use a logger abstraction for non-trivial apps.
- Logging must not crash the app.
- Do not log secrets.
- Use levels when useful:
  - debug
  - info
  - warn
  - error
- User-facing monitor messages should be short.
- Technical logs can be more detailed.
- Remove temporary debug prints before marking work complete.

---

## Testing / Validation Rules

- When possible, add small validation functions for pure logic.
- Prefer testing pure functions without CC:Tweaked APIs.
- Keep logic testable by isolating CC APIs behind adapters.
- Add dry-run modes for installers or destructive workflows when practical.
- Validate manifests/configs before using them.
- If a test framework is unavailable, provide a simple Lua validation script.
- Do not mark work complete if known validation fails.
- Document any behavior that could not be tested in-game.

---

## Documentation Rules

- Document public modules with a short header comment.
- Document constructors and public methods.
- Document expected config shape.
- Document network message shapes.
- Document installer commands if an installer is changed.
- Keep README examples copy-pasteable.
- Do not document features that do not exist.
- When adding a new module, include:
  - purpose
  - public API
  - expected inputs
  - failure behavior

---

## Performance Rules

- Avoid unnecessary work inside tight loops.
- Cache wrapped peripherals when safe.
- Avoid repeated full inventory scans unless needed.
- Use refresh intervals for dashboards.
- Avoid excessive monitor redraws.
- Avoid unnecessary table allocation in high-frequency loops.
- Prefer event-driven loops where suitable.
- Do not optimize prematurely at the cost of clarity.
- Explain performance-sensitive choices with short comments.

---

## Git / Change Management Rules

- Keep changes small and focused.
- One logical change per commit suggestion.
- Use Conventional Commit style when suggesting commits:
  - `feat:`
  - `fix:`
  - `docs:`
  - `chore:`
  - `refactor:`
  - `test:`
- Do not suggest committing if validation is failing.
- Before large changes, list affected files and ask for approval.
- Prefer reversible changes.
- Do not mix formatting-only changes with functional changes.

---

## Communication Rules

- Be concise and direct.
- Before modifying more than 5 files, provide a short plan.
- List files that will be changed before making broad edits.
- If behavior is ambiguous, ask one focused question.
- If a safe default exists, choose the minimal safe change.
- Explain root cause before proposing a fix.
- After completing a multi-step task, summarize:
  - what changed
  - how it was validated
  - remaining risks or follow-ups
- Do not explain basic Lua syntax unless asked.

---

## Completion Criteria

A task is complete only when:

- Code is Lua / CC:Tweaked compatible.
- No accidental globals were introduced.
- No secrets were added or exposed.
- No unrelated modules were modified.
- Public behavior is preserved unless explicitly changed.
- New modules have clear responsibilities.
- Stateful modules use explicit constructors.
- Peripheral/network/config inputs are validated.
- Errors are handled or clearly surfaced.
- Documentation is updated when user-facing behavior changes.
- Validation was run or limitations were clearly stated.

---

## UI Theme / Style Rules

- **NEVER** modify the `Dashboard.Theme` configurations in `ui/Dashboard.lua` (or any related UI visual layout files such as `FrameRenderer.lua` and `VirtualCanvas.lua`) unless explicitly requested by the user.
- **NEVER** change the character mappings (`chars`, e.g., `H_TOP`, `H_BOT`, `TL`, `TR`, `BL`, `BR`) or swap configurations (`swap`) or color selections that have been carefully calibrated by the user.
- These visual layout settings and custom character/border alignments are fully customized by the user and must be treated as **FROZEN** during any functional refactoring or new feature additions.
