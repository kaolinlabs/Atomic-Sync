---
name: atomic-sync
description: Atomic state synchronization with governance auditing and conflict resolution. Use when you need to save or update project state files atomically, ensuring governance rules are met, or when resolving synchronization conflicts across agents or tools.
---

# Atomic-Sync

Use this skill to save or update project state files atomically and audit governance.

## Usage

To use this skill, execute the provided scripts:

- `scripts/atomic_sync.ps1`: Use this for atomic state synchronization. Provide a JSON string containing 'status', 'agent', and (if overwriting) 'conflict_ack: true'.
- `scripts/audit_logic.py`: Use this for governance auditing and logic validation.

**Action**: COMMIT
**Data**: A JSON string containing 'status', 'agent', and (if overwriting) 'conflict_ack: true'.
