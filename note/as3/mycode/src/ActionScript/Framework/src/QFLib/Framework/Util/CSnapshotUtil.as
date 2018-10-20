//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/11/17.
 */
package QFLib.Framework.Util
{

    import QFLib.Framework.CObject;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.utils.CSnapShotUtil;
    import QFLib.Math.CAABBox2;

    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    public class CSnapshotUtil
    {
        public static function set snashotDraw ( value : Boolean) : void { CSnapShotUtil.sSnapshotDraw = value; }

        public static function snapshot ( target : CObject, inBound : Rectangle, result : BitmapData, baseOnInBound : Boolean = false, scaleWithInBound : Boolean = false, scaleWithStage : Boolean = false ) : BitmapData
        {
            var renderable : CBaseObject = target.theObject;
            var selfBound : CAABBox2 = renderable.currentBound;

            return snapshotex ( renderable, inBound, result, selfBound, baseOnInBound, scaleWithInBound, scaleWithStage );
        }

        public static function snapshotex ( target : CBaseObject, inBound : Rectangle, result : BitmapData, selfBound : CAABBox2 = null, baseOnInBound : Boolean = false, scaleWithInBound : Boolean = false, scaleWithStage : Boolean = false ) : BitmapData
        {
            var renderable : DisplayObject = target.renderableObject;
            if ( renderable )
                return CSnapShotUtil.snapshot ( renderable, inBound, result, selfBound, baseOnInBound, scaleWithInBound, scaleWithStage );

            return null;
        }
    }
}
