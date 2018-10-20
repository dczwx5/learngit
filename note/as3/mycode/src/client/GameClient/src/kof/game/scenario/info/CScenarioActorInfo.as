//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/8.
 */
package kof.game.scenario.info {
public class CScenarioActorInfo {
    public function CScenarioActorInfo(data:Object) {
        _actorID = data["actorID"];
        _actorType = data["actorType"];
        _target = data["target"];
        _campID = data["campID"];
        _x = data["x"];
        _y = data["y"];
        _z = data["z"];
    }

    final public function get actorID() : int {
        return _actorID;
    }
    final public function get actorType() : int {
        return _actorType;
    }
    final public function get target() : String {
        return _target;
    }
    final public function get x() : Number {
        return _x;
    }
    final public function get y() : Number {
        return _y;
    }
    final public function get z() : Number {
        return _z;
    }
    final public function set x( value:Number ) : void {
        _x = value;
    }
    final public function set y( value:Number ) : void {
        _y = value;
    }
    final public function set z( value:Number) : void {
        _z = value;
    }

    public function get campID() : int {
        return _campID;
    }

    public function set campID( value : int ) : void {
        _campID = value;
    }

    private var _actorID:int;
    private var _actorType:int;
    private var _campID:int;
    private var _target:String; // 演员的name, id， 等
    private var _x:Number;
    private var _y:Number;
    private var _z:Number;

}
}
