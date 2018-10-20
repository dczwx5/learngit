//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/1/12.
//----------------------------------------------------------------------
package kof.game.character.fight.skill.model {

public class CSkillEffectInfo {

    public var EffectType : int;
    public var EffectID : int;
    public var EffectTime : Number;
    public var EffectDes : String;
    public var HitEventSignal : String;
    public var Duration : Number;

    public function loadFromData( data : Object ) : void
    {
        this.EffectID = "EffectID" in data ?  data.EffectID : 0;
        this.EffectType = "EffectType" in data ?  data.EffectType : 0;
        this.EffectTime = "EffectTime" in data ?  data.EffectTime : ("time" in data ? data.time : 0.0);
        this.EffectDes = "description" in data ?  data.description : "";
        this.Duration = "fDuration" in data ? data.fDuration : 0;
    }
}
}
