package com.dynamsoft.readmultipleuniquebarcodes;

import android.os.Bundle;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

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

        ArrayList<String> results = getIntent().getStringArrayListExtra(MainActivity.EXTRA_RESULTS);
        if (results == null) results = new ArrayList<>();

        tvTitle.setText(getString(R.string.results_title, results.size()));

        RecyclerView rvResults = findViewById(R.id.rv_results);
        rvResults.setLayoutManager(new LinearLayoutManager(this));
        rvResults.setAdapter(new ResultsAdapter(results));
    }
}