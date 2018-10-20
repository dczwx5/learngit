//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/13.
 */
package kof.ui.components {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextFormat;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import morn.core.components.Button;
import morn.core.components.ComboBox;
import morn.core.components.Image;
import morn.core.components.List;
import morn.core.components.Styles;
import morn.core.components.VScrollBar;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**selectedIndex属性变化时调度*/
[Event(name="change",type="flash.events.Event")]
public class KOFComboBox extends ComboBox {

    protected var _back:Image;

    private var _resetID : uint ;

    public function KOFComboBox( skin : String = null, labels : String = null ) {
        super( skin, labels );
    }
    override protected function createChildren():void {
        addChild(_button = new Button());
        _list = new List();
        _list.mouseHandler = new Handler(onlistItemMouse);
        _scrollBar = new VScrollBar();
        _list.addChildAt(_back = new Image(),0);
        _list.addChild(_scrollBar);
    }
    override protected function initialize():void {
        super.initialize();
        _back.sizeGrid  = "4,4,4,4";
        App.stage.addEventListener(Event.RESIZE, onResize);
    }
    private function onResize( evt : Event ):void{
        callLater( changeListPosition );
        clearInterval( _resetID );//todo 暂时
        _resetID = setInterval( resetAfterResize , 500 );
    }
    private function resetAfterResize():void{
        clearInterval( _resetID );
        callLater( changeListPosition )
    }

    private function changeListPosition():void{
        if (_isOpen) {
            var p : Point = localToGlobal( new Point() );
            var py : Number = p.y + _button.height;
            py = py + _listHeight <= App.stage.stageHeight ? py : p.y - _listHeight;
            _list.setPosition( p.x, py );
        }
    }
    override public function set skin(value:String):void {
        if (_button.skin != value) {
            _button.skin = value;
            _back.skin = value + "$bg";
            _contentWidth = _button.width;
            _contentHeight = _button.height;
            callLater(changeList);
        }
    }
    override protected function changeItem():void {
        //赋值之前需要先初始化列表
        exeCallLater(changeList);
        //显示边框
        _listHeight = _labels.length > 0 ? Math.min(_visibleNum, _labels.length) * _itemHeight : _itemHeight;
        _scrollBar.height = _listHeight ;
        //填充背景
        _back.width = width;
        _back.height = _listHeight + _visibleNum + 3;
        //填充数据
        var a:Array = [];
        for (var i:int = 0, n:int = _labels.length; i < n; i++) {
            a.push({label: _labels[i]});
        }
        _list.array = a;
    }
    override protected function changeList():void {
        var labelWidth:Number = width - 10;
        var labelColor:Number = _itemColors[2];
        _itemHeight = ObjectUtils.getTextField(new TextFormat(Styles.fontName, _itemSize)).height - 2 ;
        _list.itemRender = new XML("<Box><Label name='label' width='" + labelWidth + "' size='" + _itemSize + "' height='" + _itemHeight + "' color='" + labelColor + "' x='3' y='1' /></Box>");
        _list.repeatY = _visibleNum;
        _scrollBar.x = width - _scrollBar.width - 5;
        _scrollBar.y = 3;
        _list.refresh();
    }

}
}
