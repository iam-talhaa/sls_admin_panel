const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Helper to verify caller is present in the `admins` Firestore collection
 */
async function verifyAdminCaller(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'The function must be called by an authenticated user.'
    );
  }

  const callerUid = context.auth.uid;
  const adminDoc = await admin.firestore().collection('admins').doc(callerUid).get();

  if (!adminDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Caller is not an administrator in the admins collection.'
    );
  }

  return adminDoc.data();
}

/**
 * listUsers: Fetches paginated Firebase Auth users
 */
exports.listUsers = functions.https.onCall(async (data, context) => {
  await verifyAdminCaller(context);

  try {
    const maxResults = (data && data.maxResults) || 100;
    const pageToken = data && data.pageToken;

    const listUsersResult = await admin.auth().listUsers(maxResults, pageToken);

    const users = listUsersResult.users.map((userRecord) => ({
      uid: userRecord.uid,
      email: userRecord.email || '',
      displayName: userRecord.displayName || '',
      photoUrl: userRecord.photoURL || '',
      phoneNumber: userRecord.phoneNumber || '',
      disabled: userRecord.disabled || false,
      createdAt: userRecord.metadata.creationTime
        ? new Date(userRecord.metadata.creationTime).getTime()
        : null,
      lastSignInAt: userRecord.metadata.lastSignInTime
        ? new Date(userRecord.metadata.lastSignInTime).getTime()
        : null,
    }));

    return {
      users,
      pageToken: listUsersResult.pageToken || null,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      'Failed to list Firebase Auth users: ' + error.message
    );
  }
});

/**
 * setUserDisabled: Enables or disables a user account in Firebase Auth
 */
exports.setUserDisabled = functions.https.onCall(async (data, context) => {
  await verifyAdminCaller(context);

  const { uid, disabled } = data || {};

  if (!uid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The "uid" argument is required.'
    );
  }

  try {
    await admin.auth().updateUser(uid, {
      disabled: Boolean(disabled),
    });

    return { success: true, uid, disabled };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      'Failed to update user status: ' + error.message
    );
  }
});
