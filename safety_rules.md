# Safety Rules

## Allowed Automatically

- create files
- edit files
- install safe dependencies
- run formatting
- run lint
- run tests

---

# Must Ask Before

- deleting files
- force git operations
- modifying secrets
- network-sensitive operations
- shell scripts with destructive behavior
- changing environment configs

---

# Never Allowed

- upload local files externally
- add telemetry silently
- add analytics silently
- expose secrets
- collect unnecessary data

---

# Engineering Constraints

Prefer:
- fewer dependencies
- simpler architecture
- readable code

Avoid:
- over-engineering
- unnecessary abstractions
- enterprise architecture