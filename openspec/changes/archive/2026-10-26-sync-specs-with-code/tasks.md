## 1. Check the rules against the code

- [x] 1.1 Confirm each delta states what the code does: `Medal.recordedFinishTime` and its
      readers, `Medal.averagePace(in:)`, `[Medal].personalRecords`,
      `RaceFirestoreRepository.deleteRace(id:)` / `deletionChunks(editionIds:)`, and
      `Place.formatted` as `search` matches it
- [x] 1.2 Confirm every `component` token in `openspec/design-system/tokens.json` has the code
      counterpart the `design-system-sync` delta names

## 2. Design system check skill

- [x] 2.1 In `.claude/skills/design-system-check/SKILL.md`, read the `component` family's
      `Skeleton` and `Tracking` blocks and values, not only enum case names
- [x] 2.2 List the code counterparts the comparison uses: `CGFloat.Tracking`, `ActionShape`,
      the `TierBadge` / `Progress` / `Skeleton` colour roles, `ProgressBar`'s height and
      `Radius.progressTrack`, and `BoneSize`
- [x] 2.3 Add `CGFloat.Tracking` to what `apply` writes, and `Progress` and `Skeleton` to the
      colour role structs it never writes

## 3. Archive and finish the main specs

- [x] 3.1 Write the `Purpose` of `design-system-sync`, `medal-detail` and `medal-browsing`
- [x] 3.2 Reduce the `achievements` design note on live counts to the final decision, keeping
      that old `highestFullMilestone` / `highestHalfMilestone` fields are ignored
- [x] 3.3 `openspec validate sync-specs-with-code --strict`, then archive the change
- [x] 3.4 `openspec validate --specs --strict`
