//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/8/17.
 * //todo 跟mornUI结合
 */
package kof.game.mask {

import com.greensock.TimelineLite;
import com.greensock.TweenLite;

import flash.display.Shape;
import flash.events.Event;

import kof.framework.CAppStage;
import kof.framework.CViewHandler;

public class CMaskViewHandler extends CViewHandler {

    private var _shape:Shape;
    private var _showTime:Number;
    private var _color:uint;
    private var _callBackFun:Function;
    private var _onStartFunc:Function;
    private var _onProcessFunc:Function;
    private static const MAX_ALPHA:Number = 1;
    private var _timeline:TimelineLite;

    public function CMaskViewHandler() {
        super();
        _shape = new Shape();
    }
    public function show(callBackFun:Function , onStartFun:Function, onProcessFun:Function, showTime:Number, color:uint ):void {
        _callBackFun = callBackFun;
        _onStartFunc = onStartFun;
        _onProcessFunc = onProcessFun;
       _showTime = showTime;
       _color = color;
        create();
        if(_timeline){
            _timeline.stop();
            _timeline = null;
    }
        _timeline = new TimelineLite();
        _timeline.stop();
        _shape.alpha = 0;
        _timeline.append(new TweenLite(_shape,_showTime *.5,{alpha :MAX_ALPHA,onStart:_onStart,onComplete:_onProcess}));//onStart
        _timeline.append(new TweenLite(_shape,_showTime *.5,{alpha:0,onComplete:_onComplete}));
        _timeline.play();

        system.stage.flashStage.addChild(_shape);
    }
    private function create():void{
        clear();
        if(_shape){
            _shape.graphics.beginFill(_color);
            _shape.graphics.drawRect(0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight);
            _shape.graphics.endFill();
        }
    }
    private function clear():void{
        if(_shape)
           _shape.graphics.clear();
    }
    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
//        _appStage = appStage;
        system.stage.flashStage.addEventListener(Event.RESIZE,_onResizeHandler);
    }
    override protected function exitStage( appStage : CAppStage ) : void {
        super.exitStage( appStage );
        system.stage.flashStage.removeEventListener(Event.RESIZE,_onResizeHandler);
    }
    private function _onComplete(...params):void
    {
        hide();
        if(_callBackFun){
            _callBackFun.apply();
        }
    }
    private function _onStart():void
    {
        if(_onStartFunc){
            _onStartFunc.apply();
        }
    }

    private function _onProcess():void
    {
        if(_onProcessFunc){
            _onProcessFunc.apply();
        }
    }

    private function _onResizeHandler(evt:Event):void{
        // create();
        }
    public function hide(removed:Boolean = true):void {
        if (_timeline)
            _timeline.stop();
        _timeline = null;
        clear();
        }
    }
}
