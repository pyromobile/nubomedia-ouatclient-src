package com.zed.livetales;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;

import com.zed.livetales.managers.LibraryMgr;
import com.zed.livetales.models.book.BookDescription;
import com.zed.livetales.models.user.User;
import com.zed.livetales.util.Utils;

import java.util.ArrayList;
import java.util.Locale;

public class Main2Activity extends AppCompatActivity implements View.OnClickListener
{
    /*============================================================================================*/
    /*                             Override from AppCompatActivity                                */
    /*============================================================================================*/
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

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

        this.setContentView(R.layout.activity_main2);

        this.prepareEventsView();

        this.user = new User();

        boolean isHD = Utils.isHDResolution( this, 1024, true );
        String langId = Locale.getDefault().getLanguage();
        Log.v( "TalesLive", "IS HD:"+ isHD );
        Log.v( "TalesLive", "Language:"+ langId );

        LibraryMgr.create( this, langId, isHD );
        ArrayList<BookDescription> books = LibraryMgr.getInstance().currentBooks();
        for(BookDescription book:books)
        {
            Log.v( "TalesLive", "Book: "+book.getId() + " - " + book.getTitle() );
        }
    }


    /*============================================================================================*/
    /*                             Override from OnClickListener                                  */
    /*============================================================================================*/
    @Override
    public void onClick(View view)
    {
        switch( view.getId() )
        {
            case R.id.loginButton:
                this.onLogin();
                break;
            case R.id.taleModeButton:
                this.onTaleMode();
                break;
            case R.id.freeModeButton:
                this.onFreeMode();
                break;
            case R.id.invitesButton:
                this.onInvites();
                break;
            case R.id.libraryButton:
                this.onLibrary();
                break;
            case R.id.friendsButton:
                this.onFriends();
                break;
            case R.id.infoButton:
                this.onInfo();
                break;
        }
    }


    /*============================================================================================*/
    /*                                    Private Section                                         */
    /*============================================================================================*/
    private void prepareEventsView()
    {
        Button loginButton = (Button)findViewById( R.id.loginButton );
        loginButton.setOnClickListener( this );

        Button taleModeButton = (Button)findViewById( R.id.taleModeButton );
        taleModeButton.setOnClickListener( this );

        Button freeModeButton = (Button)findViewById( R.id.freeModeButton );
        freeModeButton.setOnClickListener( this );

        Button invitesButton = (Button)findViewById( R.id.invitesButton );
        invitesButton.setOnClickListener( this );

        Button libraryButton = (Button)findViewById( R.id.libraryButton );
        libraryButton.setOnClickListener( this );

        Button friendsButton = (Button)findViewById( R.id.friendsButton );
        friendsButton.setOnClickListener( this );

        Button infoButton = (Button)findViewById( R.id.infoButton );
        infoButton.setOnClickListener( this );
    }

    //----------------------------------------------------------------------------------------------
    // Events.
    private void onLogin()
    {
        Log.v( "LiveTales", "Botón Login presionado" );
    }

    private void onTaleMode()
    {
        Log.v( "LiveTales", "Botón TaleMode presionado" );
    }

    private void onFreeMode()
    {
        Log.v( "LiveTales", "Botón FreeMode presionado" );
        Intent intent = new Intent( Main2Activity.this, TaleModeLobbyActivity.class );

        //Pass data to TaleModeLobbyActivity.
        Bundle bundle = new Bundle();
        bundle.putParcelable( "com.zed.livetales.models.user.User", this.user );
        intent.putExtras( bundle );

        this.startActivity( intent );
        this.finish();
    }

    private void onInvites()
    {
        Log.v( "LiveTales", "Botón Invites presionado" );

    }

    private void onLibrary()
    {
        Log.v( "LiveTales", "Botón Library presionado" );

    }

    private void onFriends()
    {
        Log.v( "LiveTales", "Botón Friends presionado" );

    }

    private void onInfo()
    {
        Log.v( "LiveTales", "Botón Info presionado" );

    }


    private User user;
}
