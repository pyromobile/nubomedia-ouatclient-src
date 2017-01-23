package com.zed.livetales.models.book;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class BookDescription
{
    public BookDescription(String id, String title)
    {
        this.id = id;
        this.title = title;
    }

    public String getId()
    {
        return this.id;
    }

    public String getTitle()
    {
        return this.title;
    }


    private String id;
    private String title;
}
