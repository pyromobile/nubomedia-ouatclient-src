package com.zed.livetales.models.book;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class Page
{
    public Page(String text, String imagePath, boolean changeImage)
    {
        this.text = text;
        this.imagePath = imagePath;
        this.changeImage = changeImage;
    }

    public String getText()
    {
        return this.text;
    }

    public String getImagePath()
    {
        return this.imagePath;
    }

    public boolean isChangeImage()
    {
        return this.changeImage;
    }


    private String text;
    private String imagePath;
    private boolean changeImage;
}

enum PageType {
    FrontCover,
    Page,
    BackCover
}