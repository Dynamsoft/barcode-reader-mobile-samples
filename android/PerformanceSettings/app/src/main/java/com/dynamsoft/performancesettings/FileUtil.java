package com.dynamsoft.performancesettings;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.provider.DocumentsContract;
import android.provider.MediaStore;

public class FileUtil {

    public static String getFilePathFromUri(final Context context, final Uri uri) {
        if (uri == null) {
            return null;
        }
        if(uri.toString().contains("/storage/emulated/0/")){
            int index = uri.toString().indexOf("/storage/emulated/0/");
            return uri.toString().substring(index);
        }
        if (DocumentsContract.isDocumentUri(context, uri)) {
            final String authority = uri.getAuthority();
            if ("com.android.externalstorage.documents".equals(authority)) {
                final String doc = DocumentsContract.getDocumentId(uri);
                final String[] divide = doc.split(":");
                final String type = divide[0];
                if ("primary".equals(type)) {
                    return Environment.getExternalStorageDirectory().getAbsolutePath().concat("/").concat(divide[1]);
                } else {
                    return "/storage/".concat(type).concat("/").concat(divide[1]);
                }
            } else if ("com.android.providers.downloads.documents".equals(authority)) {
                final String doc = DocumentsContract.getDocumentId(uri);
                if (doc.startsWith("raw:")) {
                    return doc.replaceFirst("raw:", "");
                }
                final Uri downloadUri = ContentUris.withAppendedId(Uri.parse("content://downloads/public_downloads"), Long.parseLong(doc));
                return queryAbsolutePath(context, downloadUri, null, null);
            } else if ("com.android.providers.media.documents".equals(authority)) {
                final String doc = DocumentsContract.getDocumentId(uri);
                final String[] splits = doc.split(":");
                final String type = splits[0];
                Uri mediaUri;
                if ("image".equals(type)) {
                    mediaUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                } else if ("video".equals(type)) {
                    mediaUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI;
                } else if ("audio".equals(type)) {
                    mediaUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI;
                } else {
                    return null;
                }
                final String selection = "_id=?";
                final String[] selectionArgs = new String[]{splits[1]};
                mediaUri = ContentUris.withAppendedId(mediaUri, Long.parseLong(splits[1]));
                return queryAbsolutePath(context, mediaUri,selection,selectionArgs);
            }
        } else {
            final String scheme = uri.getScheme();
            String path = null;
            if ("content".equals(scheme)) {
                path = queryAbsolutePath(context, uri, null, null);
            } else if ("file".equals(scheme)) {
                path = uri.getPath();
            }
            return path;
        }
        return null;
    }

    private static String queryAbsolutePath(final Context context, final Uri uri, String selection, String[] selectionArgs) {
        final String[] projection = {MediaStore.MediaColumns.DATA};
        Cursor cursor = null;
        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs, null);
            if (cursor != null && cursor.moveToFirst()) {
                final int index = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns.DATA);
                return cursor.getString(index);
            }
        } catch (final Exception ex) {
            ex.printStackTrace();
            if (cursor != null) {
                cursor.close();
            }
        }
        return null;
    }
}
