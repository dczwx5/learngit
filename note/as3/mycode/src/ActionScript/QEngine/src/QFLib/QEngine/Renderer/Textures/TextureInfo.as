/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.Renderer.Textures
{
    import flash.geom.Rectangle;

    public class TextureInfo
    {
        public function TextureInfo( region : Rectangle, frame : Rectangle, rotated : Boolean )
        {
            this.region = region;
            this.frame = frame;
            this.rotated = rotated;
        }

        public var region : Rectangle;
        public var frame : Rectangle;
        public var rotated : Boolean;
    }
}