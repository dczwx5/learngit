//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight {

import QFLib.Interface.IUpdatable;

import kof.game.core.IGameComponent;

/**
 * 战斗效果容器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IStatEffectContainer extends IUpdatable, IGameComponent {

    function addStatEffect( statEffect : IStatEffect ) : void;

    function removeStatEffect( statEffect : IStatEffect ) : void;

    function hasStatEffect( id : Number ) : Boolean;

    function getStatEffect( id : Number ) : IStatEffect;

    function get size() : uint;

    function get iterator() : IIterable;

}
}
