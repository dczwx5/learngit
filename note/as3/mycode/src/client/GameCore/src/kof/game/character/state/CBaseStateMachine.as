//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/12.
//----------------------------------------------------------------------
package kof.game.character.state {

import kof.framework.fsm.CFiniteStateMachine;
import kof.game.core.CSubscribeBehaviour;

public class CBaseStateMachine extends CSubscribeBehaviour {
    public function CBaseStateMachine( name : String = "") {
        super( name );
    }

    public function get  actionFSM() : CFiniteStateMachine {
        return null;
    }

}
}
