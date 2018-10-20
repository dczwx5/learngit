//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/9/20.
 */
package kof.ui.components {

import flash.events.Event;
import flash.events.Event;

import morn.core.components.Box;
import morn.core.components.Clip;

public class KOFNum extends Box {

    private var _timeNum:String;
    private var _num:Number;
    private var _clipAry:Array;
    private var _skin:String;
    private var _clipX:int;
    private var _offsetX:int;

    public function KOFNum() {
        super();
    }
    override protected function createChildren() : void {
        super.createChildren();
        _clipAry = [];
    }

    // 00:00:00
    public function set timeNum(v:String) : void {
        _timeNum = v;
        callLater( _updateNum );
    }
    public function get timeNum() : String {
        return _timeNum;
    }
    public function get num() : Number {
        return _num;
    }
    public function set num( value : Number ) : void {
        _num = value;
        callLater( _updateNum );
    }
    public function get offsetX() : int {
        return _offsetX;
    }
    public function set offsetX( value : int ) : void {
        _offsetX = value;
        callLater( _updateNum );
    }

    public function get skin() : String {
        return _skin;
    }
    public function set skin( value : String ) : void {
        _skin = value;
    }
    public function get clipX() : int {
        return _clipX;
    }
    public function set clipX( value : int ) : void {
        _clipX = value;
        callLater( _updateNum );
    }

    private function _updateNum() : void {
        while( numChildren > 0 ){
            removeChildAt(0);
        }

        var arr:Array;
        if (_timeNum) {
            arr = _timeNum.split("");

        } else {
            arr = String(int(_num)).split("");
        }

        var i:int;
        var len:int = arr.length - _clipAry.length;
        if(len > 0){
            for(i = 0; i < len ; i++){
                _clipAry.push(createClip());
            }
        }
        var clip:Clip;
        for(i = 0; i < arr.length; i++){
            clip = _clipAry[i] as Clip;
            if (arr[i] == ":") {
                clip.index = 10;
            } else {
                clip.index = int(arr[i]);
            }
            clip.x = ( clip.width + _offsetX ) * i;
            addChild(clip);
        }
        this.centerX = centerX;
        dispatchEvent(new Event(Event.CHANGE));
    }
    private function createClip():Clip{
        var clip:Clip = new Clip();
        clip.skin = skin;
        clip.clipX = clipX;
        return clip;
    }
}
}
