package nl.prototypeandroid;

import android.app.Activity;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.support.v4.app.RemoteInput;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/*
 * Singleton class for managing the sent to the wear notifications
 */
public class WearNotificationManager {

    // strings important for the communication flow between wear and phone
    // check the AndroidManifest
    public static final String EXTRA_VOICE_NOTIFICATION = "nl.prototypeandroid.EXTRA_VOICE_REPLY";
    public static final String ACTION_NOTIFY = "nl.prototypeandroid.ACTION_NOTIFY";
    public static final String EXTRA_MESSAGE = "nl.prototypeandroid.EXTRA_MESSAGE";
    public static final String ACTION_ALARM = "nl.prototypeandroid.ACTION_ALARM";

    private static WearNotificationManager instance = null;

    private WearNotificationManager() {
        // Exists only to defeat instantiation.
    }

    /* get instance method */
    public static WearNotificationManager getInstance() {
        if(instance == null) {
            instance = new WearNotificationManager();
        }
        return instance;
    }

    /* notifies the wearable */
    public void notifyWear(Activity notifier, String title, String content) {
        // request reply action
        String replyLabel = notifier.getResources().getString(R.string.wearable_reply_label);
        String[] replyChoices = notifier.getResources().getStringArray(R.array.wearable_reply_choices);

        RemoteInput remoteInput = new RemoteInput.Builder(EXTRA_VOICE_NOTIFICATION)
                .setLabel(replyLabel)
                .setChoices(replyChoices)
                .build();

        // create an intent for the reply action
        Intent alarmIntent = new Intent(notifier, WearActionHandler.class)
                .putExtra(EXTRA_MESSAGE, "Alarm action selected.")
                .setAction(ACTION_ALARM);
        PendingIntent alarmPendingIntent = PendingIntent.getBroadcast(notifier, 0, alarmIntent, 0);

        Intent replyIntent = new Intent(notifier, WearActionHandler.class)
                .putExtra(EXTRA_MESSAGE, "Notify action selected.")
                .setAction(ACTION_NOTIFY);
        PendingIntent replyPendingIntent = PendingIntent.getBroadcast(notifier, 0, replyIntent, 0);

        // create the actions
        NotificationCompat.Action actionAlarm = new NotificationCompat.Action.Builder(R.drawable.alarm_wear_action,
                notifier.getString(R.string.label_alarm), alarmPendingIntent).build();

        NotificationCompat.Action actionNotify = new NotificationCompat.Action.Builder(R.drawable.notify_wear_action,
                notifier.getString(R.string.label_notify), replyPendingIntent)
                .addRemoteInput(remoteInput)
                .build();

        List<NotificationCompat.Action> actions = new ArrayList<>(Arrays.asList(actionAlarm, actionNotify));

        // set background img for the wearable cards
        Bitmap background = BitmapFactory.decodeResource(notifier.getResources(), R.drawable.background_wear_cards);

        // init the wearable extender through which the wearable actions will be added to the notification
        NotificationCompat.WearableExtender wearableExtender = new NotificationCompat.WearableExtender()
                .setHintShowBackgroundOnly(true)
                .setBackground(background)
                .addActions(actions);


        // build the notification
        Notification notification = new NotificationCompat.Builder(notifier)
                .setSmallIcon(R.drawable.ic_launcher)
                .setContentTitle(title)
                .setContentText(content)
                .extend(wearableExtender)
                .build();

        // issue the notification
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(notifier);
        int notificationId = 1;
        notificationManager.notify(notificationId, notification);

    }

}
