//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/13.
 */
package kof.game.common.view.component {

import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.game.common.view.CViewBase;

import morn.core.components.Component;

import morn.core.components.Image;

public class CDragMapCompoent extends CUICompoentBase {
    /**
     * usage
     * _dragMapComponent = new CDragMapCompoent(this, _ui.map_img, _ui.content_box, CDragMapCompoent.ALGIN_LEFT_CENTER, false, true);
     * _dragMapComponent.moveto(x, y);
     */

    public static const ALGIN_LEFT_TOP:int = 0; // x -> left, y -> top
    public static const ALGIN_LEFT_CENTER:int = 1; // x -> left, y->center
    public static const ALGIN_CENTER:int = 2; // x,y -> center
    public static const ALGIN_CENTER_TOP:int = 3; // x -> center, y-> top

    private var _align:int;
    private var _autoResizeX:Boolean;
    private var _autoResizeY:Boolean;
    // mapImg : 根据mapImg为拖动标准, moveObject : 拖动对象
    // algin : 对齐方式
    // autoResizeX : 窗口改变时, 自动设置x坐标为初始坐标, (根据algin)
    public function CDragMapCompoent(view:CViewBase, mapImg:Image, moveObject:Component, alignInitial:int = 0, autoResizeX:Boolean = false, autoResizeY:Boolean = false) {
        super(view);
        _align = alignInitial;
        _autoResizeX = autoResizeX;
        _autoResizeY = autoResizeY;
        _bgImg = mapImg;
        _moveObject = moveObject;
        _stage = view.uiCanvas.rootContainer.stage;
        _lastPos = new Point();
        _moveObject.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);

        _autoResize(true);

        _stage.addEventListener(Event.RESIZE, _onResize);
    }


    public override function dispose() : void {

        super.dispose();
        _moveObject.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
        _moveObject.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        _moveObject.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
        if (_stage) {
            _stage.removeEventListener(Event.RESIZE, _onResize);
            _stage = null;
        }
    }
    public override function clear() : void {

        super.clear();
        _moveObject.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);
        _moveObject.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        _moveObject.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);

        if (_stage) {
            _stage.removeEventListener(Event.RESIZE, _onResize);
            _stage = null;
        }
    }

    // x, y为中心点坐标
    public function moveto(x:Number, y:Number) : void {
        if (_needMoveY) {
            _moveObject.y = -(y - _stage.stageHeight/2);
        }
        if (_needMoveX) {
            _moveObject.x = -(x - _stage.stageWidth/2);
        }
        _fixPos();
    }

    private function get _needMoveX() : Boolean {
        return _bgImg.width > _stage.stageWidth;
    }
    private function get _needMoveY() : Boolean {
        return _bgImg.height > _stage.stageHeight;
    }
    private function _onMouseDown(e:MouseEvent) : void {
        if (!_needMoveX && !_needMoveY) {
            return ;
        }
        _lastPos.x = e.stageX;
        _lastPos.y = e.stageY;
        _moveObject.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        _moveObject.addEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
    }
    private function _onMouseMove(e:MouseEvent) : void {
        if (e.buttonDown == false) {
            _onMouseUp(e);
            return ;
        }
        var hasChange:Boolean = false;
        if (_needMoveX) {
            var deltaX:Number = e.stageX - _lastPos.x;
            _lastPos.x = e.stageX;
            _moveObject.x += deltaX;
            hasChange = true;
        }

        if (_needMoveY) {
            var deltaY : Number = e.stageY - _lastPos.y;
            _lastPos.y = e.stageY;
            _moveObject.y += deltaY;
            hasChange = true;
        }
        if (hasChange) {
            _fixPos();
        }

    }
    private function _fixPos() : void {
        if (_needMoveX) {
            _fixLeft();
            _fixRight();
        }

        if (_needMoveY) {
            _fixTop();
            _fixBottom();
        }
    }
    private function _onMouseUp(e:MouseEvent) : void {
        _moveObject.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
        _moveObject.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUp);
        _moveObject.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDown);

    }

    private function _onResize(e:Event) : void {
        _autoResize(false)
    }
    private function _autoResize(force:Boolean) : void {
        _fixRight();
        _fixBottom();

        switch (_align) {
            case ALGIN_LEFT_TOP :
                if (force || _autoResizeX) {
                    _moveObject.x = 0;
                }
                if (force || _autoResizeY) {
                    _moveObject.y = 0;
                }

                break;
            case ALGIN_LEFT_CENTER :
                if (force || _autoResizeX) {
                    _moveObject.x = 0;
                }
                if (force || _autoResizeY) {
                    _moveObject.y = (_stage.stageHeight - _moveObject.height)*0.5;
                }
                break;
            case ALGIN_CENTER :
                if (force || _autoResizeX) {
                    _moveObject.x = (_stage.stageWidth - _moveObject.width)*0.5;
                }
                if (force || _autoResizeY) {
                    _moveObject.y = (_stage.stageHeight - _moveObject.height)*0.5;
                }
                break;
            case ALGIN_CENTER_TOP :
                if (force || _autoResizeX) {
                    _moveObject.x = (_stage.stageWidth - _moveObject.width)*0.5;
                }
                if (force || _autoResizeY) {
                    _moveObject.y = 0;
                }
                break;
        }
    }
    private function _fixLeft() : void {
        if (_moveObject.x > 0) {
            _moveObject.x = 0; // 有问题
        }
    }
    private function _fixRight() : void {
        var stageWidth:int =_stage.stageWidth;
        var maxMoveX:Number = -(_bgImg.width - stageWidth);
        if (_moveObject.x < maxMoveX) {
            _moveObject.x = maxMoveX;
        }
    }
    private function _fixTop() : void {
        if (_moveObject.y > 0) {
            _moveObject.y = 0; // 有问题
        }
    }
    private function _fixBottom() : void {
        var stageHeight : int = _stage.stageHeight;
        var maxMoveY : Number = -(_bgImg.height - stageHeight);
        if (_moveObject.y < maxMoveY) {
            _moveObject.y = maxMoveY;
        }
    }


    private var _bgImg:Image;
    private var _moveObject:Component;
    private var _lastPos:Point;
    private var _stage:Stage;

}
}
