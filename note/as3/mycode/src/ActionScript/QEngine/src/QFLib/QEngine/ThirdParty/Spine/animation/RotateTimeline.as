/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class RotateTimeline extends CurveTimeline
    {
        static private const PREV_FRAME_TIME : int = -2;
        static private const FRAME_VALUE : int = 1;

        public function RotateTimeline( frameCount : int )
        {
            super( frameCount );
            frames = new Vector.<Number>( frameCount * 2, true );
        }
                public var boneIndex : int; // time, value, ...
public var frames : Vector.<Number>;

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] )
                return; // Time is before first frame.

            var bone : Bone = skeleton.bones[ boneIndex ];

            var amount : Number;
            if( time >= frames[ int( frames.length - 2 ) ] )
            { // Time is after last frame.
                amount = bone.data.rotation + frames[ int( frames.length - 1 ) ] - bone.rotation;
                while( amount > 180 )
                    amount -= 360;
                while( amount < -180 )
                    amount += 360;
                bone.rotation += amount * alpha;
                return;
            }

            // Interpolate between the previous frame and the current frame.
            var frameIndex : int = Animation.binarySearch( frames, time, 2 );
            var prevFrameValue : Number = frames[ int( frameIndex - 1 ) ];
            var frameTime : Number = frames[ frameIndex ];
            var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
            percent = getCurvePercent( frameIndex / 2 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

            amount = frames[ int( frameIndex + FRAME_VALUE ) ] - prevFrameValue;
            while( amount > 180 )
                amount -= 360;
            while( amount < -180 )
                amount += 360;
            amount = bone.data.rotation + (prevFrameValue + amount * percent) - bone.rotation;
            while( amount > 180 )
                amount -= 360;
            while( amount < -180 )
                amount += 360;
            bone.rotation += amount * alpha;
        }

        /** Sets the time and angle of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, angle : Number ) : void
        {
            frameIndex *= 2;
            frames[ frameIndex ] = time;
            frames[ int( frameIndex + 1 ) ] = angle;
        }
    }

}
