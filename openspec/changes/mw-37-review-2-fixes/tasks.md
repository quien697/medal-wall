## 1. Firestore rules

- [x] 1.1 Write failing rules tests: a race missing `name`, with a blank `name`, with a text
      `createdAt`, with a non-string `photoUrl`, or with a non-int `editionCount` is refused on
      create and update; an edition with a text `startDate`, a non-int `year` or a non-string
      `photoUrl` is refused; a null `photoUrl` and `websiteUrl` are accepted
- [x] 1.2 Add `isValidRace` and extend `isValidEdition` (design.md, The rules check what the
      decoders require)
- [x] 1.3 Write a failing test that deleting a race already gone succeeds; allow it
- [x] 1.4 Write a failing test that an edition set committed with a count change is refused;
      add `countChange() == 0` to the edition update rule
- [x] 1.5 Write failing tests that a race at 200 editions refuses another edition and one at
      199 accepts it, and that a race with 200 editions is deleted in one batch; add the limit
      to the edition create rule

## 2. Storage rules

- [x] 2.1 Write failing tests that a path under a race other than the four logo paths is
      refused, whether or not the race exists
- [x] 2.2 Replace `races/{raceId}/{allPaths=**}` with the four logo matches

## 3. Edition limit in Edit Race

- [x] 3.1 Write failing `EditRaceViewModel` tests for `canAddEdition`: 199 editions, 200
      editions, 200 with one staged for deletion, 199 plus one staged addition, and a stored
      count of 200 before the editions load
- [x] 3.2 Add `Race.maxEditionCount` and `EditRaceViewModel.canAddEdition`
- [x] 3.3 `EditRaceEditionSection` takes `canAddEdition`, disables Add and shows the note as
      its footer; add a preview at the limit
- [x] 3.4 Add "A race can have up to %lld editions." with zh-TW to the String Catalog and a
      `StringCatalogTests` case

## 4. One batch for a race's delete

- [x] 4.1 Delete each edition and the race in one batch in `RaceFirestoreRepository.deleteRace`;
      remove `deletionChunks`, `batchLimit` and their tests

## 5. Docs and verify

- [x] 5.1 State `--test-concurrency=1` and why in the archived `mw-37-review-fixes` design, and
      correct its list of count refusals
- [x] 5.2 Run `npm test` in `rules-tests/`, the full iOS test suite and lint
- [x] 5.3 `openspec validate mw-37-review-2-fixes --strict`
- [ ] 5.4 Deploy the rules with `npm run deploy` after `npx firebase login`, then delete a race
      with several editions on a device (the user)
