package com.dynamsoft.dbr.generalsettings.settings.barcodeformat;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.dynamsoft.dbr.generalsettings.databinding.FragmentBarcodeFormatBinding;
import com.dynamsoft.dbr.generalsettings.ui.ExpandLinearLayout;
import com.dynamsoft.dbr.generalsettings.ui.formatselection.FormatSelectionView;

public class BarcodeFormatsFragment extends Fragment {

    private BarcodeFormatsViewModel viewModel;
    private FragmentBarcodeFormatBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        viewModel = new ViewModelProvider(this).get(BarcodeFormatsViewModel.class);
        binding = FragmentBarcodeFormatBinding.inflate(inflater, container, false);
        binding.setViewModel(viewModel);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        requireActivity().setTitle("Barcode Formats");
        binding.setLifecycleOwner(getViewLifecycleOwner());

        linkExpandTitleAndFormatSelection(binding.expandOned, binding.selectionOned);
        linkExpandTitleAndFormatSelection(binding.expandTwod, binding.selectionTwod);
        linkExpandTitleAndFormatSelection(binding.expandPharmaCode, binding.selectionPharmaCode);
        linkExpandTitleAndFormatSelection(binding.expandOthers, binding.selectionOthers);
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        binding = null;
    }

    private void linkExpandTitleAndFormatSelection(ExpandLinearLayout expandLinearLayout, FormatSelectionView formatSelectionView) {
        if (expandLinearLayout.switchCompat == null) {
            return;
        }
        expandLinearLayout.switchCompat.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                formatSelectionView.allChecked();
            } else if (buttonView.isPressed()) {
                formatSelectionView.allUnchecked();
            }
        });
        formatSelectionView.setOnMultiSelectionCallback((position, representValue, isThisChecked, allChecked, allUnchecked) -> {
            expandLinearLayout.switchCompat.setChecked(allChecked);
        });
    }
}