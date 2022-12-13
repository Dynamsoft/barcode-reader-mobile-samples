package com.dynamsoft.generalsettings;

import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.view.KeyEvent;

import android.view.Menu;

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