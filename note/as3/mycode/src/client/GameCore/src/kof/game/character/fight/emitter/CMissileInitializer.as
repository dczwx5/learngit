//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/26.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.character.CCharacterInitializer;

public class CMissileInitializer extends CCharacterInitializer{
    public function CMissileInitializer() {
    }

    override protected function onEnter() : void{
        super.onEnter();
        this.moveToAvailablePosition = false;
    }
}
}
