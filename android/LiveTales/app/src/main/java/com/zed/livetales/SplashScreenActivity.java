package com.zed.livetales;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

/**
 * Created by jemalpartida on 06/10/2016.
 */

public class SplashScreenActivity extends Activity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate( savedInstanceState );
        setContentView( R.layout.splash );

        Thread timerThread = new Thread()
        {
            public void run()
            {
                try
                {
                    sleep(3000);
                }
                catch(InterruptedException e)
                {
                    e.printStackTrace();
                }
                finally
                {
                    Intent intent = new Intent( SplashScreenActivity.this, Main2Activity.class );
                    startActivity(intent);
                    finish();
                }
            }
        };
        timerThread.start();
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        finish();
    }
}
