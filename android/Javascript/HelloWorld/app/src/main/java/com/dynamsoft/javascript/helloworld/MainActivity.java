package com.dynamsoft.javascript.helloworld;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends AppCompatActivity {
    WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize WebView
        mWebView = findViewById(R.id.myWebview);

        // Pollute your WebView
        new MainScanner().pollute(mWebView);

        // for development, enabled debugging and clear html files cache
        WebView.setWebContentsDebuggingEnabled(true);
        mWebView.clearCache(true);

        mWebView.setWebChromeClient(new WebChromeClient());
        mWebView.setWebViewClient(new WebViewClient());

        // load local or remote web page
        mWebView.loadUrl("file:///android_asset/index.html");
    }

}