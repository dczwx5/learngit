//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property.interfaces {

/**
 *
 *
 * @author eddy
 */
public interface IMonsterProperty extends ICharacterProperty {

    /** 怪物品质类型 */
    function get quality() : int;

    function set quality( value : int ) : void;

    /** 怪物类型 */
    function get monsterType() : int;

}
}
