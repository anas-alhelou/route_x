# الأزرار والتدفقات المؤجلة — نقاط الربط وما ينقص

> مصدر هذا الجرد: قراءة الكود (`TODO` والدوال الفارغة `() {}`) بتاريخ 2026-11-15.
> لم يتغير سلوك أي زر. الأزرار تبقى ظاهرة كما هي حتى يجهز الباكند أو التصميم.
> ما يخص الباكند منها مكرر في `Backend_MVP_Requests.md` حيث ورد هناك.

## كيف تقرأ الجدول
- **الحالة:** `باكند` = ينتظر endpoint · `تصميم` = لا شاشة مصممة بعد · `بلا باكند` = يمكن ربطه الآن إن أردنا.
- **نقطة الربط:** الملف والسطر الذي يُستبدل فيه الفراغ.

## 1) تنتظر الباكند

| # | الزر / التدفق | نقطة الربط | الحالة | ما ينقص |
|---|---|---|---|---|
| 1 | **تعذّر التسليم** (من ContactStepsSheet: "تعذّر التسليم") | `route_fleet/presentation/widgets/contact_steps_sheet.dart:31` (`onMarkCouldntDeliverTapped`)، و`route_fleet_cubit.dart:266` (طابور المزامنة دون اتصال) | باكند (مطلوب أصلاً: بند 1 في الملف) | Endpoint يستقبل `orderId` + السبب (العميل لا يرد / موقع خاطئ / تعذّر) + ملاحظة وصورة اختياريتين |
| 2 | **موقع خاطئ** | `route_fleet/data/datasources/route_fleet_api_data_source.dart:56` | باكند | نفس endpoint أعلاه بسبب "موقع خاطئ" |
| 3 | **اتصال بالعميل / مراسلته** | `contact_steps_sheet.dart:27,29` (`onCallAgainTapped`, `onMessageTapped`) | بلا باكند جزئياً | رقم العميل داخل بيانات الطلب (إن كان يصل) لفتح الاتصال والرسائل بـ `url_launcher`. إن لم يصل الرقم فباكند |
| 4 | **سجل الطلبات المنتهية** | شاشات السجل في `orders/` | باكند (بند 2) | `GET` للموصّلة والملغاة مع `deliveredAt` |
| 5 | **رفع fcmToken** | `core/notifications/push_messaging_service.dart:87` و`auth/presentation/controllers/login_bloc.dart:225` | باكند (بند 4) | Endpoint لتحديث الرمز + فصل رموز Android عن الويب |
| 6 | **مراسلة الإدارة (Dispatch) من تفاصيل الطلب** | `orders/presentation/pages/order_detail_page.dart:235` (`MessageDispatchButton`) | باكند + تصميم | Endpoint إرسال رسالة مرتبطة بـ`orderId`، أو رقم/قناة الإدارة |
| 7 | **ورقة المساعدة داخل المسار**: اتصال بالإدارة / رسالة / مشكلة بالمركبة / غير آمن | `route_fleet/presentation/pages/route_fleet_page.dart:168-172` و`route_page.dart:689-697` | باكند + تصميم | رقم الإدارة من بيانات الشركة (للاتصال)، وendpoint لبلاغ "مشكلة بالمركبة" و"غير آمن". واسم الشركة مكتوب ثابتاً `Red Sea Express` (`route_page.dart:688`، `route_fleet_page.dart:166`) فيجب أن يأتي من بيانات الشركة |
| 8 | **تحديث المركبة** | `home/presentation/widgets/go_online/go_online_actions.dart:100` و`route_fleet/presentation/widgets/declined_status_card.dart:158` (يربطه اليوم `route_fleet_page.dart:731` مؤقتاً بـ `goToFindFleet()`) | باكند + تصميم | تأكيد: هل تحديث بيانات المركبة (النوع واللوحة) موجود في endpoint الملف الشخصي؟ وإن لم يكن فمطلوب. ويلزم تصميم الشاشة |
| 9 | **عرض الطلب** (طلب الانضمام) | `go_online_actions.dart:65` | باكند + تصميم | Endpoint حالة طلب الانضمام الحالي (الحالة، الشركة، تاريخ الإرسال). وشاشتا `request_pending_view` و`request_approved_view` موجودتان في `route_fleet/` وقد تصلحان، يلزم التأكد |
| 10 | **اسأل المدير** | `home/presentation/pages/enter_fleet_code_page.dart:180-181` (`onAskManager: () {}`) | باكند + تصميم | جهة اتصال المدير للشركة (اسم/هاتف) أو endpoint رسالة، ولا وجهة مصممة بعد |
| 11 | **تفاصيل أيام الطلبات / مراجعة الطلبات الجديدة** | `orders/presentation/pages/orders_today_page.dart:376` (`onReviewPressed`) و`:411` (`onTap` للصف) | باكند | جدولة لكل يوم وبحث (`order_search_api_data_source.dart:13`) |
| 12 | **ملاحظة التسليم** | `route_fleet/presentation/widgets/arrival_sheet.dart:126` | تصميم + باكند | ورقة الملاحظة، وحفظها (مع endpoint تعذّر التسليم أو endpoint ملاحظات الطلب) |
| 13 | **حقول ناقصة في بيانات الطلب** | `orders/data/datasources/*` (`TODO(backend)`) | باكند | نافذة التسليم، ترتيب التوقف، الوقت المقدّر للانتهاء، المسافة، اسم الشركة، رمز البوابة، عدد الممسوح، رموز "مسحوب" و"منتهي" |

## 2) تنتظر قراراً أو تصميماً

| الزر | نقطة الربط | ملاحظة |
|---|---|---|
| **المساعدة** (قبل إدخال الرمز) | `home/presentation/widgets/enter_code_help_button.dart:31` | لا وجهة مصممة. توجد `help_center_page.dart` في الإعدادات فقد تصلح |
| **سياسة الخصوصية** | `settings/presentation/pages/settings_page.dart:253` | يلزم رابط السياسة. (سبق قرارك: تبقى TODO) |
| **توصيل صفحة المسار** | `route_page.dart:661` (انتقال R12)، و`:675` (توصيل لتوقف آخر)، و`:880-881` (بدء المسار وحزمة مفقودة) | مواضع في معاينة المسار/الفراغات تنتظر تدفق R12 |

## 3) يمكن ربطه الآن بلا باكند (إن أردت)

| الزر | نقطة الربط | الفكرة |
|---|---|---|
| ترويسة بطاقة السائق: الإعدادات والملف | `home/presentation/pages/home_dashboard_page.dart:147-148` | الانتقال إلى صفحتي الإعدادات والملف الموجودتين |
| إغلاق بطاقة الإشعار الداخلية | `home/presentation/pages/delivery_dashboard_page.dart:395` (`onDismiss`) | إخفاء البطاقة محلياً |
| الاتصال بالإدارة (جزء من البند 7) | `route_page.dart:689`، `route_fleet_page.dart:168` | إن وُجد رقم الشركة في الملف الشخصي (`company_contact.dart`) فيكفي `url_launcher` |

## ما نطلبه من الباكند (ملخص)
1. Endpoint تعذّر التسليم (السبب + ملاحظة/صورة) ويغطي "موقع خاطئ".
2. `GET` سجل الطلبات المنتهية.
3. Endpoint تحديث `fcmToken` وفصل Android/Web.
4. جهة اتصال الإدارة/المدير للشركة (اسم وهاتف) وendpoint رسالة.
5. Endpoint بلاغ مشكلة المركبة / غير آمن.
6. حالة طلب الانضمام الحالي، وتحديث بيانات المركبة (أو تأكيد أنه في الملف الشخصي).
7. حقول الطلب الناقصة (البند 13 أعلاه).
8. تأكيد معرّف Google الجديد (`1033509692006-07h4pq07baikpie8uik9vbrsmvocpmoq.apps.googleusercontent.com`) وإرسال FCM من مشروع `route-x-edb69`.
