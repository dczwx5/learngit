//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------

package QFLib.Graphics.Character
{
import QFLib.Foundation;
import QFLib.Math.CVector2;

    import spine.animation.TrackEntry;

    public class CAnimationClip
    {
        public function CAnimationClip( theCharacterObject : CCharacterObject )
        {
            m_theCharacterObjectRef = theCharacterObject;
        }

        //
        // callback: function _onAnimationFinished( theCharacterObject : CCharacterObject ) : void
        //
        public function set( sClipName : String, bLoop : Boolean, bExtractAnimationOffset : Boolean, theAnimationInfo : CAnimationClipInfo, theEntry : TrackEntry,
                                fLoopTime : Number, fnAnimationFinished : Function ) : void
        {
            m_sName = sClipName;
            m_bLoop = bLoop;
            m_bExtractAnimationOffset = bExtractAnimationOffset;

            m_fStartTime = theAnimationInfo.m_fStartTime;
            m_fEndTime = theAnimationInfo.m_fEndTime;
            m_fDuration = m_fEndTime - m_fStartTime;

            m_fTime = m_fTotalTime = theEntry.time;
            m_fLastTime = m_fTime;
            m_nCurrentLoopTimes = 0;

            m_theAnimationInfoRef = theAnimationInfo;
            m_theEntryRef = theEntry;

            m_fLoopTime = fLoopTime;
            m_fnAnimationFinished = fnAnimationFinished;
        }

        public function isActive() : Boolean
        {
            return m_theEntryRef ? true : false;
        }
        public function reset( bCallback : Boolean = true ) : void
        {
            if( m_fnAnimationFinished != null )
            {
                var fnCallback : Function = m_fnAnimationFinished;
                m_fnAnimationFinished = null;
                if( bCallback ) fnCallback( m_theCharacterObjectRef );
            }

            m_theEntryRef = null;
        }

        [inline]
        public function update( fDeltaTime : Number ) : void
        {
            m_fTotalTime += fDeltaTime;
            m_fLastTime = m_fTime;
            if( m_theEntryRef == null ) return;

            var bReachEnd : Boolean = false;

            if( m_bLoop )
            {
                if( m_fLoopTime > 0.0 && m_fTotalTime >= m_fLoopTime ) bReachEnd = true;
                if( bReachEnd )
                {
                    m_theEntryRef.time = m_fTime = m_fEndTime; // freeze the time
                }
                else
                {
                    m_fTime = ( m_theEntryRef.time - m_fStartTime ) % m_fDuration + m_fStartTime;
                    if( m_theEntryRef.time > m_fTime )
                    {
                        m_nCurrentLoopTimes++;
                        m_theEntryRef.time = m_fTime;
                    }
                }
            }
            else
            {
                if( m_fTime == m_fEndTime ) bReachEnd = true;
                else
                {
                    m_fTime = m_theEntryRef.time;
                    if( m_fTime > m_fEndTime )
                    {
                        m_nCurrentLoopTimes++;
                        m_fTime = m_fEndTime;
                        m_theEntryRef.time = m_fEndTime;
                    }
                    if( m_fTime == m_fEndTime ) bReachEnd = true;
                }
            }

            if( bReachEnd )
            {
                if( m_fnAnimationFinished != null )
                {
                    var fnCallback : Function = m_fnAnimationFinished;
                    m_fnAnimationFinished = null;
                    fnCallback( m_theCharacterObjectRef );
                }
            }
        }

        //
        //
        public var m_fStartTime : Number;
        public var m_fEndTime : Number;
        public var m_fDuration : Number;

        public var m_fLastTime : Number;
        public var m_fTime : Number;
        public var m_fTotalTime : Number;
        public var m_nCurrentLoopTimes : int;

        public var m_sName : String;
        public var m_bLoop : Boolean;
        public var m_bExtractAnimationOffset : Boolean;

        public var m_fLoopTime : Number;

        public var m_fnAnimationFinished : Function;

        internal var m_theEntryRef : TrackEntry;
        internal var m_theAnimationInfoRef : CAnimationClipInfo;

        internal var m_theCharacterObjectRef : CCharacterObject;

        internal var m_vAnimationOffsetPosLast : CVector2 = new CVector2();
        internal var m_vAnimationOffsetPos : CVector2 = new CVector2();
        internal var m_vAnimationOffset : CVector2 = new CVector2();
        internal var m_vAnimationOffsetPerSec : CVector2 = new CVector2();
    }

}
