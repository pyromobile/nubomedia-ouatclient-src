package com.zed.livetales.models.user;

import android.os.Parcel;
import android.os.Parcelable;

import com.zed.livetales.models.LobbyType;

/**
 * Created by jemalpartida on 24/11/2016.
 */

public class User implements Parcelable
{
    public User()
    {
        this.id = "";
        this.name = "";
        this.password = "";
        this.secretCode = "";
        this.nick = "Guest";
        this.lobby = LobbyType.Free;
        this.roomId = "";
        this.acceptedRoomInvitation = false;
        this.narrator = false;
    }

    public User(Parcel in)
    {
        this.id = in.readString();
        this.name = in.readString();
        this.password = in.readString();
        this.secretCode = in.readString();
        this.nick = in.readString();
        this.lobby = in.readByte() == 0 ? LobbyType.Tale : LobbyType.Free;
        this.roomId = in.readString();
        this.acceptedRoomInvitation = in.readByte() != 0;
        this.narrator = in.readByte() != 0;
    }

    public boolean isLogged()
    {
        return !this.id.isEmpty() && !this.name.isEmpty();
    }

    public void setProfile(String id, String name, String password, String secretCode)
    {
        this.id = id;
        this.name = name;
        this.password = password;
        this.secretCode = secretCode;
    }

    public void reset()
    {
        this.id = "";
        this.name = "";
        this.password = "";
        this.secretCode = "";
        this.nick = "Guest";
        this.lobby = LobbyType.Free;
        this.roomId = "";
        this.acceptedRoomInvitation = false;
        this.narrator = false;
    }

    public void setNick(String nick)
    {
        this.nick = ( ( nick == null ) || nick.isEmpty() ) ? "Guest" : nick;
    }

    public String getNick()
    {
        return this.nick;
    }

    public void setLobby(LobbyType lobby)
    {
        this.lobby = lobby;
    }

    public LobbyType getLobby()
    {
        return this.lobby;
    }

    public void setRoomId(String roomId)
    {
        this.roomId = roomId;
    }

    public String getRoomId()
    {
        return this.roomId;
    }

    public void setAcceptedRoomInvitation(boolean acceptedRoomInvitation)
    {
        this.acceptedRoomInvitation = acceptedRoomInvitation;
    }

    public boolean isAcceptedRoomInvitation()
    {
        return this.acceptedRoomInvitation;
    }

    public void setNarrator(boolean narrator)
    {
        this.narrator = narrator;
    }

    public boolean isNarrator()
    {
        return this.narrator;
    }


    /*============================================================================================*/
    /*                                  Override from Parcelable                                  */
    /*============================================================================================*/
    @Override
    public int describeContents()
    {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int flags)
    {
        parcel.writeString( this.id );
        parcel.writeString( this.name );
        parcel.writeString( this.password );
        parcel.writeString( this.secretCode );
        parcel.writeString( this.nick );
        parcel.writeByte( (byte)( (this.lobby == LobbyType.Tale) ? 0 : 1 ) );
        parcel.writeString( this.roomId );
        parcel.writeByte( (byte)( this.acceptedRoomInvitation ? 1 : 0 ) );
        parcel.writeByte( (byte)( this.narrator ? 1 : 0 ) );
    }

    public static final Parcelable.Creator<User> CREATOR = new Parcelable.Creator<User>()
    {
        public User createFromParcel(Parcel in)
        {
            return new User( in );
        }

        public User[] newArray(int size)
        {
            return new User[size];
        }
    };


    private String id;
    private String name;
    private String password;
    private String secretCode;
    private String nick;
    private LobbyType lobby;
    private String roomId;
    private boolean acceptedRoomInvitation;
    private boolean narrator;
}
