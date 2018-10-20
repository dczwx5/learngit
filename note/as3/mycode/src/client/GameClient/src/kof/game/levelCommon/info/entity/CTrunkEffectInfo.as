//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/8.
 */
package kof.game.levelCommon.info.entity {

import flash.geom.Vector3D;

import kof.game.levelCommon.info.base.CTrunkEntityBaseData;

/**
 * 特效,动画
 */
public class CTrunkEffectInfo extends CTrunkEntityBaseData {
    public static var EFFECT:int = 1;//特效
    public static var ANIMATION:int = 2;//动画

    public var name:String;
    public var layerId:int;
    public var effectType:int;
    public var fileName:String;
    public var scale:Object;
    public var animation:String;
    public var loop:Boolean;

    public function CTrunkEffectInfo(data : Object ) {
        super( data );
        name = data["name"];
        layerId = data["layerId"];
        effectType = data["effectType"];
        fileName = data["fileName"];
        scale = data["scale"];
        animation = data["animation"];
        loop = data["loop"];
    }
}
}
