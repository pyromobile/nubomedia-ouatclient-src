package com.zed.livetales.models.book;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import com.zed.livetales.util.Utils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class Book
{
    public Book(Context context, String id, String langId, boolean isHD)
    {
        this.context = context;
        this.id = id;
        this.langId = langId;
        this.isHD = isHD;
        this.story = null;
        this.storyLanguage = null;
        this.imagesPath = new HashMap<>();
        this.currentPieceStory = 0;
        this.currentPage = 0;
        this.state = PageType.FrontCover;
    }

    public String getId()
    {
        return this.id;
    }

    public Page load()
    {
        this.loadStory();
        this.loadStoryLanguage();
        this.loadImages();

        this.state = PageType.FrontCover;

        Page pageToShow = this.preparePageToShow( true );
        return pageToShow;
    }

    public Page changeLanguage(String langId)
    {
        this.langId = langId;
        this.loadStoryLanguage();

        Page pageToShow = this.preparePageToShow( true );
        return pageToShow;
    }

    public Page goBegin()
    {
        this.currentPieceStory = 0;
        this.currentPage = 0;
        this.state = PageType.FrontCover;

        Page pageToShow = this.preparePageToShow( true );
        return pageToShow;
    }

    public Page goToPage( int pageNum )
    {
        this.currentPieceStory = 0;
        this.currentPage = 0;

        int itemsOld = 0;
        boolean foundPage= false;
        while( !foundPage )
        {
            //int items = this.story["story"]![this.currentPieceStory]["texts"]!!.count

            try {
                int items = this.story.getJSONArray("story").getJSONObject(this.currentPieceStory).getJSONArray("texts").length();

                if (pageNum <= (items + itemsOld)) {
                    this.currentPage = pageNum - itemsOld;
                    foundPage = true;
                } else {
                    itemsOld += items;
                    this.currentPieceStory += 1;
                }
            }
            catch( JSONException jsone )
            {
                Log.e( "TalesLive", "Error getting texts size");
            }
        }

        Page page = this.preparePageToShow( true );

        this.checkState();

        return page;
    }

    public Page prevPage()
    {
        this.currentPage -= 1;
        Page page = this.checkChangeImage();

        this.checkState();

        return page;
    }

    public Page nextPage()
    {
        this.currentPage += 1;
        Page page = this.checkChangeImage();

        this.checkState();

        return page;
    }

    public void release()
    {
        //Images.
        /*
        for pair in this.imagesPath
        {
            this.imagesPath.removeValueForKey( pair.0 )
        }*/
        this.imagesPath.clear();


        //Story
        //this.story.removeValueForKey( "story" )
        this.story = null;
        //Story language
        /*
        for pair in this.storyLanguage
        {
            this.storyLanguage.removeValueForKey( pair.0 )
        }
        */
        this.storyLanguage = null;
    }

    public boolean isAtFirstPage()
    {
        return this.state == PageType.FrontCover;
    }

    public boolean isAtLastPage()
    {
        return this.state == PageType.BackCover;
    }


    /*============================================================================================*/
    /*                                      Private Section                                       */
    /*============================================================================================*/
    private void loadStory()
    {
        try
        {
            AssetManager assetMgr = context.getAssets();
            InputStream is = assetMgr.open( "tales/" + this.id + "/story.json" );
            this.story = Utils.loadJSON( is );
        }
        catch( IOException ioe )
        {
            Log.e( "TalesLive", "Error reading story.json!" );
        }
        catch( JSONException jsone )
        {
            Log.e( "TalesLive", "Error process story.json!" );
        }
    }

    private void loadStoryLanguage()
    {
        try
        {
            AssetManager assetMgr = context.getAssets();
            InputStream is = assetMgr.open( "tales/" + this.id + "/languages/" + this.langId );
            this.storyLanguage = Utils.loadJSON(is);
        }
        catch( IOException ioe )
        {
            Log.e( "TalesLive", "Error reading story.json!" );
        }
        catch( JSONException jsone )
        {
            Log.e( "TalesLive", "Error process story.json!" );
        }
    }

    private void loadImages()
    {
        String resolutionPath = ( this.isHD ) ? "/" : "/sd/";
        try
        {
            JSONArray story = this.story.getJSONArray( "story" );
            for(int itemPos = 0; itemPos < story.length(); itemPos++)
            {
                JSONObject itemStory = story.getJSONObject( itemPos );
                String imgId = itemStory.getString("image");
                String imagePath = "tales/" + this.id + "/images" + resolutionPath + "esc" + imgId + ".jpg";
                this.imagesPath.put( imgId, imagePath );
            }
        }
        catch( JSONException jsone )
        {

        }
    }

    private Page checkChangeImage()
    {
        try
        {
            int MAX_PIECE_STORY = this.story.getJSONArray( "story" ).length();
            boolean changeImage = false;
            this.state = PageType.Page;

            int count = this.story.getJSONArray("story").getJSONObject(this.currentPieceStory).getJSONArray("texts").length();
            if( this.currentPage >= count )
            {
                if( this.currentPieceStory < MAX_PIECE_STORY )
                {
                    this.currentPieceStory += 1;
                    this.currentPage = 0;
                    changeImage = true;
                }
            }
            else if( this.currentPage < 0 )
            {
                if( this.currentPieceStory > 0 )
                {
                    this.currentPieceStory -= 1;
                    this.currentPage = count - 1;
                    changeImage = true;
                }
            }

            Page pageToShow = this.preparePageToShow( changeImage );
            return pageToShow;
        }
        catch( JSONException jsone )
        {
            Log.e( "LiveTales", "Error accediendo texts!" );
            return null;
        }

    }

    private Page preparePageToShow(boolean changeImage)
    {
        try
        {
            JSONArray tmp = this.story.getJSONArray("story").getJSONObject(this.currentPieceStory).getJSONArray("texts");
            String textId = tmp.getString(this.currentPage);
            String text = this.storyLanguage.getString(textId);
            String imgPos = this.story.getJSONArray("story").getJSONObject(this.currentPieceStory).getString("image");
            String imagePath = this.imagesPath.get(imgPos);

            Page pageToShow = new Page(text, imagePath, changeImage);
            return pageToShow;
        }
        catch(JSONException jsone )
        {
            Log.e("","");
            return null;
        }
    }

    private void checkState()
    {
        try
        {
            int MAX_PIECE_STORY = this.story.getJSONArray("story").length() - 1;

            if( this.currentPage == 0 && this.currentPieceStory == 0 )
            {
                this.state = PageType.FrontCover;
            }
            else if( this.currentPage >= this.story.getJSONArray("story").getJSONObject(this.currentPieceStory).getJSONArray("texts").length() - 1 && this.currentPieceStory == MAX_PIECE_STORY)
            {
                this.state = PageType.BackCover;
            }
        }
        catch( JSONException jsone )
        {
            Log.e( "", "" );
        }
    }


    private Context context;
    private String id;
    private String langId;
    private boolean isHD;
    private JSONObject story;
    private JSONObject storyLanguage;
    private Map<String,String> imagesPath;
    private int currentPieceStory;
    private int currentPage;
    private PageType state;
}
