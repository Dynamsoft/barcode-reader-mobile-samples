package com.dynamsoft.generalsettings;

import android.app.AlertDialog;
import android.content.Context;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.view.ContextThemeWrapper;
import androidx.fragment.app.Fragment;
import androidx.navigation.fragment.NavHostFragment;


public abstract class BaseFragment extends Fragment {
    @Override
    public void onResume() {
        super.onResume();
        setHasOptionsMenu(true);
        setupActionBar();
    }



    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            requireActivity().onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void setupActionBar() {
        AppCompatActivity activity = (AppCompatActivity) requireActivity();
        ActionBar actionBar = activity.getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setTitle(getTitle());
        }
    }

    protected abstract String getTitle();

    protected void moveToFragment(int action){
        NavHostFragment.findNavController(BaseFragment.this).navigate(action);
    }

    protected void showTip(int titleId, int messageId) {
        AlertDialog dialog = new AlertDialog
                .Builder(new ContextThemeWrapper(getContext(), R.style.CustomDialogTheme))
                .setTitle(titleId)
                .setMessage(messageId)
                .create();
        dialog.show();
    }

    protected void hideKeyboard(View focusedView) {
        try {
            InputMethodManager imm = (InputMethodManager) requireContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(focusedView.getWindowToken(), 0);
        } catch (Exception e) {
            Log.e(getClass().getSimpleName(), "Error closing the keyboard", e);
        }
    }

    protected boolean checkEditText(){
        return true;
    }

}
