/**
 * Morn UI Version 3.0 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package kof.ui.components {
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import morn.core.components.Box;
import morn.core.components.HScrollBar;
import morn.core.components.ScrollBar;
import morn.core.components.VScrollBar;
import morn.editor.core.IContent;

//noinspection JSUnresolvedVariable
/**面板*/
public class KOFPanel extends Box implements IContent {
    protected var _content:Box;
    protected var _vScrollBar:VScrollBar;
    protected var _hScrollBar:HScrollBar;

    public function KOFPanel() {
        width = height = 100;
    }

    /**垂直滚动条*/
    public function get vScrollBar():VScrollBar {
        return _vScrollBar;
    }

    public function set vScrollBar(value:VScrollBar):void {
        if (_vScrollBar != value) {
            _vScrollBar = value;
            if (value) {
                super.addChild(_vScrollBar);
                _vScrollBar.target = this;
                _vScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
                callLater(changeScroll);
            }
        }
    }


    /**垂直滚动条*/
    public function get hScrollBar():HScrollBar {
        return _hScrollBar;
    }

    public function set hScrollBar(value:HScrollBar):void {
        if (_hScrollBar != value) {
            _hScrollBar = value;
            if (value) {
                super.addChild(_hScrollBar);
                _hScrollBar.target = this;
                _hScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
                _hScrollBar.mouseWheelEnable = false;
                callLater(changeScroll);
            }
        }
    }

    override protected function createChildren():void {
        super.addChild(_content = new Box());
    }

    protected function isScrollBarAdded( child : DisplayObject ) : Boolean {
        if ( child.name == "vScrollBar" ) {
            vScrollBar = child as VScrollBar;
            if ( _vScrollBar )
                return child;
            return false;
        }
        if ( child.name == "hScrollBar" ) {
            hScrollBar = child as HScrollBar;
            if ( _hScrollBar )
                return child;
            return false;
        }
        return false;
    }

    override public function addChild(child:DisplayObject):DisplayObject {
        if ( isScrollBarAdded( child ))
            return child;

        child.addEventListener(Event.RESIZE, onResize);
        callLater(changeScroll);
        return _content.addChild(child);
    }

    private function onResize(e:Event):void {
        callLater(changeScroll);
    }

    override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
        if ( isScrollBarAdded( child ))
            return child;

        child.addEventListener(Event.RESIZE, onResize);
        callLater(changeScroll);
        return _content.addChildAt(child, index);
    }

    override public function removeChild(child:DisplayObject):DisplayObject {
        child.removeEventListener(Event.RESIZE, onResize);
        callLater(changeScroll);
        return _content.removeChild(child);
    }

    override public function removeChildAt(index:int):DisplayObject {
        getChildAt(index).removeEventListener(Event.RESIZE, onResize);
        callLater(changeScroll);
        return _content.removeChildAt(index);
    }

    override public function removeAllChild(except:DisplayObject = null):void {
        for (var i:int = _content.numChildren - 1; i > -1; i--) {
            if (except != _content.getChildAt(i)) {
                _content.removeChildAt(i);
            }
        }
        callLater(changeScroll);
    }

    override public function getChildAt(index:int):DisplayObject {
        return _content.getChildAt(index);
    }

    override public function getChildByName(name:String):DisplayObject {
        return _content.getChildByName(name);
    }

    override public function getChildIndex(child:DisplayObject):int {
        return _content.getChildIndex(child);
    }

    override public function get numChildren():int {
        return _content.numChildren;
    }

    private function changeScroll():void {
        var contentW:Number = contentWidth;
        var contentH:Number = contentHeight;
        var vShow:Boolean = _vScrollBar && contentH > _height;
        var hShow:Boolean = _hScrollBar && contentW > _width;
        var showWidth:Number = vShow ? _width - _vScrollBar.width : _width;
        var showHeight:Number = hShow ? _height - _hScrollBar.height : _height;
        setContentSize(showWidth, showHeight);
        if (_vScrollBar) {
//            _vScrollBar.x = _vScrollBar.width;
//            _vScrollBar.y = 0;
//            _vScrollBar.height = _height - (hShow ? _hScrollBar.height : 0);
            _vScrollBar.scrollSize = Math.max(_height * 0.033, 1);
            _vScrollBar.thumbPercent = showHeight / contentH;
            _vScrollBar.setScroll(0, contentH - showHeight, _vScrollBar.value);
            if( _vScrollBar.name != 'vScrollBar')
                _vScrollBar.height = _height - (hShow ? _hScrollBar.height : 0);
        }

        if (_hScrollBar) {
//            _hScrollBar.x = 0;
//            _hScrollBar.y = _height - _hScrollBar.height;
//            _hScrollBar.width = _width - (vShow ? _vScrollBar.width : 0);
            _hScrollBar.scrollSize = Math.max(_width * 0.033, 1);
            _hScrollBar.thumbPercent = showWidth / contentW;
            _hScrollBar.setScroll(0, contentW - showWidth, _hScrollBar.value);
            if( _hScrollBar.name != 'hScrollBar')
                _hScrollBar.width = _width - (vShow ? _vScrollBar.width : 0);
        }
    }

    private function get contentWidth():Number {
        var max:Number = 0;
        for (var i:int = _content.numChildren - 1; i > -1; i--) {
            var comp:DisplayObject = _content.getChildAt(i);
            max = Math.max(comp.x + comp.width * comp.scaleX, max);
        }
        return max;
    }

    private function get contentHeight():Number {
        var max:Number = 0;
        for (var i:int = _content.numChildren - 1; i > -1; i--) {
            var comp:DisplayObject = _content.getChildAt(i);
            max = Math.max(comp.y + comp.height * comp.scaleY, max);
        }
        return max;
    }

    private function setContentSize(width:Number, height:Number):void {
        var g:Graphics = graphics;
        g.clear();
        g.beginFill(0xffff00, 0);
        g.drawRect(0, 0, width, height);
        g.endFill();
        _content.width = width;
        _content.height = height;
        _content.scrollRect = new Rectangle(0, 0, width, height);
    }

    override public function set width(value:Number):void {
        super.width = value;
        callLater(changeScroll);
    }

    override public function set height(value:Number):void {
        super.height = value;
        callLater(changeScroll);
    }

    /**垂直滚动条皮肤*/
    public function get vScrollBarSkin():String {
        return _vScrollBar.skin;
    }

    public function set vScrollBarSkin(value:String):void {
        if (_vScrollBar == null) {
            super.addChild(_vScrollBar = new VScrollBar());
            _vScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
            _vScrollBar.target = this;
            callLater(changeScroll);
        }
        _vScrollBar.skin = value;
    }

    /**水平滚动条皮肤*/
    public function get hScrollBarSkin():String {
        return _hScrollBar.skin;
    }

    public function set hScrollBarSkin(value:String):void {
        if (_hScrollBar == null) {
            super.addChild(_hScrollBar = new HScrollBar());
            _hScrollBar.addEventListener(Event.CHANGE, onScrollBarChange);
            _hScrollBar.mouseWheelEnable = false;
            _hScrollBar.target = this;
            callLater(changeScroll);
        }
        _hScrollBar.skin = value;
    }

    /**内容容器*/
    public function get content():Sprite {
        return _content;
    }

    protected function onScrollBarChange(e:Event):void {
        var rect:Rectangle = _content.scrollRect;
        if (rect) {
            var scroll:ScrollBar = e.currentTarget as ScrollBar;
            var start:int = Math.round(scroll.value);
            scroll.direction == ScrollBar.VERTICAL ? rect.y = start : rect.x = start;
            _content.scrollRect = rect;
        }
    }

    override public function commitMeasure():void {
        exeCallLater(changeScroll);
    }

    /**滚动到某个位置*/
    public function scrollTo(x:Number = 0, y:Number = 0):void {
        commitMeasure();
        if (vScrollBar) {
            vScrollBar.value = y;
        }
        if (hScrollBar) {
            hScrollBar.value = x;
        }
    }

    public function refresh():void {
        changeScroll();
    }
}
}