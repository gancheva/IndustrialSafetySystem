package nl.peperzaken.prototypeandroid;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.RemoteInput;
import android.util.Log;

/*
 * Broadcast receiver that handles the received from the wear notifications
 */
public class WearActionHandler extends BroadcastReceiver {

    private static final String TAG = "Wear Action Handler";

    @Override
    public void onReceive(Context context, Intent intent) {

        // if the received action is notify or alarm do smt
        if (intent.getAction().equals(WearNotificationManager.ACTION_NOTIFY)) {
            String message = intent.getStringExtra(WearNotificationManager.EXTRA_MESSAGE);
            Log.v(TAG, "Extra message from intent = " + message);

            Bundle remoteInput = RemoteInput.getResultsFromIntent(intent);
            CharSequence reply = remoteInput.getCharSequence(WearNotificationManager.EXTRA_VOICE_NOTIFICATION);
            Log.v(TAG, "User reply from wearable: " + reply);

            MainActivity.updateTextView("Received from wear:\n" + reply);

        } else if (intent.getAction().equals(WearNotificationManager.ACTION_ALARM)) {
            String message = intent.getStringExtra(WearNotificationManager.EXTRA_MESSAGE);
            Log.v(TAG, "Extra message from intent = " + message);

            MainActivity.updateTextView("Received from wear:\nALARM");

        }

    }

}
