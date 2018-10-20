//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

public class CHitStateInfo {
    public function CHitStateInfo() : void {
        hitCount = 0;
    }

    public function reset() : void
    {
        hitCount = 0 ;
        elapsTime = 0.0;
        beingHitted = false;
    }

    public function boNotReachMaxHit( maxCount : int ) : Boolean
    {
        return hitCount < maxCount;
    }


    public var hitCount : int = 0;
    public var elapsTime : Number = 0.0;
    public var beingHitted : Boolean;
}
}
