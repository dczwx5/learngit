//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------

package QFLib.Framework
{
    import QFLib.Graphics.Character.CAnimationState;

    public class CAnimationState extends QFLib.Graphics.Character.CAnimationState
    {
        public function CAnimationState( sStateName : String, sAnimationName : String, bLoop : Boolean, bForceReplay : Boolean = false,
                                           bExtractAnimationOffset : Boolean = true,
                                           bApplyAnimationOffsetToAnimationSpeed : Boolean = false, bApplyAnimationOffsetToPosition : Boolean = false )
        {
            super( sStateName, sAnimationName, bLoop, bForceReplay, bExtractAnimationOffset );
            m_bApplyAnimationOffsetToAnimationSpeed = bApplyAnimationOffsetToAnimationSpeed;
            m_bApplyAnimationOffsetToPosition = bApplyAnimationOffsetToPosition;
        }

        public override function dispose() : void
        {
            super.dispose();
        }

        public function get applyAnimationOffsetToAnimationSpeed() : Boolean
        {
            return m_bApplyAnimationOffsetToAnimationSpeed;
        }
        public function get applyAnimationOffsetToPosition() : Boolean
        {
            return m_bApplyAnimationOffsetToPosition;
        }
        public function set applyAnimationOffsetToPosition( value : Boolean ) : void
        {
            m_bApplyAnimationOffsetToPosition = value;
        }

        //
        private var m_bApplyAnimationOffsetToAnimationSpeed : Boolean;
        private var m_bApplyAnimationOffsetToPosition : Boolean;

   }

}

