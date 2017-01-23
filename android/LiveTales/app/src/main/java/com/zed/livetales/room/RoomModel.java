package com.zed.livetales.room;

import android.content.Context;
import android.graphics.PixelFormat;
import android.util.Log;

import com.kuasars.org.KuasarsError;
import com.kuasars.org.KuasarsListener;
import com.kuasars.org.KuasarsQuery;
import com.kuasars.org.KuasarsResponse;
import com.kuasars.org.entities.KuasarsEntity;
import com.zed.livetales.ConfigListener;
import com.zed.livetales.models.ConfigModel;

import org.webrtc.SurfaceViewRenderer;

import java.security.cert.Certificate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import fi.vtt.nubomedia.webrtcpeerandroid.NBMMediaConfiguration;

/**
 * Created by jemalpartida on 03/10/2016.
 */
public class RoomModel
{
    public RoomModel(Context context, SurfaceViewRenderer masterRenderer, SurfaceViewRenderer remoteRenderer1, SurfaceViewRenderer remoteRenderer2, SurfaceViewRenderer remoteRenderer3)
    {
        this.mediaConfig = new NBMMediaConfiguration(
                NBMMediaConfiguration.NBMRendererType.OPENGLES,
                NBMMediaConfiguration.NBMAudioCodec.OPUS, 0,
                NBMMediaConfiguration.NBMVideoCodec.VP8, 0,
                new NBMMediaConfiguration.NBMVideoFormat( 352, 288, PixelFormat.RGB_888, 30 ),
                NBMMediaConfiguration.NBMCameraPosition.FRONT
        );
        this.roomManager = new RoomManager( context, masterRenderer, remoteRenderer1, remoteRenderer2, remoteRenderer3 );
    }

    public void joinRoom(final String userName, final String roomName)
    {
        /*
        KuasarsEntity entity = new KuasarsEntity("config",false);
        entity.getAsync( "config", "appconfig", new KuasarsListener<KuasarsEntity>() {
            @Override
            public void onComplete(KuasarsResponse<KuasarsEntity> kuasarsResponse)
            {
                Log.v( "LiveTales", "Response from Kuasars:"  );
                KuasarsEntity configEntity = kuasarsResponse.getContent();
                String id = configEntity.getId();
                String kmsServiceUrl = (String)configEntity.getCustomData().get("kms_service_url");

                Room room = new Room( userName, roomName, kmsServiceUrl );

                RoomModel.this.roomManager.joinRoom( room, RoomModel.this.mediaConfig );
            }

            @Override
            public void onError(KuasarsError kuasarsError)
            {
                Log.e( "LiveTales", "Error from Kuasars:" + kuasarsError.getDescription() );
            }
        });
        */
        ConfigModel.getConfig( new ConfigListener(){
            @Override
            public void onReady( Map<String,String> config )
            {
                if( config == null )
                {

                }
                else
                {
                    String kmsServiceUrl = config.get("kms_service_url");
                    Room room = new Room( userName, roomName, kmsServiceUrl );
                    RoomModel.this.roomManager.joinRoom( room, RoomModel.this.mediaConfig );
                }
            }
        });
        /*
        String roomURL = "wss://10.0.0.222:8443/room";

        Room room = new Room( userName, roomName, roomURL );

        this.roomManager.joinRoom( room, this.mediaConfig );
        */
    }

    public void prepareBook(String bookId, String langId)
    {
        Map<String,String> request = new HashMap<>();
        request.put( "type", "1" );
        request.put( "bookId", bookId );
        request.put( "langId", langId );

        this.roomManager.customRequest( request );
    }

    public void requestBook()
    {
        Map<String,String> request = new HashMap<>();
        request.put( "type", "2" );

        this.roomManager.customRequest( request );
    }

    public void actionPage(String action)
    {
        Map<String,String> request = new HashMap<>();
        request.put( "type", "3" );
        request.put( "action", action );

        this.roomManager.customRequest( request );
    }

    public void putAccesory(String accesoryId, String pack)
    {
        Map<String,String> request = new HashMap<>();
        request.put( "type", "4" );
        request.put( "accesory", accesoryId );
        request.put( "pack", pack );

        this.roomManager.customRequest( request );
    }

    public void leaveRoom()
    {
        this.roomManager.leaveRoom();
    }

    public void release()
    {
        this.roomManager.release();
    }

    private NBMMediaConfiguration mediaConfig;
    private RoomManager roomManager;
}
