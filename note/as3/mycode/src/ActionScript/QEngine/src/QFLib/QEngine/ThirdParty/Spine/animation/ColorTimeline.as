/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;
    import QFLib.QEngine.ThirdParty.Spine.Slot;

    public class ColorTimeline extends CurveTimeline
    {
        static private const PREV_FRAME_TIME : int = -5;
        static private const FRAME_R : int = 1;
        static private const FRAME_G : int = 2;
        static private const FRAME_B : int = 3;
        static private const FRAME_A : int = 4;

        public function ColorTimeline( frameCount : int )
        {
            super( frameCount );
            frames = new Vector.<Number>( frameCount * 5, true );
        }
                public var slotIndex : int; // time, r, g, b, a, ...
public var frames : Vector.<Number>;

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] )
                return; // Time is before first frame.

            var r : Number, g : Number, b : Number, a : Number;
            if( time >= frames[ int( frames.length - 5 ) ] )
            {
                // Time is after last frame.
                var i : int = frames.length - 1;
                r = frames[ int( i - 3 ) ];
                g = frames[ int( i - 2 ) ];
                b = frames[ int( i - 1 ) ];
                a = frames[ i ];
            } else
            {
                // Interpolate between the previous frame and the current frame.
                var frameIndex : int = Animation.binarySearch( frames, time, 5 );
                var prevFrameR : Number = frames[ int( frameIndex - 4 ) ];
                var prevFrameG : Number = frames[ int( frameIndex - 3 ) ];
                var prevFrameB : Number = frames[ int( frameIndex - 2 ) ];
                var prevFrameA : Number = frames[ int( frameIndex - 1 ) ];
                var frameTime : Number = frames[ frameIndex ];
                var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
                percent = getCurvePercent( frameIndex / 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

                r = prevFrameR + (frames[ int( frameIndex + FRAME_R ) ] - prevFrameR) * percent;
                g = prevFrameG + (frames[ int( frameIndex + FRAME_G ) ] - prevFrameG) * percent;
                b = prevFrameB + (frames[ int( frameIndex + FRAME_B ) ] - prevFrameB) * percent;
                a = prevFrameA + (frames[ int( frameIndex + FRAME_A ) ] - prevFrameA) * percent;
            }
            var slot : Slot = skeleton.slots[ slotIndex ];
            if( alpha < 1 )
            {
                slot.r += (r - slot.r) * alpha;
                slot.g += (g - slot.g) * alpha;
                slot.b += (b - slot.b) * alpha;
                slot.a += (a - slot.a) * alpha;
            } else
            {
                slot.r = r;
                slot.g = g;
                slot.b = b;
                slot.a = a;
            }
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, r : Number, g : Number, b : Number, a : Number ) : void
        {
            frameIndex *= 5;
            frames[ frameIndex ] = time;
            frames[ int( frameIndex + 1 ) ] = r;
            frames[ int( frameIndex + 2 ) ] = g;
            frames[ int( frameIndex + 3 ) ] = b;
            frames[ int( frameIndex + 4 ) ] = a;
        }
    }

}
