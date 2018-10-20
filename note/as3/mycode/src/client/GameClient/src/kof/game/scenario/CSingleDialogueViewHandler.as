//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/25.
 */
package kof.game.scenario {
import flash.events.Event;

import kof.framework.CAppStage;
import kof.game.player.config.CPlayerPath;

import kof.ui.CUISystem;

import kof.ui.demo.BlackScreenDialogUI;
import kof.ui.demo.SingleDialogUI;

/**
 * 剧情单人对话
 */
public class CSingleDialogueViewHandler extends CBaseDialogueViewHandler {

    public var m_singleDialogueUI:SingleDialogUI;

    private static const TIME_ON_ALLSHOW:Number = 3.0;
    private var _strIndex:int;
    private var _time:Number = 0.0;

    private var _callBackFun:Function;

    public function CSingleDialogueViewHandler() {
        super(true);
    }

    override public function get viewClass():Array {
        return [BlackScreenDialogUI,SingleDialogUI];
    }
    override protected function get additionalAssets() : Array {
        return [
            "comdialogue.swf"
        ];
    }
    override protected function onAssetsLoadCompleted():void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView():Boolean {
        if (!m_singleDialogueUI) {
            m_singleDialogueUI = new SingleDialogUI();

            m_singleDialogueUI.icon_image.mask =  m_singleDialogueUI.hero_icon_mask;

            m_singleDialogueUI.addEventListener(Event.ADDED_TO_STAGE, _onAddStage);
            m_singleDialogueUI.addEventListener(Event.REMOVED_FROM_STAGE, _onRemoveStage);

        }
        return Boolean(m_singleDialogueUI);
    }

    override public function show(callBackFun:Function = null):void {
        _callBackFun = callBackFun;

        m_singleDialogueUI.txt_content.text = "";
        if (display == 1) {
            _strIndex = 0;
            _time = 0.0;
        } else {
            _time = 0.0;
            m_singleDialogueUI.txt_content.text = content;
        }

        m_singleDialogueUI.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(int(head));

//        _onStageResize(null);


        uiCanvas.rootContainer.addChild( m_singleDialogueUI );

//        (uiCanvas as CUISystem).plotLayer.popup(m_singleDialogueUI);

        schedule(1.0/30, this.update);
    }

    override protected function enterStage(appStage:CAppStage):void {
        super.enterStage(appStage);
    }

    override protected function exitStage(appStage:CAppStage):void {
        super.exitStage(appStage);
    }

    private function _onComplete(...params):void {
        hide();
        if (_callBackFun) {
            _callBackFun.apply();
        }
    }

    private function _onAddStage(e:Event):void {
        system.stage.flashStage.addEventListener(Event.RESIZE, _onStageResize, false, 0, true);
    }

    private function _onRemoveStage(e:Event):void {
        system.stage.flashStage.removeEventListener(Event.RESIZE, _onStageResize);
    }

    private function _onStageResize(e:Event = null):void {
        if (m_singleDialogueUI) {
//            m_singleDialogueUI.img_mask.width = system.stage.flashStage.stageWidth;
//            m_singleDialogueUI.img_mask.height = system.stage.flashStage.stageHeight;
//            m_singleDialogueUI.txt_content.width = int((system.stage.flashStage.stageWidth * 978) / 1500);
//            m_singleDialogueUI.txt_content.centerX = 0;
//            m_singleDialogueUI.txt_content.centerY = 0;
        }
    }

    private function onFinish():void {
        if (_callBackFun) {
            _callBackFun.apply();
        }
    }

    private function showStrOneByOne():void {
        if (!m_singleDialogueUI || !m_singleDialogueUI.parent)
            return;
        if (_strIndex >= content.length && _time >= TIME_ON_ALLSHOW) {
            onFinish();
            return;
        }
        m_singleDialogueUI.txt_content.text += content.charAt(_strIndex);
    }

    override public function update(delta:Number):void {
        _time += delta;
        if (display && _time >= rate * _strIndex) {
            showStrOneByOne();
            _strIndex++;
        } else if (!display && _time >= TIME_ON_ALLSHOW) {
            onFinish();
        }
    }

    override public function hide():void {
        unschedule(this.update);

        if(m_singleDialogueUI.parent){
            uiCanvas.rootContainer.removeChild( m_singleDialogueUI );
        }

//        (uiCanvas as CUISystem).plotLayer.close(m_singleDialogueUI);
    }

}
}
