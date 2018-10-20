//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property.interfaces {

/**
 * 游戏中全局属性
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public interface IGlobalProperty {

    /** 最大怒气个数 */
    function get maxRageCount() : int;

    /**怒气回复间隔*/
    function get ragePowerRecoverCD() : int;

    /**通用怪怒气回复比率*/
    function get commonRageRestoreRate() : int;

    /**精英怪回复比率*/
    function get eliteRageRestoreRate() : int;

    /** boss 回复怒气比率*/
    function get bossRageRestoreRate() : int;

    /**玩家回复怒气比率*/
    function get playerRageRestoreRate() : int;
}
}


