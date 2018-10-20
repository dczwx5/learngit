/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

package QFLib.QEngine.ThirdParty.Spine.animation
{
    import QFLib.QEngine.ThirdParty.Spine.Bone;
    import QFLib.QEngine.ThirdParty.Spine.Event;
    import QFLib.QEngine.ThirdParty.Spine.Skeleton;

    public class ScaleTimeline extends TranslateTimeline
    {
        public function ScaleTimeline( frameCount : int )
        {
            super( frameCount );
        }

        override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false ) : void
        {
            if( time < frames[ 0 ] )
                return; // Time is before first frame.

            var bone : Bone = skeleton.bones[ boneIndex ];
            if( time >= frames[ int( frames.length - 3 ) ] )
            { // Time is after last frame.
                bone.scaleX += (bone.data.scaleX * frames[ int( frames.length - 2 ) ] - bone.scaleX) * alpha;
                bone.scaleY += (bone.data.scaleY * frames[ int( frames.length - 1 ) ] - bone.scaleY) * alpha;
                return;
            }

            // Interpolate between the previous frame and the current frame.
            var frameIndex : int = Animation.binarySearch( frames, time, 3 );
            var prevFrameX : Number = frames[ int( frameIndex - 2 ) ];
            var prevFrameY : Number = frames[ int( frameIndex - 1 ) ];
            var frameTime : Number = frames[ frameIndex ];
            var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
            percent = getCurvePercent( frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

            bone.scaleX += (bone.data.scaleX * (prevFrameX + (frames[ int( frameIndex + FRAME_X ) ] - prevFrameX) * percent) - bone.scaleX) * alpha;
            bone.scaleY += (bone.data.scaleY * (prevFrameY + (frames[ int( frameIndex + FRAME_Y ) ] - prevFrameY) * percent) - bone.scaleY) * alpha;
        }
    }

}
