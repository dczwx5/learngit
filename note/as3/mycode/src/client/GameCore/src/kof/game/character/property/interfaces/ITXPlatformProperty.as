//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/16.
//----------------------------------------------------------------------
package kof.game.character.property.interfaces {

public interface ITXPlatformProperty {
    function get pf() : String;

    function get isYellowVip() : int;

    function get yellowVipLevel() : int;

    function get  isYellowHighVip() : int;

    function get  isYellowYearVip() : int;

    function get isBlueVip() : int;

    function get isSuperBlueVip() : int;

    function get blueVipLevel() : int;

    function get isBlueYearVip() : int;

}
}
