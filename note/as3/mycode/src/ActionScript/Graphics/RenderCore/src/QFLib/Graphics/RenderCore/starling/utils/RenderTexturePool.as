//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/6/3.
 */
package QFLib.Graphics.RenderCore.starling.utils {

    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
import QFLib.Foundation.CSet;
import QFLib.Foundation.CTimer;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;

import cmodule.hookOggVorbisLib.gvglpixels;

import flash.events.TimerEvent;
    import flash.utils.Timer;

    public class RenderTexturePool {
    private var m_mapRenderTextures : CMap = new CMap ();
    private var m_mapIdleTextures : CMap = new CMap ();

    private var m_mapLoadedTextures : CMap = new CMap ();
    private var m_fRecycleTime : Number = 45;
    private var m_fPlayTime : Number = 0;
    private var m_theRunTimer : Timer = null;
    private var m_theTimer: CTimer = null;
    private static var s_theInstance : RenderTexturePool = null;


    public static function instance() : RenderTexturePool
    {
        if( s_theInstance == null ) s_theInstance = new RenderTexturePool();
        return s_theInstance;
    }

    public function RenderTexturePool(fUpdateTimeInterval : Number = 15.0, fFPS : Number = 15.0)
    {
        m_fRecycleTime = fUpdateTimeInterval;
        if( fFPS > 0.0 )
        {
            var iMilliSec : int = 1000.0 / fFPS;

            m_theRunTimer = new Timer( iMilliSec );
            m_theRunTimer.addEventListener( TimerEvent.TIMER, _onTimer );
            m_theRunTimer.start();

            m_theTimer = new CTimer();
            m_theTimer.reset();
        }
    }

    public function dispose() : void
    {
        m_theRunTimer.removeEventListener( TimerEvent.TIMER, _onTimer );
        m_theRunTimer.stop();
        m_theRunTimer = null;

        m_theTimer = null;
        var textures : CSet;
        for (var key : String in  m_mapIdleTextures)
        {
            textures = m_mapIdleTextures.find(key);
            for (var texture : Texture in textures)
            {
                texture.dispose();
                texture = null;
             }
            textures.clear();
        }
        m_mapIdleTextures.clear();
        for each (texture in m_mapRenderTextures)
        {
            textures = m_mapRenderTextures.find(key);
            for (texture in textures)
            {
                texture.dispose();
                texture = null;
            }
            textures.clear();
        }
        m_mapRenderTextures.clear();
        for (texture in m_mapLoadedTextures)
        {
            texture.dispose();
            texture = null;
        }
        m_mapLoadedTextures.clear();
    }

    public function set recycleTime(time : Number) : void
    {
        m_fRecycleTime = time;
    }
    public function get renderTextureCount() : int
    {
        var count : int = 0;
        for each(var textures : CSet in m_mapRenderTextures )
        {
            count += textures.count;
        }
        return count;
    }

    public  function get loadedTextureCount() : int
    {
        return m_mapLoadedTextures.count;
    }

    public function get textureCount() : int
    {
        var count : int = 0;
        for each(var textures : CSet in m_mapRenderTextures )
        {
            count += textures.count;
        }
        for each( textures in m_mapIdleTextures )
        {
            count += textures.count;
        }
        return count;
    }

    public function get renderTextureState() : String
    {
        var state : String = "render texture state : \n";
        for (var key : String in m_mapRenderTextures)
        {
            state += key + " count :  " +  (m_mapRenderTextures.find(key) as  CSet).count + "\n";
        }
        state += "idle render texture state : \n"
        for ( key in m_mapIdleTextures)
        {
            state += key +" count :  " +  (m_mapIdleTextures.find(key) as  CSet).count + "\n";
        }
        return state;
    }

    public function update(deltaTime : Number) : void
    {
        m_fPlayTime += deltaTime;
        if (m_fPlayTime > m_fRecycleTime)
        {
            m_fPlayTime = 0;
            _recycle();
        }
    }

    private function _recycle() : void
    {
        for (var key : String in m_mapIdleTextures)
        {
            var textures : CSet = m_mapIdleTextures.find(key);
            for (var texture : Texture in textures)
            {
                if (texture.isTobeRecycled)
                {
                    textures.remove(texture);
                    if (textures.count == 0)
                        m_mapIdleTextures.remove(key);
                    texture.dispose();
                    texture = null;
                }
                else
                {
                    texture.isTobeRecycled = true;
                }
            }

        }

    }

    //先找idle  再找render texture
    public function empty(width:Number, height:Number, premultipliedAlpha:Boolean=true,
                                 mipMapping:Boolean = false, optimizeForRenderToTexture:Boolean=false,
                                 scale:Number= -1, format:String = "compressedAlpha", repeat:Boolean=false):Texture
    {
        var potWidth:int   = GetNextPowerOfTwo(width);
        var potHeight:int  = GetNextPowerOfTwo(height);
        var isPot:Boolean  = (width == potWidth && height == potHeight);
        if (!isPot)
        {
            Foundation.Log.logErrorMsg("the width and height of renderTexture must be power of 2, please check!");
        }
//        if (premultipliedAlpha == true && mipMapping == false && optimizeForRenderToTexture == true && scale == 1 && format == "bgra")
//        {
            var texture : Texture = null;
            var textures : CSet;
            var key : String = _getKey(width, height);
            if (m_mapIdleTextures.find(key) == null)
            {
                try
                {
                    texture = Texture.empty(width ,height, premultipliedAlpha, mipMapping, optimizeForRenderToTexture, scale, format, repeat);
                }
                catch ( error : Error )
                {
                    Foundation.Log.logErrorMsg( "Can not create render texture, because: " + error.toString() );
                    texture = null;
                }

                if ( texture != null )
                {
                    _addRenderTexture(key, texture);
                }
                return texture;
            }
            else
            {
                textures = m_mapIdleTextures.find(key);
                if (textures.count > 1)
                {
                    texture = textures.first();
                    textures.popFirst();
                }
                else
                {
                    try
                    {
                        texture = Texture.empty(width ,height, premultipliedAlpha, mipMapping, optimizeForRenderToTexture, scale, format, repeat);
                    }
                    catch ( error : Error )
                    {
                        Foundation.Log.logErrorMsg( "Can not create render texture, because: " + error.toString() );
                        texture = null;
                    }
                }

                if ( texture != null )
                {
                    _addRenderTexture(key, texture);
                }
                return texture;
            }
//        }
//        else
//        {
//           m_nUncontrolledTextureCount++;
//            return  Texture.empty(width ,height, premultipliedAlpha, mipMapping, optimizeForRenderToTexture, scale, format, repeat);
//         }
    }


    public function recycleTexture( texture : Texture) : void
    {
        if (texture == null)
            return;
        var key :String = _getKey(texture.width, texture.height);

        if (m_mapRenderTextures.find(key) != null)
        {
            var textures : CSet = m_mapRenderTextures.find(key);
            if (textures.isExisted(texture))
            {
                textures.remove(texture);
                if (textures.count == 0)
                    m_mapRenderTextures.remove(key)
                _addIdlTexture(key, texture);
                return;
            }
        }

        //if texture is not in m_mapRenderTextures , it will be disposed next
        texture.dispose();
        texture = null;
    }

    private function _getKey(width:Number, height:Number) : String
    {
        return width.toString() + "_" + height.toString();
    }

    private function _addRenderTexture(key : String, texture:Texture) : void
    {
        var textures : CSet;
        if (m_mapRenderTextures.find(key) != null)
        {
            textures = m_mapRenderTextures.find(key);
            textures.add(texture);
        }
        else
        {
            textures = new CSet();
            textures.add(texture);
            m_mapRenderTextures.add(key, textures);
        }
    }

    private function _addIdlTexture(key : String, texture:Texture) : void
    {
        var textures : CSet;
        texture.isTobeRecycled = false;
        if (m_mapIdleTextures.find(key) != null)
        {
            textures = m_mapIdleTextures.find(key);
            textures.add(texture);
        }
        else
        {
            textures = new CSet();
            textures.add(texture);
            m_mapIdleTextures.add(key, textures);
        }
    }

    private function _onTimer( e:TimerEvent ) : void
    {
        update( m_theTimer.seconds() );
        m_theTimer.reset();
    }
}
}