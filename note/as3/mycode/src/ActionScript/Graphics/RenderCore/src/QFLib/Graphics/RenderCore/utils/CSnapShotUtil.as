package QFLib.Graphics.RenderCore.utils
{

    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Math.CAABBox2;

    import flash.display.BitmapData;
    import flash.geom.Rectangle;

    public class CSnapShotUtil
    {
        public static var sSnapshotDraw : Boolean = true;

        private static var sBoundHelper : Rectangle = new Rectangle ();

        public static function snapshot ( target : DisplayObject, inBound : Rectangle,
                                          result : BitmapData = null, selfInBound : CAABBox2 = null, baseOnInBound : Boolean = false, scaleWithInBound : Boolean = false, scaleWithStage : Boolean = false, onError : Function = null ) : BitmapData
        {
            var selfBound : Rectangle = null;

            var selfXOffset : Number = 0;
            var selfYOffset : Number = 0;
            if ( null == selfInBound )
            {
                selfBound = target.getBounds ( target, null );

                selfXOffset = ( selfBound.left + selfBound.right ) * 0.5 - target.x;
                selfYOffset = selfBound.height * 0.5 - Math.abs ( ( selfBound.top + selfBound.bottom ) * 0.5 - target.y );
            }
            else
            {
                selfBound = sBoundHelper;

                selfBound.width = selfInBound.width;
                selfBound.height = selfInBound.height;

                selfXOffset = selfInBound.center.x;
                selfYOffset = selfInBound.height * 0.5 - Math.abs( selfInBound.center.y );
            }

            var snapshotW : int;
            var snapshotH : int;

            var scale : Number = 1;
            var scaleX : Number = 1;
            var scaleY : Number = 1;
            if ( baseOnInBound )
            {
                snapshotW = inBound.width;
                snapshotH = inBound.height;

                if ( scaleWithInBound )
                {
                    var targetScaleX : Number = target.scaleX;
                    var targetScaleY : Number = target.scaleY;
                    scaleX = snapshotW / ( selfBound.width / targetScaleX );
                    scaleY = snapshotH / ( selfBound.height / targetScaleY );

                    scale = scaleX > scaleY ? scaleY : scaleX;
                }
            }
            else
            {
                snapshotW = selfBound.width - Math.abs ( inBound.x );
                snapshotH = selfBound.height - Math.abs ( inBound.y );
            }

            if ( snapshotW <= 0 || snapshotH <= 0 ) return null;

            var stageScale : Number = 1.0;
            if ( scaleWithStage )
            {
                scaleX = Starling.current.viewPort.width / 1500.0;
                scaleY = Starling.current.viewPort.height / 900.0;

                stageScale = scaleX > scaleY ? scaleY : scaleX;
                snapshotW *= stageScale;
                snapshotH *= stageScale;

                selfXOffset *= stageScale;
                selfYOffset *= stageScale;
            }

            var bitmapW : int = Math.min( snapshotW, Starling.current.viewPort.width );
            var bitmapH : int = Math.min( snapshotH, Starling.current.viewPort.height );

            if ( !result || result.width != bitmapW || result.height != bitmapH )
            {
                if ( result ) result.dispose ();
                result = new BitmapData ( bitmapW, bitmapH, true, 0 );
            }

            scale *= stageScale;
            Starling.current.snapshotRendering ( target, snapshotW, snapshotH, inBound.x - selfXOffset, inBound.y - selfYOffset, scale, scale );
            Starling.current.snapshotToBitmapData ( result, sSnapshotDraw );

            return result;
        }
    }
}


