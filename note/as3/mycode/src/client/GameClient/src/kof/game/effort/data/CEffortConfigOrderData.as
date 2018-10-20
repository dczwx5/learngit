//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/6/2
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.data {

/**
 * @author Leo.Li
 * @date 2018/6/2
 */
public class CEffortConfigOrderData {

    public var ID:int;
    public var name:String;
    public var type:int;
    public var effortTargetId:Array;
    public var image:String;
    public var lastObtainedTick:Number = -1;
    public var canObtained:Boolean;


    public function CEffortConfigOrderData() {
    }
}
}
