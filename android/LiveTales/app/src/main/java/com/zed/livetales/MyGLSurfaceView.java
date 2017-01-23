package com.zed.livetales;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.AttributeSet;

/**
 * Created by jemalpartida on 04/10/2016.
 */
@Deprecated
public class MyGLSurfaceView extends GLSurfaceView
{

    public MyGLSurfaceView(Context context, AttributeSet attrs )
    {
        super( context, attrs );

        // Create an OpenGL ES 2.0 context
        setEGLContextClientVersion(2);

        mRenderer = new MyRenderer();

        // Set the Renderer for drawing on the GLSurfaceView
        setRenderer(mRenderer);
        setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    }
    private final MyRenderer mRenderer;
}
