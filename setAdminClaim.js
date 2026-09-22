// setAdminClaim.js
const { initializeApp, cert, applicationDefault } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const path = require("path");
const fs = require("fs");

const serviceAccountPath = path.join(__dirname, "serviceAccountKey.json");

let app;
if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  app = initializeApp({
    credential: cert(serviceAccount),
  });
} else {
  try {
    app = initializeApp({
      credential: applicationDefault(),
    });
  } catch (err) {
    app = initializeApp();
  }
}

const auth = getAuth(app);
const uid = "QR13LS9XkHTyH2ofeAjoOajHQFj1";

auth
  .setCustomUserClaims(uid, { role: "admin" })
  .then(() => {
    console.log("✅ Success! Admin custom claim { role: 'admin' } has been set for UID:", uid);
    process.exit(0);
  })
  .catch((error) => {
    console.error("❌ Error setting custom claim:", error.message);
    if (!fs.existsSync(serviceAccountPath)) {
      console.log("\n👉 How to fix:");
      console.log("1. Open Firebase Console (https://console.firebase.google.com)");
      console.log("2. Project Settings ⚙️ -> 'Service accounts' tab");
      console.log("3. Click 'Generate new private key'");
      console.log("4. Place the downloaded JSON file into this folder as 'serviceAccountKey.json'");
      console.log("5. Re-run: node setAdminClaim.js\n");
    }
    process.exit(1);
  });
