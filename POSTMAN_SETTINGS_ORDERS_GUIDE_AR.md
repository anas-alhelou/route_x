# ⚙️ شرح الشغلات اللازمة لـ Settings و Orders من ملف الـ Postman

> **ملاحظة أولى مهمة:** ملف الـ Postman **ما فيه مجلد اسمه "Settings"** — طلبات الإعدادات **موزعة** على مجلدات Auth و Companies و WhatsApp. وطلبات الـ Orders موجودة بمجلد واحد كبير (15 طلب) + مجلدين مكملين له (Live Tracking و WhatsApp). هذا الشرح بجمعهم لك حسب الشاشة.

---

## الجزء الأول: Settings (الإعدادات والملف الشخصي)

شاشة الإعدادات بالتطبيق فيها: صورة البروفايل + الاسم/الإيميل/التلفون، معلومات العربة، اللغة، إشعارات، وزر تسجيل الخروج. **كل طلبات الـ API اللي بتغذي هذه الشاشة:**

### 1. جلب بيانات البروفايل — أول طلب بتنفذه الشاشة
| | |
|---|---|
| **الاسم بالبوست مان** | `Get me` (مجلد 1. Auth) |
| **الرابط** | `GET {{baseUrl}}/auth/me` |
| **التوثيق** | `Bearer {{driverToken}}` (أو أي توكن — بيرجع بيانات صاحب التوكن) |
| **Body** | لا يوجد |
| **ليش لازمة؟** | بترجع كل بيانات المستخدم: الاسم، الإيميل، التلفون، الدولة، `vehicleType`, `vehicleNumber`، وحالة الـ notifications — يعني هي اللي بتملي شاشة الإعدادات |

### 2. تعديل الملف الشخصي — لما يضغط Edit
| | |
|---|---|
| **الاسم بالبوست مان** | `Update profile (multipart)` (مجلد 1. Auth) |
| **الرابط** | `PATCH {{baseUrl}}/auth/profile` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **Body** | `form-data` — حقول اختيارية، بتعدل بس اللي بتبعتو: `firstName`, `lastName`, `phone`, `country`, `hearAboutUs`, `companyName`, `registrationNumber`, `tgaLicenseNumber`, `tgaLicenseExpiryDate`, وملف `profileImage` (صورة) |

### 3. تغيير كلمة المرور — لو في خيار "Change Password" بالإعدادات
| | |
|---|---|
| **الاسم بالبوست مان** | `Change password` (مجلد 1. Auth) |
| **الرابط** | `PATCH {{baseUrl}}/auth/change-password` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **Body (JSON)** | `currentPassword` + `newPassword` + `confirmNewPassword` (3 حقول إجبارية) |

### 4. تسجيل الخروج — زر Log Out
| | |
|---|---|
| **الاسم بالبوست مان** | `Logout` (مجلد 1. Auth) |
| **الرابط** | `POST {{baseUrl}}/auth/logout` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **Body** | لا يوجد — الـ backend بيرجع يبطل التوكن (blacklist) |

### 5. تحديث موقعي — لو الإعدادات فيها موقع الحساب
> حسب دورك: المتجر بيستعمل رابط `businesses`، ومالك الأسطول بيستعمل `companies`:
| | |
|---|---|
| **الاسم بالبوست مان** | `Update my store location` أو `Update my company location` (مجلد 2) |
| **الرابط** | `PATCH {{baseUrl}}/businesses/me/location` أو `PATCH {{baseUrl}}/companies/me/location` |
| **التوثيق** | `Bearer {{storeToken}}` / `Bearer {{fleetToken}}` |
| **Body (JSON)** | `latitude`, `longitude`, `address` |

### 6. حالة WhatsApp — لو الإعدادات فيها "ربط WhatsApp"
| | |
|---|---|
| **الأسماء بالبوست مان** | `Connect`, `Get QR`, `Status`, `Disconnect` (مجلد 6. WhatsApp) |
| **الروابط** | `POST /whatsapp/connect`, `GET /whatsapp/qr`, `GET /whatsapp/status`, `POST /whatsapp/disconnect` |
| **التوثيق** | `Bearer {{storeToken}}` |
| **Body** | `{}` فاضي للـ connect/disconnect — الـ QR بينعرض للمسح |

### 📌 ملخص Settings في 3 سطور
```
افتح الشاشة  →  GET /auth/me            (جيب بياناتي)
عدل شي      →  PATCH /auth/profile      (أو change-password)
اطلع       →  POST /auth/logout
```

---

## الجزء الثاني: Orders (الطلبات) — قصة التوصيل كاملة

مجلد **5. Orders** فيه 15 طلب. هذا ترتيبهم حسب **رحلة السائق** الحقيقية بالتطبيق:

### المرحلة 1 — السائق يشوف طلباته
| | |
|---|---|
| **الاسم** | `My orders (DRIVER)` |
| **الرابط** | `GET {{baseUrl}}/orders/mine` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **Body** | لا يوجد |
| **ليش لازمة؟** | هذه هي شاشة "Orders Today" — بتجيب كل الطلبات المسندة للسائق الحالي |

> 👈 اللي بيستعملو المتجر: `List store orders` (`GET /orders?page=1&limit=10` بتوكن المتجر) — نفس الرابط، بفرق التوكن.

### المرحلة 2 — تفاصيل طلب معين
| | |
|---|---|
| **الاسم** | `Get order (SMALL_BUSINESS)` |
| **الرابط** | `GET {{baseUrl}}/orders/{{orderId}}` |
| **التوثيق** | `Bearer {{driverToken}}` (أو توكن المتجر) |
| **متغير لازم** | `{{orderId}}` — بينحفظ تلقائياً بعد Create order، أو بتجيبو من قائمة الطلبات |

> **صيغة ثانية:** `Get order by company + id` → `GET /orders/{{storeId}}/{{orderId}}`

### المرحلة 3 — السائق يقبل أو يرفض
| الطلب | الرابط | Body | ملاحظات |
|---|---|---|---|
| `Driver accepts order` | `PATCH /orders/accept` | `{ "orderId": "{{orderId}}" }` | قبول بسيط |
| `Driver rejects order` | `PATCH /orders/reject` | `{ "orderId", "reason" }` | لازم سبب — مثل "Too far from my current position" |

### المرحلة 4 — بدء التوصيل
| | |
|---|---|
| **الاسم** | `Start delivery (DRIVER)` |
| **الرابط** | `POST {{baseUrl}}/orders/start-delivery` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **⚠️ ملاحظة** | بالملف **ما فيه body** — غالباً لازم تبعت `orderId`، اسأل الـ backend أو جرب تضيفو |

### المرحلة 5 — التتبع المباشر أثناء التوصيل (مجلد 8 — مكمل للـ Orders)
> **الترتيب إجباري:** start session → upload samples → end session

| الخطوة | الطلب | الرابط | توثيق خاص | Body |
|---|---|---|---|---|
| 1 | `Start session` | `POST /tracking/session` | `Bearer {{driverToken}}` | `{ "appVersion": "1.0.0" }` → **يرجع `trackingToken` وينحفظ تلقائياً** |
| 2 | `Upload location sample` | `POST /tracking/location` | `Bearer {{trackingToken}}` ⚠️ (توكن الجلسة مش توكن السائق!) | ملف **binary** + هيدر `X-Tracking-Seq` |
| 3 | `End session` | `POST /tracking/session/end` | `Bearer {{driverToken}}` | لا يوجد |

### المرحلة 6 — تأكيد التسليم بصورة إثبات
| | |
|---|---|
| **الاسم** | `Confirm delivery with proof photo (DRIVER, multipart)` |
| **الرابط** | `POST {{baseUrl}}/orders/deliver` |
| **التوثيق** | `Bearer {{driverToken}}` |
| **Body (form-data)** | `orderId` (نص = `{{orderId}}`) + `proof` (ملف صورة) |
| **⚠️ ملاحظة** | مسار الصورة بالملف من جهاز تاني (`C:/Users/HP/Desktop/t.PNG`) — غيّرو لمسار عندك |

### المرحلة 7 — عرض إثبات التسليم (للمتجر/الإدارة/السائق)
| | |
|---|---|
| **الاسم** | `Get delivery proof (store / fleet / driver / admin)` |
| **الرابط** | `GET {{baseUrl}}/orders/{{orderId}}/delivery-proof` |
| **التوثيق** | أي توكن من الأدوار الأربعة |
| **الاستخدام** | جلب صورة الإثبات — بيشتغل مع الكل |

### طلبات إدارة إضافية (بأغلبها للمتجر)
| الطلب | الرابط | Body | المعنى |
|---|---|---|---|
| `Create order` | `POST /orders` | زبون + items + عنوان + إحداثيات + `source: MANUAL` | إنشاء طلب → **ينحفظ `orderId` تلقائياً** |
| `Update order status` | `PATCH /orders/status` | `{ orderId, status: "NEEDS_REVIEW" }` | تغيير الحالة |
| `Cancel order` | `PATCH /orders/cancel` | `{ orderId, reason }` | إلغاء |
| `Edit order details` | `PATCH /orders/customer-name` | `{ orderId, customerName, customerPhone, address, region }` | تعديل بيانات الزبون |
| `Assign order to driver` | `PATCH /orders/assign-driver` | `{ orderId, driverId }` | إسناد للسائق |

### 🧩 الروابط الجانبية اللي تخدم Orders
- **رسالة WhatsApp للزبون** (زر message dispatch بشاشة تفاصيل الطلب): `POST /whatsapp/send-message` — `{ "to": "رقم", "message": "النص" }` بتوكن المتجر.
- **اقتراح أفضل سائق** (قبل الإسناد): `POST /routing/best-driver` — `{ ringSize, limit }` بتوكن المتجر.

---

## 🎯 الفروقات بين توكنات الطلبات (أهم شي تحفظو)

| الدور | التوكن | طلباته |
|---|---|---|
| **السائق** | `{{driverToken}}` | `GET /orders/mine`, `accept`, `reject`, `start-delivery`, `deliver`, tracking |
| **المتجر** | `{{storeToken}}` | `GET /orders`, `create`, `status`, `cancel`, `edit`, `assign-driver`, WhatsApp |
| **مالك الأسطول** | `{{fleetToken}}` | `GET /fleet/orders`, `GET /orders/{id}/delivery-proof` |
| **المدير** | `{{adminToken}}` | الموافقات + delivery-proof |

> **قاعدة ذهبية:** أي طلب بيشتغل مع **كل الأدوار** (مثل `delivery-proof` و `Get me`) — لكن الطلبات الخاصة بدور معين لازم توكنه هو، وإلا بيرجع 401/403.

---

## 🔑 المتغيرات اللي بتحتاجها لهذي الطلبات

| المتغير | من وين بيجي | بأي طلب بينستخدم |
|---|---|---|
| `{{driverToken}}` | Login - Driver (تلقائي) | كل طلبات السائق |
| `{{storeToken}}` | Login - Store (تلقائي) | كل طلبات المتجر |
| `{{orderId}}` | Create order (تلقائي) | accept / reject / deliver / proof / get order |
| `{{trackingToken}}` | Start session (تلقائي) | Upload location sample |
| `{{storeId}}` | **يدوي** من رد الـ Login/me | `GET /orders/{{storeId}}/{{orderId}}` |
| `{{driverId}}` | **يدوي** من رد الـ List drivers/me | `assign-driver` |

---

## 🧪 سيناريو اختبار سريع للـ Orders (من جهة السائق)

```
1. Login - Driver                    → خذ driverToken (تلقائي)
2. My orders                         → شوف الطلبات المسندة لك
3. Get order (بـ orderId)            → افتح التفاصيل
4. Driver accepts order              → اقبل
5. Start delivery                    → ابدأ التوصيل
6. Start session                     → ابدأ التتبع (trackingToken ينحفظ)
7. Upload location sample (×N)       → ابعت عينات موقع
8. End session                       → أنهي التتبع
9. Confirm delivery with proof photo → سلم بصورة
10. Get delivery proof               → تأكد إن الصورة انحفظت
```
