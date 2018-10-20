//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/8/10.
 */
package kof.game.scenario {

import QFLib.Graphics.RenderCore.CImageObject;

import kof.game.level.*;
import kof.game.levelCommon.CLevelLog;

import kof.game.scenario.*;

import QFLib.Foundation.CKeyboard;
import QFLib.Framework.CPostEffects;
import QFLib.Framework.CTweener;
import QFLib.Graphics.Sprite.CSprite;

import flash.ui.Keyboard;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.levelCommon.CLevelPath;
import kof.game.scenario.imp.CScenarioActorCG;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scene.CSceneSystem;
import kof.table.Dialogue;
import kof.table.PlayerLines;
import kof.ui.CUISystem;

public class CScenarioViewHandler extends CViewHandler  {


    public static const PLOT:int = 0;//双人对话
    public static const BUBBLE:int = 1;//冒泡对话
    public static const COM:int = 2;//通讯对话
    public static const BLACKSCREEN_PLOT:int = 3;//黑幕对话
    public static const SINGLE_PLOT:int = 4;//单人对话

    public static const LIKING_PLOT:int = 8;//好感度对话选项
    public static const OPTION_PLOT:int = 9;//普通对话选项


    private var _curDialogueViewHandler:CBaseDialogueViewHandler;
    private var _dialogCallBackFun:Function;

    private var _tweener:CTweener;
    private var _data:CScenarioPartInfo;

    public function CScenarioViewHandler() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        _dialogOnFinish();
        endKeyboard();
        m_pKeyboard = null;
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_pKeyboard = new CKeyboard(system.stage.flashStage);

        return true;
    }

    //显示CG图片
    public function showCGAnimation(_info:CScenarioPartInfo, _showOverFun:Function, actor:CScenarioActorCG):void{
        var sp:CSprite;
        _data = _info;
        if(actor.actorImg){
            sp = actor.actorImg;
        }
        else{
            var _sceneSystem:CSceneSystem = system.stage.getSystem(CSceneSystem) as CSceneSystem;
            var path:String = CLevelPath.getImgPath(_info.params["picName"]);
            sp = new CSprite(  _sceneSystem.graphicsFramework.spriteSystem, true );
            sp.loadFile( path, fnOnLoadFinished );
//            sp.setPosition(_info.params["x"]+sp.width/2,_info.params["y"]+sp.height/2);
            _sceneSystem.graphicsFramework.spriteSystem.addToSpriteLayer(sp);
            actor.actorImg = sp;
        }
        function fnOnLoadFinished(sp : CImageObject, idErrorCode : int ):void{
            sp.setPosition(_data.params["x"]+sp.width/2,_data.params["y"]+sp.height/2);
            _tweener = _sceneSystem.graphicsFramework.tweenSystem.addSequentialTweener( sp, CTweener.moveToXYZ, 0, _info.params["moveTime"], _info.params["moveX"]+sp.width/2, _info.params["moveY"]+sp.height/2 );
            _tweener = _sceneSystem.graphicsFramework.tweenSystem.addParallelTweener( sp, CTweener.scaleToXYZ, 0, _info.params["moveTime"],_info.params["scale"], _info.params["scale"]);
            _tweener = _sceneSystem.graphicsFramework.tweenSystem.addSequentialTweener( sp, CTweener.funCallObject,_showOverFun);
        }
    }

    public function hideCGAnimation(_showOverFun:Function):void{
        _tweener.clearAll();
        _showOverFun();
    }

    public function showDialogBubbles(actor:CGameObject,id:int,x:int,y:int,position:int = 0, callBackFun:Function = null):void{

        (system.getBean(CSCenarioBubblesViewHandler) as CSCenarioBubblesViewHandler).actor = actor;
        (system.getBean(CSCenarioBubblesViewHandler) as CSCenarioBubblesViewHandler).x = x;
        (system.getBean(CSCenarioBubblesViewHandler) as CSCenarioBubblesViewHandler).y = y;
        (system.getBean(CSCenarioBubblesViewHandler) as CSCenarioBubblesViewHandler).position = position;

        showScenarioDialog(id,callBackFun);
    }

    /**
     * 显示剧情对话
     * @param id 对话ID（当isDialogOption=false时，id不为0；当isDialogOption=true时，id为0）
     * @param callBackFun
     * @param isDialogOption 默认false，如果是true选项对话，需要传递args = [800001,800002]参数
     * @param args 格式[800001,800002]
     */
    public function showScenarioDialog(id:int,callBackFun:Function = null,isDialogOption:Boolean = false,args:Array = null):void {
        _dialogOnFinish();
        _dialogCallBackFun = callBackFun;
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTableDialogue : IDataTable = pDB.getTable( KOFTableConstants.DIALOGUE );
        var uiSystem:CUISystem = (uiCanvas as CUISystem);
        var pDialogue : Dialogue = pTableDialogue.findByPrimaryKey( id );

        if(pDialogue == null){
            CLevelLog.addDebugLog("未找到"+id+"对话配置");
            return;
        }

        if(pDialogue.Type == PLOT || pDialogue.Type == LIKING_PLOT || pDialogue.Type == OPTION_PLOT){
            _curDialogueViewHandler = uiSystem.getBean(CPlotViewHandler) as CBaseDialogueViewHandler;//剧情对话,包括对话选项
        }else if(pDialogue.Type == BUBBLE){
            _curDialogueViewHandler = system.getBean(CSCenarioBubblesViewHandler) as CBaseDialogueViewHandler;//冒泡对话
        }else if(pDialogue.Type == COM){
            _curDialogueViewHandler = uiSystem.getBean(CComViewHandler) as CBaseDialogueViewHandler;//通讯对话
        }else if(pDialogue.Type == BLACKSCREEN_PLOT){
            _curDialogueViewHandler = uiSystem.getBean(CBlackScreenDialogueViewHandler) as CBaseDialogueViewHandler;//黑幕对话
        }else if(pDialogue.Type == SINGLE_PLOT){
            _curDialogueViewHandler = uiSystem.getBean(CSingleDialogueViewHandler) as CBaseDialogueViewHandler;//单人对话
        }

        if(pDialogue.Type == COM){
            _curDialogueViewHandler.name = pDialogue.Name;
            _curDialogueViewHandler.head = pDialogue.Head;
            _curDialogueViewHandler.name1 = null;
            _curDialogueViewHandler.head1 = null;
            _curDialogueViewHandler.animationName1 = "";
        }else{
             _curDialogueViewHandler.name = pDialogue.Name;
             _curDialogueViewHandler.head = pDialogue.Head;
            _curDialogueViewHandler.animationName = pDialogue.animationName;
            _curDialogueViewHandler.isLoop = pDialogue.isLoop;
            _curDialogueViewHandler.name1 = pDialogue.Name1;
            _curDialogueViewHandler.head1 = pDialogue.Head1;
            _curDialogueViewHandler.animationName1 = pDialogue.animationName1;
            _curDialogueViewHandler.isLoop1 = pDialogue.isLoop1;
        }

        if(isDialogOption && (pDialogue.Type == PLOT || pDialogue.Type == LIKING_PLOT || pDialogue.Type == OPTION_PLOT)){
            var plotViewHandler:CPlotViewHandler = _curDialogueViewHandler as CPlotViewHandler;
            plotViewHandler.m_bIsDialogOption = true;
            plotViewHandler.m_bIsShowIcon = (pDialogue.Type == LIKING_PLOT ? true:false);

            var dialogIdA:int = args[0].optionA;
            var pDialogueA : Dialogue = pTableDialogue.findByPrimaryKey( dialogIdA );

            plotViewHandler.m_nDialogOptionId1 = dialogIdA;
            plotViewHandler.m_nTriggerId1 = args[0].triggerA;
            if(pDialogueA){
                plotViewHandler.m_sOptionContent1 = pDialogueA.content;
            }

            var dialogIdB:int = args[1].optionB;
            var pDialogueB : Dialogue = pTableDialogue.findByPrimaryKey( dialogIdB );

            plotViewHandler.m_nDialogOptionId2 = dialogIdB;
            plotViewHandler.m_nTriggerId2 = args[1].triggerB;
            if(pDialogueB){
                plotViewHandler.m_sOptionContent2 = pDialogueB.content;
            }

        }else if(!isDialogOption && pDialogue.Type == PLOT){
            (_curDialogueViewHandler as CPlotViewHandler).m_bIsDialogOption = false;
            (_curDialogueViewHandler as CPlotViewHandler).m_bIsShowIcon = false;
        }


        _curDialogueViewHandler.size = 14;
        _curDialogueViewHandler.color = "0xcccccc";
        if(pDialogue.Type != BUBBLE){
            _curDialogueViewHandler.position = pDialogue.position;
        }
        _curDialogueViewHandler.display = pDialogue.display;
        _curDialogueViewHandler.rate = pDialogue.rate;
        _curDialogueViewHandler.content = pDialogue.content;
        _curDialogueViewHandler.uitype = pDialogue.uitype;
        _curDialogueViewHandler.dialogNumber = pDialogue.dialogNumber;
        _curDialogueViewHandler.show(_dialogOnFinish);
    }

    public function hideScenarioDialog():void {
        if(_curDialogueViewHandler) {
            _curDialogueViewHandler.hide();
           // _curDialogueViewHandler.dispose();
            _curDialogueViewHandler = null;
        }
    }
    private function _dialogOnFinish( actionId:int = 0):void{
//        if(_curDialogueViewHandler) {
//            _curDialogueViewHandler.hide();
//            _curDialogueViewHandler = null;
//        }
        if(_dialogCallBackFun){
            _dialogCallBackFun( actionId );
            _dialogCallBackFun = null;
        }
    }

    // 剧情过场黑屏
    public function showMaskView(callBackFun:Function = null, onStartFun:Function = null, onProcessFun : Function = null, showTime:Number = 2.0, color:uint = 0x000000) : void {
        uiCanvas.showMaskView(callBackFun, onStartFun, onProcessFun, showTime, color);
    }

    public function showScenarioStartView( callBackFun : Function = null ) : void{
        uiCanvas.showScenarioStartView( callBackFun );
    }

    public function showScenarioEndView( callBackFun : Function = null ) : void{
        uiCanvas.showScenarioEndView( callBackFun );

    }

    public function startKeyboard() : void {
        endKeyboard();
        if (m_pKeyboard) m_pKeyboard.registerKeyCode(true, Keyboard.ESCAPE, _onKeyDown);
    }
    public function endKeyboard() : void {
        if (m_pKeyboard)  m_pKeyboard.unregisterKeyCode(true, Keyboard.ESCAPE, _onKeyDown);
    }
    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.ESCAPE:
                    var scenarioMgr:CScenarioManager = (system.getBean(CScenarioManager) as CScenarioManager);
                    if (scenarioMgr) {
                        if(!scenarioMgr.isEscEnable){
                            scenarioMgr.stopAllPart();
                            //对话结束停止模糊效果（ESC快捷键也会调用）
                            CPostEffects.getInstance().stop(CPostEffects.Blur);
                        }
                    }
                break;
        }
    }

    private var m_pKeyboard:CKeyboard;
}
}
