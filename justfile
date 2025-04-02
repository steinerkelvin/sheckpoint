import? '../local.justfile'
import? './local.justfile'

# Default recipe to display help
default:
    @just --list

# Run shellcheck on all shell scripts
lint:
    shellcheck .

# Install the application from the current directory
install:
    nix profile install .

# Remove the application from the user profile
uninstall:
    nix profile remove .#default

# Enter a development shell with required tools
dev:
    nix develop
