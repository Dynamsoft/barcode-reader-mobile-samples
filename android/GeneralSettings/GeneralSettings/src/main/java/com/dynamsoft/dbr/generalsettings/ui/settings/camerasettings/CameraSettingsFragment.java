package com.dynamsoft.dbr.generalsettings.ui.settings.camerasettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.dynamsoft.dbr.generalsettings.MainViewModel;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.bean.CameraSettings;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentCameraSettingsBinding;

public class CameraSettingsFragment extends Fragment {

    FragmentCameraSettingsBinding binding;
    MainViewModel viewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentCameraSettingsBinding.inflate(inflater, container, false);
        viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);
        binding.setCameraSettings(viewModel.cameraSettings);

        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(), new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                if(checkScanRegionSettings()) {
                    NavHostFragment.findNavController(CameraSettingsFragment.this).navigateUp();
                }
            }
        });

        setHasOptionsMenu(true);
        return binding.getRoot();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            return !checkScanRegionSettings();
        } else {
            return true;
        }
    }

    private boolean checkScanRegionSettings() {
        CameraSettings settings = viewModel.cameraSettings;
        boolean hasError = false;
        if(settings.getRegionRight() < settings.getRegionLeft()) {
            int tempLeft = settings.getRegionLeft();
            settings.setRegionLeft(settings.getRegionRight());
            settings.setRegionRight(tempLeft);
            hasError = true;
        }
        if (settings.getRegionBottom() < settings.getRegionTop()) {
            int tempTop = settings.getRegionTop();
            settings.setRegionTop(settings.getRegionBottom());
            settings.setRegionBottom(tempTop);
            hasError = true;
        }
        if(hasError) {
            Toast.makeText(getContext(), getText(R.string.scan_region_settings_error), Toast.LENGTH_LONG).show();
            return false;
        } else {
            return true;
        }
    }

}