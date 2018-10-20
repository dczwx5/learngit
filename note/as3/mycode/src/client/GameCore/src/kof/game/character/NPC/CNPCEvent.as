//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/3.
 */
package kof.game.character.NPC {

import flash.events.Event;

public class CNPCEvent extends Event {

    public static const NPC_OPEN : String = "NPC_open";
    public static const NPC_TASKOVER : String = "NPC_taskOver";

    public function CNPCEvent( type : String ) {
        super( type, false, false );
    }
}
}
