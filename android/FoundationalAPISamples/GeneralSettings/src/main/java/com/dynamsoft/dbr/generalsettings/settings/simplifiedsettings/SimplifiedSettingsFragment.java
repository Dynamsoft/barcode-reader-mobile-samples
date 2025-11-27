package com.dynamsoft.dbr.generalsettings.settings.simplifiedsettings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentSimplifiedSettingsBinding;
import com.dynamsoft.dbr.generalsettings.settings.OnItemClickListener;
import com.dynamsoft.dbr.generalsettings.settings.barcodeformat.BarcodeFormatsFragment;

public class SimplifiedSettingsFragment extends Fragment implements OnItemClickListener {

    private SimplifiedSettingsViewModel viewModel;
    private FragmentSimplifiedSettingsBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        viewModel = new ViewModelProvider(this).get(SimplifiedSettingsViewModel.class);
        viewModel.setOnItemClickListener(this);
        binding = FragmentSimplifiedSettingsBinding.inflate(inflater, container, false);
        binding.setViewModel(viewModel);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        requireActivity().setTitle("Simplified Settings");
        binding.setLifecycleOwner(getViewLifecycleOwner());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        binding = null;
    }

    @Override
    public void onItemClick(String item) {
        if(requireContext().getString(R.string.barcode_formats).equals(item)) {
            goToBarcodeFormat();
        }
    }

    public void goToBarcodeFormat() {
        requireActivity().runOnUiThread(() ->
                requireActivity().getSupportFragmentManager().beginTransaction()
                        .replace(R.id.container, new BarcodeFormatsFragment())
                        .addToBackStack("BarcodeFormatsFragment")
                        .commit());
    }
}