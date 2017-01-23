package com.zed.livetales.customviews;

import android.content.Context;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.widget.TextView;

/**
 * Created by jemalpartida on 23/11/2016.
 */

public class CustomTextView extends TextView
{
    public CustomTextView(Context context, AttributeSet attrs)
    {
        super( context, attrs );

        //Get font from assets/fonts.
        Typeface typeFace = Typeface.createFromAsset( context.getAssets(), "fonts/Arial-Rounded-MT-Bold.ttf" );
        this.setTypeface( typeFace );
    }
}
