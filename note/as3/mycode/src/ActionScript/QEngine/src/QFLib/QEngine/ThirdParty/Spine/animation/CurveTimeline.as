/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    /** Base class for frames that use an interpolation bezier curve. */
    public class CurveTimeline implements Timeline
    {
        static private const LINEAR : Number = 0;
        static private const STEPPED : Number = 1;
        static private const BEZIER : Number = 2;
        static private const BEZIER_SEGMENTS : int = 10;
        static private const BEZIER_SIZE : int = BEZIER_SEGMENTS * 2 - 1;

                public function CurveTimeline( frameCount : int )
        {
            this.frameCount = frameCount;
            curves = new Vector.<Number>( (frameCount - 1) * BEZIER_SIZE, true );
        } // type, x, y, ...
        public var frameCount : int;
private var curves : Vector.<Number>;

        public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
        }

        public function getCurves() : Vector.<Number>
        {
            return curves;
        }

        public function setCurves( value : Vector.<Number> ) : void
        {
            curves = value;
        }

        [Inline]
        final public function setLinear( frameIndex : int ) : void
        {
            curves[ frameIndex * BEZIER_SIZE ] = LINEAR;
        }

        [Inline]
        final public function setStepped( frameIndex : int ) : void
        {
            curves[ frameIndex * BEZIER_SIZE ] = STEPPED;
        }

        /** Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
         * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
         * the difference between the keyframe's values. */
        [Inline]
        final public function setCurve( frameIndex : int, cx1 : Number, cy1 : Number, cx2 : Number, cy2 : Number ) : void
        {
            var subdiv1 : Number = 1 / BEZIER_SEGMENTS, subdiv2 : Number = subdiv1 * subdiv1, subdiv3 : Number = subdiv2 * subdiv1;
            var pre1 : Number = 3 * subdiv1, pre2 : Number = 3 * subdiv2, pre4 : Number = 6 * subdiv2, pre5 : Number = 6 * subdiv3;
            var tmp1x : Number = -cx1 * 2 + cx2, tmp1y : Number = -cy1 * 2 + cy2, tmp2x : Number = (cx1 - cx2) * 3 + 1, tmp2y : Number = (cy1 - cy2) * 3 + 1;
            var dfx : Number = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv3, dfy : Number = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv3;
            var ddfx : Number = tmp1x * pre4 + tmp2x * pre5, ddfy : Number = tmp1y * pre4 + tmp2y * pre5;
            var dddfx : Number = tmp2x * pre5, dddfy : Number = tmp2y * pre5;

            var i : int = frameIndex * BEZIER_SIZE;
            var curves : Vector.<Number> = this.curves;
            curves[ int( i++ ) ] = BEZIER;

            var x : Number = dfx, y : Number = dfy;
            for( var n : int = i + BEZIER_SIZE - 1; i < n; i += 2 )
            {
                curves[ i ] = x;
                curves[ int( i + 1 ) ] = y;
                dfx += ddfx;
                dfy += ddfy;
                ddfx += dddfx;
                ddfy += dddfy;
                x += dfx;
                y += dfy;
            }
        }

        public function getCurvePercent( frameIndex : int, percent : Number ) : Number
        {
            var curves : Vector.<Number> = this.curves;
            var i : int = frameIndex * BEZIER_SIZE;
            var type : Number = curves[ i ];
            if( type == LINEAR ) return percent;
            if( type == STEPPED ) return 0;
            i++;
            var x : Number = 0;
            for( var start : int = i, n : int = i + BEZIER_SIZE - 1; i < n; i += 2 )
            {
                x = curves[ i ];
                if( x >= percent )
                {
                    var prevX : Number, prevY : Number;
                    if( i == start )
                    {
                        prevX = 0;
                        prevY = 0;
                    } else
                    {
                        prevX = curves[ int( i - 2 ) ];
                        prevY = curves[ int( i - 1 ) ];
                    }
                    return prevY + (curves[ int( i + 1 ) ] - prevY) * (percent - prevX) / (x - prevX);
                }
            }
            var y : Number = curves[ int( i - 1 ) ];
            return y + (1 - y) * (percent - x) / (1 - x); // Last point is 1,1.
        }
    }

}
