// Import the Firebase SDK for Google Cloud Functions.
const functions = require('firebase-functions');
// Import and initialize the Firebase Admin SDK.
const admin = require('firebase-admin');
const { user } = require('firebase-functions/v1/auth');
admin.initializeApp(); // TODO: might need to add serviceAccount.json

// Sends a notifications to all users when a new message is posted.
exports.sendNotifications = functions.https.onRequest((req, res) => {
    // Notification details.
    const payload = {
        token: req.body.token,
        notification: {
            title: req.body.title,
            body: req.body.message
        },
        data: {
            body: req.body.message
        }
    };

    admin.messaging().send(payload).then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
        res.status(200).send(response);
    }).catch((error) => req.status(error.code).send(error));
});

// Cleans up the tokens that are no longer valid.
function cleanupTokens(response, tokens) {
    // For each notification we check if there was an error.
    const tokensDelete = [];
    response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
            functions.logger.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens that are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                const deleteTask = admin.firestore().collection('fcmTokens').doc(tokens[index]).delete();
                tokensDelete.push(deleteTask);
            }
        }
    });
    return Promise.all(tokensDelete);
}



// // Import the Firebase SDK for Google Cloud Functions.
// const functions = require('firebase-functions');
// // Import and initialize the Firebase Admin SDK.
// const admin = require('firebase-admin');
// const { user } = require('firebase-functions/v1/auth');
// admin.initializeApp();

// // // Create and Deploy Your First Cloud Functions
// // // https://firebase.google.com/docs/functions/write-firebase-functions
// //
// // exports.helloWorld = functions.https.onRequest((request, response) => {
// //   functions.logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

// // Sends a notifications to all users when a new message is posted.
// exports.sendNotifications = functions.firestore.document('rooms/{roomId}/messages/{messageId}').onCreate(
//     async(snapshot) => {
//         // Notification details.
//         const text = snapshot.data().text;
//         const payload = {
//             notification: {
//                 title: `${snapshot.data().name} posted ${text ? 'a message' : 'an image'}`,
//                 body: text ? (text.length <= 100 ? text : text.substring(0, 97) + '...') : '',
//                 // icon: snapshot.data().profilePicUrl || '/images/profile_placeholder.png',
//                 // click_action: `https://${process.env.GCLOUD_PROJECT}.firebaseapp.com`,
//             }
//         };
//         var conversationUsers;
//         await admin.firestore.collection('rooms').doc('{ roomId }').get().then(queryResult => {
//             conversationUsers = queryResult.data().userIds;
//         });
//         var usersToSend = [];
//         conversationUsers.forEach((userId) => {
//             if (userId != snapshot.data().authorId)
//                 usersToSend.push(userId);
//         });

//         // Get the list of device tokens.
//         var allTokens = [];
//         usersToSend.forEach((userId) => {
//             admin.firestore.collection('users').doc(userId).get().then(queryResult => {
//                 var map = {};
//                 map = queryResult.data().metadata;
//                 allTokens.push(map['fcmToken'])
//             })
//         });

//         if (tokens.length > 0) {
//             // Send notifications to all tokens.
//             const response = await admin.messaging().sendToDevice(tokens, payload);
//             await cleanupTokens(response, tokens);
//             functions.logger.log('Notifications have been sent and tokens cleaned up.');
//         }
//     });

// // Cleans up the tokens that are no longer valid.
// function cleanupTokens(response, tokens) {
//     // For each notification we check if there was an error.
//     const tokensDelete = [];
//     response.results.forEach((result, index) => {
//         const error = result.error;
//         if (error) {
//             functions.logger.error('Failure sending notification to', tokens[index], error);
//             // Cleanup the tokens that are not registered anymore.
//             if (error.code === 'messaging/invalid-registration-token' ||
//                 error.code === 'messaging/registration-token-not-registered') {
//                 const deleteTask = admin.firestore().collection('fcmTokens').doc(tokens[index]).delete();
//                 tokensDelete.push(deleteTask);
//             }
//         }
//     });
//     return Promise.all(tokensDelete);
// }