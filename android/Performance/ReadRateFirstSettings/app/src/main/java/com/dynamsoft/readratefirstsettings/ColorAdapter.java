package com.dynamsoft.readratefirstsettings;

import android.content.Context;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.URLUtil;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import androidx.annotation.IdRes;
import androidx.annotation.LayoutRes;

import java.util.List;
import java.util.Map;

public class ColorAdapter extends SimpleAdapter {

    private List<? extends Map<String, ?>> mData;
    private Context mContext;
    private int mLayout;
    private int mColorTvId;

    public ColorAdapter(Context context, List<? extends Map<String, ?>> data, @LayoutRes int resource, String[] from, @IdRes int[] to, @IdRes int colorTvId) {
        super(context, data, resource, from, to);
        mData = data;
        mLayout = resource;
        mContext = context;
        mColorTvId = colorTvId;
    }
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        if (convertView == null) {
            convertView = LayoutInflater.from(mContext).inflate(mLayout, null);
        }
        TextView textView = convertView.findViewById(mColorTvId);
        String s = (String) mData.get(position).get("Text");
        if (s!=null) {
            if (Patterns.WEB_URL.matcher(s).matches() || URLUtil.isValidUrl(s)) {
                textView.setTextColor(mContext.getResources().getColor(R.color.url_color));
            } else {
                textView.setTextColor(mContext.getResources().getColor(R.color.no_url_color));
            }
        }
        return super.getView(position, convertView, parent);
    }
}
