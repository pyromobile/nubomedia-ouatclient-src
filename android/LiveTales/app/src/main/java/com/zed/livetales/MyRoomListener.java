package com.zed.livetales;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.Log;

import org.webrtc.DataChannel;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.PeerConnection;
import org.webrtc.RendererCommon;
import org.webrtc.SessionDescription;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoRendererGui;

import java.security.cert.Certificate;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import fi.vtt.nubomedia.kurentoroomclientandroid.KurentoRoomAPI;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomError;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomListener;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomNotification;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomResponse;
import fi.vtt.nubomedia.utilitiesandroid.LooperExecutor;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMMediaConfiguration;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMPeerConnection;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMWebRTCPeer;

/**
 * Created by jemalpartida on 04/10/2016.
 */
@Deprecated
public class MyRoomListener implements RoomListener, NBMWebRTCPeer.Observer
{
    public MyRoomListener( String wsRoomUri, MyGLSurfaceView gl, Context context )
    {
        this.gl = gl;
        this.context = context;
        this.idMessage = 0;
        this.executor = new LooperExecutor();
        this.executor.requestStart();

        this.roomApi = new KurentoRoomAPI( executor, wsRoomUri, this );
    }

    public void useSelfSignedCertificate( boolean isSelfSignedCertificate )
    {
        this.roomApi.useSelfSignedCertificate( isSelfSignedCertificate );
    }

    public void addTrustedCertificate( String alias, Certificate certificate )
    {

        this.roomApi.addTrustedCertificate( alias, certificate );
    }

    public boolean isConnected()
    {
        return this.roomApi.isWebSocketConnected();
    }

    public void connect()
    {
        this.roomApi.connectWebSocket();
    }

    public void step1()
    {
        Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::Generate SDP Offer...");
        //Se manda:
        // connectionId -> que es el nombre del usuario que crea la conexion.
        // includeLocalMedia -> T | F
        this.webRTCPeer.generateOffer( USER, false );
        Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::Generate SDP Offer...Fin!");

        /*
        if( this.webRTCPeer.startLocalMedia() )
        {
            Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::WEBRTCPEER is startLocalMedia: YES!");

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::Generate SDP Offer...");
            this.webRTCPeer.generateOffer( sessionId, false );
            Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::Generate SDP Offer...Fin!");
        }
        else
            Log.v("MyRoomListener", "MyRoomListener::onRoomResponse::WEBRTCPEER is startLocalMedia: NO!");
*/
    }

    /*============================================================================================*/
    /*                               Override from RoomListener                                   */
    /*============================================================================================*/
    @Override
    public void onRoomConnected()
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomConnected!" );

        boolean isWSConnected = this.roomApi.isWebSocketConnected();
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomConnected -- EL WEBSOCKET ESTA CONECTADO:"+isWSConnected );
        if( isWSConnected )
        {
            Log.v( "MyRoomListener", "MyRoomListener ---> onRoomConnected -- ME UNO A LA ROOM:" + ROOM );
            this.roomApi.sendJoinRoom( USER, ROOM, false, this.idMessage++ );
        }
        else
        {
            Log.v( "MyRoomListener", "MyRoomListener ---> onRoomConnected -- EL WEBSOCKET NO ESTA CONECTADO!" );
        }
    }

    @Override
    public void onRoomDisconnected()
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomDisconnected!" );
        this.executor.requestStop();
    }

    @Override
    public void onRoomResponse( RoomResponse response )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomResponse!" );
        String responseId = response.getId();
        this.sessionId = response.getSessionId();

        List<HashMap<String,String>> values = response.getValues();

        Log.v( "MyRoomListener", "MyRoomListener ---> responseId:" + responseId );
        Log.v( "MyRoomListener", "MyRoomListener ---> sessionId :" + sessionId );
        if( values != null )
        {
            Iterator<HashMap<String,String>> it = values.iterator();
            while( it.hasNext() )
            {
                for (Map.Entry<String, String> entry :it.next().entrySet())
                {
                    String key = entry.getKey();
                    String value = entry.getValue();
                    Log.v( "MyRoomListener", "MyRoomListener ---> key:" + key + " - value:" + value );
                }
            }
            /*
            for (Map.Entry<String, String> entry : values.entrySet()) {
                String key = entry.getKey();
                String value = entry.getValue();
                Log.v( "MyRoomListener", "MyRoomListener ---> key:" + key + " - value:" + value );
            }
            */
        }

        //Configuracion...?
        if( responseId.equals("0") )
        {
            //VideoView videoView = (VideoView)((Activity)this.context).findViewById( R.id.videoView );
            //GLSurfaceView gl = new GLSurfaceView( this.context );
            //MyGLSurfaceView gl = (MyGLSurfaceView)((Activity)this.context).findViewById( R.id.videoView );

            GLSurfaceView gl2 = new GLSurfaceView(this.context);
            //((Activity)this.context).setContentView( gl2 );
            VideoRendererGui.setView( gl2, new Runnable(){
                @Override
                public void run(){
                    Log.v( "MyRoomListener", "MyRoomListener::onRoomResponse::SETVIEW OPENGL RUN" );
                }
            });

            this.localRender = VideoRendererGui.create( 72,72,25,25, RendererCommon.ScalingType.SCALE_ASPECT_FILL, false );
            NBMMediaConfiguration mediaConfiguration = new NBMMediaConfiguration();
            this.webRTCPeer = new NBMWebRTCPeer( mediaConfiguration, this.context, this.localRender, this );
            this.webRTCPeer.initialize();

            Log.v( "MyRoomListener", "MyRoomListener::onRoomResponse::WEBRTCPEER initialice called" );
        }
    }

    @Override
    public void onRoomError( RoomError error )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomError!" );

        String errorCode = error.getCode();
        String errorData = error.getData();
    }

    @Override
    public void onRoomNotification( RoomNotification notification )
    {
        String method = notification.getMethod();
        Map<String, Object> values = notification.getParams();

        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomNotification!" );
        Log.v( "MyRoomListener", "MyRoomListener ---> onRoomNotification - Method:" +  method );
        if( values != null )
        {
            for (Map.Entry<String, Object> entry : values.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                Log.v( "MyRoomListener", "MyRoomListener ---> key:" + key + " - value:" + value );
            }
            Long l = (Long)values.get("sdpMLineIndex");

            IceCandidate remote = new IceCandidate((String)values.get("sdpMid"),l.intValue(),(String)values.get("candidate"));
            this.webRTCPeer.addRemoteIceCandidate( remote, USER );
        }

        if( notification.getMethod().equals( RoomListener.METHOD_PARTICIPANT_JOINED ) )
        {
            // TODO
        }
        else if( notification.getMethod().equals( RoomListener.METHOD_SEND_MESSAGE ) )
        {
            // TODO
        }
        else
        {

        }
    }

    @Override
    public void onDataChannel(DataChannel dataChannel, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager ---> onDataChannel!" );
    }

    @Override
    public void onBufferedAmountChange(long l, NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager ---> onBufferedAmountChange!" );
    }

    @Override
    public void onStateChange(NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager ---> onStateChange!" );
    }

    @Override
    public void onMessage(DataChannel.Buffer buffer, NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager ---> onMessage!" );
    }


    /*============================================================================================*/
    /*                          Override from BMWebRTCPeer.Observer                               */
    /*============================================================================================*/
    @Override
    public void onInitialize()
    {

    }

    @Override
    public void onLocalSdpOfferGenerated(SessionDescription localSdpOffer, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onLocalSdpOfferGenerated!" );
        Log.v( "MyRoomListener", "MyRoomListener ---> onLocalSdpOfferGenerated SDPOFFER - DUMP:" + localSdpOffer.toString() );
        Log.v( "MyRoomListener", "MyRoomListener ---> onLocalSdpOfferGenerated :: CONNECTION - DUMP:" + connection.toString() );



        //Se manda:
        // remoteAnswer - > localSdpOffer
        // connectionId -> Usuario que crea la conexion.
        //this.webRTCPeer.processAnswer(localSdpOffer, USER );

        //Se manda:
        // SDPOffer -> que es la descripción.
        // loopback -> T | F
        // idMsg (int)
        this.roomApi.sendPublishVideo( localSdpOffer.description ,true, this.idMessage++ );
    }

    @Override
    public void onLocalSdpAnswerGenerated( SessionDescription localSdpAnswer, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onLocalSdpAnswerGenerated!" );
    }

    @Override
    public void onIceCandidate( IceCandidate localIceCandidate, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onIceCandidate!" );

        //Se manda:
        // EndpointName -> Nombre del usuario (que crea la conexion).
        // sdp -> SDP
        // sdpMid -> SDPMID
        // sdpMLineIndex -> SDPMLineIndex (int)
        // IdMsg (int).
        this.roomApi.sendOnIceCandidate( USER, localIceCandidate.sdp, localIceCandidate.sdpMid, String.valueOf( localIceCandidate.sdpMLineIndex ) , this.idMessage++ );
    }

    @Override
    public void onIceStatusChanged(PeerConnection.IceConnectionState state, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener","MyRoomListener ---> onIceStatusChanged!" );
    }

    @Override
    public void onRemoteStreamAdded(MediaStream stream, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRemoteStreamAdded!" );
    }

    @Override
    public void onRemoteStreamRemoved( MediaStream stream, NBMPeerConnection connection )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onRemoteStreamRemoved!" );
    }

    @Override
    public void onPeerConnectionError( String error )
    {
        Log.v( "MyRoomListener", "MyRoomListener ---> onPeerConnectionError!" );
    }


    private KurentoRoomAPI roomApi;
    private LooperExecutor executor ;
    private int idMessage;
    private Context context;
    private VideoRenderer.Callbacks localRender;
    private NBMWebRTCPeer webRTCPeer;
    private MyGLSurfaceView gl;
    private String sessionId;

    private static final String USER = "Android";
    private static final String ROOM = "r1";
}
