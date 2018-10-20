//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/8/25.
 */
package kof.game.scenario {

import QFLib.Foundation.CKeyboard;

import flash.events.MouseEvent;
import flash.ui.Keyboard;

import kof.framework.CAppStage;
import kof.game.audio.CAudioConstants;
import kof.game.audio.IAudio;
import kof.ui.CUISystem;
import kof.ui.demo.ComDialogueUI;

public class CComViewHandler extends CBaseDialogueViewHandler {

    public var m_comtDialogueUI:ComDialogueUI;
    private static const TIME_ON_ALLSHOW:Number = 6.0;
    private var _strIndex:int;
    private var _time:Number = 0.0;
    private var _callBackFun:Function;
    private var _appStage : CAppStage;
    private var m_theKeyboard : CKeyboard;

    public function CComViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function get viewClass() : Array {
        return [ ComDialogueUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    /* private function loadAssets() : Boolean { */
        /* if ( !App.loader.getResLoaded( "comdialogue.swf" ) || !App.loader.getResLoaded( "frame_comdialogue.swf" ) ) { */
            /* App.loader.loadAssets( ["comdialogue.swf","frame_comdialogue.swf"], new Handler( _onAssetsCompleted ), null, null, false ); */
            /* return false; */
        /* } */
        /* return true; */
    /* } */

    override protected function onInitializeView() : Boolean {
        m_comtDialogueUI = m_comtDialogueUI || new ComDialogueUI();
        return Boolean( m_comtDialogueUI );
    }

    override public function show(callBackFun:Function = null):void {
        if(_appStage)
            _appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
            _appStage.flashStage.addEventListener(MouseEvent.CLICK, _ck);

        if(!m_theKeyboard){
            m_theKeyboard = new CKeyboard( _appStage.flashStage );
            m_theKeyboard.registerKeyCode( true, Keyboard.SPACE, _enterKeySpace );
        }
        _callBackFun = callBackFun;
        m_comtDialogueUI.txt_content.text = "";
        m_comtDialogueUI.txt_content.size = 16;
//        m_comtDialogueUI.txt_content.size = size;
//        m_comtDialogueUI.txt_content.color = color;
        m_comtDialogueUI.txt_name.text = name;
        m_comtDialogueUI.img_p.url = "icon/role/medium/" + head + ".png";
        if (position == 0){
            m_comtDialogueUI.box_dialogue.right = NaN;
            m_comtDialogueUI.box_dialogue.left = 100;
        }
        else{
            m_comtDialogueUI.box_dialogue.left = NaN;
            m_comtDialogueUI.box_dialogue.right = 100;
        }

        if(display == 1){
            _strIndex = 0;
            _time = 0.0;
        }else{
            _time = 0.0;
            m_comtDialogueUI.txt_content.text = content;
        }
        m_comtDialogueUI.popupCenter = false;
        (uiCanvas as CUISystem).plotLayer.popup(m_comtDialogueUI);

        var audio:IAudio = system.stage.getSystem( IAudio ) as IAudio;
        audio.playAudioByName(CAudioConstants.COM_DIALOGUE , 1, 0.0, 1);

        schedule( 1.0 / 30, this.update );
    }

    override public function hide() : void {
        unschedule( this.update );

        (uiCanvas as CUISystem).plotLayer.close(m_comtDialogueUI);
        this.reset();
    }

    private function showStrOneByOne():void{
        if(!m_comtDialogueUI || !m_comtDialogueUI.parent)
            return;
        if(_strIndex >= content.length && _time >= TIME_ON_ALLSHOW ){
            onFinish();
            return;
        }
        m_comtDialogueUI.txt_content.text += content.charAt(_strIndex);
    }
    private function onFinish():void{
        if(_callBackFun){
            _callBackFun.apply();
        }
        var audio:IAudio = system.stage.getSystem( IAudio ) as IAudio;
        if(audio)
            audio.stopAudioByName(CAudioConstants.COM_DIALOGUE);
        if(_appStage)
            _appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
        if(m_theKeyboard){
            m_theKeyboard .unregisterKeyCode( true, Keyboard.SPACE, _enterKeySpace );
            m_theKeyboard.dispose();
            m_theKeyboard = null;
        }
    }

    override public function dispose() : void {
        super.dispose();
        if ( uiCanvas )
            (uiCanvas as CUISystem).plotLayer.close(m_comtDialogueUI);
        reset();
    }

    private function reset():void{
        if ( !m_comtDialogueUI )
            return;

        m_comtDialogueUI.txt_content.text =
                m_comtDialogueUI.txt_name.text =
                        m_comtDialogueUI.img_p.url = "";
    }
    private function _ck(evt:MouseEvent):void{
        onFinish();
    }
    private function _enterKeySpace(keyCode : int):void{
        if(keyCode == Keyboard.SPACE){
            onFinish();
        }
    }
    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        _appStage = appStage;
    }

    override public function update(delta:Number):void {
        _time += delta;
        if(display && _time >=  rate * _strIndex){
            showStrOneByOne();
            _strIndex ++;
        }else if(!display && _time >= TIME_ON_ALLSHOW){
            onFinish();
        }
    }
}
}
