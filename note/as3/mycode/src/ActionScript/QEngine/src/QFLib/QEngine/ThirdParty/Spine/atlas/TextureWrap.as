/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.atlas
{

    public class TextureWrap
    {
        public static const mirroredRepeat : TextureWrap = new TextureWrap( 0, "mirroredRepeat" );
        public static const clampToEdge : TextureWrap = new TextureWrap( 1, "clampToEdge" );
        public static const repeat : TextureWrap = new TextureWrap( 2, "repeat" );

        public function TextureWrap( ordinal : int, name : String )
        {
            this.ordinal = ordinal;
            this.name = name;
        }
        public var ordinal : int;
        public var name : String;
    }

}
