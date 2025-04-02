# sheckpoint

A shell-integrated checkpoint system for tracking project changes and commands,
designed to work seamlessly with an AI assistant.

## Purpose

Sheckpoint snapshots your working tree and shell activity, enabling an AI
assistant to understand project evolution through checkpoints, diffs, and
command history.

## Roadmap

### 1. Checkpoints with Git (v1)

- **What**: Use Bash and Git named stashes (e.g., `_checkpoint`) to snapshot all
  files without modifying the index ([inspired by this
  solution](https://stackoverflow.com/a/60557208/1967121)).
- **Commands**:
  - `sheckpoint save`: Create a snapshot.
  - `sheckpoint diff`: Show diff from the last checkpoint.
- **Improvements**:
  - Filter out unimportant files in diffs.
  - Optimize/compress diffs with a local LLM.
  - Study optimal diff format for LLM comprehension.

### 2. Command History with Atuin

- **What**: Integrate with [Atuin](https://github.com/atuinsh/atuin) to capture
  commands tied to checkpoint time frames.
- **Improvements**:
  - Filter commands by working tree context.
  - Optimize command data with LLM.

### 3. Terminal-Aware Shell Wrapper & Daemon (in Rust)

#### 🧩 Shell Wrapper Component

- A lightweight wrapper for shells like bash or zsh that:
  - Injects and intercepts terminal control sequences (OSC 7, OSC 133).
  - Captures commands executed, outputs, exit codes, and working directory.
  - Communicates data via IPC (Unix sockets) to the daemon.
  - Remains minimal and performance-focused.

#### 🛠 Daemon Component

- A Rust-based daemon that:
  - Receives structured logs from the shell wrapper.
  - Parses and persistently stores data (commands, outputs, exit codes,
    directories, timestamps).
  - Uses efficient storage formats (SQLite, JSONL, binary).
  - Provides querying capabilities via CLI or API.

#### 🧪 Design Principles

- **Minimal overhead**: Lightweight wrapper; logic centralized in daemon.
- **Asynchronous**: Utilizes `tokio` for concurrent processing.
- **Secure**: Safe IPC channels, sandboxing, and no elevated privileges.
- **Compatible**: Works with OSC-supporting terminal emulators (iTerm2, WezTerm,
  Kitty, Windows Terminal).
- **Extensible**: Future support for metadata integration (Git, project names),
  TUI viewers, and integration with tools like `atuin`, `tmux`, or `starship`.

### 4. Live Chunking with Daemon

- Chronologically interleave file edits and command sequences in real-time.
- Utilize file change monitoring (e.g., via `notify`) and shell interactions to
  keep checkpoints synchronized.

## Installation

<!--
1. Clone the repo: `git clone https://github.com/yourusername/sheckpoint.git`
2. Source the script: `source ./sheckpoint.sh`
3. Use the commands:
   - `sheckpoint save` to create a checkpoint
   - `sheckpoint diff` to view changes since last checkpoint
-->

- _WIP_

## Future Vision

Sheckpoint aims to evolve into a cross-platform tool (macOS/Linux) leveraging a
Rust daemon, comprehensive output capture, and seamless AI integration.

## Contributing

Contributions welcome! Check the roadmap for current priorities and submit
ideas, issues, or pull requests.

## License

MIT License
