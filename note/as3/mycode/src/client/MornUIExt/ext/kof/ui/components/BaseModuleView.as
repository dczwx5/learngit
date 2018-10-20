//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/7/29.
 */
package kof.ui.components {

import flash.errors.IllegalOperationError;
import flash.events.Event;

import morn.core.components.Dialog;
import morn.core.components.Image;

public class BaseModuleView extends Dialog {
    protected var _bg:Image;
    protected var _skin:String;
    protected var _addStyle:int;

    public function BaseModuleView() {
        super();
        addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ,false,0,true);
    }
    private function onAddedToStage(e:Event):void {
        removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
        addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ,false,0,true);
        tweenStyle();
    }
    private function onRemovedFromStage(e:Event):void {
        removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
    }
    override protected function createChildren():void {
        addChild( _bg = new Image() );
    }
    /**皮肤*/
    public function get skin():String {
        return _skin;
    }
    public function set skin(value:String):void {
        if ( _skin != value ) {
            _skin = value;
            _bg.url = _skin;
            _contentWidth = _bg.width;
            _contentHeight = _bg.height;
        }
    }
    public function get addStyle():int {
        return _addStyle;
    }
    public function set addStyle(value:int):void {
        if ( _addStyle != value ) {
            _addStyle = value;
        }
    }

    /**显示对话框(非模式窗口)
     * @param closeOther 是否关闭其他对话框*/
    override public function show(closeOther:Boolean = false):void {
//        App.dialog.show(this, closeOther);
//        tweenStyle();
        throw new IllegalOperationError("Not supported.");
    }

    override public function close( type : String = null ) : void {
        sendEvent( Event.CLOSE );
        if (_closeHandler != null) {
            _closeHandler.executeWith([type]);
        }
    }

    /**显示对话框(模式窗口)
     * @param closeOther 是否关闭其他对话框*/
    override public function popup(closeOther:Boolean = false):void {
//        App.dialog.popup(this, closeOther);
//        tweenStyle();
        throw new IllegalOperationError("Not supported.");
    }

    private function tweenStyle():void{
        switch (_addStyle){
            case 0:{
                this.x = 0;
                this.y = (stage.stageHeight - this.height) * 0.5;
//                TweenLite.to(this,.5,{x:(stage.stageWidth - this.width) * 0.5,y:(stage.stageHeight - this.height) * 0.5});
                break;
            }
            case 1:{
                this.x = stage.stageHeight;
                this.y = (stage.stageHeight - this.height) * 0.5;
//                TweenLite.to(this,.5,{x:(stage.stageWidth - this.width) * 0.5,y:(stage.stageHeight - this.height) * 0.5});
                break;
            }
        }
    }
}
}
