/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.IkConstraint;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class IkConstraintTimeline extends CurveTimeline
    {
        static private const PREV_FRAME_TIME : int = -3;
        static private const PREV_FRAME_MIX : int = -2;
        static private const PREV_FRAME_BEND_DIRECTION : int = -1;
        static private const FRAME_MIX : int = 1;

        public function IkConstraintTimeline( frameCount : int )
        {
            super( frameCount );
            frames = new Vector.<Number>( frameCount * 3, true );
        }
                public var ikConstraintIndex : int; // time, mix, bendDirection, ...
public var frames : Vector.<Number>;

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] ) return; // Time is before first frame.

            var ikConstraint : IkConstraint = skeleton.ikConstraints[ ikConstraintIndex ];

            if( time >= frames[ int( frames.length - 3 ) ] )
            { // Time is after last frame.
                ikConstraint.mix += (frames[ int( frames.length - 2 ) ] - ikConstraint.mix) * alpha;
                ikConstraint.bendDirection = int( frames[ int( frames.length - 1 ) ] );
                return;
            }

            // Interpolate between the previous frame and the current frame.
            var frameIndex : int = Animation.binarySearch( frames, time, 3 );
            var prevFrameMix : Number = frames[ int( frameIndex + PREV_FRAME_MIX ) ];
            var frameTime : Number = frames[ frameIndex ];
            var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
            percent = getCurvePercent( frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

            var mix : Number = prevFrameMix + (frames[ int( frameIndex + FRAME_MIX ) ] - prevFrameMix) * percent;
            ikConstraint.mix += (mix - ikConstraint.mix) * alpha;
            ikConstraint.bendDirection = int( frames[ int( frameIndex + PREV_FRAME_BEND_DIRECTION ) ] );
        }

        /** Sets the time, mix and bend direction of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, mix : Number, bendDirection : int ) : void
        {
            frameIndex *= 3;
            frames[ frameIndex ] = time;
            frames[ int( frameIndex + 1 ) ] = mix;
            frames[ int( frameIndex + 2 ) ] = bendDirection;
        }
    }

}
