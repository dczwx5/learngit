/**
 * Created by Maniac on 2017/6/7.
 */
package kof.game.scenario {

import QFLib.Foundation.CKeyboard;
import QFLib.Interface.IUpdatable;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import kof.framework.CAppStage;
import kof.framework.CViewHandler;
import kof.ui.demo.NoviceSkillUI;

import morn.core.handlers.Handler;

public class CScenarioPlaySkillViewHandler extends CViewHandler implements IUpdatable {

    private var  m_noviceSkillUI:NoviceSkillUI;

    public function CScenarioPlaySkillViewHandler() {
        super( true );
    }

    override public function get viewClass() : Array {
        return [ NoviceSkillUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !m_noviceSkillUI ) {
            m_noviceSkillUI = new NoviceSkillUI();

            m_noviceSkillUI.addEventListener( Event.ADDED_TO_STAGE, _onAddStage );
            m_noviceSkillUI.addEventListener( Event.REMOVED_FROM_STAGE, _onRemoveStage );

//            m_noviceSkillUI.img_u.visible = false;
//            m_noviceSkillUI.img_i.visible = false;
//            m_noviceSkillUI.img_o.visible = false;
//            m_noviceSkillUI.img_kg.visible = false;

        }
        return Boolean( m_noviceSkillUI );
    }

    public function show( callBackFunc:Function = null, isSpace:Boolean = false, skillID:int = -1 ):void{

        _isSpace = isSpace;
        _skillID = skillID;

        this.loadAssetsByView( viewClass, _addToDisplay );
        _callBack = callBackFunc;

    }

    public function hide():void{

        if(m_noviceSkillUI.parent){
            uiCanvas.rootContainer.removeChild( m_noviceSkillUI );
        }

        if ( m_theKeyboard ) {
            m_theKeyboard.unregisterKeyCode( true, Keyboard.SPACE, _enterKeyUorSpace );
            m_theKeyboard.unregisterKeyCode( true, Keyboard.U, _enterKeyUorSpace );
            m_theKeyboard.unregisterKeyCode( true, Keyboard.I, _enterKeyUorSpace );
            m_theKeyboard.unregisterKeyCode( true, Keyboard.O, _enterKeyUorSpace );
            m_theKeyboard.dispose();
            m_theKeyboard = null;
        }
        m_noviceSkillUI.framcClip_u.removeEventListener(MouseEvent.CLICK, _onClickSpace);

        unschedule( this.update );
        _time = 0;
    }

    private function get isU() : Boolean {
        return _skillID == _KYO_U_1; //  ||_skillID == _KYO_U_2 ||_skillID == _KYO_U_3;
    }

    private function get isI() : Boolean {
        return _skillID == _KYO_I;
    }

    private function get isO() : Boolean {
        return _skillID == _KYO_O;
    }

    private function get isSpace() : Boolean {
        return _isSpace;
    }

    private function _addToDisplay():void {
        if ( onInitializeView() ) {
            invalidate();
        }

        if(!m_theKeyboard){
            if( _isSpace ){
                //如果是大招
                m_theKeyboard = new CKeyboard( _appStage.flashStage );
                m_theKeyboard.registerKeyCode( true, Keyboard.SPACE, _enterKeyUorSpace );
                m_noviceSkillUI.framcClip_u.addEventListener(MouseEvent.CLICK, _onClickSpace);
            } else {
                if (isU) {
                    m_theKeyboard = new CKeyboard( _appStage.flashStage );
                    m_theKeyboard.registerKeyCode( true, Keyboard.U, _enterKeyUorSpace );
                } else if (isI) {
                    m_theKeyboard = new CKeyboard( _appStage.flashStage );
                    m_theKeyboard.registerKeyCode( true, Keyboard.I, _enterKeyUorSpace );
                } else if (isO) {
                    m_theKeyboard = new CKeyboard( _appStage.flashStage );
                    m_theKeyboard.registerKeyCode( true, Keyboard.O, _enterKeyUorSpace );
                }
            }


        }

        schedule( 0.2, this.update );

        if(m_noviceSkillUI){
            uiCanvas.rootContainer.addChild( m_noviceSkillUI );
//
//            m_noviceSkillUI.img_u.visible = false;
//            m_noviceSkillUI.img_i.visible = false;
//            m_noviceSkillUI.img_o.visible = false;
//            m_noviceSkillUI.img_kg.visible = false;

            _createRect();
            m_noviceSkillUI.framcClip_hp.playFromTo(null,null,new Handler(_playHeiPComplete));
//            m_noviceSkillUI.img_u.visible = true;
            m_noviceSkillUI.framcClip_u.playFromTo(null,null,new Handler(_playUComplete));

//            _onStageResize(null);
        }
    }

    private function _playHeiPComplete():void {
        if(m_noviceSkillUI) {
            m_noviceSkillUI.img_mask.graphics.clear();
        }
    }

    private function _playUComplete():void {
//        if( m_noviceSkillUI ){
//            m_noviceSkillUI.img_u.visible = false;
//            m_noviceSkillUI.img_i.visible = false;
//            m_noviceSkillUI.img_o.visible = false;
//            m_noviceSkillUI.img_kg.visible = false;
//        }
    }

    private function _onClickSpace(e:MouseEvent) : void {
        _enterKeyUorSpace(0);
    }
    private function _enterKeyUorSpace( keyCode : int ):void{
        if( _callBack != null ){
            _callBack.apply();
        }
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        _appStage = appStage;
    }

    override protected function exitStage( appStage : CAppStage ) : void {
        super.exitStage( appStage );
    }

    public function update(delta:Number):void {
        _time += delta;
//        if( _time >= 0.5 ){
//            if( m_noviceSkillUI ){
//                if (isSpace) {
//                    m_noviceSkillUI.img_kg.visible = true;
//                } else if (isU) {
//                    m_noviceSkillUI.img_u.visible = true;
//                } else if (isI) {
//                    m_noviceSkillUI.img_i.visible = true;
//                } else if (isO) {
//                    m_noviceSkillUI.img_o.visible = true;
//                }
//            }
//        }

        if( _time >= 3.2 ){
//            if( m_noviceSkillUI ){
//                m_noviceSkillUI.img_u.visible = false;
//                m_noviceSkillUI.img_i.visible = false;
//                m_noviceSkillUI.img_o.visible = false;
//                m_noviceSkillUI.img_kg.visible = false;
//            }
        }

        if( _time > DEFAULT_TIME ){
            this.hide();
            _enterKeyUorSpace(0);
        }
    }

    private function _createRect():void{
        if(m_noviceSkillUI){

            var width:Number = system.stage.flashStage.stageWidth;
            var height:Number = system.stage.flashStage.stageHeight;

            m_noviceSkillUI.img_mask.width = width;
            m_noviceSkillUI.img_mask.height = height;

            var postionX:Number = width / 2;
            var postionY:Number = height / 2;

            var boxW:Number = m_noviceSkillUI.box_h.width / 2;
            var boxH:Number = m_noviceSkillUI.box_h.height / 2;

            m_noviceSkillUI.img_mask.graphics.clear();
            m_noviceSkillUI.img_mask.graphics.beginFill(0,0.9);
            m_noviceSkillUI.img_mask.graphics.drawRect(0,0,width,height);
            m_noviceSkillUI.img_mask.graphics.drawRect(postionX-boxW,postionY-boxH,1500,900);
            m_noviceSkillUI.img_mask.graphics.endFill();
        }
    }

    private function _onAddStage( e : Event ) : void {
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    private function _onRemoveStage( e : Event ) : void {
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    private function _onStageResize( e : Event ) : void {
        _createRect();
    }

    public static const DEFAULT_TIME:Number = 3;

    public static const SHOW_TIME:Number = 0.48;
    public static const HIDE_TIME:Number = 3.4;

    private var _appStage : CAppStage;
    private var _callBack:Function;
    private var m_theKeyboard : CKeyboard;

    private var _isSpace:Boolean = false;
    private var _skillID:int;

    private var _time:Number = 0;

    public static const _KYO_O:int = 928721;
    public static const _KYO_I:int = 928711;
    public static const _KYO_U_1:int = 928701;
//    public static const _KYO_U_2:int = 101211;
//    public static const _KYO_U_3:int = 101221;
//    public static const _KYO_SPACE:int = 101901;

//    public static const _IORI_SPACE:int = 928802;
}
}