//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.property.interfaces {


/**
 * @author eddy
 * @date 2016/6/8
 */
public interface ICharacterProperty extends IMapObjectProperty, IGlobalProperty,IFightProperty {

    //===-----------------------------------------------------------------===//
    // Feature properties
    //===-----------------------------------------------------------------===//

    /** 攻击值恢复CD */
    function get attackPowerRecoverCD() : int;

    /**攻击值回复加速度*/
    function get attackPowerRecoverAcceleration() : int;

    /**攻击值回复停止时间*/
    function get attackPowerRecoverStopTime() : int ;

    /** 防御值恢复速度 */
    function get defensePowerRecoverSpeed() : int;

    /**防御值回复加速度*/
    function get defensePowerRecoverAcceleration() : int;

    /**防御值回复停止时间*/
    function get defensePowerRecoverStopTime() : int;

    /** 翻滚防御值消耗 */
    function get rollCost() : int;

    /** 强制翻滚防御值消耗 */
    function get driveRollCost() : int;

    /** 受身防御值消耗 */
    function get quickStandCost() : int;

    /**翻滚冷却*/
    function get rollCD() : int;

    /**受身冷却*/
    function get quickStandCD() : int;

    /**百分比装备攻击*/
    function get InitPercentATK() : Number;

    /**百分比装备防御*/
    function get InitPercentDEF() : Number;

    /**百分比装备生命*/
    function get InitPercentHP() : Number;

    /**怒气回复间隔*/
    function get rageRestoreComboInterval() : int;

}
}
