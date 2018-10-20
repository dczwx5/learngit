//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/4.
//----------------------------------------------------------------------
package kof.game.character.fight.sync {

import flash.utils.ByteArray;

/**
 * fighting property
 */
public class CSyncHitTargetEntity {
    public var ID : Number;
    public var type : int;
    public var posX : Number;
    public var posY : Number;
    public var queueID : Number;
    public var dynamicStates :Object;
    public function CSyncHitTargetEntity() {
    }

    public function createTargetEntity( data : Object ) : void
    {
        this.ID = data.ID;
        this.type = data.type;
        this.posX = data.posX;
        this.posY = data.posY;
        this.queueID = data.queueID;
        this.dynamicStates = data.dynamicStates;
    }

    public function toObj() : Object
    {
        var ret : Object = {};
        var ba : ByteArray = new ByteArray();
        ret.ID = ID;
        ret.type = type;
        ret.posX = posX;
        ret.posY = posY;
        ret.queueID = queueID;
        ret.dynamicStates = dynamicStates;
        ba.writeObject( ret );
        ba.position = 0;
        return ba.readObject();

    }

}
}
