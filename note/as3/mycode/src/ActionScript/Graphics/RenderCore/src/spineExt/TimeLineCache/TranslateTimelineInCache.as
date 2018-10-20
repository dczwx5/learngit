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
import spine.animation.TranslateTimeline;

public class TranslateTimelineInCache extends TranslateTimeline
{
    public function TranslateTimelineInCache(frameCount:int)
    {
        super (frameCount);
    }

    static internal const PREV_FRAME_TIME:int = -3;
    static internal const FRAME_X:int = 1;
    static internal const FRAME_Y:int = 2;

    private var m_vvTranslate : Vector.<Vector.<Number>> = null;
    private var m_vTranslate : Vector.<Number> = new Vector.<Number>(2, true);

    private var m_nFrameIndex : int;
    public  function initial() : void
    {
        if (m_vvTranslate == null)
        {
            m_vvTranslate = new Vector.<Vector.<Number>>((frames[frames.length - 3] + 0.00001) / TimelineCache.FrameGap + 1) ;
        }
    }

    [Inline]
    final  override public function apply (skeleton:Skeleton, lastTime:Number, time:Number, firedEvents:Vector.<Event>, alpha:Number, isPassMiddleMixTime : Boolean = false) : void
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

        if (time >= frames[int(frames.length - 3)])  // Time is after last frame.
        {
            m_nFrameIndex = m_vvTranslate.length - 1;
            if (m_vvTranslate[m_nFrameIndex] == null)
            {
                m_vvTranslate[m_nFrameIndex] = new Vector.<Number>(2, true);
                m_vTranslate[0] = bone.data.x + frames[int(frames.length - 2)];
                m_vTranslate[1] = bone.data.y + frames[int(frames.length - 1)];
                m_vvTranslate[m_nFrameIndex][0] =  m_vTranslate[0];
                m_vvTranslate[m_nFrameIndex][1] =  m_vTranslate[1];

                m_vTranslate[0] -= bone.x;
                m_vTranslate[1] -= bone.y;
                bone.x += m_vTranslate[0] * alpha;
                bone.y += m_vTranslate[1] * alpha;
            }
            else
            {
                m_vTranslate[0] = m_vvTranslate[m_nFrameIndex][0] - bone.x;
                m_vTranslate[1] = m_vvTranslate[m_nFrameIndex][1] - bone.y;

                bone.x += m_vTranslate[0] * alpha;
                bone.y += m_vTranslate[1] * alpha;
            }
        }
        else
        {
            m_nFrameIndex = TimelineCache.getFrameIndex(time);
            if (m_vvTranslate[m_nFrameIndex] == null) {

                time = (int)(time/TimelineCache.FrameGap) * TimelineCache.FrameGap + 0.00001; //此处Number.MIN_VALUE不可用
                // Interpolate between the previous frame and the current frame.
                var frameIndex : int = Animation.binarySearch( frames, time, 3 );
                var prevFrameX : Number = frames[ int( frameIndex - 2 ) ];
                var prevFrameY : Number = frames[ int( frameIndex - 1 ) ];
                var frameTime : Number = frames[ frameIndex ];
                var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
                percent = getCurvePercent( frameIndex / 3 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );

                m_vvTranslate[m_nFrameIndex] = new Vector.<Number>(2, true);
                m_vvTranslate[m_nFrameIndex][0] = bone.data.x + prevFrameX + (frames[ int( frameIndex + FRAME_X ) ] - prevFrameX) * percent;
                m_vvTranslate[m_nFrameIndex][1] = bone.data.y + prevFrameY + (frames[ int( frameIndex + FRAME_Y ) ] - prevFrameY) * percent;


                m_vTranslate[0] = m_vvTranslate[m_nFrameIndex][0] - bone.x;
                m_vTranslate[1] = m_vvTranslate[m_nFrameIndex][1] - bone.y;
                bone.x += m_vTranslate[0] * alpha;
                bone.y += m_vTranslate[1] * alpha;

//                if (TimelineCache.getFrameIndex(time) == 1 && boneIndex == 1)
//                {
//                    trace("initial timeline data , translate  : " + skeleton.skinName + " ,   " + name);
//                }
            }
            else
            {
                m_vTranslate[0] = m_vvTranslate[m_nFrameIndex][0] - bone.x;
                m_vTranslate[1] = m_vvTranslate[m_nFrameIndex][1] - bone.y;
                bone.x +=m_vTranslate[0] * alpha;
                bone.y += m_vTranslate[1] * alpha;
            }
        }
    }
}
}
