//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{
    import QFLib.Graphics.Character.CAnimationController;

    public class CAnimationController extends QFLib.Graphics.Character.CAnimationController
    {
        public function CAnimationController( theDefaultState : CAnimationState, fnOnStateChanged : Function = null )
        {
            super( theDefaultState, fnOnStateChanged );

            this.initStates();
            this.initStateRelationships();
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function get theCurrentState() : CAnimationState
        {
            return CAnimationState( super.currentState );
        }

        //
        // args: a list of animation clip names, mapping to their state names: sStateNamePrefix + animation clip names
        //
        public function addSequentialAnimationStates( sBeginStateName : String, sEndStateName : String, sFinishedStateName : String, bBeginStateForceReplay : Boolean, ...args ) : void
        {
            var sStateName : String = "";
            var sLastStateName : String = "";
            var bAddRelationship : Boolean = false;
            for( var i : int = 0; i < args.length; i++ )
            {
                if( i == 0 )
                {
                    sStateName = sBeginStateName;
                    if( this.findState( sStateName ) == null )
                    {
                        this.addState( new CAnimationState( sStateName, args[i], false, bBeginStateForceReplay ) );
                        bAddRelationship = true;
                    }
                }
                else
                {
                    if( ( i == args.length - 1 ) && sEndStateName != null && sEndStateName.length != 0 ) sStateName = sEndStateName;
                    else sStateName = sBeginStateName + "_" + i;
                    if( this.findState( sStateName ) == null )
                    {
                        this.addState( new CAnimationState( sStateName, args[i], false, true ) );
                    }
                }

                if( i != 0 && bAddRelationship )
                {
                    this.addStateRelationship( sLastStateName, sStateName, null );
                }

                sLastStateName = sStateName;
            }

            if( bAddRelationship ) this.addStateRelationship( sLastStateName, sFinishedStateName, null );
        }

        protected virtual function initStates() : void
        {
        }

        protected virtual function initStateRelationships() : void
        {
        }

        //
        internal function _setCharacter( character : CCharacter ) : void
        {
            m_theCharacterRef = character;
        }

        //
        protected var m_theCharacterRef : CCharacter = null;
    }
}
