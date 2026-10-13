## 1. Trim entered text (TDD, done before this change was written)

- [x] 1.1 Medal name, bib number and note saved trimmed; blank note saved as none (9025209, c797641)
- [x] 1.2 Medal name, bib number, tags and `isFormValid` also drop line breaks; tag add button matches `addTag` (ed48388, 6215a8a)
- [x] 1.3 Race name and website saved trimmed; blank website saved as none; `isFormValid` drops line breaks (614f0a1, 6215a8a)
- [x] 1.4 `Place.isValid` treats a country code or city of only line breaks as blank (6215a8a)

## 2. Bound Storage calls (TDD, done before this change was written)

- [x] 2.1 An upload whose link cannot be fetched gets a delete attempt, through `StorageService.storeThenFetchURL` (811d252, 6215a8a)
- [x] 2.2 `maxOperationRetryTime` capped at 30 seconds beside `maxUploadRetryTime` (6215a8a)

## 3. Verify

- [x] 3.1 Full test suite passes with no new SwiftLint warnings
