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

secrets exec -- claude            # only that process sees them
eval "$(secrets export)"          # or load into this shell
```

`export` takes `--file` to select names from a template, `--format
shell|dotenv|json`, and `--on-missing throw|empty|keep`.

## Scope

`secrets exec` reads the store directly through sops. The store is **not**
declared in any mise config, so nothing is injected into your shell merely by
entering a directory, and `mise exec` will not see it either. Only the command
you name gets the values. Add `--pristine` to pass the secrets and nothing else.

If you would rather have them everywhere, declare the store in the global mise
config instead - at the cost of every process you start being able to read it.

## Paths

| | Default | Override |
|---|---|---|
| Store | `~/.config/mise/secrets.json` | `SECRETS_FILE` |
| Key | `~/.config/mise/age.txt` | `SOPS_AGE_KEY_FILE` |

The store is safe to commit. The key is not, and `init` refuses to create one
inside a git repo.
