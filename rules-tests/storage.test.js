import { readFileSync } from 'node:fs';
import { after, afterEach, before, describe, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
import { deleteObject, getMetadata, ref, uploadBytes } from 'firebase/storage';

const jpeg = new Uint8Array([0xff, 0xd8, 0xff, 0xe0]);
const asJpeg = { contentType: 'image/jpeg' };

let testEnv;

function storage(uid) {
  return uid ? testEnv.authenticatedContext(uid).storage() : testEnv.unauthenticatedContext().storage();
}

function upload(uid, path, metadata = asJpeg) {
  return uploadBytes(ref(storage(uid), path), jpeg, metadata);
}

async function seedFile(path) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), path), jpeg, asJpeg);
  });
}

async function seedRace(createdBy) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'races/race-1'), {
      id: 'race-1',
      name: 'Taipei Marathon',
      place: { countryCode: 'TW', city: 'Taipei City' },
      editionCount: 0,
      createdBy,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  });
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-medal-wall',
    firestore: { rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8') },
    storage: { rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8') },
  });
});

afterEach(async () => {
  await testEnv.clearStorage();
  await testEnv.clearFirestore();
});

after(() => testEnv.cleanup());

describe("a user's own files", () => {
  const paths = [
    'users/alice/avatar/3F2A.jpg',
    'users/alice/avatar/profile.jpg',
    'users/alice/medals/medal-1/cover/3F2A.jpg',
    'users/alice/medals/medal-1/eventPhotos/photo-1.jpg',
    'users/alice/medals/medal-1/medal.jpg',
  ];

  test('the owner can upload, read and delete them', async () => {
    for (const path of paths) {
      await assertSucceeds(upload('alice', path));
      await assertSucceeds(getMetadata(ref(storage('alice'), path)));
      await assertSucceeds(deleteObject(ref(storage('alice'), path)));
    }
  });

  test('another user cannot upload, read or delete them', async () => {
    for (const path of paths) {
      await seedFile(path);
      await assertFails(upload('bob', path));
      await assertFails(getMetadata(ref(storage('bob'), path)));
      await assertFails(deleteObject(ref(storage('bob'), path)));
    }
  });

  test('a signed-out request cannot read them', async () => {
    await seedFile(paths[0]);
    await assertFails(getMetadata(ref(storage(null), paths[0])));
  });

  test('only JPEG uploads are accepted', async () => {
    await assertFails(upload('alice', paths[0], { contentType: 'image/png' }));
  });

  test('nothing else under the user is writable', async () => {
    await assertFails(upload('alice', 'users/alice/other/file.jpg'));
  });
});

describe('race and edition logos', () => {
  const paths = [
    'races/race-1/raceLogo/3F2A.jpg',
    'races/race-1/logo.jpg',
    'races/race-1/editions/edition-1/editionLogo/3F2A.jpg',
    'races/race-1/editions/edition-1/logo.jpg',
  ];

  test('any signed-in user can upload a logo before its race exists', async () => {
    await assertSucceeds(upload('bob', paths[0]));
  });

  test("the race's creator can upload, read and delete its logos", async () => {
    await seedRace('alice');
    for (const path of paths) {
      await assertSucceeds(upload('alice', path));
      await assertSucceeds(getMetadata(ref(storage('alice'), path)));
      await assertSucceeds(deleteObject(ref(storage('alice'), path)));
    }
  });

  test("another user can read the race's logos but not upload or delete them", async () => {
    await seedRace('alice');
    for (const path of paths) {
      await seedFile(path);
      await assertSucceeds(getMetadata(ref(storage('bob'), path)));
      await assertFails(upload('bob', path));
      await assertFails(deleteObject(ref(storage('bob'), path)));
    }
  });

  test("a deleted race's logos can still be deleted", async () => {
    await seedFile(paths[0]);
    await assertSucceeds(deleteObject(ref(storage('alice'), paths[0])));
  });

  test('a signed-out request cannot read a logo', async () => {
    await seedRace('alice');
    await seedFile(paths[0]);
    await assertFails(getMetadata(ref(storage(null), paths[0])));
  });

  test('only JPEG logos are accepted', async () => {
    await seedRace('alice');
    await assertFails(upload('alice', paths[0], { contentType: 'image/heic' }));
  });

  test('nothing else under a race is writable, whether or not the race exists', async () => {
    const otherPaths = [
      'races/race-1/other.jpg',
      'races/race-1/raceLogo/nested/3F2A.jpg',
      'races/race-1/editions/edition-1/other.jpg',
      'races/race-1/editions/edition-1/editionLogo/nested/3F2A.jpg',
    ];
    for (const path of otherPaths) {
      await assertFails(upload('bob', path));
    }
    await seedRace('alice');
    for (const path of otherPaths) {
      await assertFails(upload('alice', path));
    }
  });
});

describe('anything else', () => {
  test('a path the app never uses is refused', async () => {
    await assertFails(upload('alice', 'public/file.jpg'));
  });
});
