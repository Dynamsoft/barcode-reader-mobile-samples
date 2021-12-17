package com.dynamsoft.generalsettings.settings.barcodesettings.barcodeformats;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.dynamsoft.generalsettings.BaseFragment;
import com.dynamsoft.generalsettings.R;

public class BarcodeFormatsFragment extends BaseFragment {

    private BarcodeFormatsViewModel viewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        viewModel = new ViewModelProvider(requireActivity()).get(BarcodeFormatsViewModel.class);
        viewModel.initFormatsMap();
    }

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_barcode_formats, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        BarcodeFormatsAdapter adapterOned = new BarcodeFormatsAdapter(viewModel, viewModel.getListOned(),15);
        RecyclerView recyclerOned = view.findViewById(R.id.recycler_formats_oned);
        recyclerOned.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerOned.setAdapter(adapterOned);
        view.findViewById(R.id.iv_OneD).setOnClickListener(v -> showSubView(v, recyclerOned));

        BarcodeFormatsAdapter adapterGs1 = new BarcodeFormatsAdapter(viewModel, viewModel.getListGs1Databar(),15);
        RecyclerView recyclerGs1 = view.findViewById(R.id.recycler_formats_gs1);
        recyclerGs1.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerGs1.setAdapter(adapterGs1);
        view.findViewById(R.id.iv_GS1_Databar).setOnClickListener(v -> showSubView(v, recyclerGs1));

        BarcodeFormatsAdapter adapterPostal = new BarcodeFormatsAdapter(viewModel, viewModel.getListPostalCode(),15);
        RecyclerView recyclerPostal = view.findViewById(R.id.recycler_formats_postal);
        recyclerPostal.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerPostal.setAdapter(adapterPostal);
        view.findViewById(R.id.iv_Postal_Code).setOnClickListener(v -> showSubView(v, recyclerPostal));

        BarcodeFormatsAdapter adapterOther = new BarcodeFormatsAdapter(viewModel, viewModel.getListOtherFormats());
        RecyclerView recyclerOther = view.findViewById(R.id.recycler_formats_other);
        recyclerOther.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerOther.setAdapter(adapterOther);
    }

    @Override
    protected String getTitle() {
        return "Barcode Formats";
    }

    public void showSubView(View clickView, View subView){
        if(subView.getVisibility() == View.GONE){
            subView.setVisibility(View.VISIBLE);
            clickView.setBackground(ResourcesCompat.getDrawable(getResources(),R.drawable.arrow_up,null));
        } else if(subView.getVisibility() == View.VISIBLE){
            subView.setVisibility(View.GONE);
            clickView.setBackground(ResourcesCompat.getDrawable(getResources(),R.drawable.arrow_down,null));
        }
    }
}
