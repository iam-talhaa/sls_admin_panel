// upload_assets_to_firebase.js
const fs = require('fs');
const path = require('path');
const https = require('https');

const BUCKET = 'swissproject-33b18.firebasestorage.app';
const PROJECT_ID = 'swissproject-33b18';
const ASSETS_DIR = path.join(__dirname, 'assets');

// Content type detection
function getContentType(filename) {
  const ext = path.extname(filename).toLowerCase();
  switch (ext) {
    case '.png': return 'image/png';
    case '.jpg':
    case '.jpeg': return 'image/jpeg';
    case '.webp': return 'image/webp';
    case '.gif': return 'image/gif';
    case '.svg': return 'image/svg+xml';
    default: return 'application/octet-stream';
  }
}

// Upload a single file to Firebase Storage via REST API
function uploadToFirebaseStorage(filePath, storageName) {
  return new Promise((resolve, reject) => {
    const fileBytes = fs.readFileSync(filePath);
    const contentType = getContentType(filePath);
    const encodedName = encodeURIComponent(storageName);
    const url = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o?name=${encodedName}`;

    const parsedUrl = new URL(url);
    const options = {
      hostname: parsedUrl.hostname,
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'POST',
      headers: {
        'Content-Type': contentType,
        'Content-Length': fileBytes.length,
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const json = JSON.parse(data);
            const token = json.downloadTokens || '';
            const publicUrl = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodeURIComponent(json.name)}?alt=media${token ? `&token=${token}` : ''}`;
            resolve({ name: json.name, url: publicUrl, token });
          } catch (e) {
            reject(new Error(`Failed to parse response: ${e.message} - ${data}`));
          }
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(fileBytes);
    req.end();
  });
}

// Update a Firestore document field via REST API
function patchFirestoreDoc(collection, docId, fieldsToUpdate, updateMask) {
  return new Promise((resolve, reject) => {
    const maskParams = updateMask.map(m => `updateMask.fieldPaths=${encodeURIComponent(m)}`).join('&');
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId}?${maskParams}`;

    const parsedUrl = new URL(url);
    const body = JSON.stringify({ fields: fieldsToUpdate });

    const options = {
      hostname: parsedUrl.hostname,
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(data));
        } else {
          reject(new Error(`Firestore PATCH HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

// Get Firestore document via REST API
function getFirestoreDoc(collection, docId) {
  return new Promise((resolve, reject) => {
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId}`;
    const parsedUrl = new URL(url);

    https.get(parsedUrl, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve(JSON.parse(data));
        } else if (res.statusCode === 404) {
          resolve(null);
        } else {
          reject(new Error(`Firestore GET HTTP ${res.statusCode}: ${data}`));
        }
      });
    }).on('error', reject);
  });
}

async function run() {
  console.log('🚀 Starting asset upload to Firebase Storage and Firestore synchronization...');

  const assetFiles = [
    'jet1.png', 'jet2.png', 'jet3.png', 'chopper.png',
    'des1.jpg', 'des2.png', 'des3.png', 'des4.png', 'des5.png', 'des6.png', 'des7.png', 'des8.png', 'des9.webp', 'des10.webp',
    'blog3.png', 'blog4.png', 'blog5.png', 'blog6.png', 'blog7.png', 'blog8.png', 'blog9.png', 'blog10.png', 'blog11.png',
    'hotelBooking.png', 'conciergeService.png', 'concierge2.png', 'concierge3.png', 'concierge4.png', 'concierge5.png',
    'homeimage.png', 'slslogo.png', 'fly_private.png', '10Most.png'
  ];

  const urlMap = {};

  for (const filename of assetFiles) {
    const filePath = path.join(ASSETS_DIR, filename);
    if (!fs.existsSync(filePath)) {
      console.warn(`⚠️ Asset ${filename} not found, skipping.`);
      continue;
    }

    try {
      const storagePath = `app_assets/${filename}`;
      const res = await uploadToFirebaseStorage(filePath, storagePath);
      urlMap[filename] = res.url;
      urlMap[`assets/${filename}`] = res.url;
      console.log(`✅ Uploaded: ${filename} -> ${res.url}`);
    } catch (e) {
      console.error(`❌ Failed to upload ${filename}: ${e.message}`);
    }
  }

  // Save the URL mapping to a json file
  fs.writeFileSync(path.join(__dirname, 'uploaded_asset_urls.json'), JSON.stringify(urlMap, null, 2));
  console.log('\n📄 Saved uploaded_asset_urls.json with', Object.keys(urlMap).length, 'entries');

  // Now update Firestore documents across all 5 sections!
  console.log('\n🔄 Updating Firestore documents...');

  // 1: Fleet
  console.log('--- Updating Fleet (jets) ---');
  const jetMapping = {
    'light_jet': urlMap['jet1.png'],
    'midsize_jet': urlMap['jet2.png'],
    'heavy_jet': urlMap['jet3.png'],
    'helicopter': urlMap['chopper.png'],
  };

  for (const [jetId, imgUrl] of Object.entries(jetMapping)) {
    if (!imgUrl) continue;
    try {
      await patchFirestoreDoc('jets', jetId, {
        imageUrl: { stringValue: imgUrl }
      }, ['imageUrl']);
      console.log(`  ✓ Updated jet ${jetId} with ${imgUrl}`);
    } catch (e) {
      console.error(`  ✗ Error updating jet ${jetId}: ${e.message}`);
    }
  }

  // 2: Destination
  console.log('--- Updating Destinations ---');
  const destMapping = {
    'wef-davos-europe': urlMap['des1.jpg'],
    'art-basel': urlMap['des10.webp'],
    'new-york-zurich': urlMap['des2.png'],
    'zurich-london': urlMap['des4.png'],
    'zurich-paris': urlMap['des5.png'],
    'davos': urlMap['des1.jpg'],
    'st-moritz': urlMap['des2.png'],
    'gstaad': urlMap['des3.png'],
    'monaco': urlMap['des6.png'],
    'courchevel': urlMap['des7.png'],
    'ibiza': urlMap['des8.png'],
    'milan': urlMap['des9.webp'],
  };

  for (const [destId, imgUrl] of Object.entries(destMapping)) {
    if (!imgUrl) continue;
    try {
      const doc = await getFirestoreDoc('destinations', destId);
      if (doc) {
        await patchFirestoreDoc('destinations', destId, {
          imageUrl: { stringValue: imgUrl }
        }, ['imageUrl']);
        console.log(`  ✓ Updated destination ${destId} with ${imgUrl}`);
      }
    } catch (e) {
      console.log(`  - Note on dest ${destId}: ${e.message}`);
    }
  }

  // 3: Blogs
  console.log('--- Updating Blogs ---');
  const blogMapping = {
    'blog_1': urlMap['blog3.png'],
    'blog_2': urlMap['blog4.png'],
    'blog_3': urlMap['blog5.png'],
    'blog_4': urlMap['blog6.png'],
    'blog_5': urlMap['blog7.png'],
    'blog_6': urlMap['blog8.png'],
    'blog_7': urlMap['blog9.png'],
    'blog_8': urlMap['blog10.png'],
    'blog_9': urlMap['blog11.png'],
  };

  for (const [blogId, imgUrl] of Object.entries(blogMapping)) {
    if (!imgUrl) continue;
    try {
      const doc = await getFirestoreDoc('blogs', blogId);
      if (doc) {
        await patchFirestoreDoc('blogs', blogId, {
          imageUrl: { stringValue: imgUrl }
        }, ['imageUrl']);
        console.log(`  ✓ Updated blog ${blogId} with ${imgUrl}`);
      }
    } catch (e) {
      console.log(`  - Note on blog ${blogId}: ${e.message}`);
    }
  }

  // 4: Home Content
  console.log('--- Updating Home Content ---');
  try {
    const card1Url = urlMap['des1.jpg'] || '';
    const card2Url = urlMap['des4.png'] || '';

    const homeContentBody = {
      routeCards: {
        arrayValue: {
          values: [
            {
              mapValue: {
                fields: {
                  id: { stringValue: 'card_1' },
                  imageUrl: { stringValue: card1Url },
                  duration: { stringValue: '1 hr 10 min' },
                  title: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'Davos Ski Escape' },
                        fr: { stringValue: 'Séjour ski à Davos' },
                        de: { stringValue: 'Ski-Urlaub in Davos' },
                        ar: { stringValue: 'عطلة تزلج في دافوس' }
                      }
                    }
                  },
                  category: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'SWISS ALPS' },
                        fr: { stringValue: 'ALPES SUISSES' },
                        de: { stringValue: 'SCHWEIZER ALPEN' },
                        ar: { stringValue: 'جبال الألب السويسرية' }
                      }
                    }
                  },
                  overlayTag: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'POPULAR ROUTE' },
                        fr: { stringValue: 'ROUTE POPULAIRE' },
                        de: { stringValue: 'BELIEBTE ROUTE' },
                        ar: { stringValue: 'مسار مميز' }
                      }
                    }
                  }
                }
              }
            },
            {
              mapValue: {
                fields: {
                  id: { stringValue: 'card_2' },
                  imageUrl: { stringValue: card2Url },
                  duration: { stringValue: '1 hr 40 min' },
                  title: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'Zurich to London' },
                        fr: { stringValue: 'Zurich vers Londres' },
                        de: { stringValue: 'Zürich nach London' },
                        ar: { stringValue: 'من زيورخ إلى لندن' }
                      }
                    }
                  },
                  category: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'BUSINESS & CULTURE' },
                        fr: { stringValue: 'AFFAIRES ET CULTURE' },
                        de: { stringValue: 'WIRTSCHAFT & KULTUR' },
                        ar: { stringValue: 'أعمال وثقافة' }
                      }
                    }
                  },
                  overlayTag: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'VIP CHARTER' },
                        fr: { stringValue: 'VOL VIP' },
                        de: { stringValue: 'VIP CHARTER' },
                        ar: { stringValue: 'شارتر VIP' }
                      }
                    }
                  }
                }
              }
            }
          ]
        }
      },
      stats: {
        arrayValue: {
          values: [
            {
              mapValue: {
                fields: {
                  count: { stringValue: '150+' },
                  label: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'Private Destinations' },
                        fr: { stringValue: 'Destinations Privées' },
                        de: { stringValue: 'Private Reiseziele' },
                        ar: { stringValue: 'وجهات خاصة' }
                      }
                    }
                  }
                }
              }
            },
            {
              mapValue: {
                fields: {
                  count: { stringValue: '99.8%' },
                  label: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'On-Time VIP Departures' },
                        fr: { stringValue: 'Départs VIP à l\'heure' },
                        de: { stringValue: 'Pünktliche VIP-Abflüge' },
                        ar: { stringValue: 'دقة المواعيد' }
                      }
                    }
                  }
                }
              }
            },
            {
              mapValue: {
                fields: {
                  count: { stringValue: '24/7' },
                  label: {
                    mapValue: {
                      fields: {
                        en: { stringValue: 'Dedicated Concierge' },
                        fr: { stringValue: 'Conciergerie Dédiée' },
                        de: { stringValue: 'Dedizierter Concierge' },
                        ar: { stringValue: 'خدمة كونسيرج 24/7' }
                      }
                    }
                  }
                }
              }
            }
          ]
        }
      },
      updatedAt: { stringValue: new Date().toISOString() }
    };

    await patchFirestoreDoc('home_content', 'main', homeContentBody, ['routeCards', 'stats', 'updatedAt']);
    console.log('  ✓ Updated home_content/main with Firebase Storage images');
  } catch (e) {
    console.error(`  ✗ Error updating home_content: ${e.message}`);
  }

  // 5: Concierge
  console.log('--- Updating Concierge ---');
  try {
    const bannerUrl = urlMap['conciergeService.png'] || '';
    if (bannerUrl) {
      await patchFirestoreDoc('concierge_banner', 'main', {
        imageUrl: { stringValue: bannerUrl },
        updatedAt: { stringValue: new Date().toISOString() }
      }, ['imageUrl', 'updatedAt']);
      console.log('  ✓ Updated concierge_banner/main with Firebase Storage URL');
    }
  } catch (e) {
    console.error(`  ✗ Error updating concierge banner: ${e.message}`);
  }

  const catMapping = {
    'cat_hotel_booking': urlMap['hotelBooking.png'],
    'cat_chauffeur': urlMap['concierge2.png'],
    'cat_security': urlMap['concierge3.png'],
    'cat_lifestyle': urlMap['concierge4.png'],
    'cat_diplomatic': urlMap['concierge5.png'],
  };

  for (const [catId, imgUrl] of Object.entries(catMapping)) {
    if (!imgUrl) continue;
    try {
      const doc = await getFirestoreDoc('concierge_categories', catId);
      if (doc) {
        await patchFirestoreDoc('concierge_categories', catId, {
          imageUrl: { stringValue: imgUrl }
        }, ['imageUrl']);
        console.log(`  ✓ Updated concierge category ${catId} with ${imgUrl}`);
      }
    } catch (e) {
      console.log(`  - Note on category ${catId}: ${e.message}`);
    }
  }

  console.log('\n🎉 All asset images uploaded to Firebase Storage and Firestore updated successfully!');
}

run().catch(console.error);
