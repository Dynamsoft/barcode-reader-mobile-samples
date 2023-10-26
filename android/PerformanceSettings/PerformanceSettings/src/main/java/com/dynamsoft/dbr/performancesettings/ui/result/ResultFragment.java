package com.dynamsoft.dbr.performancesettings.ui.result;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.MainThread;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.dynamsoft.core.basic_structures.CapturedResult;
import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.dbr.BarcodeResultItem;
import com.dynamsoft.dbr.performancesettings.ImageUtil;
import com.dynamsoft.dbr.performancesettings.R;
import com.dynamsoft.dbr.performancesettings.databinding.FragmentResultBinding;
import com.psoffritti.slidingpanel.PanelState;

import java.util.ArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ResultFragment extends Fragment {

    private FragmentResultBinding binding;
    private byte[] jpegBytes;
    private String mCurrentTemplate;
    private boolean isCapturing = false;

    private final MutableLiveData<CapturedResult> mResultLiveData = new MutableLiveData<>();
    private static final ExecutorService mDecodeThread = Executors.newSingleThreadExecutor();
    private ResultViewModel mViewModel;

    public static ResultFragment newInstance(byte[] fileBytes, String template) {
        ResultFragment resultFragment = new ResultFragment();
        resultFragment.jpegBytes = fileBytes;
        resultFragment.mCurrentTemplate = template;
        return resultFragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewModel = new ViewModelProvider(this).get(ResultViewModel.class);
        if (savedInstanceState == null) {
            //use ViewModel save instance state
            mViewModel.jpegBytes = jpegBytes;
            mViewModel.templateName = mCurrentTemplate;
        }
    }

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        binding = FragmentResultBinding.inflate(inflater, container, false);
        initView();
        return binding.getRoot();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    public void initView() {
        binding.pbDecoding.setVisibility(View.VISIBLE);

        Bitmap bitmap = ImageUtil.jpegBytesToBitmap(mViewModel.jpegBytes);
        int scale = ImageUtil.getScaleFromJpegBytes(mViewModel.jpegBytes);
        binding.ivPhotoDetail.setImageBitmap(bitmap);

        mDecodeThread.submit(() -> {
            isCapturing = true;
            CaptureVisionRouter cvr = new CaptureVisionRouter(requireContext());
            CapturedResult result = cvr.capture(mViewModel.jpegBytes, mViewModel.templateName);
            isCapturing = false;
            mResultLiveData.postValue(result);
        });

        mResultLiveData.observe(getViewLifecycleOwner(), result -> {
            if (binding == null) {
                return;
            }
            binding.pbDecoding.setVisibility(View.GONE);
            if (result == null || result.getItems() == null || result.getItems().length == 0) {
                return;
            }
            CapturedResultItem[] items = result.getItems();
            ImageUtil.drawResultsOnBitmap(bitmap, items, scale);
            showResult(result);
        });

        intiSlidingPanel();
    }

    @MainThread
    private void intiSlidingPanel() {
        binding.slidingPanel.addSlideListener((slidingPanel, panelState, v) -> {
            if (binding == null) {
                return;
            }
            if (panelState == PanelState.EXPANDED) {
                binding.ivArrow.setImageResource(R.drawable.arrow_down);
                binding.dragText.setText(getText(R.string.scroll_down));
            } else {
                binding.ivArrow.setImageResource(R.drawable.arrow_up);
                binding.dragText.setText(getText(R.string.more_results));
            }
        });

        binding.resultDragView.setOnClickListener(v -> {
            if (binding == null) {
                return;
            }
            if (binding.slidingPanel.getState() == PanelState.COLLAPSED) {
                binding.slidingPanel.slideTo(PanelState.EXPANDED);
            } else {
                binding.slidingPanel.slideTo(PanelState.COLLAPSED);
            }
        });
    }

    @MainThread
    private void showResult(CapturedResult result) {
        binding.pbDecoding.setVisibility(View.GONE);
        if (result == null || result.getItems() == null || result.getItems().length == 0 || binding == null) {
            return;
        }
        CapturedResultItem[] items = result.getItems();
        ArrayList<Pair<String, String>> resultsList = new ArrayList<>();
        for (CapturedResultItem capturedResultItem : items) {
            BarcodeResultItem item = (BarcodeResultItem) capturedResultItem;
            resultsList.add(new Pair<>(item.getFormatString(), item.getText()));
        }
        binding.tvToal.setText(String.format(getString(R.string.Total), resultsList.size()));
        ResultAdapter resultAdapter = new ResultAdapter(resultsList);
        binding.rvResultsList.setLayoutManager(new LinearLayoutManager(getContext()));
        binding.rvResultsList.setAdapter(resultAdapter);
    }

    public void showTip() {
        Toast.makeText(requireContext(), "Please wait for decoding to complete before returning.", Toast.LENGTH_SHORT).show();
    }

    public boolean isCapturing() {
        return isCapturing;
    }
}