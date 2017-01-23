package com.zed.livetales.managers;

/**
 * Created by jemalpartida on 25/11/2016.
 */

public class LanguageMgr
{
    public static LanguageMgr getInstance()
    {
        if( LanguageMgr.instance == null )
        {
            LanguageMgr.instance = new LanguageMgr();
        }

        return LanguageMgr.instance;
    }

    public String getId()
    {
        return this.langId;
    }

    public void setId(String langId)
    {
        boolean supported = false;
        for( String id :SUPPORTED_LANGS )
        {
            if( id.equals( langId ) )
                supported = true;
        }

        this.langId = ( supported ) ? langId : DEFAULT_LANG;
    }


    /*============================================================================================*/
    /*                                    Private Section                                         */
    /*============================================================================================*/
    private LanguageMgr()
    {
        this.langId = DEFAULT_LANG;
    }


    private static LanguageMgr instance;

    private String langId;

    private final String DEFAULT_LANG = "en";
    private final String[] SUPPORTED_LANGS = {"en","es","de"};
}
