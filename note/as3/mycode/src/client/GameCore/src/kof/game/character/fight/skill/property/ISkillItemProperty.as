//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/15.
//----------------------------------------------------------------------
package kof.game.character.fight.skill.property {

public interface ISkillItemProperty {
    function get BaseDamage() : int;
    function get BaseHealing() : int;
    function get DamagePer() : int;
    function get HealingPer() : int;
    function get CD() : Number;
    function get ConsumeAP() : int;
    function get ConsumePGP() : int;
    function get ConsumeGP() : int;
    function get ExCounterAttack() :int;
    function get RageRestoreWhenSpellSkill() : int;
    function get RageRestoreWhenHitTarget() : int;
    function get BuffList() : Array;


}
}
