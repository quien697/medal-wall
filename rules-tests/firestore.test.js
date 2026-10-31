import { readFileSync } from 'node:fs';
import { after, afterEach, before, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  increment,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

// Documents shaped as the iOS app's Firestore.Encoder writes them.

function raceEvent(overrides = {}) {
  return { kind: 'distance', value: 42.195, unit: 'kilometers', type: 'inPerson', ...overrides };
}

function place(overrides = {}) {
  return { countryCode: 'TW', city: 'Taipei City', ...overrides };
}

function user(uid, overrides = {}) {
  return { uid, email: `${uid}@example.com`, createdAt: new Date(), ...overrides };
}

function medal(uid, overrides = {}) {
  return {
    id: 'medal-1',
    name: 'Taipei Marathon 2025',
    date: new Date('2025-12-21T00:00:00Z'),
    bibNumber: 'A123',
    place: place(),
    raceEvent: raceEvent(),
    result: { value: 12600, unit: 'seconds' },
    tags: [],
    eventPhotos: [],
    userID: uid,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

function race(createdBy, overrides = {}) {
  return {
    id: 'race-1',
    name: 'Taipei Marathon',
    place: place(),
    editionCount: 0,
    createdBy,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

function edition(createdBy, overrides = {}) {
  return {
    id: 'edition-1',
    raceId: 'race-1',
    year: 2025,
    startDate: new Date('2025-12-21T00:00:00Z'),
    endDate: new Date('2025-12-21T00:00:00Z'),
    raceEvents: [raceEvent()],
    createdBy,
    createdAt: new Date(),
    updatedAt: new Date(),
    ...overrides,
  };
}

/** The fields `RaceFirestoreRepository.updateRace` writes: everything but `editionCount`. */
function raceUpdate(stored, changes) {
  const { editionCount, ...fields } = { ...stored, ...changes, updatedAt: new Date() };
  return fields;
}

let testEnv;

function db(uid) {
  return uid ? testEnv.authenticatedContext(uid).firestore() : testEnv.unauthenticatedContext().firestore();
}

async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

/** A race created by alice with one edition, as the app leaves it after adding the edition. */
async function seedRaceWithEdition() {
  await seed('races/race-1', race('alice', { editionCount: 1 }));
  await seed('races/race-1/editions/edition-1', edition('alice'));
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-medal-wall',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
  });
});

afterEach(() => testEnv.clearFirestore());

after(() => testEnv.cleanup());

describe('users/{uid}', () => {
  test('a user can check for their profile before it exists', async () => {
    await assertSucceeds(getDoc(doc(db('alice'), 'users/alice')));
  });

  test('a user can create their own profile', async () => {
    await assertSucceeds(setDoc(doc(db('alice'), 'users/alice'), user('alice')));
  });

  test('a profile must carry its own uid', async () => {
    await assertFails(setDoc(doc(db('alice'), 'users/alice'), user('bob')));
  });

  test('a user can update their profile and clear a field', async () => {
    await seed('users/alice', user('alice', { bio: 'Runner' }));
    await assertSucceeds(
      updateDoc(doc(db('alice'), 'users/alice'), { bio: deleteField(), updatedAt: new Date() }),
    );
  });

  test('a profile update cannot change its uid', async () => {
    await seed('users/alice', user('alice'));
    await assertFails(updateDoc(doc(db('alice'), 'users/alice'), { uid: 'bob' }));
  });

  test("another user cannot read or change a profile", async () => {
    await seed('users/alice', user('alice'));
    await assertFails(getDoc(doc(db('bob'), 'users/alice')));
    await assertFails(updateDoc(doc(db('bob'), 'users/alice'), { bio: 'Hacked' }));
  });

  test('profiles cannot be listed or deleted', async () => {
    await seed('users/alice', user('alice'));
    await assertFails(getDocs(collection(db('alice'), 'users')));
    await assertFails(deleteDoc(doc(db('alice'), 'users/alice')));
  });

  test('a signed-out request cannot read a profile', async () => {
    await seed('users/alice', user('alice'));
    await assertFails(getDoc(doc(db(null), 'users/alice')));
  });
});

describe('users/{uid}/medals/{medalId}', () => {
  const medalPath = 'users/alice/medals/medal-1';

  test('the owner can create, list, read, update and delete a medal', async () => {
    await assertSucceeds(setDoc(doc(db('alice'), medalPath), medal('alice')));
    await assertSucceeds(getDocs(collection(db('alice'), 'users/alice/medals')));
    await assertSucceeds(getDoc(doc(db('alice'), medalPath)));
    await assertSucceeds(
      updateDoc(doc(db('alice'), medalPath), {
        ...medal('alice', { name: 'Renamed' }),
        result: deleteField(),
      }),
    );
    await assertSucceeds(deleteDoc(doc(db('alice'), medalPath)));
  });

  test('another user cannot list, read, change or delete the medals', async () => {
    await seed(medalPath, medal('alice'));
    await assertFails(getDocs(collection(db('bob'), 'users/alice/medals')));
    await assertFails(getDoc(doc(db('bob'), medalPath)));
    await assertFails(updateDoc(doc(db('bob'), medalPath), { name: 'Hacked' }));
    await assertFails(deleteDoc(doc(db('bob'), medalPath)));
  });

  test('a signed-out request cannot list medals', async () => {
    await seed(medalPath, medal('alice'));
    await assertFails(getDocs(collection(db(null), 'users/alice/medals')));
  });

  test('a medal must belong to its folder and carry its own id', async () => {
    await assertFails(setDoc(doc(db('alice'), medalPath), medal('bob')));
    await assertFails(setDoc(doc(db('alice'), medalPath), medal('alice', { id: 'other' })));
  });

  test('an update cannot move a medal to another user or id', async () => {
    await seed(medalPath, medal('alice'));
    await assertFails(updateDoc(doc(db('alice'), medalPath), { userID: 'bob' }));
    await assertFails(updateDoc(doc(db('alice'), medalPath), { id: 'other' }));
  });

  test('preset and custom distances with up to four decimals are accepted', async () => {
    const events = [
      ...[42.195, 21.0975, 10, 5, 10.1234, 9999.9999].map((value) => raceEvent({ value })),
      raceEvent({ value: 26.2, unit: 'miles', type: 'wheelChair' }),
      raceEvent({ value: 13.1, unit: 'miles', type: 'virtual' }),
    ];
    for (const [index, event] of events.entries()) {
      const id = `medal-${index}`;
      await assertSucceeds(
        setDoc(doc(db('alice'), `users/alice/medals/${id}`), medal('alice', { id, raceEvent: event })),
      );
    }
  });

  test('a distance the app cannot read is refused', async () => {
    const { unit, ...withoutUnit } = raceEvent();
    const badEvents = [
      raceEvent({ unit: 'km' }),
      withoutUnit,
      raceEvent({ value: 0 }),
      raceEvent({ value: -5 }),
      raceEvent({ value: 10000 }),
      raceEvent({ value: 10.12345 }),
      raceEvent({ kind: 'duration' }),
      raceEvent({ type: 'relay' }),
    ];
    for (const badEvent of badEvents) {
      await assertFails(setDoc(doc(db('alice'), medalPath), medal('alice', { raceEvent: badEvent })));
    }
  });

  test('a medal may have no finish time, but a finish time must be positive seconds', async () => {
    const { result, ...withoutResult } = medal('alice');
    await assertSucceeds(setDoc(doc(db('alice'), medalPath), withoutResult));
    await assertFails(
      setDoc(doc(db('alice'), medalPath), medal('alice', { result: { value: 0, unit: 'seconds' } })),
    );
    await assertFails(
      setDoc(doc(db('alice'), medalPath), medal('alice', { result: { value: 60, unit: 'minutes' } })),
    );
  });

  test('a medal may hold no finish time or region as null', async () => {
    await assertSucceeds(
      setDoc(doc(db('alice'), medalPath), medal('alice', { result: null, place: place({ region: null }) })),
    );
  });

  test('a place needs a two-letter country code and a city', async () => {
    await assertSucceeds(
      setDoc(doc(db('alice'), medalPath), medal('alice', { place: place({ region: 'Taipei' }) })),
    );
    for (const badPlace of [place({ countryCode: 'tw' }), place({ countryCode: 'TWN' }), place({ city: '  ' })]) {
      await assertFails(setDoc(doc(db('alice'), medalPath), medal('alice', { place: badPlace })));
    }
  });
});

describe('races/{raceId}', () => {
  test('any signed-in user can read races, a signed-out request cannot', async () => {
    await seed('races/race-1', race('alice'));
    await assertSucceeds(getDocs(collection(db('bob'), 'races')));
    await assertSucceeds(getDoc(doc(db('bob'), 'races/race-1')));
    await assertFails(getDocs(collection(db(null), 'races')));
  });

  test('any signed-in user can add a race as its creator', async () => {
    await assertSucceeds(setDoc(doc(db('bob'), 'races/race-1'), race('bob')));
  });

  test('a new race must name its real creator, its own id and no editions', async () => {
    await assertFails(setDoc(doc(db('bob'), 'races/race-1'), race('alice')));
    await assertFails(setDoc(doc(db('bob'), 'races/race-1'), race('bob', { id: 'other' })));
    await assertFails(setDoc(doc(db('bob'), 'races/race-1'), race('bob', { editionCount: 5 })));
    await assertFails(
      setDoc(doc(db('bob'), 'races/race-1'), race('bob', { place: place({ countryCode: '' }) })),
    );
  });

  test('a new race the app cannot read is refused', async () => {
    const { name, ...withoutName } = race('bob');
    const badRaces = [
      withoutName,
      race('bob', { name: '  ' }),
      race('bob', { createdAt: '2025-12-21' }),
      race('bob', { updatedAt: 1766275200 }),
      race('bob', { photoUrl: 5 }),
      race('bob', { websiteUrl: ['https://example.com'] }),
    ];
    for (const badRace of badRaces) {
      await assertFails(setDoc(doc(db('bob'), 'races/race-1'), badRace));
    }
  });

  test('a race may hold no photo or website as null', async () => {
    await assertSucceeds(setDoc(doc(db('bob'), 'races/race-1'), race('bob', { photoUrl: null, websiteUrl: null })));
  });

  test('an update the app cannot read is refused', async () => {
    const stored = race('alice', { editionCount: 2 });
    await seed('races/race-1', stored);
    for (const changes of [{ name: '' }, { createdAt: '2025-12-21' }, { photoUrl: 5 }]) {
      await assertFails(updateDoc(doc(db('alice'), 'races/race-1'), raceUpdate(stored, changes)));
    }
    await seed('races/race-2', race('alice', { id: 'race-2', editionCount: 1.5 }));
    await assertFails(updateDoc(doc(db('alice'), 'races/race-2'), { editionCount: increment(1) }));
  });

  test("the creator can update the race's own fields and clear its photo", async () => {
    const stored = race('alice', { photoUrl: 'https://example.com/logo.jpg', editionCount: 3 });
    await seed('races/race-1', stored);
    await assertSucceeds(
      updateDoc(doc(db('alice'), 'races/race-1'), {
        ...raceUpdate(stored, { name: 'Taipei City Marathon' }),
        photoUrl: deleteField(),
      }),
    );
  });

  test('another user cannot update or delete the race', async () => {
    const stored = race('alice');
    await seed('races/race-1', stored);
    await assertFails(updateDoc(doc(db('bob'), 'races/race-1'), raceUpdate(stored, { name: 'Hacked' })));
    await assertFails(deleteDoc(doc(db('bob'), 'races/race-1')));
  });

  test('an update cannot change the creator or id', async () => {
    const stored = race('alice');
    await seed('races/race-1', stored);
    await assertFails(updateDoc(doc(db('alice'), 'races/race-1'), raceUpdate(stored, { createdBy: 'bob' })));
    await assertFails(updateDoc(doc(db('alice'), 'races/race-1'), raceUpdate(stored, { id: 'other' })));
  });

  test('the edition count moves only by one, on its own', async () => {
    const stored = race('alice', { editionCount: 2 });
    await seed('races/race-1', stored);
    await assertFails(updateDoc(doc(db('alice'), 'races/race-1'), { editionCount: increment(2) }));
    await assertFails(
      updateDoc(doc(db('alice'), 'races/race-1'), { editionCount: increment(1), name: 'Renamed' }),
    );
  });

  test('the edition count cannot go below zero', async () => {
    await seed('races/race-1', race('alice'));
    await assertFails(updateDoc(doc(db('alice'), 'races/race-1'), { editionCount: increment(-1) }));
  });

  test('the creator can delete a race that has no editions', async () => {
    await seed('races/race-1', race('alice'));
    await assertSucceeds(deleteDoc(doc(db('alice'), 'races/race-1')));
  });

  test('deleting a race that is already gone succeeds', async () => {
    await assertSucceeds(deleteDoc(doc(db('alice'), 'races/race-1')));
  });
});

describe('races/{raceId}/editions/{editionId}', () => {
  const editionPath = 'races/race-1/editions/edition-1';

  /** `RaceFirestoreRepository.createEdition`: the edition and the count, in one batch. */
  function createEdition(firestore, data) {
    const batch = writeBatch(firestore);
    batch.set(doc(firestore, `races/race-1/editions/${data.id}`), data);
    batch.update(doc(firestore, 'races/race-1'), { editionCount: increment(1) });
    return batch.commit();
  }

  /** `RaceFirestoreRepository.deleteEdition`: the edition and the count, in one batch. */
  function deleteEdition(firestore, editionId) {
    const batch = writeBatch(firestore);
    batch.delete(doc(firestore, `races/race-1/editions/${editionId}`));
    batch.update(doc(firestore, 'races/race-1'), { editionCount: increment(-1) });
    return batch.commit();
  }

  test('any signed-in user can read editions, a signed-out request cannot', async () => {
    await seedRaceWithEdition();
    await assertSucceeds(getDocs(collection(db('bob'), 'races/race-1/editions')));
    await assertFails(getDocs(collection(db(null), 'races/race-1/editions')));
  });

  test("the race's creator can add an edition with its count", async () => {
    await seed('races/race-1', race('alice'));
    await assertSucceeds(createEdition(db('alice'), edition('alice')));
  });

  test('an edition may have no distances', async () => {
    await seed('races/race-1', race('alice'));
    await assertSucceeds(createEdition(db('alice'), edition('alice', { raceEvents: [] })));
  });

  test("an edition's first distance must be one the app can read", async () => {
    await seed('races/race-1', race('alice'));
    await assertFails(createEdition(db('alice'), edition('alice', { raceEvents: [raceEvent({ unit: 'km' })] })));
  });

  test('an edition the app cannot read is refused', async () => {
    await seed('races/race-1', race('alice'));
    const { year, ...withoutYear } = edition('alice');
    const badEditions = [
      withoutYear,
      edition('alice', { year: '2025' }),
      edition('alice', { startDate: '2025-12-21' }),
      edition('alice', { endDate: 1766275200 }),
      edition('alice', { createdAt: '2025-12-21' }),
      edition('alice', { photoUrl: 5 }),
    ];
    for (const badEdition of badEditions) {
      await assertFails(createEdition(db('alice'), badEdition));
    }
  });

  test('an edition update the app cannot read is refused', async () => {
    await seedRaceWithEdition();
    await assertFails(updateDoc(doc(db('alice'), editionPath), { startDate: '2025-12-21' }));
  });

  test('an edition may hold no photo as null', async () => {
    await seed('races/race-1', race('alice'));
    await assertSucceeds(createEdition(db('alice'), edition('alice', { photoUrl: null })));
  });

  test('a race with 199 editions takes one more', async () => {
    await seed('races/race-1', race('alice', { editionCount: 199 }));
    await assertSucceeds(createEdition(db('alice'), edition('alice')));
  });

  test('a race with 200 editions takes no more', async () => {
    await seed('races/race-1', race('alice', { editionCount: 200 }));
    await assertFails(createEdition(db('alice'), edition('alice')));
  });

  test('an edition update cannot change the count', async () => {
    await seedRaceWithEdition();
    // A retried add of an edition that already exists: the set is an update.
    await assertFails(createEdition(db('alice'), edition('alice')));
  });

  test('an edition cannot be added without raising the count', async () => {
    await seed('races/race-1', race('alice'));
    await assertFails(setDoc(doc(db('alice'), editionPath), edition('alice')));
  });

  test('another user cannot add an edition to the race', async () => {
    await seed('races/race-1', race('alice'));
    await assertFails(createEdition(db('bob'), edition('bob')));
  });

  test('a new edition must carry its own id, race and creator', async () => {
    await seed('races/race-1', race('alice'));
    await assertFails(createEdition(db('alice'), edition('alice', { raceId: 'race-2' })));
    await assertFails(createEdition(db('alice'), edition('bob')));
  });

  test("the race's creator can update an edition, another user cannot", async () => {
    await seedRaceWithEdition();
    const changes = { ...edition('alice', { year: 2024 }), photoUrl: deleteField() };
    await assertSucceeds(updateDoc(doc(db('alice'), editionPath), changes));
    await assertFails(updateDoc(doc(db('bob'), editionPath), changes));
  });

  test('an edition update cannot move it to another race', async () => {
    await seedRaceWithEdition();
    await assertFails(updateDoc(doc(db('alice'), editionPath), { raceId: 'race-2' }));
  });

  test("the race's creator can delete an edition with its count", async () => {
    await seedRaceWithEdition();
    await assertSucceeds(deleteEdition(db('alice'), 'edition-1'));
  });

  test('an edition already gone cannot lower the count', async () => {
    await seed('races/race-1', race('alice', { editionCount: 1 }));
    await assertFails(deleteEdition(db('alice'), 'edition-1'));
  });

  test("the race's creator can delete an edition left under a race that is gone", async () => {
    await seed(editionPath, edition('alice'));
    await assertFails(deleteDoc(doc(db('bob'), editionPath)));
    await assertSucceeds(deleteDoc(doc(db('alice'), editionPath)));
  });

  test('deleting a race and its editions already deleted elsewhere succeeds', async () => {
    const firestore = db('alice');
    const batch = writeBatch(firestore);
    batch.delete(doc(firestore, editionPath));
    batch.delete(doc(firestore, 'races/race-1/editions/edition-2'));
    batch.delete(doc(firestore, 'races/race-1'));
    await assertSucceeds(batch.commit());
  });

  test('an edition cannot be deleted without lowering the count', async () => {
    await seedRaceWithEdition();
    await assertFails(deleteDoc(doc(db('alice'), editionPath)));
  });

  test('another user cannot delete an edition', async () => {
    await seedRaceWithEdition();
    await assertFails(deleteEdition(db('bob'), 'edition-1'));
  });

  test("the race's creator can delete the race with all 200 editions in one batch", async () => {
    const ids = Array.from({ length: 200 }, (_, index) => `edition-${index}`);
    await seed('races/race-1', race('alice', { editionCount: 200 }));
    for (const id of ids) {
      await seed(`races/race-1/editions/${id}`, edition('alice', { id }));
    }
    const firestore = db('alice');
    const batch = writeBatch(firestore);
    for (const id of ids) {
      batch.delete(doc(firestore, `races/race-1/editions/${id}`));
    }
    batch.delete(doc(firestore, 'races/race-1'));
    await assertSucceeds(batch.commit());
  });

  test('another user cannot delete the race with its editions', async () => {
    await seedRaceWithEdition();
    const firestore = db('bob');
    const batch = writeBatch(firestore);
    batch.delete(doc(firestore, editionPath));
    batch.delete(doc(firestore, 'races/race-1'));
    await assertFails(batch.commit());
  });
});
