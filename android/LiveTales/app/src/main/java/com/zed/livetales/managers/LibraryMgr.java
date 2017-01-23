package com.zed.livetales.managers;

import android.app.Application;
import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import com.zed.livetales.models.book.Book;
import com.zed.livetales.models.book.BookDescription;
import com.zed.livetales.util.Utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class LibraryMgr
{
    public static void create(Context context, String langId, boolean isHD)
    {
        if( LibraryMgr.instance == null )
        {
            LibraryMgr.instance = new LibraryMgr( context, langId, isHD );
        }
        LibraryMgr.getInstance().load();
    }

    public static LibraryMgr getInstance()
    {
        if( LibraryMgr.instance == null )
            throw new IllegalStateException("You must create a library manager by create method!");

        return LibraryMgr.instance;
    }

    public ArrayList<BookDescription> currentBooks()
    {
        ArrayList<BookDescription> lst = new ArrayList<>();
        for( Map.Entry<String,JSONObject>  item : this.talesDescription.entrySet() )
        {

            try
            {
                String id = item.getKey();
                String title = item.getValue().getJSONObject("langs").getJSONObject(this.langId).getString("title");

                lst.add(new BookDescription(id, title));
            }
            catch( JSONException jsone )
            {
                Log.e( "LiveTales", "Failed to get keys from JSON object!" );
            }
        }

        return lst;
    }

    public void changeLanguage(String langId)
    {
        this.langId = langId;
    }

    public void setBookIdSelected(String bookId)
    {
        this.bookId = bookId;
    }

    public Book getBook()
    {
        if( !this.bookId.isEmpty() && !this.book.getId().equals( this.bookId ) )
        {
            this.book.release();
            this.book = new Book( this.context, this.bookId, this.langId, this.isHD );
        }
        return this.book;
    }

    public String getFirstImageToPresentation(String bookId)
    {
        String resolutionPath = (this.isHD) ? "/" : "/sd/";
        String imagePath = "tales/" + bookId + "/images" + resolutionPath + "esc01.jpg";

        return imagePath;
    }

    public String getCoverImage(String bookId)
    {
        String resolutionPath = (this.isHD) ? "/" : "/sd/";
        String imagePath = "tales/" + bookId + "/images" + resolutionPath + "cover.png";

        return imagePath;
    }


    /*============================================================================================*/
    /*                                    Private Section                                         */
    /*============================================================================================*/
    private LibraryMgr(Context context, String langId, boolean isHD)
    {
        this.context = context;
        this.langId = langId;
        this.isHD = isHD;
        this.talesDescription = new HashMap<>();
        this.bookId = "";
        this.book = new Book( context, "01_rdo", this.langId, this.isHD );
    }

    private void load()
    {
        AssetManager assetMgr = this.context.getAssets();
        try
        {
            String[] talesPath = assetMgr.list("tales");
            for( String talePath:talesPath )
            {
                String file = "tales/" + talePath + "/description.json";
                InputStream is = assetMgr.open( file );
                JSONObject taleDescription = Utils.loadJSON( is );
                this.processDescription( taleDescription );
            }
        }
        catch( IOException ioe )
        {
            Log.e( "LiveTales", "Failed to read tales folder!" );
        }
        catch( JSONException jsone )
        {
            Log.e( "LiveTales", "Failed to parser JSON file!" );
        }
    }

    private void processDescription(JSONObject taleDescription)
    {
        try
        {
            boolean isBook = taleDescription.getBoolean("isBook");
            if( isBook )
            {
                String id = taleDescription.getString("id");
                this.talesDescription.put(id, taleDescription);
            }
        }
        catch( JSONException jsone )
        {
            Log.e( "LiveTales", "Failed to get keys from JSON object!" );
        }
    }


    private static LibraryMgr instance;

    private Context context;
    private Map<String,JSONObject> talesDescription;
    private String langId;
    private Book book;
    private boolean isHD;
    private String bookId;

}
