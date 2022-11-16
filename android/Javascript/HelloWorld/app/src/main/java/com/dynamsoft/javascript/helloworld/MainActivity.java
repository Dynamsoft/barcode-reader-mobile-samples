package com.dynamsoft.javascript.helloworld;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

@SuppressLint("SetJavaScriptEnabled")
public class MainActivity extends AppCompatActivity {
    WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize WebView
        mWebView = findViewById(R.id.myWebview);

        // Initialize BarcodeReader and WebAppInterface
        MainScanner main = new MainScanner(this, mWebView);

        WebSettings webSettings = mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        mWebView.setWebChromeClient(new WebChromeClient());
        // for debugging
        WebView.setWebContentsDebuggingEnabled(true);
        mWebView.setWebViewClient(new WebViewClient());

        // Injects the supplied Java object into this WebView
        // more details: https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)
        mWebView.addJavascriptInterface(main.webAppInterface, "Android");
        mWebView.clearCache(true);
        // load local or remote web page
        mWebView.loadUrl("file:///android_asset/index.html");
    }

}