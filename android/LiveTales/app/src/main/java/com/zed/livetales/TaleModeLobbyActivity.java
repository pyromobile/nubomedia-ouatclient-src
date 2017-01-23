package com.zed.livetales;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageButton;

public class TaleModeLobbyActivity extends AppCompatActivity implements View.OnClickListener
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate( savedInstanceState );

        this.getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN |
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        );

        this.getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                View.SYSTEM_UI_FLAG_FULLSCREEN |
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        );

        setContentView( R.layout.activity_tale_mode_lobby );

        this.prepareEventsView();
    }


    /*============================================================================================*/
    /*                             Override from OnClickListener                                  */
    /*============================================================================================*/
    @Override
    public void onClick(View view)
    {
        switch( view.getId() )
        {
            case R.id.backButton:
                this.onBack();
                break;
            case R.id.beginButton:
                this.onBegin();
                break;
        }
    }


    /*============================================================================================*/
    /*                                    Private Section                                         */
    /*============================================================================================*/
    private void prepareEventsView()
    {
        ImageButton backButton = (ImageButton)findViewById( R.id.backButton );
        backButton.setOnClickListener( this );

        Button beginButton = (Button)findViewById( R.id.beginButton);
        beginButton.setOnClickListener( this );
    }

    //----------------------------------------------------------------------------------------------
    // Events.
    private void onBack()
    {
        Log.v( "LiveTales", "Botón Back presionado" );
    }

    private void onBegin()
    {
        Log.v( "LiveTales", "Botón Begin presionado" );
    }
}
