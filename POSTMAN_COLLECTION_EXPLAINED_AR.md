# 📘 شرح كامل لمجموعة Postman — RouteX Complete API

> **الملف:** `RouteX - Complete API.postman_collection.json`
> **نوع السكيما:** Postman Collection v2.1.0
> **الوصف الرسمي داخل الملف:** "كل طلبات HTTP في مشروع RouteX (الـ gateway + الـ Python solver) مع الـ bodies. تم توليده من الـ controllers و الـ DTOs. طلبات الـ Login تحفظ التوكنات تلقائياً في متغيرات المجموعة."

---

## 1️⃣ الصورة العامة — شو هاي المجموعة أصلاً؟

هذي المجموعة هي **"خريطة كاملة" للـ Backend بتاع RouteX** (منصة توصيل طلبات Q-Commerce في غزة — Palestine). يعني بدل ما تفتح كود الـ backend وتفتش على كل endpoint، هذا الملف يجمع لك **كل endpoint مع الطريقة (method) والرابط والـ body والمثال الجاهز**.

النظام مبني على:
- **Gateway واحد** (`http://localhost:3000`) — هو البوابة الوحيدة لكل الطلبات من التطبيق.
- **Python Solver** منفصل (`http://localhost:8081`) — خدمة حل مشكلة التوصيل (CVRPTW = Vehicle Routing Problem بقيود الوقت والسعة).

### الأدوار الأربعة في النظام (Roles)
كل endpoint في النظام مخصص لدور معين:

| الدور | بالإنجليزي | مين هو؟ |
|---|---|---|
| تاجر / متجر صغير | `SMALL_BUSINESS` | صاحب المحل اللي بيعمل الطلبات ويبعت سائقين |
| مالك أسطول | `FLEET_OWNER` | عنده شركة توصيل وسائقين تحت إدارته |
| سائق | `DRIVER` | بيوصل الطلبات |
| مدير عام | `SUPER_ADMIN` | بيوافق على الشركات والمتاجر |

---

## 2️⃣ المتغيرات (Variables) — قلب المجموعة

أول شي لازم تفهمه: المجموعة تستعمل **متغيرات** `{{...}}` بدل القيم الثابتة. هاي قائمتها:

### روابط الخوادم
| المتغير | القيمة | المعنى |
|---|---|---|
| `{{baseUrl}}` | `http://localhost:3000` | رابط الـ Gateway الرئيسي |
| `{{solverUrl}}` | `http://localhost:8081` | رابط الـ Python Solver |

### حسابات تسجيل الدخول (فاضية — لازم تعبيها)
| المتغير | استخدامه |
|---|---|
| `{{storeEmail}}` / `{{storePassword}}` | حساب المتجر |
| `{{fleetEmail}}` / `{{fleetPassword}}` | حساب مالك الأسطول |
| `{{driverEmail}}` / `{{driverPassword}}` | حساب السائق |
| `{{adminEmail}}` / `{{adminPassword}}` | حساب المدير |

### التوكنات (بتنحفظ تلقائياً — لا تلمسها يدوياً)
| المتغير | متى ينحفظ؟ |
|---|---|
| `{{storeToken}}` / `{{storeRefreshToken}}` | بعد تنفيذ طلب **Login - Store** |
| `{{fleetToken}}` / `{{fleetRefreshToken}}` | بعد **Login - Fleet Owner** |
| `{{driverToken}}` / `{{driverRefreshToken}}` | بعد **Login - Driver** أو **Refresh token** |
| `{{adminToken}}` / `{{adminRefreshToken}}` | بعد **Login - Super Admin** |
| `{{trackingToken}}` | بعد **Start session** (مجلد Live Tracking) |
| `{{resetToken}}` | بعد **Verify reset OTP** |

### المعرفات (IDs) — بتنحفظ تلقائياً من الردود
| المتغير | متى ينحفظ؟ |
|---|---|
| `{{productId}}` | بعد **Create product** |
| `{{orderId}}` | بعد **Create order** |
| `{{companyJoinCode}}` | بعد **Regenerate join code** |
| `{{nowMs}}` | بعد **Driver telemetry** (وقت التنفيذ بالملي ثانية) |
| `{{storeId}}` / `{{fleetCompanyId}}` | **ما بتنحفظ تلقائياً** — لازم تحطها يدوياً من ردود الـ login أو الـ me |

> ⚠️ **ملاحظة مهمة:** فيه متغيرين مستخدمين بالطلبات لكن غير معرّفين بقائمة المتغيرات:
> - `{{driverProfileId}}` — مستخدم بمجلد Fleet owner (لازم تحطه يدوياً من رد List my drivers)
> - `{{driverUserId}}` — مستخدم بطلب "اختيار سائق وارسال له الطلب مباشرة"

---

## 3️⃣ كيف تعمل المصادقة (Authentication)؟

### النمط العام
- **الطلبات العامة** (تسجيل، دخول، Google، نسيان كلمة المرور): بدون Auth (`noauth`).
- **الطلبات المحمية**: تستعمل **Bearer Token** — كل طلب مربوط بتوكن الدور الصح:
  - طلبات المتجر → `{{storeToken}}`
  - طلبات الأسطول → `{{fleetToken}}`
  - طلبات السائق → `{{driverToken}}`
  - طلبات المدير → `{{adminToken}}`

### السحر الحقيقي: سكريبتات الحفظ التلقائي (Test Scripts)
كل طلب **Login** فيه سكريبت صغير ينفذ بعد الرد ويحفظ التوكن في متغيرات المجموعة:

```javascript
const j = pm.response.json();
const tk = (j.data && j.data.tokens) || j.tokens || {};
if (tk.accessToken) pm.collectionVariables.set('storeToken', tk.accessToken);
if (tk.refreshToken) pm.collectionVariables.set('storeRefreshToken', tk.refreshToken);
```

**شو يعني هذا؟** يعني أنت تنفذ طلب Login **مرة واحدة فقط**، ومن بعدها كل الطلبات اللي بعده رح تشتغل مباشرة لأن التوكن انحفظ تلقائياً. نفس الفكرة مع باقي المتغيرات: `productId`, `orderId`, `trackingToken`, `resetToken`, `companyJoinCode`, `nowMs`.

---

## 4️⃣ شرح المجلدات التسعة — واحد واحد

### 📁 المجلد 1: Auth (التسجيل والدخول — 19 طلب)

هذا المجلد يغطي دورة حياة الحساب كاملة:

**التسجيل — 3 طلبات مختلفة لنفس الرابط `POST /auth/register`**
الاختلاف في حقل `role` والحقول الإضافية اللي بيطلبها كل دور:

| الطلب | الحقول المميزة |
|---|---|
| Register - SMALL_BUSINESS | `role: SMALL_BUSINESS` + `businessName` + `registrationNumber` |
| Register - FLEET_OWNER | `role: FLEET_OWNER` + `companyName` + `tgaLicenseNumber` + `tgaLicenseExpiryDate` (ترخيص النقل) |
| Register - DRIVER | `role: DRIVER` + `companyId` + `vehicleType` + `vehicleNumber` |

كلها **multipart/form-data** (لأن فيها `profileImage` ملف صورة). لاحظ إن طلب السائق يستعمل `{{fleetCompanyId}}` — يعني السائق يسجل مباشرة ضمن شركة معينة.

**الدخول — 4 طلبات** لـ `POST /auth/login`:
- Login - Store: فيه **إيميل ثابت مكتوب** (`m420406894@gmail.com`)
- Login - Fleet Owner: يستعمل `{{fleetEmail}}` / `{{fleetPassword}}`
- Login - Driver: فيه **إيميل ثابت** (`kalhadda@students.iugaza.edu.ps`)
- Login - Super Admin: يستعمل `{{adminEmail}}` / `{{adminPassword}}`
- كل واحد ينفذ بعدها سكريبت حفظ التوكن (شرحناها فوق).

**دخول Google — 3 طلبات** لـ `POST /auth/google`:
كلها تبعت `idToken` (توكن Google) + `platform`:
- WEB + store → `platform: "WEB"`, `role: "SMALL_BUSINESS"` + اسم المحل
- WEB + fleet → `platform: "WEB"`, `role: "FLEET_OWNER"` + بيانات الترخيص
- MOBILE + driver → `platform: "MOBILE"` + `companyId` + بيانات العربة

> هذا يطابق تماماً الـ README بتاع تطبيق Flutter: التطبيق يبعت الـ ID token والـ backend يتأكد منه.

**استعادة كلمة المرور — سلسلة 4 طلبات (Order مهم!):**
1. `POST /auth/forgot-password` → يبعت OTP على الإيميل
2. `POST /auth/verify-reset-otp` → يتأكد من الـ OTP **ويحفظ `resetToken` تلقائياً**
3. `POST /auth/reset-password` → يستعمل `resetToken` + `newPassword` + `confirmPassword`
4. (إضافة: `POST /auth/verify-otp` لتفعيل الحساب بعد التسجيل)

**طلبات الحساب المتنوعة:**
- `GET /auth/me` → جلب بياناتي الحالية (بيشتغل مع أي توكن)
- `PATCH /auth/profile` → تعديل الملف الشخصي (multipart مع صورة)
- `PATCH /auth/change-password` → تغيير كلمة المرور (3 حقول: الحالية والجديدة وتأكيدها)
- `POST /auth/logout` → تسجيل الخروج
- `POST /auth/refresh` → تجديد التوكن. **ملاحظة:** فيه refresh token مكتوب يدوياً (صلاحيته 7 أيام) وسكريبت يحفظ توكنات **السائق** الجديدة.

---

### 📁 المجلد 2: الشركات والمتاجر وعضوية السائق (12 طلب)

هذا المجلد يحكي قصة **"الموافقات"** في النظام:

**من جهة السائق:**
- `GET /companies/search?query=Logistics` → السائق يبحث عن شركة ينضم لها

**من جهة مالك الأسطول:**
- `PATCH /companies/me/location` → تحديث موقع الشركة (lat, lng, address)
- `POST /companies/me/code/regenerate` → توليد **كود انضمام** جديد (يحفظه تلقائياً في `companyJoinCode`)
- `PATCH /companies/me/code` → تفعيل/تعطيل كود الانضمام (`enabled: false`)

**من جهة المدير العام (إدارة النظام):**
- `GET /companies?status=PENDING` → قائمة الشركات حسب الحالة (مع pagination)
- `PATCH /companies/{{fleetCompanyId}}/status` → **موافقة** (`APPROVED`) أو **رفض** (`REJECTED` + `rejectionReason` مثل "Invalid TGA license")
- `PATCH /businesses/{{storeId}}/status` → نفس الشي للمتاجر (موافقة / رفض / تعليق `SUSPENDED`)

**من جهة المتجر:**
- `PATCH /businesses/me/location` → تحديث موقع المتجر

**الانضمام للشركة — طريقتين:**
- `POST /drivers/join` → بالـ ID مباشرة: `{ "companyId": "{{fleetCompanyId}}" }`
- `POST /drivers/join-by-code` → بالكود: `{ "code": "{{companyJoinCode}}" }`

---

### 📁 المجلد 3: مالك الأسطول وإدارة السائقين (5 طلبات)

بعد ما السائق ينضم، هون مالك الأسطول يدير فريقه:

- `GET /owner/drivers?status=PENDING` → قائمة السائقين (فلترة حسب الحالة + pagination)
- `PATCH /owner/drivers/{{driverProfileId}}/status` → **موافقة** على سائق (`APPROVED`) أو **رفضه** (`REJECTED` + سبب مثل "Documents incomplete")
- `PATCH /owner/drivers/{{driverProfileId}}/vehicle` → تحديد عربة السائق (`vehicleType`, `vehicleNumber`)
- `GET /fleet/orders?page=1&limit=10` → كل طلبات الشركة

---

### 📁 المجلد 4: المنتجات (6 طلبات — كلها للمتجر)

إدارة مخزون المتجر:

| الطلب | الرابط | ملاحظات |
|---|---|---|
| Create product | `POST /products` | `name, sku, price, stockQuantity, isActive` → **يحفظ `productId` تلقائياً** |
| List products | `GET /products?page&limit&search` | بحث `search=water` |
| Get product | `GET /products/{{storeId}}/{{productId}}` | بالـ ID |
| Update details | `PATCH /products/stock` | `productId` بالـ body — اسم الرابط غريب شوي |
| Adjust stock | `POST /products/adjust-stock` | `quantityDelta` موجب أو سالب + `type: RESTOCK` |
| Delete product | `DELETE /products/{{storeId}}/{{productId}}` | حذف |

---

### 📁 المجلد 5: الطلبات — قلب النظام (15 طلب)

هنا بتصير **قصة التوصيل كاملة**. ترتيب الحياة الطبيعية للطلب:

**1. المتجر ينشئ الطلب:**
`POST /orders` — بيحدد الزبون، المنتجات، العنوان، الإحداثيات، والمصدر `MANUAL` → **يحفظ `orderId` تلقائياً**

**2. إدارة الطلب من المتجر:**
- `GET /orders` → قائمة طلباتي
- `GET /orders/{{orderId}}` → تفاصيل طلب
- `GET /orders/{{storeId}}/{{orderId}}` → نفس الطلب بصيغة ثانية
- `PATCH /orders/status` → تغيير الحالة (مثل `NEEDS_REVIEW`)
- `PATCH /orders/cancel` → إلغاء مع سبب
- `PATCH /orders/customer-name` → تعديل بيانات الزبون والعنوان

**3. إسناد السائق:**
- `PATCH /orders/assign-driver` → `{ orderId, driverId }` — موجود **مرتين**: واحدة إنجليزي وأخرى باسم عربي "اختيار سائق وارسال له الطلب مباشرة"
  - ⚠️ النسخة العربية فيها **غلطان**: بتستعمل `driverToken` بدل `storeToken`، وبتستعمل متغير `{{driverUserId}}` غير معرّف.
- `GET /orders/mine` → السائق يشوف طلباته

**4. رد السائق:**
- `PATCH /orders/accept` → قبول الطلب
- `PATCH /orders/reject` → رفض مع سبب ("Too far from my current position")

**5. التنفيذ والتسليم:**
- `POST /orders/start-delivery` → بدء التوصيل
  - ⚠️ **لاحظ:** الرابط ما فيه body — غالباً ناقص `orderId` بالملف.
- `POST /orders/deliver` → تأكيد التسليم **بصورة إثبات** (multipart: `orderId` + ملف `proof` صورة)
  - ⚠️ مسار الملف مكتوب من جهاز تاني: `/C:/Users/HP/Desktop/t.PNG` — لازم تغيره لمسار عندك.

**6. الإثبات:**
- `GET /orders/{{orderId}}/delivery-proof` → عرض صورة إثبات التسليم (لكل الأدوار: متجر/أسطول/سائق/مدير)

---

### 📁 المجلد 6: WhatsApp (5 طلبات — للمتجر)

ربط المتجر بـ WhatsApp لإرسال إشعارات للزبائن:

| الطلب | الرابط | المعنى |
|---|---|---|
| Connect | `POST /whatsapp/connect` | بدء الاتصال (body فاضي `{}`) |
| Get QR | `GET /whatsapp/qr` | جلب **QR code** للمسح من موبايل العميل |
| Status | `GET /whatsapp/status` | حالة الاتصال |
| Disconnect | `POST /whatsapp/disconnect` | قطع الاتصال |
| Send message | `POST /whatsapp/send-message` | `{ "to": "رقم", "message": "النص" }` |

> **الفكرة:** المتجر يربط WhatsApp مرة، وبعدين لما يبعت طلب، يقدر يبعت رسالة للزبون مثل "Your order is on the way" — بدون ما يعمل تسجيل دخول لرقم على جهازه.

---

### 📁 المجلد 7: التوجيه (Routing — طلبان)

- `POST /routing/best-driver` → **اقتراح أفضل سائقين** لطلب معين:
  - `ringSize` = نصف قطر البحث
  - `limit` = عدد المرشحين المطلوب
  - ⚠️ غالباً ناقص `orderId` بالـ body.
- `POST /routing/telemetry` → **بث موقع السائق** (GPS):
  - `deviceId, lat, lng, heading, speed, accuracy, timestamp`
  - بعد التنفيذ سكريبت يحدث `nowMs` — جاهز لتقليد بيانات حية متغيرة.

---

### 📁 المجلد 8: التتبع المباشر (Live Tracking — 3 طلبات)

> **وصف المجلد الرسمي:** "الـ Gateway هو نقطة الدخول الوحيدة. **الترتيب:** ابدأ الجلسة → ارفع العينات → أنهِ الجلسة."

| الترتيب | الطلب | التفاصيل |
|---|---|---|
| 1️⃣ | `POST /tracking/session` | بدء جلسة تتبع `{ "appVersion": "1.0.0" }` → **يحفظ `trackingToken` تلقائياً** |
| 2️⃣ | `POST /tracking/location` | رفع عينة موقع — **مميز جداً**: body ملف **binary** (`.bin`), هيدر `X-Tracking-Seq` (رقم تسلسلي), والتوثيق بـ `trackingToken` (مش توكن المستخدم!) |
| 3️⃣ | `POST /tracking/session/end` | إنهاء الجلسة (برجع لتوكن السائق العادي) |

> **ليش binary؟** لتحسين الأداء — بدل JSON ثقيل، كل عينة موقع تكون bytes مضغوطة. الملفات التجريبية موجودة عندك: `tracking-postman-samples/01-valid-gaza-city.bin`.

---

### 📁 المجلد 9: الخدمات الداخلية (طلبان — **بدون Gateway**)

> **وصف المجلد:** "اتصالات مباشرة للـ Python solver. خدمات الـ live-tracking والـ routing-engine والـ auth والـ orders هي **TCP microservices** (ما عندها HTTP)."

هذا يعني إن أغلب الخدمات تتكلم مع الـ gateway عبر TCP (مثل gRPC أو sockets)، لكن الـ solver عنده HTTP مباشر:
- `GET {{solverUrl}}/health` → فحص صحة الخدمة
- `POST {{solverUrl}}/solve` → **حل مشكلة التوصيل CVRPTW**:

| الحقل | المعنى |
|---|---|
| `duration_matrix_sec` / `distance_matrix_m` | مصفوفة الزمن/المسافة بين كل نقطتين (نقطة 0 = المستودع) |
| `order_ids` | قائمة الطلبات |
| `time_windows_sec` | **النوافذ الزمنية** لكل نقطة [بداية، نهاية] |
| `service_times_sec` | وقت الخدمة عند كل نقطة |
| `demands_volume_liters` / `demands_weight_kg` | حجم ووزن كل طلب |
| `vehicle_capacity_*` | سعة العربة |
| `num_vehicles` | عدد العربات |
| `node_cluster_ids` / `cluster_switch_penalty_sec` | تجميع النقاط + عقوبة التنقل بين المجموعات |

> هذا هو "العقل" اللي بيحدد **أفضل ترتيب توصيل** يقلل الوقت والمسافة مع احترام النوافذ الزمنية والسعة.

---

## 5️⃣ السيناريو الكامل — كيف تختبر النظام من A إلى Z

هذا الترتيب المقترح لتشغيل المجموعة (كل خطوة تعتمد على اللي قبلها):

```
1.  Register - FLEET_OWNER          → سجل شركة
2.  Login - Super Admin             → ادخل كمدير
3.  Approve company                 → وافق على الشركة (خذ fleetCompanyId)
4.  Login - Fleet Owner             → ادخل كمالك أسطول
5.  Regenerate join code            → خذ الكود (ينحفظ تلقائياً)
6.  Register - DRIVER               → سجل سائق (بالـ companyId)
7.  Login - Driver                  → ادخل كسائق (توكنه ينحفظ)
8.  Approve driver                  → وافق على السائق (خذ driverProfileId)
9.  Register - SMALL_BUSINESS       → سجل متجر
10. Login - Store                   → ادخل كمتجر
11. Approve store                   → وافق على المتجر (خذ storeId)
12. Create product                  → أضف منتج (productId ينحفظ)
13. Create order                    → أنشئ طلب (orderId ينحفظ)
14. Best driver candidates          → شوف أفضل السائقين
15. Assign order to driver          → أسند الطلب
16. Driver accepts order            → السائق يقبل
17. Start delivery                  → بدء التوصيل
18. Start session                   → بدء التتبع (trackingToken ينحفظ)
19. Upload location sample          → ارفع عينات موقع
20. End session                     → أنهي التتبع
21. Confirm delivery with proof     → سلم بصورة إثبات
22. Get delivery proof              → المتجر يتأكد من الصورة
23. WhatsApp - Send message         → ابعت للزبون
```

---

## 6️⃣ ملاحظات ومشاكل موجودة بالملف (مهم تعرفها)

1. **متغيرات ناقصة بالتعريف:** `driverProfileId` و `driverUserId` مستخدمة لكن غير معرّفة — لازم تحطها يدوياً.
2. **الطلب العربي "اختيار سائق..." فيه أخطاء:** بيستعمل `driverToken` بدل `storeToken` + متغير `driverUserId` غير معرّف.
3. **`Start delivery` بدون body:** غالباً ناقص `orderId`.
4. **`Best driver candidates` بدون `orderId`:** المفروض النظام يعرف أي طلب بدك سائق إله.
5. **مسارات ملفات من جهاز تاني:** `C:/Users/HP/Desktop/...` — لازم تحدثها لجهازك.
6. **إيميلات وباسوردات مكتوبة يدوياً** بطلبات الـ Login (store/driver) — متعمد لسهولة التجريب، لكن بالـ production لا تعمل هيك.
7. **طلب Refresh فيه JWT مكتوب يدوياً** — صلاحيته بتنتهي (7 أيام)، لو فشل جدد توكن من Login.
8. **`PATCH /products/stock` اسمه غلط:** هو تعديل بيانات منتج مش تعديل مخزون (تعديل المخزون إله endpoint منفصل `adjust-stock`).

---

## 7️⃣ خلاصة سريعة — إذا بدك تحفظ شي واحد

> **المجموعة هي "الـ API Reference الكامل لمنصة RouteX"**: 4 أدوار، مصادقة JWT، إدارة شركات ومتاجر وسائقين بموافقات تدريجية، إدارة منتجات وطلبات، توجيه ذكي للسائقين، تتبع مباشر بنظام binary، وحل رياضي (CVRPTW) ببايثون. السكريبتات تحفظ التوكنات والمعرفات تلقائياً عشان تعمل سيناريو كامل بضغطة وحدة على كل طلب ورا التاني.
