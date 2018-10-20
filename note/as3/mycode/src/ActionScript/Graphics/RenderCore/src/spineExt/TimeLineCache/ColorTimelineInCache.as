/**
 * Created by Burgess on 2017/9/14.
 */
package spineExt.TimeLineCache {

import spine.Event;
import spine.Skeleton;
import spine.Slot;
import spine.animation.Animation;
import spine.animation.ColorTimeline;

public class ColorTimelineInCache extends ColorTimeline
{
    public function ColorTimelineInCache(frameCount:int)
    {
        super(frameCount);
    }

    static private const PREV_FRAME_TIME:int = -5;
    static private const FRAME_R:int = 1;
    static private const FRAME_G:int = 2;
    static private const FRAME_B:int = 3;
    static private const FRAME_A:int = 4;

    private var m_vColors : Vector.<Vector.<int>> = null;

    private var m_nFrameIndex : int;
    public function initial() : void
    {
        if (m_vColors == null)
            m_vColors = new Vector.<Vector.<int>>((frames[frames.length - 5]+ 0.00001) / TimelineCache.FrameGap + 1);
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

        var slot:Slot = skeleton.slots[slotIndex];
        if (time >= frames[int(frames.length - 5)]) {
            if (alpha < 1) {
                slot.r += ( frames[frames.length - 4] - slot.r) * alpha;
                slot.g += (frames[frames.length - 3] - slot.g) * alpha;
                slot.b += (frames[frames.length - 2] - slot.b) * alpha;
                slot.a += (frames[frames.length - 1] - slot.a) * alpha;
            } else {
                slot.r =  frames[frames.length - 4];
                slot.g = frames[frames.length - 3];
                slot.b = frames[frames.length - 2];
                slot.a = frames[frames.length - 1];
            }
        }
        else {
            m_nFrameIndex = TimelineCache.getFrameIndex(time)
            if (m_vColors[m_nFrameIndex] == null)
            {
                time = (int)(time/TimelineCache.FrameGap) * TimelineCache.FrameGap + 0.00001; //此处Number.MIN_VALUE不可用
                // Interpolate between the previous frame and the current frame.
                var frameIndex:int = Animation.binarySearch(frames, time, 5);
                var prevFrameR:Number = frames[int(frameIndex - 4)];
                var prevFrameG:Number = frames[int(frameIndex - 3)];
                var prevFrameB:Number = frames[int(frameIndex - 2)];
                var prevFrameA:Number = frames[int(frameIndex - 1)];
                var frameTime:Number = frames[frameIndex];
                var percent:Number = 1 - (time - frameTime) / (frames[int(frameIndex + PREV_FRAME_TIME)] - frameTime);
                percent = getCurvePercent(frameIndex / 5 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

                m_vColors[m_nFrameIndex] = new Vector.<int>(4, true);
                m_vColors[m_nFrameIndex][0] = prevFrameR + (frames[int(frameIndex + FRAME_R)] - prevFrameR) * percent;
                m_vColors[m_nFrameIndex][1] = prevFrameG + (frames[int(frameIndex + FRAME_G)] - prevFrameG) * percent;
                m_vColors[m_nFrameIndex][2] = prevFrameB + (frames[int(frameIndex + FRAME_B)] - prevFrameB) * percent;
                m_vColors[m_nFrameIndex][3] = prevFrameA + (frames[int(frameIndex + FRAME_A)] - prevFrameA) * percent;
//                if (TimelineCache.getFrameIndex(time) == 1 && slotIndex == 1)
//                {
//                    trace("initial timeline data , color  : " + skeleton.skinName + " ,   " + name);
//                }
            }
            if (alpha < 1) {
                slot.r += (m_vColors[m_nFrameIndex][0] - slot.r) * alpha;
                slot.g += (m_vColors[m_nFrameIndex][1] - slot.g) * alpha;
                slot.b += (m_vColors[m_nFrameIndex][2] - slot.b) * alpha;
                slot.a += (m_vColors[m_nFrameIndex][3] - slot.a) * alpha;
            } else {
                slot.r = m_vColors[m_nFrameIndex][0];
                slot.g = m_vColors[m_nFrameIndex][1];
                slot.b = m_vColors[m_nFrameIndex][2];
                slot.a = m_vColors[m_nFrameIndex][3];
            }
        }
    }
}
}
