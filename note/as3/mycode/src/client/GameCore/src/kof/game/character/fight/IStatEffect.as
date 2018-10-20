//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight {

import QFLib.Interface.IUpdatable;

/**
 * 状态效果
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IStatEffect extends IUpdatable {

    /** Runtime ID */
    function get id() : Number;

    /** 效果ID */
    function get statEffectId() : int;

    /** 效果名称 */
    function get name() : String;

    /** 效果类型：1，即时，2，持续 */
    function get statEffectType() : int;
   
    /** 检测当前是否为有效的效果, 内部条件 */
    function get isValid() : Boolean;

    /** Retrieves the parent container ref. */
    function get parent() : IStatEffectContainer;

}
}
