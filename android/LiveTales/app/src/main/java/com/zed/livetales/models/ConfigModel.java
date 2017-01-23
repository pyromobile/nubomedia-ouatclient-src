package com.zed.livetales.models;

import android.util.Log;

import com.kuasars.org.KuasarsError;
import com.kuasars.org.KuasarsListener;
import com.kuasars.org.KuasarsResponse;
import com.kuasars.org.entities.KuasarsEntity;
import com.zed.livetales.ConfigListener;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by jemalpartida on 21/11/2016.
 */

public class ConfigModel
{
    public static void getConfig(final ConfigListener listener)
    {
        KuasarsEntity entity = new KuasarsEntity( "config", false );
        entity.getAsync( "config", "appconfig", new KuasarsListener<KuasarsEntity>() {
            @Override
            public void onComplete(KuasarsResponse<KuasarsEntity> kuasarsResponse)
            {
                KuasarsEntity configEntity = kuasarsResponse.getContent();

                Map<String,String> config = new HashMap<>();

                config.put( "id", configEntity.getId() );
                config.put( "kms_service_url", (String)configEntity.getCustomData().get("kms_service_url") );

                if( listener != null )
                    listener.onReady( config );
            }

            @Override
            public void onError(KuasarsError kuasarsError)
            {
                Log.e( "LiveTales", "Error from Kuasars:" + kuasarsError.getDescription() );
                if( listener != null )
                    listener.onReady( null );
            }
        });
    }
}
