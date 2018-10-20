//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/9/15.
 */
package spineExt.TimeLineCache {

import spine.Bone;
import spine.Event;
import spine.Skeleton;
import spine.animation.Animation;
import spine.animation.ScaleTimeline;

public class ScaleTimelineIncache extends ScaleTimeline{
    public function ScaleTimelineIncache(frameCount:int)
    {
        super (frameCount);
    }

    static internal const PREV_FRAME_TIME:int = -3;
    static internal const FRAME_X:int = 1;
    static internal const FRAME_Y:int = 2;
    private var m_vvScale : Vector.<Vector.<Number>> = null;
    private var m_vScale : Vector.<Number> =new Vector.<Number>(2, true);

    private var m_nFrameIndex : int;
    private var m_fDuration : Number;
    public function initial() : void
    {
        if (m_vvScale == null)
        {
            m_vvScale = new Vector.<Vector.<Number>>((frames[frames.length - 3] + 0.00001) / TimelineCache.FrameGap + 1) ;
            m_fDuration =  frames[int(frames.length - 3)];
        }
    }

    [Inline]
    final override public function apply (skeleton:Skeleton, lastTime:Number, time:Number, firedEvents:Vector.<Event>, alpha:Number, isPassMiddleMixTime : Boolean = false) : void
    {
        if (!TimelineCache.FrameCacheEnabled)
        {
            super.apply(skeleton, lastTime, time, firedEvents, alpha, isPassMiddleMixTime);
            return;
        }

        if (time < frames[0])
            return; // Time is before first frame.

        initial();

        var bone:Bone = skeleton.bones[boneIndex];
        if (time >= m_fDuration)
        { // Time is after last frame.
            m_nFrameIndex = m_vvScale.length - 1;
            if (m_vvScale[m_nFrameIndex] == null)
            {
                m_vvScale[m_nFrameIndex] = new Vector.<Number>(2, true);

                m_vvScale[m_nFrameIndex][0] =bone.data.scaleX * frames[int(frames.length - 2)] - bone.scaleX;
                m_vvScale[m_nFrameIndex][1] = bone.data.scaleY * frames[int(frames.length - 1)] - bone.scaleY;

                bone.scaleX += m_vvScale[m_nFrameIndex][0] * alpha;
                bone.scaleY += m_vvScale[m_nFrameIndex][1] * alpha;
            }
            else
            {
                bone.scaleX += m_vvScale[m_nFrameIndex][0] * alpha;
                bone.scaleY += m_vvScale[m_nFrameIndex][1] * alpha;
            }
        }
        else
        {
            m_nFrameIndex = TimelineCache.getFrameIndex(time);
            if (m_vvScale[m_nFrameIndex] == null) {

                time = (int)(time/TimelineCache.FrameGap) * TimelineCache.FrameGap + 0.00001; //此处Number.MIN_VALUE不可用
                // Interpolate between the previous frame and the current frame.
                var frameIndex:int = Animation.binarySearch(frames, time, 3);
                var prevFrameX:Number = frames[int(frameIndex - 2)];
                var prevFrameY:Number = frames[int(frameIndex - 1)];
                var frameTime:Number = frames[frameIndex];
                var percent:Number = 1 - (time - frameTime) / (frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
                percent = getCurvePercent(frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

                m_vvScale[m_nFrameIndex] = new Vector.<Number>(2, true);
                m_vvScale[m_nFrameIndex][0] = bone.data.scaleX * (prevFrameX + (frames[int(frameIndex + FRAME_X)] - prevFrameX) * percent);
                m_vvScale[m_nFrameIndex][1] = bone.data.scaleY * (prevFrameY + (frames[int(frameIndex + FRAME_Y)] - prevFrameY) * percent);

                m_vScale[0] = m_vvScale[m_nFrameIndex][0]  - bone.scaleX;
                m_vScale[1] = m_vvScale[m_nFrameIndex][1] - bone.scaleY;

                bone.scaleX += m_vScale[0] * alpha;
                bone.scaleY += m_vScale[1] * alpha;

//                if (TimelineCache.getFrameIndex(time) == 1 && boneIndex == 1)
//                {
//                    trace("initial timeline data , scale  : " + skeleton.skinName + " ,   " + name);
//                }
            }
            else
            {
                m_vScale[0] = m_vvScale[m_nFrameIndex][0] - bone.scaleX;
                m_vScale[1] = m_vvScale[m_nFrameIndex][1] - bone.scaleY;

                bone.scaleX += m_vScale[0] * alpha;
                bone.scaleY += m_vScale[1] * alpha;
            }
        }
    }
}
}
