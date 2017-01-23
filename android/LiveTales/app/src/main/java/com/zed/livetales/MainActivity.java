package com.zed.livetales;

import android.app.Activity;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.zed.livetales.room.RoomModel;

import org.webrtc.EglBase;
import org.webrtc.RendererCommon;
import org.webrtc.SurfaceViewRenderer;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;

public class MainActivity extends AppCompatActivity
{
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate( savedInstanceState );

        requestWindowFeature( Window.FEATURE_NO_TITLE );
        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN |
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        );

        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
                View.SYSTEM_UI_FLAG_FULLSCREEN |
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        );

        //La vista de la actividad está definida en res/layout.
        setContentView( R.layout.activity_main );

        SurfaceViewRenderer masterRenderer = (SurfaceViewRenderer)findViewById( R.id.gl_surface );
        SurfaceViewRenderer remoteRenderer1 = (SurfaceViewRenderer)findViewById( R.id.gl_surface_remote_1 );
        SurfaceViewRenderer remoteRenderer2 = (SurfaceViewRenderer)findViewById( R.id.gl_surface_remote_2 );
        SurfaceViewRenderer remoteRenderer3 = (SurfaceViewRenderer)findViewById( R.id.gl_surface_remote_3 );
        EglBase rootEglBase = EglBase.create();
        masterRenderer.init(rootEglBase.getEglBaseContext(), null);
        masterRenderer.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL);
        remoteRenderer1.init(rootEglBase.getEglBaseContext(), null);
        remoteRenderer1.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL);
        remoteRenderer2.init(rootEglBase.getEglBaseContext(), null);
        remoteRenderer3.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL);
        remoteRenderer3.init(rootEglBase.getEglBaseContext(), null);
        remoteRenderer3.setScalingType(RendererCommon.ScalingType.SCALE_ASPECT_FILL);

        this.roomModel = new RoomModel( this, masterRenderer, remoteRenderer1, remoteRenderer2, remoteRenderer3 );
    }

    @Override
    public void onStart()
    {
        super.onStart();
        this.roomModel.joinRoom( "android", "r1" );
    }

    private RoomModel roomModel;
}
