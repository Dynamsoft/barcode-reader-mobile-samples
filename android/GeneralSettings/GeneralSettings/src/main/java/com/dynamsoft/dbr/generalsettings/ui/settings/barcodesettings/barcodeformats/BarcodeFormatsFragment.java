package com.dynamsoft.dbr.generalsettings.ui.settings.barcodesettings.barcodeformats;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.dynamsoft.dbr.generalsettings.MainViewModel;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentBarcodeFormatsBinding;

public class BarcodeFormatsFragment extends Fragment {
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        FragmentBarcodeFormatsBinding binding = FragmentBarcodeFormatsBinding.inflate(inflater, container, false);
        MainViewModel viewModel = new ViewModelProvider(requireActivity()).get(MainViewModel.class);

        BarcodeFormatsUtil barcodeFormatsUtil = new BarcodeFormatsUtil();

        BarcodeFormatsAdapter adapterOned = new BarcodeFormatsAdapter(viewModel.barcodeSettings, barcodeFormatsUtil, barcodeFormatsUtil.getListOneDStringId(),15);
        binding.recyclerFormatsOned.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recyclerFormatsOned.setAdapter(adapterOned);
        binding.ivOneD.setOnClickListener(v -> showSubView((ImageView) v, binding.recyclerFormatsOned));

        BarcodeFormatsAdapter adapterGs1 = new BarcodeFormatsAdapter(viewModel.barcodeSettings, barcodeFormatsUtil, barcodeFormatsUtil.getListGs1DatabarStringId(),15);
        binding.recyclerFormatsGs1.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recyclerFormatsGs1.setAdapter(adapterGs1);
        binding.ivGS1Databar.setOnClickListener(v -> showSubView((ImageView)v, binding.recyclerFormatsGs1));

        BarcodeFormatsAdapter adapterPostal = new BarcodeFormatsAdapter(viewModel.barcodeSettings, barcodeFormatsUtil, barcodeFormatsUtil.getListPostalCodeStringId(),15);
        binding.recyclerFormatsPostal.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recyclerFormatsPostal.setAdapter(adapterPostal);
        binding.ivPostalCode.setOnClickListener(v -> showSubView((ImageView)v, binding.recyclerFormatsPostal));

        BarcodeFormatsAdapter adapterOther = new BarcodeFormatsAdapter(viewModel.barcodeSettings, barcodeFormatsUtil, barcodeFormatsUtil.getListOtherFormatsStringId(),15);
        binding.recyclerFormatsOther.setLayoutManager(new LinearLayoutManager(requireContext()));
        binding.recyclerFormatsOther.setAdapter(adapterOther);

        return binding.getRoot();
    }

    public void showSubView(ImageView clickView, View subView){
        if(subView.getVisibility() == View.GONE){
            subView.setVisibility(View.VISIBLE);
            clickView.setImageResource(R.drawable.arrow_up);
        } else if(subView.getVisibility() == View.VISIBLE){
            subView.setVisibility(View.GONE);
            clickView.setImageResource(R.drawable.arrow_down);
        }
    }
}