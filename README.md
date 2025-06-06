# Shell History Timestamper

This utility script enables or disables timestamped command history for Bash and Zsh shells. It does so by managing a single `.history_config` file in your home directory and ensuring your shell configuration files (`.bashrc` and `.zshrc`) source it.

## What It Does

- Ensures every command you run in Bash or Zsh is saved with an execution timestamp.
- Keeps your shell configuration clean by isolating all related settings in `.history_config`.
- Makes activation and removal fully reversible and idempotent.

## Usage

1. Download and make the script executable:
    ```sh
    chmod +x shell-timestamp.sh
    ```

2. To **enable** timestamped history, run:
    ```sh
    ./shell-timestamp.sh install
    ```

3. To **disable** and fully remove the configuration, run:
    ```sh
    ./shell-timestamp.sh uninstall
    ```

4. After installing or uninstalling, **restart your shell** or run:
    ```sh
    source ~/.bashrc
    ```
    or
    ```sh
    source ~/.zshrc
    ```
    to apply changes immediately.

## Notes

- The script will not overwrite your existing shell configuration or history settings; it only adds or removes a dedicated sourcing block and config file.
- Existing history files are not modified; only new history entries will include timestamps after installation.
