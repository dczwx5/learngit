//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/18.
 */
package QFLib.Graphics.FX {

import QFLib.Foundation;
import QFLib.ResourceLoader.CJsonLoader;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.Quality;

public class CFxAtlasInfo {

    public var atlasInfo:Object;
    private var isLoading:Boolean = false;
    private var isLoadFailed:Boolean = false;

    private var _resource : CResource = null;

    public function CFxAtlasInfo() {
    }

    private static var _instance:CFxAtlasInfo;
    public static function get instance():CFxAtlasInfo
    {
        if(_instance == null)
        {
            _instance = new CFxAtlasInfo();
        }
        return _instance;
    }

    public function loadFile():void
    {
        if(CFxAtlasInfo.instance.atlasInfo || isLoading || isLoadFailed) return;

        isLoading = true;
        CResourceLoaders.instance ().startLoadFile ( "assets/fx/textureAltas/textureInfo.json", onLoadFinished, CJsonLoader.NAME, ELoadingPriority.CRITICAL );
    }

    private function onLoadFinished ( loader : CJsonLoader, idErrorCode : int ) : void
    {
        isLoading = false;
        if ( idErrorCode == 0 )
        {
            _resource = loader.createResource ();
            atlasInfo = _resource.theObject;

            if(atlasInfo == null)
            {
                isLoadFailed = true;
                Quality.useFxAtlas = false;
                Foundation.Log.logErrorMsg ( "FX' atlasData parse failed, please check the file: " + loader.filename );
            }
        }
        else
        {
            isLoadFailed = true;
            Quality.useFxAtlas = false;
            Foundation.Log.logErrorMsg ( "FX' atlasData load failed, please check the url: " + loader.filename );
        }
    }

    public static function getFileName(url:String):String
    {
        var lastIndex:int = url.lastIndexOf("/");
        return url.slice(lastIndex+1);
    }

    public static function getFileNameWithoutSuffix(url:String):String
    {
        var lastIndex:int = url.lastIndexOf("/");
        var fileName:String = url.slice(lastIndex+1);
        lastIndex = fileName.lastIndexOf(".");
        return fileName.slice(0, lastIndex);
    }
}
}
