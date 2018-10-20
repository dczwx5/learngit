//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/10/19.
 */
package kof.game.reciprocation {

import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import kof.framework.CAppSystem;

import kof.game.common.CLang;
import kof.game.item.CItemData;
import kof.table.Item;
import kof.ui.IUICanvas;
import kof.ui.master.messageprompt.MPCallUI;

import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CQuickUse extends Component {

    public var m_noticeUI : MPCallUI;
    private var _itemData : CItemData = new CItemData();
    private var _completeBackFunc : Function;

    private var _canUseMaxNum:int = 1;
    private var _selectItemNum:int = 1;

    private var _countTime:int = 10;

    private var _system:CAppSystem;
    private var _intervalId:int = 0;

    private var _viewHandler:CGetPropsViewHandler;
    private var _data:Object;

    public function CQuickUse(viewHandler:CGetPropsViewHandler) {
        super();
        _viewHandler = viewHandler;
    }

    public function initView():void{
        if ( m_noticeUI == null ) {
            m_noticeUI = new MPCallUI();

            m_noticeUI.slider.value = 1;
            m_noticeUI.slider.tick = 1;
            m_noticeUI.slider.min = 1;
            m_noticeUI.slider.lable.color = 0xffffff;
            m_noticeUI.slider.changeHandler = new Handler(_sliderHandler);
            m_noticeUI.slider.scrollCompleteHandler = new Handler(_sliderComplete);

            m_noticeUI.btn_min.clickHandler = new Handler(_minNumFunc);
            m_noticeUI.btn_max.clickHandler = new Handler(_maxNumFunc);

            m_noticeUI.btn_ok.clickHandler = new Handler( _onBtnClickHandler, [ m_noticeUI.btn_ok ] );
            m_noticeUI.btn_close.clickHandler = new Handler( _onBtnClickHandler, [ m_noticeUI.btn_close ] );

            m_noticeUI.addEventListener(Event.ADDED_TO_STAGE, _onAddStage );
            m_noticeUI.addEventListener(Event.REMOVED_FROM_STAGE, _onRemoveStage );
        }
    }

    public function show(ui:IUICanvas, item : Item, num : int, completeBackFunc : Function = null, system:CAppSystem = null ) : void {

        _itemData.itemRecord = item;


        _system = system;

        if ( m_noticeUI ) {
            ui.addDialog(m_noticeUI);
//            m_noticeUI.right = 1;
//            m_noticeUI.bottom = 85;

            var startX:int = _system.stage.flashStage.stageWidth - 2 - m_noticeUI.width * 0.5;
            var startY:int = _system.stage.flashStage.stageHeight - 85 - m_noticeUI.height * 0.5;
            var endX:int = _system.stage.flashStage.stageWidth - 2 - m_noticeUI.width;
            var endY:int = _system.stage.flashStage.stageHeight - 85 - m_noticeUI.height;
            TweenMax.fromTo(m_noticeUI, 0.3, {scale:0, x:startX, y:startY}, {scale:1, x:endX, y:endY, ease:Back.easeOut});

            m_noticeUI.slider.value = num;
            m_noticeUI.slider.max = num;

            m_noticeUI.txt_num.text = CLang.LANG_00350 + num+"/"+num;
            m_noticeUI.txt_time.text = CLang.LANG_00351 + _countTime + "S";

            m_noticeUI.txt_name.text = _itemData.nameWithColor;
            m_noticeUI.itemView.img.url = _itemData.iconBig;
            m_noticeUI.itemView.clip_bg.index = _itemData.quality;
            m_noticeUI.itemView.txt_num.text = num.toString();
            m_noticeUI.itemView.box_effect.visible = _itemData.effect;
            _intervalId = setInterval(_showCountTime,1000);
        }

        _canUseMaxNum = num;
        _selectItemNum = num;
        m_noticeUI.slider.value = _selectItemNum;

        this._completeBackFunc = completeBackFunc;
    }
    private function _showCountTime():void{
        if(m_noticeUI){
            m_noticeUI.txt_time.text = CLang.LANG_00351 + _countTime + "S";
        }
        if(_countTime <= 0){
            _countTime = 0;
//            _onBtnClickHandler(m_noticeUI.btn_ok);
            this.hide();
            return;
        }
        _countTime --;
    }

    private function _sliderComplete():void
    {

    }

    private function _sliderHandler(value:int):void
    {
        _selectItemNum = value;
        m_noticeUI.txt_num.text = CLang.LANG_00350 + _selectItemNum+"/"+_canUseMaxNum;
    }

    private function _minNumFunc():void
    {
        m_noticeUI.slider.value = 1;
    }

    private function _maxNumFunc():void
    {
        m_noticeUI.slider.value = _canUseMaxNum;
    }

    private function _onBtnClickHandler( btn : Button ) : void {
        switch ( btn ) {
            case m_noticeUI.btn_ok:
                if ( _completeBackFunc ) {
                    _completeBackFunc( _itemData.itemRecord, _selectItemNum );
                }
                removeQuickUse();
                this.hide();
                break;
            case m_noticeUI.btn_close:
                this.hide();
                break;
        }
    }

    public function hide() : void {
        if(TweenMax.isTweening(m_noticeUI))
        {
            return;
        }

        if ( m_noticeUI.parent ) {
//            m_noticeUI.remove();

            var startX:int = _system.stage.flashStage.stageWidth - 2 - m_noticeUI.width * 0.5;
            var startY:int = _system.stage.flashStage.stageHeight - 85 - m_noticeUI.height * 0.5;
            var endX:int = _system.stage.flashStage.stageWidth - 2 - m_noticeUI.width;
            var endY:int = _system.stage.flashStage.stageHeight - 85 - m_noticeUI.height;
            TweenMax.fromTo(m_noticeUI, 0.3, {scale:1, x:endX, y:endY}, {scale:0, x:startX, y:startY, ease:Back.easeIn,onComplete:onCompleteHandler});
        }

        function onCompleteHandler():void
        {
            m_noticeUI.remove();
        }

        _countTime = 10;
        _selectItemNum = 1;
        clearInterval(_intervalId);
    }

    private function removeQuickUse():void{
        var waitVec:Vector.<Object> = _viewHandler.getWaitVec();
        var index:int = waitVec.indexOf(this.data);
        if(index != -1){
            waitVec.splice(index,1);
        }
    }

    private function _onAddStage( e : Event ) : void {
        if(_system){
            _system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
        }
    }

    private function _onRemoveStage( e : Event ):void {
        if(_system){
            _system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
        }
    }

    private function _onStageResize( e : Event ) : void {
        if(m_noticeUI){
            m_noticeUI.right = 1;
            m_noticeUI.bottom = 85;
        }
    }

    public function get data() : Object {
        return _data;
    }

    public function set data( value : Object ) : void {
        _data = value;
    }
}
}
