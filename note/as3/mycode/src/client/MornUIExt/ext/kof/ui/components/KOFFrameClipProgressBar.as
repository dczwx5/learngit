/**
 * Morn UI Version 3.0 http://www.mornui.com/
 * Feedback yungzhu@gmail.com http://weibo.com/newyung
 */
package  kof.ui.components {

import flash.events.Event;
import flash.geom.Rectangle;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**值改变后触发*/
[Event(name="change",type="flash.events.Event")]

/**进度条*/
public class KOFFrameClipProgressBar extends Component {
    protected var _bg:Image;
    protected var _bar:FrameClip;
    protected var _skin:String;
    protected var _value:Number = 0.5;
    protected var _label:String;
    protected var _barLabel:Label;
    protected var _changeHandler:Handler;

    public function KOFFrameClipProgressBar(skin:String = null) {
        this.skin = skin;
    }

    override protected function createChildren():void {
        addChild(_bg = new Image());
        addChild(_bar = new FrameClip());
        addChild(_barLabel = new Label());
    }

    override protected function initialize():void {
        _barLabel.width = 200;
        _barLabel.height = 18;
        _barLabel.align = "center";
        _barLabel.stroke = "0x004080";
        _barLabel.color = 0xffffff;
    }

    /**皮肤*/
    public function get skin():String {
        return _skin;
    }

    public function set skin(value:String):void {
        if (_skin != value) {
            _skin = value;
            _bg.url = _skin;
            _bar.skin = _skin.slice(_skin.indexOf("_") + 1,_skin.length);
            _bar.autoPlay = true;
            _contentWidth = _bg.width;
            _contentHeight = _bg.height;
            callLater(changeLabelPoint);
            callLater(changeValue);

        }
    }

    protected function changeLabelPoint():void {
        _barLabel.x = (width - _barLabel.width) * 0.5;
        _barLabel.y = (height - _barLabel.height) * 0.5 - 2;
    }

    /**当前值(0-1)*/
    public function get value():Number {
        return _value;
    }

    public function set value(num:Number):void {
        if (_value != num) {
            num = num > 1 ? 1 : num < 0 ? 0 : num;
            _value = num;
            callLater(changeValue);
            sendEvent(Event.CHANGE);
            if (_changeHandler != null) {
                _changeHandler.executeWith([num]);
            }
        }
    }

    protected function changeValue():void {
        _bar.scrollRect = new Rectangle(0,0,width * _value, _bar.height);
    }

    /**标签*/
    public function get label():String {
        return _label;
    }

    public function set label(value:String):void {
        if (_label != value) {
            _label = value;
            _barLabel.text = _label;
        }
    }

    /**进度条*/
    public function get bar():FrameClip {
        return _bar;
    }

    /**标签实体*/
    public function get barLabel():Label {
        return _barLabel;
    }
    override public function set width(value:Number):void {
        super.width = value;
        _bg.width = _width;
        _bar.width = _width;
        _barLabel.width = _width;
        callLater(changeLabelPoint);
        callLater(changeValue);
    }

    override public function set height(value:Number):void {
        super.height = value;
        _bg.height = _height;
        _bar.height = _height;
        _bar.height = _height;
        callLater(changeLabelPoint);
    }

    override public function set dataSource(value:Object):void {
        _dataSource = value;
        if (value is Number || value is String) {
            this.value = Number(value);
        } else {
            super.dataSource = value;
        }
    }


    /**当前帧(为了统一，frame从0开始，原始的movieclip从1开始)*/
    public function get frame():int {
        return _bar.frame;
    }

    public function set frame(value:int):void {
        _bar.frame = value;
    }

    /**当前帧，等同于frame*/
    public function get index():int {
        return _bar.frame;
    }

    public function set index(value:int):void {
        frame = value;
    }

    /**切片帧的总数*/
    public function get totalFrame():int {
        return _bar.totalFrame;
    }

    /**从显示列表删除后是否自动停止播放*/
    public function get autoStopAtRemoved():Boolean {
        return _bar.autoStopAtRemoved;
    }

    public function set autoStopAtRemoved(value:Boolean):void {
        _bar.autoStopAtRemoved = value;
    }

    /**自动播放*/
    public function get autoPlay():Boolean {
        return _bar.autoPlay;
    }

    public function set autoPlay(value:Boolean):void {
        _bar.autoPlay = value;
    }

    /**动画播放间隔(单位毫秒)*/
    public function get interval():int {
        return _bar.interval;
    }

    public function set interval(value:int):void {
        _bar.interval = value;
    }

    /**是否正在播放*/
    public function get isPlaying():Boolean {
        return _bar.isPlaying;
    }

    public function set isPlaying(value:Boolean):void {
        _bar.isPlaying = value;
    }

    /**开始播放*/
    public function play():void {
        _bar.play();
    }

    /**停止播放*/
    public function stop():void {
        _bar.stop();
    }

    /**从指定的位置播放*/
    public function gotoAndPlay(frame:int):void {
        _bar.gotoAndPlay(frame);
    }

    /**跳到指定位置并停止*/
    public function gotoAndStop(frame:int):void {
        _bar.gotoAndStop(frame)
    }

    /**从某帧播放到某帧，播放结束发送事件(为了统一，frame从0开始，原始的movieclip从1开始)
     * @param from 开始帧或标签(为null时默认为第一帧)
     * @param to 结束帧或标签(为null时默认为最后一帧)
     */
    public function playFromTo(from:Object = null, to:Object = null, complete:Handler = null):void {
        _bar.playFromTo(from, to, complete);
    }
}
}