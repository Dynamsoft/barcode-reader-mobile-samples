package com.dynamsoft.javascript.helloworld;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import android.content.pm.PackageManager;
import android.os.Bundle;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends AppCompatActivity {
    WebView mWebView;
    DBRWebViewHelper webViewHelper;
    public final static int Camera_Permission_Request_Code = 2;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize WebView
        mWebView = findViewById(R.id.myWebview);

        // Pollute your WebView
        webViewHelper = new DBRWebViewHelper();
        webViewHelper.pollute(mWebView);

        // for development, enabled debugging and clear html files cache
        WebView.setWebContentsDebuggingEnabled(true);
        mWebView.clearCache(true);

        mWebView.setWebChromeClient(new WebChromeClient());
        mWebView.setWebViewClient(new WebViewClient());

        // load local or remote web page
        mWebView.loadUrl("file:///android_asset/index.html");
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == Camera_Permission_Request_Code) {
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                webViewHelper.startScanner();
            }
        }
    }
}