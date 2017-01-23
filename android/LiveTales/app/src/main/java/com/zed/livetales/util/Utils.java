package com.zed.livetales.util;

import android.content.Context;
import android.util.DisplayMetrics;
import android.view.Display;
import android.view.WindowManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class Utils
{
    public static JSONObject loadJSON(InputStream is) throws IOException, JSONException
    {
        int size = is.available();
        byte[] buffer = new byte[size];
        is.read( buffer );
        is.close();

        JSONObject json = new JSONObject( new String( buffer, "UTF-8" ) );

        return json;
    }

    public static boolean isHDResolution(Context context, int size, boolean isLandscape)
    {
        WindowManager wm = (WindowManager)context.getSystemService( Context.WINDOW_SERVICE );
        Display display = wm.getDefaultDisplay();
        DisplayMetrics metrics = new DisplayMetrics();
        display.getMetrics( metrics );

        boolean isHD = false;
        if( isLandscape )
        {
            int width = metrics.widthPixels;
            isHD = width > size;
        }
        else
        {
            int height = metrics.heightPixels;
            isHD = height > size;
        }

        return isHD;
    }
}
