package com.zed.livetales.room;

import android.app.Activity;
import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.util.Log;

import com.zed.livetales.R;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.DataChannel;
import org.webrtc.EglBase;
import org.webrtc.IceCandidate;
import org.webrtc.MediaStream;
import org.webrtc.PeerConnection;
import org.webrtc.RendererCommon;
import org.webrtc.SessionDescription;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoRenderer;
import org.webrtc.VideoRendererGui;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.util.HashMap;
import java.util.Map;

import fi.vtt.nubomedia.kurentoroomclientandroid.KurentoRoomAPI;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomError;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomListener;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomNotification;
import fi.vtt.nubomedia.kurentoroomclientandroid.RoomResponse;
import fi.vtt.nubomedia.utilitiesandroid.LooperExecutor;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMPeerConnection;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMWebRTCPeer;
import fi.vtt.nubomedia.webrtcpeerandroid.NBMMediaConfiguration;

/**
 * Created by jemalpartida on 03/10/2016.
 * Manage rooms with kurento/nubomedia.
 */

/**
 *
 */
class RoomManager implements RoomListener, NBMWebRTCPeer.Observer
{
    RoomManager(Context context, SurfaceViewRenderer masterRenderer, SurfaceViewRenderer remoteRenderer1, SurfaceViewRenderer remoteRenderer2, SurfaceViewRenderer remoteRenderer3)
    {
        this.context = context;
        this.masterRenderer = masterRenderer;
        this.remoteRenderer1 = remoteRenderer1;
        this.remoteRenderer2 = remoteRenderer2;
        this.remoteRenderer3 = remoteRenderer3;
        this.videoRequestUserMapping = new HashMap<>();
        this.handler = new Handler();
        this.callState = CallState.IDLE;
        this.sentConnectionRequest = false;
    }

    void joinRoom(Room room, NBMMediaConfiguration mediaConfiguration)
    {
        this.room = room;
        this.config = mediaConfiguration;

        this.setupRoomClient( room );
        this.setupReachability();
        this.setupWebRTCSession();
    }

    void customRequest(  Map<String,String> request )
    {
        String[] fields = new String[request.keySet().size()];
        String[] values = new String[request.keySet().size()];

        fields = request.keySet().toArray( fields );
        values = request.values().toArray( values );
        this.roomClient.sendCustomRequest( fields, values, this.messageId++ );
    }

    void leaveRoom()
    {
        this.roomClient.sendLeaveRoom( this.messageId++ );
    }

    void release()
    {
        if( this.roomClient.isWebSocketConnected() )
        {
            this.roomClient.sendLeaveRoom( this.messageId++ );
            this.roomClient.disconnectWebSocket();
        }
        this.executor.requestStop();
    }

    /*============================================================================================*/
    /*                                Override from RoomListener                                  */
    /*============================================================================================*/
    @Override
    public void onRoomResponse(RoomResponse response)
    {
        Log.v( "RoomManager", "RoomManager::onRoomResponse! --> " + response );
        int requestId = Integer.valueOf( response.getId() );

        if( requestId == this.messageId ) //this.publishVideoRequestId )
        {
            SessionDescription sd = new SessionDescription( SessionDescription.Type.ANSWER, response.getValue( "sdpAnswer" ).get( 0 ) );

            // Check if we are waiting for publication of our own vide
            if( this.callState == CallState.PUBLISHING )
            {
                this.callState = CallState.PUBLISHED;
                this.webRTCPeer.processAnswer( sd, "local" );
                this.handler.postDelayed( this.offerWhenReady, 2000 );

                // Check if we are waiting for the video publication of the other peer
            }
            else if ( this.callState == CallState.WAITING_REMOTE_USER )
            {
                //String user_name = Integer.toString(publishVideoRequestId);
                this.callState = CallState.RECEIVING_REMOTE_USER;
                String connectionId = videoRequestUserMapping.get( this.messageId );    //this.publishVideoRequestId
                this.webRTCPeer.processAnswer( sd, connectionId );
            }
        }
        else
        {
            JSONObject jsonObject = null;
            try
            {
                jsonObject = new JSONObject(response.getJsonObject().toJSONString());
            }
            catch( JSONException e )
            {
                e.printStackTrace();
            }
            Log.v( "RoomManager", "RoomManager::onRoomResponse --> " + jsonObject.toString() );
            JSONArray values = jsonObject.optJSONArray( "value" );

            // joinRoom response
            if( values!= null && values.length()>0 )
            {
                JSONObject responseIter = values.optJSONObject( 0 );
                if( responseIter != null )
                {
                    final String otherUser = responseIter.optString( "id" );
                    //logAndToast("User: " + otherUser);
                    //MainActivity.this.runOnUiThread(new Runnable() {
                    //    @Override
                    //    public void run() {
                    //        mCallNumET.setText(otherUser);
                    //    }
                    //});

                    final JSONArray streams = responseIter.optJSONArray( "streams" );
                    if( streams != null && streams.length() > 0 && otherUser != null )
                    {
                        this.userPublishList.put( otherUser, true );
                        Log.v( "RoomManager", "I'm " + this.room.getUserName() + " DERP: Other peer published already (Room response)" );
                    }
                }
            }
        }

    }

    @Override
    public void onRoomError(RoomError error)
    {
        Log.v( "RoomManager", "RoomManager::onRoomError! --> " + error );
    }

    @Override
    public void onRoomNotification(RoomNotification notification)
    {
        Log.v( "RoomManager", "RoomManager::onRoomNotification! --> " + notification );
        Map<String, Object> map = notification.getParams();

        if( notification.getMethod().equals( RoomListener.METHOD_ICE_CANDIDATE ) )
        {
            String sdpMid = map.get( "sdpMid" ).toString();
            int sdpMLineIndex = Integer.valueOf( map.get( "sdpMLineIndex" ).toString() );
            String sdp = map.get( "candidate" ).toString();
            IceCandidate ic = new IceCandidate( sdpMid, sdpMLineIndex, sdp );

            if( this.callState == CallState.PUBLISHING || this.callState == CallState.PUBLISHED )
            {
                this.webRTCPeer.addRemoteIceCandidate( ic, "local" );
            }
            else
            {
                this.webRTCPeer.addRemoteIceCandidate( ic, notification.getParam( "endpointName" ).toString() );
            }
        }

        // Somebody in the room published their video
        else if( notification.getMethod().equals( RoomListener.METHOD_PARTICIPANT_PUBLISHED ) )
        {
            this.handler.postDelayed( offerWhenReady, 2000 );
        }
    }

    @Override
    public void onRoomConnected()
    {
        Log.v( "RoomManager", "RoomManager::onRoomConnected!" );

        boolean isWSConnected = this.roomClient.isWebSocketConnected();
        Log.v( "RoomManager", "RoomManager::onRoomConnected -- EL WEBSOCKET ESTA CONECTADO:" + isWSConnected );
        if( isWSConnected )
        {
            if(  !this.sentConnectionRequest )
            {
                this.sentConnectionRequest = true;
                Log.v( "RoomManager", "RoomManager::onRoomConnected -- ME UNO A LA ROOM:" + this.room.getRoomName() );
                this.roomClient.sendJoinRoom( this.room.getUserName(), this.room.getRoomName(), false, this.messageId++ );
            }
        }
        else
        {
            Log.v( "RoomManager", "RoomManager::onRoomConnected -- EL WEBSOCKET NO ESTA CONECTADO!" );
        }
    }

    @Override
    public void onRoomDisconnected()
    {
        Log.v( "RoomManager", "RoomManager::onRoomDisconnected!" );
    }


    /*============================================================================================*/
    /*                           Override from NBMWebRTCPeer.Observer                             */
    /*============================================================================================*/
    @Override
    public void onInitialize()
    {
        Log.v( "RoomManager", "RoomManager::onInitialize!" );
        this.webRTCPeer.generateOffer( this.room.getUserName(), true );
    }

    @Override
    public void onLocalSdpOfferGenerated(final SessionDescription localSdpOffer, final NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onLocalSdpOfferGenerated!" );
        if( this.callState == CallState.PUBLISHING || this.callState == CallState.PUBLISHED )
        {
            ((Activity)this.context).runOnUiThread(new Runnable(){
                @Override
                public void run()
                {
                    Log.d( "RoomManager", "RoomManager::onLocalSdpOfferGenerated --> Sending " + localSdpOffer.type );
                    //publishVideoRequestId = ++RoomManager.this.messageId;
                    //MainActivity.getKurentoRoomAPIInstance().sendPublishVideo(sessionDescription.description, false, publishVideoRequestId);
                    RoomManager.this.roomClient.sendPublishVideo( localSdpOffer.description, false, RoomManager.this.messageId++ );
                }
            });
        }
        else
        {
            // Asking for remote user video
            ((Activity)this.context).runOnUiThread( new Runnable(){
                @Override
                public void run()
                {
                    Log.v( "RoomManager", "RoomManager::onLocalSdpOfferGenerated --> Sending " + localSdpOffer.type );
                    //RoomManager.this.publishVideoRequestId = ++RoomManager.this.messageId;
                    String username = connection.getConnectionId() + "_webcam";
                    int msgId = RoomManager.this.messageId++;
                    videoRequestUserMapping.put( msgId, connection.getConnectionId() );
                    //MainActivity.getKurentoRoomAPIInstance().sendReceiveVideoFrom(username, sessionDescription.description, publishVideoRequestId);
                    RoomManager.this.roomClient.sendReceiveVideoFrom( username, localSdpOffer.description, msgId );
                }
            });
        }
    }

    @Override
    public void onLocalSdpAnswerGenerated(SessionDescription localSdpAnswer, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onLocalSdpAnswerGenerated!" );
    }

    @Override
    public void onIceCandidate(IceCandidate localIceCandidate, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onIceCandidate!" );

        //Se manda:
        // EndpointName -> Nombre del usuario (que crea la conexion).
        // sdp -> SDP
        // sdpMid -> SDPMID
        // sdpMLineIndex -> SDPMLineIndex (int)
        // IdMsg (int).
        //this.roomClient.sendOnIceCandidate( this.room.getUserName(), localIceCandidate.sdp, localIceCandidate.sdpMid, String.valueOf( localIceCandidate.sdpMLineIndex ) , this.idMessage++ );

        if( this.callState == CallState.PUBLISHING || callState == CallState.PUBLISHED )
        {
            this.roomClient.sendOnIceCandidate( this.room.getUserName(), localIceCandidate.sdp,
                    localIceCandidate.sdpMid, Integer.toString(localIceCandidate.sdpMLineIndex), this.messageId++ );
        }
        else
        {
            this.roomClient.sendOnIceCandidate(connection.getConnectionId(), localIceCandidate.sdp,
                    localIceCandidate.sdpMid, Integer.toString( localIceCandidate.sdpMLineIndex ), this.messageId++ );
        }
    }

    @Override
    public void onIceStatusChanged(PeerConnection.IceConnectionState state, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onIceStatusChanged!" );
    }

    @Override
    public void onRemoteStreamAdded(MediaStream stream, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onPeerConnectionError!" );
        this.webRTCPeer.setActiveMasterStream( stream );
        ((Activity)this.context).runOnUiThread( new Runnable(){
            @Override
            public void run()
            {
                //mCallStatus.setText("");
            }
        });
    }

    @Override
    public void onRemoteStreamRemoved(MediaStream stream, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onRemoteStreamAdded!" );
    }

    @Override
    public void onPeerConnectionError(String error)
    {
        Log.v( "RoomManager", "RoomManager::onPeerConnectionError! --> " + error );
    }

    @Override
    public void onDataChannel(DataChannel dataChannel, NBMPeerConnection connection)
    {
        Log.v( "RoomManager", "RoomManager::onDataChannel!" );
    }

    @Override
    public void onBufferedAmountChange(long l, NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager::onBufferedAmountChange!" );
    }

    @Override
    public void onStateChange(NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager::onStateChange!" );
    }

    @Override
    public void onMessage(DataChannel.Buffer buffer, NBMPeerConnection connection, DataChannel channel)
    {
        Log.v( "RoomManager", "RoomManager::onMessage!" );
    }


    /*============================================================================================*/
    /*                                      Private Section                                       */
    /*============================================================================================*/
    private void setupRoomClient(Room room)
    {
        Log.v( "RoomManager", "RoomManager::setupRoomClient..." );
        this.executor = new LooperExecutor();
        this.executor.requestStart();
        this.roomClient = new KurentoRoomAPI( executor, room.getRoomURL(), this );
        Log.v( "RoomManager", "RoomManager::setupRoomClient...ok" );
    }

    private void setupReachability()
    {
        Log.v( "RoomManager", "RoomManager::setupReachability..." );
        try
        {
            CertificateFactory cf = CertificateFactory.getInstance( "X.509" );
            InputStream caInput = new BufferedInputStream( this.context.getAssets().open( "uoatselfsigned.cer" ) );
            Certificate myCert = cf.generateCertificate(caInput);
            this.roomClient.useSelfSignedCertificate( true );
            this.roomClient.addTrustedCertificate( "uoat-selfsigned", myCert );
        }
        catch( CertificateException | IOException ce )
        {
            ce.printStackTrace();
        }

        Log.v( "RoomManager", "RoomManager::setupReachability ---> trying connect with websocket..." );
        this.roomClient.connectWebSocket();
        Log.v( "RoomManager", "RoomManager::setupReachability ---> setupReachability...ok" );
    }

    private void setupWebRTCSession()
    {
        Log.v( "RoomManager", "RoomManager::setupWebRTCSession..." );
        //GLSurfaceView gl2 = new GLSurfaceView(this.context);
        //((Activity)this.context).setContentView( gl2 );
        //GLSurfaceView gl2 = (GLSurfaceView)((Activity)this.context).findViewById( R.id.videoView );
        //VideoRendererGui.setView( gl2, new Runnable(){
        //    @Override
        //    public void run(){
        //        Log.v( "RoomManager", "RoomManager::setupWebRTCSession::SETVIEW OPENGL RUN" );
        //    }
        //});

        //this.localRender = VideoRendererGui.create( 72,72,25,25, RendererCommon.ScalingType.SCALE_ASPECT_FILL, false );
        this.masterRenderer.setMirror(true);

        this.webRTCPeer = new NBMWebRTCPeer( this.config, this.context, this.masterRenderer, this );
        this.webRTCPeer.registerMasterRenderer( this.remoteRenderer1 );
        this.webRTCPeer.initialize();

        this.callState = CallState.PUBLISHING;
        Log.v( "RoomManager", "RoomManager::setupWebRTCSession...ok" );
    }

    private void generateOfferForRemote(String remoteName)
    {
        this.webRTCPeer.generateOffer( remoteName, false );
        callState = CallState.WAITING_REMOTE_USER;
        //runOnUiThread(new Runnable() {
        //    @Override
        //    public void run() {
        //        mCallStatus.setText(R.string.waiting_remote_stream);
        //    }
        //});
    }


    private Runnable offerWhenReady = new Runnable(){
        @Override
        public void run()
        {
            // Generate offers to receive video from all peers in the room
            for( Map.Entry<String, Boolean> entry : RoomManager.this.userPublishList.entrySet() )
            {
                if( entry.getValue() )
                {
                    RoomManager.this.generateOfferForRemote( entry.getKey() );
                    Log.v( "RoomManager", "I'm " + RoomManager.this.room.getUserName() + " DERP: Generating offer for peer " + entry.getKey() );
                }
            }
        }
    };

    private Context context;
    private KurentoRoomAPI roomClient;
    private LooperExecutor executor;
    private Room room;
    private NBMMediaConfiguration config;
    private NBMWebRTCPeer webRTCPeer;
    //private VideoRenderer.Callbacks localRender;
    private SurfaceViewRenderer masterRenderer;
    private SurfaceViewRenderer remoteRenderer1;
    private SurfaceViewRenderer remoteRenderer2;
    private SurfaceViewRenderer remoteRenderer3;

    private int messageId;
    //private int publishVideoRequestId;
    private CallState callState;

    private enum CallState{
        IDLE, PUBLISHING, PUBLISHED, WAITING_REMOTE_USER, RECEIVING_REMOTE_USER
    }
    private Map<Integer, String> videoRequestUserMapping;
    private Map<String, Boolean> userPublishList = new HashMap<>();
    private Handler handler;

    private boolean sentConnectionRequest;
}


