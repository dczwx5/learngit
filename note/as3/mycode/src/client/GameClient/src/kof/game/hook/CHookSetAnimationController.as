//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/20.
 * Time: 17:47
 */
package kof.game.hook {

    import QFLib.Framework.CAnimationState;
    import QFLib.Framework.CCharacterAnimationController;

    import kof.game.character.animation.CAnimationStateConstants;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/20
     */
    public class CHookSetAnimationController extends CCharacterAnimationController {
        public function CHookSetAnimationController( theDefaultState : CAnimationState, fnOnStateChanged : Function = null ) {
            super( theDefaultState, fnOnStateChanged );
        }

        override protected virtual function initStates() : void{
            this.addState( new CAnimationState( CAnimationStateConstants.SKILL, "Skill_1", true ) );
            this.addState( new CAnimationState( CAnimationStateConstants.SKILL_2, "Skill_3", false, true, true ) );
        }

        override protected virtual function initStateRelationships() : void {

        }
    }
}
