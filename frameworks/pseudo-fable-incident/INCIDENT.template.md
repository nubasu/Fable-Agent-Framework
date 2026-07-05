## Incident — when production is bleeding

<!-- pseudo-fable-incident v1.1 (2026-07-05) — live incident response + blameless postmortem.
     v1.1: family renamed fable-* → pseudo-fable-*.
     Append this section to the project CLAUDE.md. Add-on module: works with any pseudo-fable
     configuration. Defers diagnosis mechanics to root-cause-debug (pseudo-fable-lift) and
     lesson routing to retro (pseudo-fable-retro) when installed; degrades gracefully without. -->

Incident mode is not debugging under pressure — it is a different discipline with a different objective function: **impact first, cause second**. It starts when production is impacted NOW (users, data, money, or security — actual or imminent); everything else is a normal bug and goes through the normal loop.

### Non-negotiables of incident response

1. **Mitigate before diagnose.** Stop the bleeding (rollback / flag off / failover / scale), then find the knife. Root-causing while users bleed is negligence — the only exception is when mitigation itself requires the diagnosis, and then you say so explicitly.
2. **Production state is evidence.** Capture before you change: logs, metric snapshots, process state. Restarts, cache clears, and data changes destroy the crime scene — take the photo first.
3. **Reversible or approved.** Every production action is reversible, or explicitly approved by the user first. One change at a time; observe; record. Simultaneous changes make it impossible to know what helped.
4. **Timeline from minute one.** Every action and observation gets a timestamped line in the incident file. Mid-incident memory is unreliable, "did we already try X?" must be answerable, and the postmortem depends on it.
5. **Resolved means observed-healthy.** Declare resolution only when the specific symptom is demonstrably gone AND metrics hold through a monitoring window — "looks better" is not resolved. The incident is not closed until the postmortem exists.

### Hard triggers

| Situation | Invoke |
|---|---|
| Production impacted now, or impact imminent | `incident-response` — open the incident file, mitigate first |
| A bug that does NOT impact production right now | Normal loop (`root-cause-debug` if installed). Do not run incidents for non-incidents. |
| Symptom gone + monitoring window passed | `postmortem` — mandatory for real incidents; false alarms get a 3-line note |
| Postmortem written | `retro` (if installed) — route the lessons; action items become tickets |
