/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class TranslateTimeline extends CurveTimeline
    {
        static internal const PREV_FRAME_TIME : int = -3;
        static internal const FRAME_X : int = 1;
        static internal const FRAME_Y : int = 2;

        public function TranslateTimeline( frameCount : int )
        {
            super( frameCount );
            frames = new Vector.<Number>( frameCount * 3, true );
        }
                public var boneIndex : int; // time, value, value, ...
public var frames : Vector.<Number>;

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] )
                return; // Time is before first frame.

            var bone : Bone = skeleton.bones[ boneIndex ];

            if( time >= frames[ int( frames.length - 3 ) ] )
            { // Time is after last frame.
                bone.x += (bone.data.x + frames[ int( frames.length - 2 ) ] - bone.x) * alpha;
                bone.y += (bone.data.y + frames[ int( frames.length - 1 ) ] - bone.y) * alpha;
                return;
            }

            // Interpolate between the previous frame and the current frame.
            var frameIndex : int = Animation.binarySearch( frames, time, 3 );
            var prevFrameX : Number = frames[ int( frameIndex - 2 ) ];
            var prevFrameY : Number = frames[ int( frameIndex - 1 ) ];
            var frameTime : Number = frames[ frameIndex ];
            var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
            percent = getCurvePercent( frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

            bone.x += (bone.data.x + prevFrameX + (frames[ int( frameIndex + FRAME_X ) ] - prevFrameX) * percent - bone.x) * alpha;
            bone.y += (bone.data.y + prevFrameY + (frames[ int( frameIndex + FRAME_Y ) ] - prevFrameY) * percent - bone.y) * alpha;
        }

        /** Sets the time and value of the specified keyframe. */
        [Inline]
        final public function setFrame( frameIndex : int, time : Number, x : Number, y : Number ) : void
        {
            frameIndex *= 3;
            frames[ frameIndex ] = time;
            frames[ int( frameIndex + 1 ) ] = x;
            frames[ int( frameIndex + 2 ) ] = y;
        }
    }

}
