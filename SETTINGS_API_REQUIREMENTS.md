# تقرير متطلبات الـ API لربط إعدادات التطبيق (RouteX Mobile - Settings Feature)

> **المستهدف:** فريق تطوير الـ Backend  
> **التاريخ:** 17 أكتوبر 2026  
> **الحالة الراهنة في التطبيق:** شاشات الإعدادات (`features/settings`) مكتملة واجهاتها ومنطقها البرمجي (Clean Architecture)، ولكنها تعتمد حالياً على بيانات وهمية محلية (`Mock Data`) لعدم توفر معظم الـ Endpoints المطلوبة على السيرفر.

---

## 1. ملخص تنفيذي (Executive Summary)

عند مراجعة الـ API الحالي المتوفر في التطبيق ومجموعة الـ Postman (`q-commerce-routing.postman_collection.json`)، تبيّن الآتي:
- المتوفر حالياً يقتصر على التوثيق الأساسي (`register`, `login`, `verify-otp`, `google`, `forgot-password`, `reset-password`, `refresh`) وطلب إنشاء الطلبات (`orders`).
- مسار `GET /auth/me` موجود في ملف الـ Postman فقط، لكنه غير مفعّل أو مكتمل، ولا يعيد بيانات السائق الإضافية (مثل المركبة، الشركة، التقييم).
- **لا توجد أي مسارات خاصة بـ:**
  - تعديل بيانات الملف الشخصي ورفع الصورة الشخصية (Avatar).
  - تغيير كلمة المرور لمستخدم مسجل دخوله (`Change Password`).
  - جلب بيانات الشركة أو المركبة المسندة للسائق.
  - استعراض الأساطيل القريبة أو الانضمام لأسطول برمز (Fleet Code).
  - إرسال بلاغات الدعم الفني والمشاكل مع المرفقات (`Report a Problem`).
  - تسجيل الخروج من السيرفر وإبطال الـ Token (`Server-side Logout`).

---

## 2. هيكلية استجابة الـ API المتوقعة (Response Envelope)

تطبيق الموبايل مهيأ لاستقبال الردود عبر كلاس `ApiEnvelope` بالشكل المعياري التالي:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... },
  "timestamp": "2026-10-17T12:00:00.000Z"
}
```
وفي حال حدوث خطأ:
```json
{
  "success": false,
  "message": "وصف الخطأ أو كود الخطأ",
  "errors": {
    "email": ["Email already taken"]
  }
}
```

---

## 3. تفاصيل الـ Endpoints المطلوبة من الـ Backend

### أ. الملف الشخصي (Profile & Avatar)

#### 1. جلب بيانات السائق الحالي (Get Driver Profile)
- **Method:** `GET`
- **Endpoint:** `/driver/profile` أو تفعيل وإكمال `/auth/me`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Response Data:**
```json
{
  "id": "uuid-here",
  "name": "Hamza Barakat",
  "email": "hamza.barakat@gmail.com",
  "phone": "+966550000000",
  "rating": 4.92,
  "photoUrl": "https://cdn.example.com/avatars/driver_123.jpg",
  "vehicle": {
    "type": "VAN",
    "number": "PAL-99488",
    "model": "Toyota Hiace",
    "colour": "White",
    "loadCapacityKg": 400
  },
  "company": {
    "id": "comp-123",
    "name": "Red Sea Express",
    "code": "RSX482",
    "joinedAt": "2026-10-06T00:00:00Z",
    "logoUrl": "https://cdn.example.com/logos/rsx.png",
    "phone": "+966126004400",
    "email": "drivers@redsea.express"
  }
}
```

#### 2. تحديث الملف الشخصي (Update Profile)
- **Method:** `PATCH` أو `PUT`
- **Endpoint:** `/driver/profile`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Request Body:**
```json
{
  "name": "Hamza Barakat",
  "email": "hamza.new@gmail.com",
  "phone": "+966551112233"
}
```
- **حالات الخطأ:**
  - `400 / 422`: في حال كان البريد الإلكتروني أو الهاتف مستخدماً لحساب آخر (`email_taken` / `phone_taken`).

#### 3. رفع صورة الملف الشخصي (Upload Avatar)
- **Method:** `POST`
- **Endpoint:** `/driver/avatar` (أو إرسالها مع تحديث الملف الشخصي)
- **Content-Type:** `multipart/form-data`
- **Body Fields:**
  - `file`: (image/jpeg, image/png)
- **Response Data:**
```json
{
  "photoUrl": "https://cdn.example.com/avatars/driver_123.jpg"
}
```

---

### ب. الأمان وتغيير كلمة المرور (Security & Password)

#### 1. تغيير كلمة المرور لمستخدم مسجل (Change Password)
- **Method:** `POST`
- **Endpoint:** `/auth/change-password` أو `/driver/change-password`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Request Body:**
```json
{
  "currentPassword": "OldPassword123!",
  "newPassword": "NewStrongPassword123!"
}
```
- **حالات الرد:**
  - `200 OK`: تم التغيير بنجاح.
  - `400 Bad Request`: كلمة المرور الحالية غير صحيحة (`invalid_current_password`).

---

### ج. إدارة الأساطيل (Fleets & Join Requests)

#### 1. جلب الأساطيل القريبة (Get Nearby Fleets)
- **Method:** `GET`
- **Endpoint:** `/fleets/nearby`
- **Query Params (اختياري):** `?lat=21.5433&lng=39.1728&radius=10`
- **Response Data:**
```json
[
  {
    "id": "red-sea-express",
    "name": "Red Sea Express",
    "area": "Al Hamra",
    "distanceKm": 1.2,
    "logoUrl": "https://..."
  },
  {
    "id": "ktn-wears",
    "name": "KTN Wears",
    "area": "Al Rawdah",
    "distanceKm": 2.6,
    "logoUrl": "https://..."
  }
]
```

#### 2. البحث عن أسطول برمز الانضمام (Find Fleet by Code)
- **Method:** `GET`
- **Endpoint:** `/fleets/by-code/:code` (أو `/fleets/search?code=RSX482`)
- **Response Data:** بيانات الأسطول المطابق للكود، أو `404 Not Found` إن لم يوجد.

#### 3. إرسال طلب انضمام لأسطول (Send Join Request)
- **Method:** `POST`
- **Endpoint:** `/fleets/:id/join`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Response:**
```json
{
  "requestId": "req-987",
  "status": "PENDING",
  "requestedAt": "2026-10-17T12:00:00Z"
}
```

#### 4. إلغاء طلب الانضمام المعلق (Cancel Join Request)
- **Method:** `DELETE` أو `POST`
- **Endpoint:** `/fleets/:id/cancel-join` أو `/fleets/requests/:requestId`

---

### د. الدعم الفني والإبلاغ عن مشكلة (Help Center & Support)

#### 1. إرسال بلاغ عن مشكلة (Submit Problem Report)
- **Method:** `POST`
- **Endpoint:** `/support/reports`
- **Content-Type:** `multipart/form-data`
- **Body Fields:**
  - `category`: (e.g. `APP_BUG`, `VEHICLE`, `ORDER_ISSUE`, `ACCOUNT`, `OTHER`)
  - `description`: نص المشكلة (حتى 500 حرف)
  - `includeDeviceDetails`: boolean (`true` / `false`)
  - `deviceModel`: (e.g. `Samsung Galaxy S23 - Android 14`)
  - `appVersion`: (e.g. `1.0.0+1`)
  - `screenshots`: مصفوفة صور (حتى 3 صور اختيارية)
- **Response Data:**
```json
{
  "ticketNumber": "RPT-4821",
  "status": "OPEN",
  "createdAt": "2026-10-17T12:10:00Z"
}
```

---

### هـ. تسجيل الخروج وإبطال الجلسة (Logout)

#### 1. تسجيل الخروج من السيرفر (Server Logout)
- **Method:** `POST`
- **Endpoint:** `/auth/logout`
- **Headers:** `Authorization: Bearer <accessToken>`
- **Request Body:**
```json
{
  "refreshToken": "optional-token-to-revoke"
}
```
- **الهدف:** إبطال صلاحية الـ Refresh Token في قاعدة البيانات لمنع استخدامه لاحقاً.

---

## 4. قائمة التحقق للـ Backend (Checklist)

| المسار المطلوب | Method | الأولوية | الحالة لدى الباك إند |
| :--- | :---: | :---: | :---: |
| `/auth/me` أو `/driver/profile` | `GET` | 🔴 عاجل جداً | [ ] |
| `/driver/profile` | `PATCH` | 🔴 عاجل جداً | [ ] |
| `/driver/avatar` | `POST` | 🟡 متوسطة | [ ] |
| `/auth/change-password` | `POST` | 🔴 عاجل | [ ] |
| `/auth/logout` | `POST` | 🟡 متوسطة | [ ] |
| `/fleets/nearby` | `GET` | 🟡 متوسطة | [ ] |
| `/fleets/by-code/:code` | `GET` | 🟡 متوسطة | [ ] |
| `/fleets/:id/join` | `POST` | 🟡 متوسطة | [ ] |
| `/fleets/:id/cancel-join` | `DELETE` | 🟢 منخفضة | [ ] |
| `/support/reports` | `POST` | 🟡 متوسطة | [ ] |

---

## 5. ملاحظات إضافية لتسهيل الربط
1. **تفضيلات السائق المحلية (Settings Preferences):**
   - إعدادات مثل (اللغة، الثيم الداكن/الفاتح، التطبيق الافتراضي للملاحة Google Maps / Waze، وتنبيهات الإشعارات وساعات الهدوء) يمكن للتطبيق الاحتفاظ بها محلياً على الجهاز عبر `SharedPreferences`. إذا كنتم تفضلون مزامنتها عبر الحساب لتظهر على أكثر من جهاز، يمكن إضافة مسار اختياري: `PUT /driver/preferences`.
2. **التوثيق (Authentication):**
   - الـ Mobile Client يرسل تلقائياً الـ Access Token في الترويسات، كما يملك آلية جاهزة لإعادة طلب التوكن تلقائياً (`401 Auto-Refresh`) باستخدام الـ `refreshToken`.
