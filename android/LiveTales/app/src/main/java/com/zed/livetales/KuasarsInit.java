package com.zed.livetales;

import android.app.Application;
import android.util.Log;

import com.kuasars.org.Kuasars;
import com.kuasars.org.Kuasars.KEnvironment;

/**
 * Created by jemalpartida on 21/11/2016.
 */

public class KuasarsInit extends Application
{
    public void onCreate()
    {
        super.onCreate();

        //Kuasars initialize.
        Kuasars.initialize( this, "560ab6e3e4b0b185810131aa", KEnvironment.PRO );
        Log.v( "LiveTales", "Kuasars initialized!");
    }
}
