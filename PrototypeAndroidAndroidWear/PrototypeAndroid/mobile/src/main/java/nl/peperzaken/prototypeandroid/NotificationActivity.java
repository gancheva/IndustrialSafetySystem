package nl.peperzaken.prototypeandroid;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;


public class NotificationActivity extends Activity {

    private EditText editableTextField;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notification);
        editableTextField = (EditText) findViewById(R.id.notificationTextView);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_notification, menu);
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

    /* help method for hiding the keyboard and clearing the shown text */
    private void hideTextAndKeyboard() {
        // clear text in TextField and hide keyboard
        editableTextField.setText("");
        InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        mgr.hideSoftInputFromWindow(editableTextField.getWindowToken(), 0);
    }

    /* buttons */
    public void dismiss(View view) {
        hideTextAndKeyboard();
        onBackPressed();
    }

    public void send(View view) {
        String message = editableTextField.getText().toString();
        WearNotificationManager.getInstance().notifyWear(this, "New notification", message);
        hideTextAndKeyboard();
    }

}
