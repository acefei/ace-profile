# secrets — local secret storage with sops + age

`utility/secrets` keeps tokens in one sops-encrypted JSON file. `setup-utility`
symlinks it onto your PATH.

sops owns the file format, age owns the key. The script is the ergonomics: it
keeps values off the command line, out of shell history and out of `ps`.

## Setup

```bash
mise install          # brings in age, sops, jq
secrets init          # creates the key, warns you to back it up
```

`init` refuses to continue until you confirm the backup. That is deliberate:
the age key is the only way to read the store, and there is no recovery.

## Use

```bash
secrets set GITHUB_TOKEN          # prompts; input hidden
secrets list                      # names only, never values
secrets get GITHUB_TOKEN
secrets search 'token$'
secrets rm OLD_TOKEN

eval "$(secrets export)"          # load everything into this shell
```

`export` takes `--file` to select names from a template, `--format
shell|dotenv|json`, and `--on-missing throw|empty|keep`.

## Paths

| | Default | Override |
|---|---|---|
| Store | `~/.config/mise/secrets.json` | `SECRETS_FILE` |
| Key | `~/.config/mise/age.txt` | `SOPS_AGE_KEY_FILE` |

The store is safe to commit. The key is not, and `init` refuses to create one
inside a git repo.
