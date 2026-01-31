# Manter classes do Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Manter classes de agendamento e receivers
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver

# Evitar erros com Timezone
-keep class androidx.lifecycle.** { *; }

# Manter classes do Firebase Messaging e Boot (se estiver usando)
-keep class io.flutter.plugins.firebase.messaging.** { *; }