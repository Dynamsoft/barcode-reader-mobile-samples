package com.dynamsoft.dbr.scanvin;

import android.os.Bundle;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.ArrayList;

public class ResultActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_result);

        EdgeToEdge.enable(this);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        ActionBar actionBar = getSupportActionBar();
        assert actionBar != null;
        actionBar.setTitle("Result");
        actionBar.setDisplayHomeAsUpEnabled(true);

        ListView resultsView = findViewById(R.id.lv_result);
        VINData vinData = (VINData) getIntent().getSerializableExtra("vinData");
        assert vinData != null;
        ArrayAdapter<String> adapter = getStringArrayAdapter(vinData);
        resultsView.setAdapter(adapter);
    }

    @NonNull
    private ArrayAdapter<String> getStringArrayAdapter(VINData vinData) {
        ArrayList<String> strings = new ArrayList<>();
        strings.add("vinString: "+ vinData.vinString);
        strings.add("WMI: "+ vinData.WMI);
        strings.add("region: "+ vinData.region);
        strings.add("VDS: "+ vinData.VDS);
        strings.add("checkDigit: "+ vinData.checkDigit);
        strings.add("modelYear: "+ vinData.modelYear);
        strings.add("serialNumber: "+ vinData.serialNumber);
        strings.add("plantCode: "+ vinData.plantCode);
        return new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, strings);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }
}