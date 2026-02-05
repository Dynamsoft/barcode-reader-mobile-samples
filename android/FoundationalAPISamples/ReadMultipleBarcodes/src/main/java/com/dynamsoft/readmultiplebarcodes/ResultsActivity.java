package com.dynamsoft.readmultiplebarcodes;

import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.HashMap;

public class ResultsActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_results);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        TextView tvTitle = findViewById(R.id.tv_title);
        ImageView btnClose = findViewById(R.id.btn_close);
        btnClose.setOnClickListener(v -> finish());

        HashMap<String, Integer> results = (HashMap<String, Integer>) getIntent().getSerializableExtra(MainActivity.EXTRA_RESULTS);
        if (results == null) results = new HashMap<>();

        int totalCount = 0;
        for (int count : results.values()) {
            totalCount += count;
        }
        tvTitle.setText(getString(R.string.result_title, totalCount));

        RecyclerView rvResults = findViewById(R.id.rv_results);
        rvResults.setLayoutManager(new LinearLayoutManager(this));
        rvResults.setAdapter(new ResultsAdapter(results));
    }
}