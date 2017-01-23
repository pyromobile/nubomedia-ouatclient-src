package com.zed.livetales.customviews;

import android.content.Context;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.widget.Button;

/**
 * Created by jemalpartida on 23/11/2016.
 */

public class CustomButtonView extends Button
{
    public CustomButtonView(Context context, AttributeSet attrs)
    {
        super(context,attrs);

        //Get font from assets/fonts.
        Typeface typeFace = Typeface.createFromAsset( context.getAssets(), "fonts/Arial-Rounded-MT-Bold.ttf" );
        this.setTypeface( typeFace );
    }
}
