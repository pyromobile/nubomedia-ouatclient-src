package com.zed.livetales;

import java.util.Map;

/**
 * Created by jemalpartida on 21/11/2016.
 */

public interface ConfigListener
{
    void onReady(Map<String,String> config);
}
