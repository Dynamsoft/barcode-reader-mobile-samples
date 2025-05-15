package com.dynamsoft.dbr.generalsettings.settings;

import android.app.AlertDialog;
import android.os.Bundle;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.URLUtil;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.CaptureVisionRouterException;
import com.dynamsoft.dbr.generalsettings.R;
import com.dynamsoft.dbr.generalsettings.databinding.DialogImportTemplateBinding;
import com.dynamsoft.dbr.generalsettings.databinding.FragmentSettingsBinding;
import com.dynamsoft.dbr.generalsettings.settings.simplifiedsettings.SimplifiedSettingsFragment;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class SettingsFragment extends Fragment implements OnItemClickListener {

    private SettingsViewModel viewModel;
    private FragmentSettingsBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        viewModel = new ViewModelProvider(this).get(SettingsViewModel.class);
        viewModel.setOnItemClickListener(this);
        binding = FragmentSettingsBinding.inflate(inflater, container, false);
        binding.setViewModel(viewModel);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        requireActivity().setTitle("Settings");
        binding.setLifecycleOwner(getViewLifecycleOwner());
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        binding = null;
    }

    @Override
    public void onItemClick(String item) {
        if (requireContext().getString(R.string.import_template).equals(item)) {
            importTemplate();
        } else if (requireContext().getString(R.string.export_template).equals(item)) {
            exportTemplate();
        } else if (requireContext().getString(R.string.configure_simplified_settings).equals(item)) {
            goToSimplifiedSettings();
        } else if (requireContext().getString(R.string.restore_default).equals(item)) {
            new AlertDialog.Builder(requireContext())
                    .setMessage(R.string.restore_default_tip)
                    .setNegativeButton("Cancel", null)
                    .setPositiveButton("Continue", (dialog, which) -> viewModel.resetSettings())
                    .show();
        }
    }

    private void importTemplate() {
        DialogImportTemplateBinding dialogBinding = DialogImportTemplateBinding.inflate(getLayoutInflater());
        AlertDialog alertDialog = new AlertDialog.Builder(requireContext())
                .setTitle("Please input a JSON link")
                .setPositiveButton("OK", null)
                .setNegativeButton("Cancel", null)
                .setView(dialogBinding.getRoot())
                .create();
        alertDialog.setOnShowListener(dialogInterface -> alertDialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(v -> {
            dialogBinding.pbForImport.setVisibility(View.VISIBLE);
            String text = dialogBinding.etImportTemplate.getText().toString();
            if (Patterns.WEB_URL.matcher(text).matches() || URLUtil.isValidUrl(text)) {
                if (text.startsWith("http://")) {
                    text = new StringBuilder(text).insert(4, "s").toString();
                } else if (!text.contains("http://") && !text.contains("https://")) {
                    text = "https://" + text;
                }
            } else {
                dialogBinding.pbForImport.setVisibility(View.GONE);
                dialogBinding.tvImportError.setVisibility(View.VISIBLE);
                dialogBinding.tvImportError.setText("Error: This is not a correct site.");
                return;
            }
            String finalText = text;
            new Thread(() -> {
                try {
                    URL url = new URL(finalText);
                    HttpURLConnection urlConnection = ((HttpURLConnection) url.openConnection());
                    try (InputStream is = urlConnection.getInputStream();
                         BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(is))) {
                        String line;
                        StringBuilder stringBuilder = new StringBuilder();
                        while ((line = bufferedReader.readLine()) != null) {
                            stringBuilder.append(line);
                        }
                        viewModel.updateImportedTemplate(stringBuilder.toString());
                    }
                    requireActivity().runOnUiThread(alertDialog::dismiss);
                } catch (IOException e) {
                    requireActivity().runOnUiThread(() -> {
                        dialogBinding.pbForImport.setVisibility(View.GONE);
                        dialogBinding.tvImportError.setVisibility(View.VISIBLE);
                        dialogBinding.tvImportError.setText("Error: " + e.getMessage());
                    });
                } catch (CaptureVisionRouterException e) {
                    requireActivity().runOnUiThread(() -> Toast.makeText(requireContext(), e.getMessage(), Toast.LENGTH_SHORT).show());
                }
            }).start();
        }));
        alertDialog.show();
    }

    private void exportTemplate() {
        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss", Locale.getDefault());
        String timeString = format.format(System.currentTimeMillis());
        File savedFile = new File(requireActivity().getExternalCacheDir().getAbsolutePath() + "/templates/" + timeString + ".json");
        if (!savedFile.getParentFile().exists()) {
            savedFile.getParentFile().mkdirs();
        }
        CaptureVisionRouter router = new CaptureVisionRouter();
        viewModel.settingsCache.decodeSettings.updateToCvr(router);

        try {
            router.outputSettingsToFile(viewModel.settingsCache.decodeSettings.getSelectedPresetTemplateName(), savedFile.getAbsolutePath(), false);
            new AlertDialog.Builder(requireContext())
                    .setMessage("Template json file has been saved to " + savedFile.getAbsolutePath())
                    .setPositiveButton("Ok", null)
                    .show();
        } catch (CaptureVisionRouterException e) {
            //no-op
            e.printStackTrace();
        }
    }

    private void goToSimplifiedSettings() {
        requireActivity().runOnUiThread(() ->
                requireActivity().getSupportFragmentManager().beginTransaction()
                        .replace(R.id.container, new SimplifiedSettingsFragment())
                        .addToBackStack("SimplifiedSettingsFragment")
                        .commit());
    }
}