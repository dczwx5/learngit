/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class EventTimeline implements Timeline
    {
                public function EventTimeline( frameCount : int )
        {
            frames = new Vector.<Number>( frameCount, true );
            events = new Vector.<Event>( frameCount, true );
        } // time, ...
public var frames : Vector.<Number>;
        public var events : Vector.<Event>;

        [Inline]
        final public function get frameCount() : int
        {
            return frames.length;
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, event : Event ) : void
        {
            frames[ frameIndex ] = event.time;
            events[ frameIndex ] = event;
        }

        /** Fires events for frames > lastTime and <= time. */
        public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( !firedEvents ) return;

            if( lastTime > time )
            { // Fire events after last time for looped animations.
                apply( skeleton, lastTime, int.MAX_VALUE, firedEvents, alpha );
                lastTime = -1;
            } else if( lastTime >= frames[ int( frameCount - 1 ) ] ) // Last time is after last frame.
                return;
            if( time < frames[ 0 ] ) return; // Time is before first frame.

            var frameIndex : int;
            if( lastTime < frames[ 0 ] )
                frameIndex = 0;
            else
            {
                frameIndex = Animation.binarySearch1( frames, lastTime );
                var frame : Number = frames[ frameIndex ];
                while( frameIndex > 0 )
                { // Fire multiple events with the same frame.
                    if( frames[ int( frameIndex - 1 ) ] != frame ) break;
                    frameIndex--;
                }
            }
            for( ; frameIndex < frameCount && time >= frames[ frameIndex ]; frameIndex++ )
                firedEvents[ firedEvents.length ] = events[ frameIndex ];
        }
    }

}
