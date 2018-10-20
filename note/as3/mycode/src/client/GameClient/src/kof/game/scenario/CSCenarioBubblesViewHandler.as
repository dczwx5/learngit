/**
 * Created by user on 2016/12/3.
 */
package kof.game.scenario {

import QFLib.Foundation.CKeyboard;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.MouseEvent;
import flash.ui.Keyboard;

import kof.framework.CAppStage;
import kof.game.audio.CAudioConstants;
import kof.game.audio.IAudio;
import kof.game.character.CFacadeMediator;
import kof.game.character.scene.CBubblesMediator;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.ui.CUISystem;
import kof.ui.demo.BubblesDialogueUI;

import morn.core.handlers.Handler;

/*对话冒泡*/
public class  CSCenarioBubblesViewHandler extends CBaseDialogueViewHandler {
    private var _appStage : CAppStage;
    private var m_theKeyboard : CKeyboard;
    private var _callBackFun:Function;
    public var actor:CGameObject;
    public var x:int;
    public var y:int;

    public function CSCenarioBubblesViewHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.loadAssets();
        return ret;
    }
    private function loadAssets() : Boolean {
        if ( !App.loader.getResLoaded( "bubbles.swf" ) ) {
            App.loader.loadSWF( "bubbles.swf", new Handler( _onAssetsCompleted ), null, null, false );
            return false;
        }
        return true;
    }
    private function _onAssetsCompleted( ... args ) : void {
        LOG.logTraceMsg( "ON 'bubbles.swf' load completed..." );
        this.makeStarted();
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        _appStage = appStage;
    }

    override public function show(callBackFun:Function = null):void{
        if(_appStage){
            _appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
            _appStage.flashStage.addEventListener(MouseEvent.CLICK, _ck);
        }

        if(!m_theKeyboard){
            m_theKeyboard = new CKeyboard( _appStage.flashStage );
            m_theKeyboard.registerKeyCode( true, Keyboard.SPACE, _enterKeySpace );
        }
        _callBackFun = callBackFun;

        if(actor){
            (actor.getComponentByClass( CBubblesMediator, true) as CBubblesMediator).bubblesTalk(content,2,position,x,y,_callBackFun,this.uitype);
        }

    }


    private function _ck(evt:MouseEvent):void{
//        onFinish();
    }
    private function _enterKeySpace(keyCode : int):void{
        if(keyCode == Keyboard.SPACE){
//            onFinish();
        }
    }
    private function onFinish():void{
        if(_callBackFun && (actor.getComponentByClass( CBubblesMediator, true) as CBubblesMediator) != null){
//            _callBackFun.apply();
            (actor.getComponentByClass( CBubblesMediator, true) as CBubblesMediator).hideTalk();
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

    }

    override public function hide():void {
        super.hide();
        if(actor){
            (actor.getComponentByClass( CBubblesMediator, true) as CBubblesMediator).hideTalk();
        }
        if(_appStage){
            _appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
        }
        if(m_theKeyboard){
            m_theKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _enterKeySpace );
        }
    }

    override protected function exitStage( appStage : CAppStage ) : void {
        super.exitStage( appStage );
        appStage.flashStage.removeEventListener(MouseEvent.CLICK, _ck);
        if(m_theKeyboard){
            m_theKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _enterKeySpace );
            m_theKeyboard.dispose();
            m_theKeyboard = null;
        }
    }
}
}
