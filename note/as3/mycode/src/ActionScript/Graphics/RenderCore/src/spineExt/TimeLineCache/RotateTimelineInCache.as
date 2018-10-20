//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/9/14.
 */
package spineExt.TimeLineCache {
import spine.Bone;
import spine.Event;
import spine.Skeleton;
import spine.animation.Animation;
import spine.animation.RotateTimeline;

public class RotateTimelineInCache extends RotateTimeline {
    public function RotateTimelineInCache( frameCount : int ) {
        super( frameCount );
    }

    static private const PREV_FRAME_TIME : int = -2;
    static private const FRAME_VALUE : int = 1;

    private var m_vAmount : Vector.<Number>;
    private var m_fAmount : Number;

    private var m_nFrameIndex : int;
    public function initial() : void {
        if ( m_vAmount == null ) {
            var frameLength : int = (frames[ frames.length - 2 ] + 0.00001) / TimelineCache.FrameGap + 1;
            m_vAmount = new Vector.<Number>( frameLength, true);
            for ( var i : int = 0; i < frameLength; ++i ) {
                m_vAmount[ i ] = -1000000;
            }
        }
    }

    [Inline]
    final override public function apply( skeleton : Skeleton, lastTime : Number, time : Number, firedEvents : Vector.<Event>, alpha : Number, isPassMiddleMixTime : Boolean = false) : void {
        if ( !TimelineCache.FrameCacheEnabled ) {
            super.apply( skeleton, lastTime, time, firedEvents, alpha, isPassMiddleMixTime );
            return;
        }
        if ( time < frames[ 0 ] )
            return; // Time is before first frame.
        initial();

        var bone : Bone = skeleton.bones[ boneIndex ];

        if ( time >= frames[ int( frames.length - 2 ) ] ) // Time is after last frame.
        {
            m_nFrameIndex = m_vAmount.length - 1;
            if ( m_vAmount[m_nFrameIndex] < -9999 ) {
                m_fAmount = bone.data.rotation + frames[ int( frames.length - 1 ) ];
                m_vAmount[m_nFrameIndex] = m_fAmount;
                m_fAmount -= bone.rotation;
                while ( m_fAmount > 180 )
                    m_fAmount -= 360;
                while ( m_fAmount < -180 )
                    m_fAmount += 360;
                bone.rotation += m_fAmount * alpha;
            }
            else {
                m_fAmount = m_vAmount[m_nFrameIndex];
                m_fAmount -= bone.rotation;
                while ( m_fAmount > 180 )
                    m_fAmount -= 360;
                while ( m_fAmount < -180 )
                    m_fAmount += 360;
                bone.rotation += m_fAmount * alpha;
            }
        }
        else
        {
            m_nFrameIndex = TimelineCache.getFrameIndex( time );
            if ( m_vAmount[m_nFrameIndex] < -9999 ) {
                time = (int)(time/TimelineCache.FrameGap) * TimelineCache.FrameGap + 0.00001; //此处Number.MIN_VALUE不可用
                // Interpolate between the previous frame and the current frame.
                var frameIndex : int = Animation.binarySearch( frames, time, 2 );
                var prevFrameValue : Number = frames[ int( frameIndex - 1 ) ];
                var frameTime : Number = frames[ frameIndex ];
                var percent : Number = 1 - (time - frameTime) / (frames[ int( frameIndex + PREV_FRAME_TIME ) ] - frameTime);
                percent = getCurvePercent( frameIndex / 2 - 1, percent < 0 ? 0 : (percent > 1 ? 1 : percent) );
                m_fAmount = frames[ int( frameIndex + FRAME_VALUE ) ] - prevFrameValue;
                while ( m_fAmount > 180 )
                    m_fAmount -= 360;
                while ( m_fAmount < -180 )
                    m_fAmount += 360;


                m_fAmount = bone.data.rotation + (prevFrameValue + m_fAmount * percent);
                m_vAmount[m_nFrameIndex] = m_fAmount;
                m_fAmount -= bone.rotation;
                while ( m_fAmount > 180 )
                    m_fAmount -= 360;
                while ( m_fAmount < -180 )
                    m_fAmount += 360;
                bone.rotation += m_fAmount * alpha;
                if (TimelineCache.getFrameIndex(time) == 1 && boneIndex == 1)
                {
                    trace("initial timeline data , rotate  : " + skeleton.skinName);
                }
            }
            else {
                m_fAmount = m_vAmount[m_nFrameIndex] - bone.rotation;
                while ( m_fAmount > 180 )
                    m_fAmount -= 360;
                while ( m_fAmount < -180 )
                    m_fAmount += 360;
                bone.rotation += m_fAmount * alpha;
            }

        }
    }
}
}
