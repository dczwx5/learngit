//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property.interfaces {

import QFLib.Interface.IDisposable;

import kof.framework.IDataHolder;
import kof.game.core.IGameComponent;

/**
 * 游戏中基本对象属性，例如ID，显示资源，移动速度，生命值等
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IMapObjectProperty extends IDisposable, IDataHolder, IGameComponent {

    /** 唯一ID */
    function get ID() : Number;

    /** 原型ID（表ID) */
    function get prototypeID() : int;

    /** 名称 */
    function get nickName() : String;

    /** 称谓 */
    function get appellation() : String;

    /** 职业ID */
    function get profession() : int;

    /** 角色资源路径 */
    function get skinName() : String;

    /** 移动速度*/
    function get moveSpeed() : int;

    /** 阵营ID */
    function get campID() : int;

    /** 自动战斗AI包ID */
    function get aiID() : int;

    /**模型缩放值*/
    function get size() : Number;

}
}
