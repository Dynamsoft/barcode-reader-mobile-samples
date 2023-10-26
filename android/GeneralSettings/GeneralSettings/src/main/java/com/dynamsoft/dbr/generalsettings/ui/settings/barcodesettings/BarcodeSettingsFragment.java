package com.dynamsoft.dbr.generalsettings.ui.settings.barcodesettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.dynamsoft.dbr.generalsettings.MainViewModel;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentBarcodeSettingsBinding;

public class BarcodeSettingsFragment extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        FragmentBarcodeSettingsBinding binding = FragmentBarcodeSettingsBinding.inflate(inflater, container, false);
        MainViewModel viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);
        binding.setBarcodeSettings(viewModel.barcodeSettings);
        return binding.getRoot();
    }
}