package dev.avidkiya.devhub;

import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.Button;
import android.widget.TextView;
import android.graphics.Color;

public class MainActivity extends Activity {
    String url = "http://127.0.0.1:8765/?mode=apk";
    WebView web;
    public void onCreate(Bundle b) {
        super.onCreate(b);
        LinearLayout root = new LinearLayout(this); root.setOrientation(LinearLayout.VERTICAL); root.setBackgroundColor(Color.rgb(7,9,20));
        TextView title = new TextView(this); title.setText("AvidKiya DevHub"); title.setTextColor(Color.WHITE); title.setTextSize(22); title.setPadding(24,20,24,8); root.addView(title);
        Button start = new Button(this); start.setText("Start Termux DevHub backend"); root.addView(start);
        web = new WebView(this); root.addView(web, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,0,1));
        setContentView(root);
        WebSettings s = web.getSettings(); s.setJavaScriptEnabled(true); s.setDomStorageEnabled(true); s.setCacheMode(WebSettings.LOAD_DEFAULT);
        web.setWebViewClient(new WebViewClient()); web.loadUrl(url);
        start.setOnClickListener(v -> {
            try {
                Intent i = new Intent();
                i.setClassName("com.termux", "com.termux.app.RunCommandService");
                i.setAction("com.termux.RUN_COMMAND");
                i.putExtra("com.termux.RUN_COMMAND_PATH", "/data/data/com.termux/files/usr/bin/bash");
                i.putExtra("com.termux.RUN_COMMAND_ARGUMENTS", new String[]{"-lc", "avid app || ~/.termux-avid-kiya/bin/avid app"});
                i.putExtra("com.termux.RUN_COMMAND_BACKGROUND", true);
                startService(i);
            } catch(Exception e) {
                Intent open = getPackageManager().getLaunchIntentForPackage("com.termux");
                if(open != null) startActivity(open);
            }
            web.postDelayed(() -> web.loadUrl(url), 1600);
        });
    }
    public void onBackPressed(){ if(web != null && web.canGoBack()) web.goBack(); else super.onBackPressed(); }
}
