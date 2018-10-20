//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/9/28.
 */
package kof.ui.components {

import flash.events.Event;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.Tab;

/**tab的selectedIndex属性变化时调度*/
[Event(name="change",type="flash.events.Event")]
public class KOFMenu extends Component {

    protected var _skin:String;

    protected var _back:Image;

    protected var _tab:Tab;

    protected var _labels:String;

    private var _selectedIndex:int;

    protected var _labelBold:Object;

    protected var _labelColors:String;

    protected var _labelSize:Object;

    protected var _labelStroke:String;

    protected var _labelMargin:String;

    public function KOFMenu( skin:String = null ) {
        this.skin = skin;
        addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ,false,0,true);
    }

    override protected function createChildren():void {
        addChild(_back = new Image());
        addChild(_tab = new Tab());
        _tab.addEventListener(Event.CHANGE,_onChangeHandler );
        _tab.selectedIndex = -1;

        _back.mouseChildren = false;
    }
    private function _onChangeHandler(evt:Event):void{
        selectedIndex = _tab.selectedIndex;
        sendEvent(Event.CHANGE);
    }
    override protected function initialize():void {
        _back.sizeGrid  = "4,4,4,4";
    }

    /**皮肤*/
    public function get skin():String {
        return _skin;
    }

    public function set skin(value:String):void {
        if (_skin != value) {
            _skin = value;
            _tab.skin = _skin;
            _back.skin = _skin + "$bar";
        }
    }
    /**标签集合*/
    public function get labels():String {
        return _labels;
    }

    public function set labels(value:String):void {
        if (_labels != value) {
            _labels = value;
            callLater(changeValue)
        }
    }

    /**按钮标签粗细*/
    public function get labelBold():Object {
        return _labelBold;
    }

    public function set labelBold(value:Object):void {
        if (_labelBold != value) {
            _labelBold = value;
            callLater(changeTab);
        }
    }

    /**按钮标签颜色(格式:upColor,overColor,downColor,disableColor)*/
    public function get labelColors():String {
        return _labelColors;
    }

    public function set labelColors(value:String):void {
        if (_labelColors != value) {
            _labelColors = value;
            callLater(changeTab);
        }
    }

    /**按钮标签大小*/
    public function get labelSize():Object {
        return _labelSize;
    }

    public function set labelSize(value:Object):void {
        if (_labelSize != value) {
            _labelSize = value;
            callLater(changeTab);
        }
    }

    /**按钮标签描边(格式:color,alpha,blurX,blurY,strength,quality)*/
    public function get labelStroke():String {
        return _labelStroke;
    }

    public function set labelStroke(value:String):void {
        if (_labelStroke != value) {
            _labelStroke = value;
            callLater(changeTab);
        }
    }

    /**按钮标签边距(格式:左边距,上边距,右边距,下边距)*/
    public function get labelMargin():String {
        return _labelMargin;
    }

    public function set labelMargin(value:String):void {
        if (_labelMargin != value) {
            _labelMargin = value;
            callLater(changeTab);
        }
    }

    protected function changeValue():void {
        _tab.direction = Tab.VERTICAL;
        _tab.labels = _labels;
        _back.width = _tab.width + 10;
        _back.height = _tab.height + 10;
        _tab.x = _back.x + 5;
        _tab.y = _back.y + 5;
    }
    protected function changeTab():void {
        _tab.labelBold = _labelBold;
        _tab.labelColors = _labelColors;
        _tab.labelSize = _labelSize;
        _tab.labelStroke = _labelStroke;
        _tab.labelMargin = _labelMargin;
    }
    private function onAddedToStage(e:Event):void {
        if(_tab)
            _tab.selectedIndex = -1;
    }


    public function get selectedIndex() : int {
        return _selectedIndex;
    }

    public function set selectedIndex( value : int ) : void {
        _selectedIndex = value;
    }

    public function get tab() : Tab {
        return _tab;
    }

    public function set tab( value : Tab ) : void {
        _tab = value;
    }
}
}
