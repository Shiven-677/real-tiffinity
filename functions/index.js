const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Sends a push notification when a new notification doc is created in Firestore
exports.sendNewOrderNotification = functions.firestore
  .document("notifications/{notifId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data.fcmToken) return null;

    const payload = {
      notification: {
        title: data.title || "🛎 New Order!",
        body: data.body || "New order placed.",
      },
      data: {
        orderId: data.orderId || "",
        type: data.type || "",
      },
    };

    try {
      await admin.messaging().sendToDevice(data.fcmToken, payload);
      await snap.ref.update({ sent: true });
    } catch (e) {
      console.error("FCM send error:", e);
    }

    return null;
  });
