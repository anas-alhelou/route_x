# Notifications Feature

The driver's notifications inbox: populates new and earlier notifications, handles unread statuses, mark all as read, and empty state.

## Structure

```
lib/features/notifications/
├── domain/
│   ├── entities/        # AppNotification entity & AppNotificationKind enum
│   ├── repositories/    # NotificationsRepository contract
│   └── usecases/        # GetNotifications, MarkAllNotificationsRead, ToggleNotificationsEmpty
│
├── data/
│   ├── models/          # AppNotificationModel (JSON serialization / DTO)
│   ├── datasources/     # NotificationsLocalDataSource (mock scenarios N01 & N02)
│   └── repositories/    # NotificationsRepositoryImpl
│
├── presentation/
│   ├── bloc/            # NotificationsBloc, event, and state
│   ├── routes/          # NotificationsRoutes
│   ├── pages/           # NotificationsPage
│   └── widgets/         # NotificationCard, NotificationsEmptyState, PopulatedNotificationsList
│
└── README.md
```

## Figma Reference
- **N01**: Populated Notifications list (New / Earlier sections, unread indicators)
- **N02**: Empty Notifications state (3D bell illustration, empty headline and description)
