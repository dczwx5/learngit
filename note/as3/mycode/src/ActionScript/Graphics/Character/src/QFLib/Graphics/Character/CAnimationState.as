//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------

package QFLib.Graphics.Character
{
    public class CAnimationState
    {
        public function CAnimationState( sStateName : String, sAnimationName : String, bLoop : Boolean, bForceReplay : Boolean = false,
                                         bExtractAnimationOffset : Boolean = true )
        {
            m_sStateName = sStateName;
            m_bLoop = bLoop;
            m_bForceReplay = bForceReplay;
            m_bExtractAnimationOffset = bExtractAnimationOffset;

            m_vAnimationInfos[ 0 ] = new _CAnimationInfo( sAnimationName );
        }

        public function dispose() : void
        {
            m_vAnimationInfos.length = 0;
        }

        public function get stateName() : String
        {
            return m_sStateName;
        }

        public function get stateIndex() : int
        {
            return m_iStateIndex;
        }

        public function get animationLoop() : Boolean
        {
            return m_bLoop;
        }
        public function set animationLoop( bLoop : Boolean ) : void
        {
            m_bLoop = bLoop;
        }
        public function get animationForceReplay() : Boolean
        {
            return m_bForceReplay;
        }
        public function set animationForceReplay( bForce : Boolean ) : void
        {
            m_bForceReplay = bForce;
        }
        public function get randomStart() : Boolean
        {
            return m_bRandomStart;
        }
        public function set randomStart( bRandomStart : Boolean ) : void
        {
            m_bRandomStart = bRandomStart;
        }
        public function get animationExtractOffset() : Boolean
        {
            return m_bExtractAnimationOffset;
        }
        public function set animationExtractOffset( bExtract : Boolean ) : void
        {
            m_bExtractAnimationOffset = bExtract;
        }

        public function get animationName() : String
        {
            return m_vAnimationInfos[ 0 ].m_sAnimationName;
        }
        public function set animationName( sName : String ) : void
        {
            m_vAnimationInfos[ 0 ].m_sAnimationName = sName;
        }

        public function getAnimationName( iIdx : int ) : String
        {
            if( iIdx >= m_vAnimationInfos.length ) iIdx = m_vAnimationInfos.length - 1;
            return m_vAnimationInfos[ iIdx ].m_sAnimationName;
        }
        public function setAnimationName( iIdx : int, sName : String ) : void
        {
            if( iIdx >= m_vAnimationInfos.length ) iIdx = m_vAnimationInfos.length - 1;
            m_vAnimationInfos[ iIdx ].m_sAnimationName = sName;
        }

        public function get toString() : String
        {
            return m_sStateName + "(" + m_vAnimationInfos[ 0 ] + ")";
        }

        [Inline]
        final internal function _setStateIndex( idx : int ) : void
        {
            m_iStateIndex = idx;
        }

        //
        //
        private var m_sStateName : String;
        private var m_bLoop : Boolean;
        private var m_bForceReplay : Boolean;
        private var m_bRandomStart : Boolean;
        private var m_bExtractAnimationOffset : Boolean;

        private var m_vAnimationInfos : Vector.<_CAnimationInfo> = new Vector.<_CAnimationInfo>( 1 );

        private var m_iStateIndex : int = -1;
    }

}


class _CAnimationInfo
{
    public function _CAnimationInfo( sAnimationName : String )
    {
        m_sAnimationName = sAnimationName;
        if( m_sAnimationName == null ) m_sAnimationName = "";
    }

    public var m_sAnimationName : String;
}