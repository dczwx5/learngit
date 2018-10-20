//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------

package QFLib.Graphics.Character
{

import QFLib.Foundation.CMap;
    import QFLib.Foundation.CSet;

    public class CAnimationController
    {
        public function CAnimationController( theDefaultState : CAnimationState, fnOnStateChanged : Function = null )
        {
            // state index is the index of the state in the m_vStates, for saving linear search issue
            theDefaultState._setStateIndex( 0 );

            m_vStates = new Vector.<CAnimationState>( 1 );
            m_vStates[ 0 ] = theDefaultState;
            m_iCurrentStateIdx = 0;
            m_iLastStateIdx = 0;

            m_mapAnimationStates = new CMap();
            m_mapAnimationStates.add( theDefaultState.stateName, theDefaultState );

            m_mapStateRelationships = new CMap();

            m_setOnStateChangedFunctions = new CSet();
            if( fnOnStateChanged != null ) m_setOnStateChangedFunctions.add( fnOnStateChanged );
        }

        public function dispose() : void
        {
            if ( m_vStates )
            {
                m_vStates.splice(0, m_vStates.length);
            }
            m_vStates = null;

            if ( m_mapAnimationStates )
            {
                m_mapAnimationStates.clear();
            }
            m_mapAnimationStates = null;
            m_setOnStateChangedFunctions.clear();
            m_setOnStateChangedFunctions = null;
        }

        public function addState( theState : CAnimationState ) : void
        {
            // state index is the index of the state in the m_vStates,set state index before adding to the state list(vector) for saving linear search issue
            theState._setStateIndex( m_vStates.length );
            m_vStates.push( theState );
            m_mapAnimationStates.add( theState.stateName, theState );
        }

        public function findState( sStateName : String ) : CAnimationState
        {
            return m_mapAnimationStates.find( sStateName ) as CAnimationState;
        }

        public function addStateRelationship( sFromStateName : String, sToStateName : String, fnCondition : Function, fBlendTime : Number = 0.0 ) : Boolean
        {
            var fromState : CAnimationState = this.findState( sFromStateName );
            var toState : CAnimationState = this.findState( sToStateName );

            if( fromState != null && toState != null )
            {
                var stateRelationships : _CStateRelationships = m_mapStateRelationships.find( fromState.stateIndex ) as _CStateRelationships;
                if( stateRelationships == null )
                {
                    stateRelationships = new _CStateRelationships( fromState.stateIndex );
                    m_mapStateRelationships.add( fromState.stateIndex, stateRelationships );
                }

                stateRelationships.add( new _CStateRelationship( fromState.stateIndex, toState.stateIndex, fnCondition, fBlendTime ) );
                if( m_theCharacterObjectRef != null && m_theCharacterObjectRef.isLoaded )
                {
                    m_theCharacterObjectRef.setAnimationClipBlendTime( fromState.animationName, toState.animationName, fBlendTime );
                }
                return true;
            }
            else return false;
        }

        [Inline]
        final public function get currentState() : CAnimationState
        {
            return m_vStates[ m_iCurrentStateIdx ];
        }
        [Inline]
        final public function get currentStateIndex() : int
        {
            return m_iCurrentStateIdx;
        }

        [Inline]
        final public function get lastState() : CAnimationState
        {
            return m_vStates[ m_iLastStateIdx ];
        }
        [Inline]
        final public function get lastStateIndex() : int
        {
            return m_iLastStateIdx;
        }

        [Inline]
        final public function getStateByIndex( iIdx : int ) : CAnimationState
        {
            if( iIdx >= m_vStates.length ) return null;
            return m_vStates[ iIdx ];
        }

        [Inline]
        final public function get numStates() : int
        {
            return m_vStates.length;
        }

        public function removeStateChangedCallback( fnOnStateChanged : Function ) : void
        {
            if( fnOnStateChanged != null )
            {
                m_setOnStateChangedFunctions.remove( fnOnStateChanged );
            }
        }
        public function addStateChangedCallback( fnOnStateChanged : Function ) : void
        {
            if( fnOnStateChanged != null ) m_setOnStateChangedFunctions.add( fnOnStateChanged );
        }

        public function playState( sStateName : String, bForceLoop : Boolean = false, bForceReplay : Boolean = false, iTrackIdx : int = 0,
                                     bForceRandomStart : Boolean = false, fLoopTime : Number = 0.0 ) : CAnimationState
        {
            var theState : CAnimationState = m_mapAnimationStates.find( sStateName ) as CAnimationState;
            if( theState != null )
            {
                // Resets current state index.
                var iToState : int = theState.stateIndex;
                if( iToState >= 0 && ( m_iCurrentStateIdx != iToState || bForceReplay ) )
                {
                    if( m_theCharacterObjectRef._playAnimationWithState( theState, bForceLoop, bForceReplay, iTrackIdx, bForceRandomStart, fLoopTime ) )
                    {
                        m_iLastStateIdx = m_iCurrentStateIdx;
                        m_iCurrentStateIdx = iToState;

                        _onStateChanged( m_vStates[ m_iLastStateIdx ].stateName, m_vStates[ m_iCurrentStateIdx ].stateName );
                    }
                    else return null;
                }
            }

            return theState;
        }

        protected virtual function _onStateChanged( sFromStateName : String, sToStateName : String ) : void
        {
            for each( var callback : Function in m_setOnStateChangedFunctions ) callback( sFromStateName, sToStateName );
        }

        public virtual function update( fDeltaTime : Number ) : void
        {
            var stateRelationships : _CStateRelationships = m_mapStateRelationships.find( m_iCurrentStateIdx ) as _CStateRelationships;
            if( stateRelationships == null ) return;

            for each( var stateRelationship : _CStateRelationship in stateRelationships.m_vStateRelationships )
            {
                var bChange : Boolean = false;
                if( stateRelationship.m_fnCondition == null )
                {
                    if( m_theCharacterObjectRef.currentAnimationClipTimeLeft <= stateRelationship.m_fBlendTime ) bChange = true;
                }
                else if( stateRelationship.m_fnCondition() ) bChange = true;

                if( bChange )
                {
                    m_iLastStateIdx = m_iCurrentStateIdx;
                    m_iCurrentStateIdx = stateRelationship.m_iToStateIdx;

                    if( m_theCharacterObjectRef != null ) m_theCharacterObjectRef._playAnimationWithState( currentState, false, false, 0, false, 0.0 );

                    _onStateChanged( m_vStates[ m_iLastStateIdx ].stateName, m_vStates[ m_iCurrentStateIdx ].stateName );
                }
            }
        }

        //
        //
        internal function _setCharacter( character : CCharacterObject ) : void
        {
            m_theCharacterObjectRef = character;
            if( m_theCharacterObjectRef != null && m_theCharacterObjectRef.isLoaded )
            {
                _onLoadCharacterFinished();
            }
        }

        internal function _setCharacterLoadFinished() : void
        {
            _onLoadCharacterFinished();
        }

        protected virtual function _onLoadCharacterFinished() : void
        {
            if( m_theCharacterObjectRef != null )
            {
                for each( var relationships : _CStateRelationships in m_mapStateRelationships )
                {
                    for each( var relationship : _CStateRelationship in relationships.m_vStateRelationships )
                    {
                        m_theCharacterObjectRef.setAnimationClipBlendTime( m_vStates[ relationship.m_iFromStateIdx ].animationName, m_vStates[ relationship.m_iToStateIdx ].animationName, relationship.m_fBlendTime );
                    }
                }
            }
        }

        //
        //
        private var m_vStates : Vector.<CAnimationState>;
        private var m_setOnStateChangedFunctions : CSet;
        private var m_mapAnimationStates : CMap;
        private var m_mapStateRelationships : CMap;
        private var m_iCurrentStateIdx : int;
        private var m_iLastStateIdx : int;

        protected var m_theCharacterObjectRef : CCharacterObject = null;
    }
}

class _CStateRelationships
{
    public function _CStateRelationships( iFromStateIdx : int )
    {
        m_iFromStateIdx = iFromStateIdx;
        m_vStateRelationships = new Vector.<_CStateRelationship>();
    }

    public function add( stateRelationship : _CStateRelationship ) : void
    {
        m_vStateRelationships.push( stateRelationship );
    }

    public var m_iFromStateIdx : int;
    public var m_vStateRelationships : Vector.<_CStateRelationship>;

}

class _CStateRelationship
{
    public function _CStateRelationship( iFromStateIdx : int, iToStateIdx : int, fnCondition : Function, fBlendTime : Number = 0.0 )
    {
        m_iFromStateIdx = iFromStateIdx;
        m_iToStateIdx = iToStateIdx;
        m_fBlendTime = fBlendTime;
        m_fnCondition = fnCondition;
    }

    public var m_iFromStateIdx : int;
    public var m_iToStateIdx : int;
    public var m_fBlendTime : Number;
    public var m_fnCondition : Function;
}
