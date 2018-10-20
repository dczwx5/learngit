/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;
    import QFLib.QEngine.ThirdParty.Spine.Slot;

    public class DrawOrderTimeline implements Timeline
    {
                public function DrawOrderTimeline( frameCount : int )
        {
            frames = new Vector.<Number>( frameCount, true );
            drawOrders = new Vector.<Vector.<int>>( frameCount, true );
        } // time, ...
public var frames : Vector.<Number>;
        public var drawOrders : Vector.<Vector.<int>>;

        [Inline]
        final public function get frameCount() : int
        {
            return frames.length;
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, drawOrder : Vector.<int> ) : void
        {
            frames[ frameIndex ] = time;
            drawOrders[ frameIndex ] = drawOrder;
        }

        public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] )
                return; // Time is before first frame.

            var frameIndex : int;
            if( time >= frames[ int( frames.length - 1 ) ] ) // Time is after last frame.
                frameIndex = frames.length - 1;
            else
                frameIndex = Animation.binarySearch1( frames, time ) - 1;

            var drawOrder : Vector.<Slot> = skeleton.drawOrder;
            var slots : Vector.<Slot> = skeleton.slots;
            var drawOrderToSetupIndex : Vector.<int> = drawOrders[ frameIndex ];
            var i : int = 0;
            if( !drawOrderToSetupIndex )
            {
                for each ( var slot : Slot in slots )
                    drawOrder[ i++ ] = slot;
            } else
            {
                for each ( var setupIndex : int in drawOrderToSetupIndex )
                    drawOrder[ i++ ] = slots[ setupIndex ];
            }
        }
    }

}
