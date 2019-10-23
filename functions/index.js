const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
    .document('messages/{groupId1}/{groupId2}/{message}')
    .onCreate((snap, context) => {
        console.log('sending message...')

        const doc = snap.data()

        const idFrom = doc.from
        const idTo = doc.to
        const contentMessage = doc.content

        admin
            .firestore()
            .doc(`users/${idTo}/info/public`)
            .get()
            .then(querySnapshot => {
                const userToData = querySnapshot.data()
                if (!userToData.pushToken) {
                    console.log('Cannot find pushToken target user')
                    return null
                }

                admin
                    .firestore()
                    .doc(`users/${idFrom}/info/public`)
                    .get()
                    .then(querySnapshot2 => {
                        const userFromData = querySnapshot2.data()
                        const payload = {
                            notification: {
                                title: `Message from ${userFromData.username}`,
                                body: contentMessage,
                                badge: '1',
                                sound: 'default'
                            }
                        }
                        admin.messaging().sendToDevice(userToData.pushToken, payload)
                            .then(response => { console.log('Successfully sent message:', response) })
                            .catch(error => { console.log('Error sending message:', error) })

                    })
            })
        return null
    })