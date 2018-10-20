////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

/**
 * Created by david on 2017/5/9.
 */
package QFLib.Graphics.RenderCore.starling.filters
{
    public class RimLightEffect extends FilterEffect
    {
        public static const Name : String = "Rimlight";

        public function RimLightEffect ( pFilter : ObjectFilter )
        {
            super ( pFilter );
        }

        override public function dispose () : void
        {
            super.dispose ();
        }

        [Inline] override public function get name () : String { return Name; }
    }
}
