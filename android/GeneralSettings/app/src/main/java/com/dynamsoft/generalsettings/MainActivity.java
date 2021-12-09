package com.dynamsoft.generalsettings;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.view.KeyEvent;

import android.view.Menu;
import android.view.MenuItem;

import com.dynamsoft.generalsettings.settings.barcodesettings.BarcodeSettingsFragment;

public class MainActivity extends AppCompatActivity {
    private BaseFragment mCurrentFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

//    @Override
//    public boolean onOptionsItemSelected(MenuItem item) {
//        // Handle action bar item clicks here. The action bar will
//        // automatically handle clicks on the Home/Up button, so long
//        // as you specify a parent activity in AndroidManifest.xml.
//        int id = item.getItemId();
//        //noinspection SimplifiableIfStatement
////        if (id == R.id.action_settings) {
////            return true;
////        }
//
//        return super.onOptionsItemSelected(item);
//    }

    public void setCurrentFragment(BaseFragment currentFragment) {
        this.mCurrentFragment = currentFragment;
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (mCurrentFragment != null && keyCode == KeyEvent.KEYCODE_BACK) {
            if (mCurrentFragment.checkEditText()) {
                return super.onKeyDown(keyCode, event);
            } else {
                return false;
            }
        }
        return super.onKeyDown(keyCode, event);
    }
}