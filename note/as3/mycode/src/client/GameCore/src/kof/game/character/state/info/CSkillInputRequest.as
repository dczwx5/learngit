//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/12/4.
//----------------------------------------------------------------------
package kof.game.character.state.info {

public class CSkillInputRequest {
    public var skillIndex : uint;
    public var args : Array;
    public var requestTime : Number;

    public function CSkillInputRequest( nSkillIdx : uint, fRequestTime : Number ,args : Array = null) {
        this.skillIndex = nSkillIdx;
        this.requestTime = fRequestTime;
        this.args = args;
    }
}
}
