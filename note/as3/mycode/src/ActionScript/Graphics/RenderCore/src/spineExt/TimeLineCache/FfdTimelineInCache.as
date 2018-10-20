//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/9/16.
 */
package spineExt.TimeLineCache {

import spine.Event;
import spine.Skeleton;
import spine.Slot;
import spine.animation.Animation;
import spine.animation.FfdTimeline;
import spine.attachments.FfdAttachment;

public class FfdTimelineInCache extends FfdTimeline
{
    public function FfdTimelineInCache(frameCount:int) {
        super(frameCount);
    }

    public var m_vvCacheVertices : Vector.<Vector.<Number>>;
    private var m_nFrameIndex : int;

    public function initial() : void
    {
        if (m_vvCacheVertices == null)
            m_vvCacheVertices = new Vector.<Vector.<Number>>((frames[frames.length - 1]+ 0.00001) / TimelineCache.FrameGap + 1);
    }

    [Inline]
    final override public function apply (skeleton:Skeleton, lastTime:Number, time:Number, firedEvents:Vector.<Event>, alpha:Number, isPassMiddleMixTime : Boolean = false) : void
    {
        if (!TimelineCache.FrameCacheEnabled)
        {
            super.apply(skeleton, lastTime, time, firedEvents, alpha, isPassMiddleMixTime);
            return;
        }

        var slot:Slot = skeleton.slots[slotIndex];
        var slotAttachment:FfdAttachment = slot.attachment as FfdAttachment;
        if (!slotAttachment || !slotAttachment.applyFFD(attachment)) return;

        if (time < frames[0]) return; // Time is before first frame.
        var vertexCount:int = frameVertices[0].length;
        initial();

        var vertices:Vector.<Number> = slot.attachmentVertices;
        if (vertices.length != vertexCount) alpha = 1; // Don't mix from uninitialized slot vertices.
        vertices.length = vertexCount;
        var i:int;
        if (time >= frames[frames.length - 1]) { // Time is after last frame.
            var lastVertices:Vector.<Number> = frameVertices[frames.length - 1];
            if (alpha < 1) {
                for (i = 0; i < vertexCount; i++)
                    vertices[i] += (lastVertices[i] - vertices[i]) * alpha;
            } else {
                for (i = 0; i < vertexCount; i++)
                    vertices[i] = lastVertices[i];
            }
        }
        else
        {
            m_nFrameIndex = TimelineCache.getFrameIndex(time);
            if (m_vvCacheVertices[m_nFrameIndex] == null)
            {
                time = (int)(time/TimelineCache.FrameGap) * TimelineCache.FrameGap + 0.00001; //此处Number.MIN_VALUE不可用
                m_vvCacheVertices[m_nFrameIndex] = new Vector.<Number>(vertexCount);

                // Interpolate between the previous frame and the current frame.
                var frameIndex:int = Animation.binarySearch1(frames, time);
                var frameTime:Number = frames[frameIndex];
                var percent:Number = 1 - (time - frameTime) / (frames[frameIndex - 1] - frameTime);
                percent = getCurvePercent(frameIndex - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent));

                var prevVertices:Vector.<Number> = frameVertices[frameIndex - 1];
                var nextVertices:Vector.<Number> = frameVertices[frameIndex];

                if (alpha < 1) {
                    for (i = 0; i < vertexCount; i++) {
                        m_vvCacheVertices[m_nFrameIndex][i] = prevVertices[i] + (nextVertices[i] - prevVertices[i]) * percent;
                        vertices[i] += (m_vvCacheVertices[m_nFrameIndex][i] - vertices[i]) * alpha;
                    }
                } else {
                    for (i = 0; i < vertexCount; i++) {
                        m_vvCacheVertices[m_nFrameIndex][i] = prevVertices[i] + (nextVertices[i] - prevVertices[i]) * percent;
                        vertices[i] = m_vvCacheVertices[m_nFrameIndex][i];
                    }
                }
            }
            else
            {
                if (alpha < 1)
                {
                    for (i = 0; i < vertexCount; i++) {
                        vertices[i] += (m_vvCacheVertices[m_nFrameIndex][i] - vertices[i]) * alpha;
                    }
                }
                else
                {
                    for (i = 0; i < vertexCount; i++) {
                        vertices[i] = m_vvCacheVertices[m_nFrameIndex][i];
                    }
                }
            }
        }

    }
}
}
