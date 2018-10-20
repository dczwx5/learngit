//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

/**
 * 角色形象配置
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ICharacterProfile {

    /**
     * 显示名字
     */
    function get nameDisplayed() : Boolean;

    function set nameDisplayed( value : Boolean ) : void;

    /**
     * 显示角色
     */
    function get playerDisplayed() : Boolean;

    function set playerDisplayed( value : Boolean ) : void;

    function get isNeedChange() : Boolean;

    function set isNeedChange( value : Boolean ) : void;

    function get playerTitleDisplayed() : Boolean;
    function set playerTitleDisplayed(value : Boolean) : void;

}
}
