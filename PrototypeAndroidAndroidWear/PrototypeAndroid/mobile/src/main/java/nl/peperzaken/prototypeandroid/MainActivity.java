package nl.peperzaken.prototypeandroid;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.content.Intent;
import android.widget.TextView;

import java.util.Random;


public class MainActivity extends Activity {

    private static final String TAG = "MainActivity";
    private static MainActivity staticSelf;
    private static TextView mainTextView;
    private GPSTracker gpsTracker;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        staticSelf = this;
        mainTextView = (TextView) findViewById(R.id.mainTextView);
        requestGPSStart();
    }

    @Override
    protected void onStop () {
        gpsTracker.stopUsingGPS();
        super.onStop();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        if (id == R.id.action_settings) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    /* help method*/
    private void requestGPSStart() {
        gpsTracker = new GPSTracker(MainActivity.this);
        if (!gpsTracker.canGetLocation()) {
            gpsTracker.showSettingsAlert();
        }
    }

    /* buttons */
    public void showCurrentLocation(View view) {
        String message = "Current location unknown.\nNo GPS data available.";

        if (gpsTracker.canGetLocation()) {
            // testing GPSTracker
            //double latitude = gpsTracker.getLatitude();
            //double longitude = gpsTracker.getLongitude();
            //message = "Current location:\nlatitude = " + latitude + "\nlongitude = " + longitude + "\nFollow the safety instructions for this zone.";
            message = "Current location: " + pickZone() + "\nFollow the instructions for this zone";
        }
        updateScreens("Current location", message);
    }

    public void openNotificationScreen(View view) {
        Intent intent = new Intent(this, NotificationActivity.class);
        startActivity(intent);
    }

    public void alarmWatch(View view) {
        mainTextView.setText("ALARM sent to wear!");
        WearNotificationManager.getInstance().notifyWear(this, "ALARM", "Alarm received! Follow the safety instructions.");
    }

    public void showAirPollution(View view) {
        updateScreens("Air pollution", "Air pollution in norm.\nNorthEast direction, 4-6 knots.");
    }

    public void showRadiation(View view) {
        updateScreens("Radiation", "Detected radiation increase!\nFollow the safety instructions.");
    }

    public void showChemicals(View view) {
        updateScreens("Chemicals", "Presence of substances hazardous to health.\nFollow all safety instructions.");
    }

    /* update mainTextView; used by BroadcastReceiver */
    public static void updateTextView (String text) {
        mainTextView.setText(text);
    }

    /* help method for updating the location; used by the GPSTracker */
    public static void updateLocation() {
        Log.d(TAG, "Location update received");
        updateScreens("Location update", "You've just entered " + pickZone() + ".\nPlease follow the safety instructions.");
    }

    /* help method for updating mobile and wearable screens */
    private static void updateScreens(String title, String message) {
        Log.d(TAG, title + ": " + message);
        mainTextView.setText(message);
        WearNotificationManager.getInstance().notifyWear(staticSelf, title, message);
    }

    /* help method; pick random zone */
    private static String pickZone() {
        Random random = new Random();
        int i = random.nextInt(4) + 1;
        return "zone " + i;
    }

}
