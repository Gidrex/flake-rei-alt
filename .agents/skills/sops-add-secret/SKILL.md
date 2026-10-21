---
name: sops-add-secret
description: Use when adding, rotating, or wiring a new secret through sops-nix + age in this repo (sops/secrets.yaml, hm-modules/security/sops.nix).
---

# Adding a secret (sops-nix + age)

Declarations: `hm-modules/security/sops.nix` (all 14 lines — read it whole).
Policy: `.sops.yaml` (a single age recipient for `sops/*.yaml`).
Decrypted output lands in `$XDG_CONFIG_HOME/sops/...`; the key lives at
`~/.config/sops/age/keys.txt`.

## Steps

1. Confirm the key exists: `ls ~/.config/sops/age/keys.txt`. No key —
   stop and ask the user (do not silently generate one).
2. Recipient public key from ssh (for `.sops.yaml`, on rotation):
   `ssh-to-age < ~/.ssh/id_ed25519.pub`.
3. Store the value: `sops sops/secrets.yaml` (interactive, encrypts in place).
   Never write a plaintext value into any repo file, and never print decrypted
   content into chat.
4. Declare it in `hm-modules/security/sops.nix`:
   `sops.secrets.<name> = { };` (neighbors for reference: `gdrive_client_id`, `gdrive_token`).
5. Reference `config.sops.secrets.<name>.path` (the decrypted file path) from the
   consumer module instead of baking the value into the config.

## Verification (without exposing values)

- `nix eval --impure ".#homeConfigurations.$FLAKE_MACHINE.config.sops.secrets"` —
  key names only, never values.
- Do NOT do `sops exec-file sops/secrets.yaml 'cat {}'`: never print secrets to
  stdout without need. A zero exit code from
  `sops -d --extract '["<name>"]' sops/secrets.yaml /dev/null` is enough proof
  the key decrypts it.

## Gotchas

- One recipient for all `sops/*.yaml`. A key change means re-encrypting the file
  (`sops rotate` / updatekeys), or old secrets become unreadable.
- The secret name in the yaml and in `sops.nix` must match exactly.
