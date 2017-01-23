package com.zed.livetales.room;

/**
 * Room bean
 * Created by jemalpartida on 03/10/2016.
 */
class Room
{
    Room(String userName, String roomName, String roomURL)
    {
        this.userName = userName;
        this.roomName = roomName;
        this.roomURL = roomURL;
    }

    String getUserName()
    {
        return this.userName;
    }
    String getRoomName()
    {
        return this.roomName;
    }
    String getRoomURL()
    {
        return this.roomURL;
    }

    private String userName;
    private String roomName;
    private String roomURL;
}
