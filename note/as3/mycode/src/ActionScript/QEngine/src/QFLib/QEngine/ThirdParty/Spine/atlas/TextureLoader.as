/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.atlas
{
    public interface TextureLoader
    {
        function loadPage( page : AtlasPage, path : String ) : void;

        function loadRegion( region : AtlasRegion ) : void;

        function unloadPage( page : AtlasPage ) : void;
    }

}
