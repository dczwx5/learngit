/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine
{

    public class BlendMode
    {
        public static const normal : BlendMode = new BlendMode( 0 );
        public static const additive : BlendMode = new BlendMode( 1 );
        public static const multiply : BlendMode = new BlendMode( 2 );
        public static const screen : BlendMode = new BlendMode( 3 );

        public function BlendMode( ordinal : int )
        {
            this.ordinal = ordinal;
        }
        public var ordinal : int;
    }

}
