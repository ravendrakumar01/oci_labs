#!/usr/bin/env python3
"""Write each Terraform-generated private key to ~/.ssh/<vm-name>.
Usage: python3 save_keys.py <keys.json>
where keys.json = output of `terraform output -json instance_private_keys`."""
import json
import os
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "keys.json"
try:
    data = json.load(open(path))
except Exception:
    data = {}

ssh_dir = os.path.expanduser("~/.ssh")
os.makedirs(ssh_dir, exist_ok=True)

if not data:
    print("No private keys found — nothing to save.")
    sys.exit(0)

for name, key in data.items():
    dest = os.path.join(ssh_dir, name)
    with open(dest, "w", newline="\n") as f:
        f.write(key if key.endswith("\n") else key + "\n")
    os.chmod(dest, 0o600)
    print("Saved:", dest)
