//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import kof.game.core.CGameObject;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public interface ICharacterFactory {

    /**
     * 创建角色游戏对象
     */
    function createCharacter(data:Object):CGameObject;

    /**
     * 销毁角色游戏对象
     */
    function disposeCharacter(character:CGameObject):void;

}
}
