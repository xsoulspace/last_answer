# Project operations — the declaration file

A project publishes its own commands. The product reads them; it never
guesses them, and it never runs one until a person asks.

## Where the declaration lives

```
<project>/.oka/project_operations.json
```

The file is **data**, not a script: an exact executable, an exact argument
list, an explicit working directory, explicit environment overrides, and an
optional declared readiness probe and endpoint. There is no shell string
anywhere in it, and nothing in it is interpreted by a shell.

The file carries the *evidence shape* of a profile — the JSON a
`ProjectOperationProfile.toJson()` produces — so a project declaration and a
shipped fixture are the same kind of thing. The strict decoder in
`oka_core` (`package:oka_core/project_operations.dart`) is the only reader.

## The rules

* **Nothing runs on load.** Reading the declaration reads a file. No process
  starts, no endpoint is probed, no command is inferred from a file name.
* **No auto-detected stack.** A profile the project did not declare does not
  exist for the product. The shipped fixtures are opt-in data, not defaults.
* **One operation per kind.** `check`, `build` and `serve` are declared at
  most once each, with their own id.
* **A refused declaration is refused, not repaired.** An unknown key, a
  wrong type, a duplicate id or kind, an empty operation list, an unknown
  working-directory kind, a non-positive timeout, an out-of-range port, a
  malformed endpoint or a readiness probe missing its own field is refused
  with a named reason (for example
  `project_operation_profile_duplicate_kind`). The surface shows the reason;
  it never repairs the file into a guess.
* **Environment values stay out of the surface.** A declaration may declare
  environment overrides. The panel shows the command, never the values, and a
  refusal never echoes one.
* **A working tree check is not a candidate check.** The `check` operation
  runs the project's own command against the owner project root. It is the
  project's report about its working tree — never evidence about a candidate
  under review, and never an acceptance.

## The shape

```json
{
  "id": "my_project",
  "operations": [
    {
      "id": "check",
      "kind": "check",
      "command": {
        "executable": "tool",
        "arguments": ["--flag", "value"],
        "workingDirectory": {"kind": "project"},
        "environment": {"NAME": "value"},
        "timeoutMs": 600000
      }
    }
  ],
  "externalPackageRoots": {"name": "/absolute/path"}
}
```

| Field | Meaning |
| --- | --- |
| `id` | the profile id; letters, digits, `.`, `_`, `-` |
| `operations` | the declared operations, in declaration order |
| `operations[].id` | the operation's own id |
| `operations[].kind` | `check`, `build` or `serve` |
| `operations[].command.executable` | the program to run, resolved by the spawn itself |
| `operations[].command.arguments` | the exact arguments, in order; an argument with spaces stays one argument |
| `operations[].command.workingDirectory` | `{"kind":"project"}`, `{"kind":"candidate"}` or `{"kind":"external","path":"/absolute/path"}` |
| `operations[].command.environment` | explicit overrides on top of the inherited environment |
| `operations[].command.timeoutMs` | the budget of the bounded run, in milliseconds (positive) |
| `operations[].endpoint` | `{"host":"127.0.0.1","port":8080,"path":"/"}` — the URL a browser window opens |
| `operations[].readiness` | `{"kind":"tcp","host":…,"port":…}`, `{"kind":"logLine","pattern":…}` or `{"kind":"filePresent","path":…}` |
| `externalPackageRoots` | package roots *referenced* (linked) into a staged candidate, never copied |

## Example — a plain web project

A static site has no build step. The project still has to publish the
command that serves it; the product does not pick one.

```json
{
  "id": "plain_web",
  "operations": [
    {
      "id": "serve",
      "kind": "serve",
      "command": {
        "executable": "python3",
        "arguments": ["-m", "http.server", "8080", "--directory", "."],
        "workingDirectory": {"kind": "project"},
        "timeoutMs": 1800000
      },
      "endpoint": {"host": "127.0.0.1", "port": 8080, "path": "/"},
      "readiness": {"kind": "tcp", "host": "127.0.0.1", "port": 8080}
    }
  ]
}
```

## Example — a Flutter web project

The commands are the ones the shipped `dart_flutter` fixture declares, so the
declaration and the fixture agree:

```json
{
  "id": "dart_flutter",
  "operations": [
    {
      "id": "check",
      "kind": "check",
      "command": {"executable": "dart", "arguments": ["analyze"]}
    },
    {
      "id": "build",
      "kind": "build",
      "command": {
        "executable": "flutter",
        "arguments": ["build", "web", "--release"]
      }
    },
    {
      "id": "serve",
      "kind": "serve",
      "command": {
        "executable": "flutter",
        "arguments": ["run", "-d", "web-server", "--web-port", "8080"],
        "timeoutMs": 1800000
      },
      "endpoint": {"host": "127.0.0.1", "port": 8080, "path": "/"},
      "readiness": {"kind": "tcp", "host": "127.0.0.1", "port": 8080}
    }
  ]
}
```

## Example — an npm project

The same contract, a different ecosystem. The commands are the ones the
shipped `react_npm` fixture declares:

```json
{
  "id": "react_npm",
  "operations": [
    {
      "id": "check",
      "kind": "check",
      "command": {"executable": "npm", "arguments": ["run", "build"]}
    },
    {
      "id": "serve",
      "kind": "serve",
      "command": {
        "executable": "npm",
        "arguments": ["run", "dev", "--", "--port", "5173"],
        "timeoutMs": 1800000
      },
      "endpoint": {"host": "127.0.0.1", "port": 5173, "path": "/"},
      "readiness": {"kind": "tcp", "host": "127.0.0.1", "port": 5173}
    }
  ]
}
```

## What the surface does with it

The project operations panel shows the declared operations and offers four
actions, each of them an explicit click:

* **Working tree check** — the project's own check command on the owner
  project root. The panel says *working tree*: the result is the project's
  report about its tree, not a candidate verification and not an acceptance.
* **Build** — the project's own build command.
* **Serve & open** — starts the declared `serve` operation and opens the
  general browser at the URL the session exposes.
* **Stop** — releases the served target. Only a process the session owns is
  stopped; a target somebody else already serves is left running and keeps
  its URL.

The panel shows the running state, the outcome, the bounded logs and the
endpoint. A cancel really stops the command: the bounded run performs the
same identity-gated tree stop the deadline performs, and the panel says
whether that stop was verified. A stop that could not be verified is a
failure with its recovery receipt, not a clean cancel.

## References

- [ADR 0021 — Generic project operations and browser session ownership](../decisions/0021-generic-project-operations.md)
- oka [ADR 0050 — General project commands and server sessions](https://github.com/Arenukvern/oka/blob/main/docs/decisions/0050-general-project-operation-sessions.mdx)
