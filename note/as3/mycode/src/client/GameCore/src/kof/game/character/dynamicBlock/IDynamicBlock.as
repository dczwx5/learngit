//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/4/18.
 */
package kof.game.character.dynamicBlock {

public interface IDynamicBlock {

    function stateChanged( animationName:String = "Idle_2", hurtState : String = "Hurt_1" ):void;

}
}
