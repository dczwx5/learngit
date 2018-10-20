//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/29.
 */
package kof.game.mask {

import flash.display.Shape;
import flash.events.Event;
import kof.framework.CViewHandler;
import kof.ui.CUISystem;

// 持续不关的mask
public class CHoldingMaskViewHandler extends CViewHandler {

    private var _shape:Shape;
    public function CHoldingMaskViewHandler() {
        super();
        _shape = new Shape();
    }

    public override function dispose() : void {
        super.dispose();
        hide();
        system.stage.flashStage.removeEventListener(Event.RESIZE, _onResizeHandler);
    }

    public function show():void {
        _renderMask();
        (uiCanvas as CUISystem).loadingLayer.addChild(_shape);
        system.stage.flashStage.addEventListener(Event.RESIZE, _onResizeHandler);

    }

    private function _renderMask() : void {
        if (_shape) {
            _shape.graphics.clear();
            _shape.graphics.beginFill(0);
            _shape.graphics.drawRect(0, 0, system.stage.flashStage.stageWidth, system.stage.flashStage.stageHeight);
            _shape.graphics.endFill();
        }
    }

    private function _onResizeHandler(evt:Event):void {
        if (_shape && _shape.parent) {
            _renderMask();
        }
    }

    public function hide():void {
        if (_shape) {
            _shape.graphics.clear();
            if (_shape.parent) {
                _shape.parent.removeChild(_shape);
            }
        }
        system.stage.flashStage.removeEventListener(Event.RESIZE, _onResizeHandler);
    }
}
}
