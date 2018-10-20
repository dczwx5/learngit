/**
 * Created by auto on 2016/8/3.
 */
package kof.game.level {

import QFLib.Framework.CFramework;

import flash.utils.setTimeout;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IApplication;
import kof.framework.IDataTable;
import kof.game.common.view.CViewManagerHandler;
import kof.game.instance.CInstanceAutoFightHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.event.CLevelEvent;
import kof.game.level.view.CLevelBossComingView;
import kof.game.level.view.CLevelIntroductionView;
import kof.game.level.view.CLevelMasterComingView;
import kof.game.level.view.CLevelSceneNameView;
import kof.game.level.view.enum.ELevelWndType;
import kof.game.levelCommon.Enum.ETrunkGoalType;
import kof.game.levelCommon.info.base.CTrunkEntityMapEntityBase;
import kof.game.levelCommon.info.goal.CTrunkGoalTargetEntityInfo;
import kof.game.levelCommon.info.goal.CTrunkGoalTargetInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import kof.game.lobby.CLobbySystem;
import kof.game.result.CGameResultViewHandler;
import kof.game.scene.ISceneFacade;
import kof.table.LevelUITxt;
import kof.table.Monster;

public class CLevelUIHandler extends CViewManagerHandler { // CAbstractHandler {

    public function CLevelUIHandler() {
        _isDispose = false;
    }
    public override function dispose() : void {
        if (_isDispose) return ;

        super.dispose();


        _isDispose = true;
    }
    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.addBean(new CGameResultViewHandler()); // K.O view.


        this.addViewClassHandler(ELevelWndType.WND_BOSS_COMING, CLevelBossComingView);
        this.addViewClassHandler(ELevelWndType.WND_MASTER_COMING, CLevelMasterComingView);
        this.addViewClassHandler(ELevelWndType.SHOW_SCENE_NAME, CLevelSceneNameView);
        this.addViewClassHandler(ELevelWndType.SHOW_INTRODUCTION, CLevelIntroductionView);

        return ret;
    }


    public function showBossComing(_data:Array) : void {
        var data:Array = _data;
        var framework:CFramework = (system.stage.getSystem( ISceneFacade ) as ISceneFacade).scenegraph.graphicsFramework;
        this.show(ELevelWndType.WND_BOSS_COMING, [framework], null, {skin:data[0],name:data[1],loop:data[2],callback:hideBossComing,time:data[4]}, int(data[3]));
        (system.getBean(CLevelManager) as CLevelManager).pauseLevel();
        (system.stage.getSystem(CInstanceSystem).getBean(CInstanceAutoFightHandler) as CInstanceAutoFightHandler).setForcePause(true);
        (system.stage.getSystem(CLobbySystem) as CLobbySystem).fightUIEnabled = false;
    }

    public function showMasterComing():void{
        this.show(ELevelWndType.WND_MASTER_COMING,[],null,{callback:hideMasterComing});
    }
    public function showMasterComingCommon(closeCallback:Function) : void {
        this.show(ELevelWndType.WND_MASTER_COMING,[],null,{callback:function () : void {
            hide(ELevelWndType.WND_MASTER_COMING);
            if (closeCallback) closeCallback();
        }});
    }

    public function hideMasterComing():void{
        this.hide(ELevelWndType.WND_MASTER_COMING);
        (system.getBean(CLevelHandler) as CLevelHandler).sendPlayBossComingEndRequest();
//        system.dispatchEvent(new CLevelEvent(CLevelEvent.BOSS_COMING_END, null));
    }

    public function showIntroductionView(_date:Array,closeFunc:Function = null):void{
        (system.getBean(CLevelManager) as CLevelManager).pauseLevel();
        (system.stage.getSystem(CInstanceSystem).getBean(CInstanceAutoFightHandler) as CInstanceAutoFightHandler).setForcePause(true);
        var pApp : Object = system.stage.getBean(IApplication) as IApplication;
        pApp._baseDeltaFactor = 0.001;

        (system.stage.getSystem(CLobbySystem) as CLobbySystem).fightUIEnabled = false;
        this.show(ELevelWndType.SHOW_INTRODUCTION,[],null,{data:_date,callback:function():void{
            hideIntroductionView();
            if(closeFunc){
                closeFunc();
            }
        }});
    }

    public function hideIntroductionView():void{
        this.hide(ELevelWndType.SHOW_INTRODUCTION);
        (system.getBean(CLevelManager) as CLevelManager).continueLevel();
        (system.stage.getSystem(CLobbySystem) as CLobbySystem).fightUIEnabled = true;
        (system.stage.getSystem(CInstanceSystem).getBean(CInstanceAutoFightHandler) as CInstanceAutoFightHandler).setForcePause(false);
        var pApp : Object = system.stage.getBean(IApplication) as IApplication;
        pApp._baseDeltaFactor = 1;
    }

    public function showSceneName(_date:Array,closeFunc:Function = null):void{
        this.show(ELevelWndType.SHOW_SCENE_NAME,[],null,{data:_date,callback:function():void{
            hideSceneName();
            if(closeFunc){
                closeFunc();
            }
        }});
    }
    public function hideSceneName():void{
        this.hide(ELevelWndType.SHOW_SCENE_NAME);
//        (system.getBean(CLevelHandler) as CLevelHandler).sendPlayBossCommingEndRequest();
    }

    public function hideBossComing() : void {
        this.hide(ELevelWndType.WND_BOSS_COMING);
        (system.getBean(CLevelHandler) as CLevelHandler).sendPlayBossComingEndRequest();
        (system.getBean(CLevelManager) as CLevelManager).continueLevel();
        (system.stage.getSystem(CLobbySystem) as CLobbySystem).fightUIEnabled = true;
        (system.stage.getSystem(CInstanceSystem).getBean(CInstanceAutoFightHandler) as CInstanceAutoFightHandler).setForcePause(false);

//        system.dispatchEvent(new CLevelEvent(CLevelEvent.BOSS_COMING_END, null));
    }


    public function getTargetTextByTrunkInfo(levelID:int, trunkInfo:CTrunkConfigInfo) : String {
        var ret:String;

        var levelUITable:IDataTable= (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LEVEL_UI_TXT);
        var key:int = (int)(levelID + trunkInfo.ID);
        var levelUIText:LevelUITxt = levelUITable.findByPrimaryKey(key) as LevelUITxt;
        if (levelUIText) {
            // 有配了自定义文本, 使用自定义文本
            ret = levelUIText.TXT;
        } else{
            var targetArray:Array = new Array();
            var entityNameList:Array = new Array();
            var targetTxt:String = new String();
            // 没有自定义文本, 使用固定的
            switch (trunkInfo.goals.targetType) {
                case ETrunkGoalType.TARGET_TYPE_KILL_ALL:
                    targetTxt = (levelUITable.findByPrimaryKey(1) as LevelUITxt).TXT;
                    break;
                case ETrunkGoalType.TARGET_TYPE_KILL_POINT_TO:
                    targetTxt = (levelUITable.findByPrimaryKey(2) as LevelUITxt).TXT;
                    break;
                case ETrunkGoalType.TARGET_TYPE_KILL_ANY_ONE:
                    targetTxt = (levelUITable.findByPrimaryKey(3) as LevelUITxt).TXT;
                    break;
            }
            // 文本替换
            var targets:Array = trunkInfo.goals.target;
            var value:String = new String(); // 所有目标组成一个字符串, 最后用于替换tartetTxt中的{v1}

            if (targets != null && targets.length > 0) {
                var countTxt:String = "";
                var subTargetTxt:String = "";
                var monsterTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MONSTER);

                // 目标 list
                for (var i:int = 0; i < targets.length; i++) {
                    var targetInfo:CTrunkGoalTargetInfo = targets[i] as CTrunkGoalTargetInfo;
                    countTxt = (levelUITable.findByPrimaryKey(100000) as LevelUITxt).TXT;
                    countTxt = countTxt.replace("{v1}", 1); // temp, 需要服务器同步已死的怪物
                    countTxt = countTxt.replace("{v2}", targetInfo.total);

                    // 击杀目标name list

                    for (var j:int = 0; j < targetInfo.object.length; j++) {
                        var entityInfo:CTrunkGoalTargetEntityInfo = targetInfo.object[j];
                        var mapObjectData:CTrunkEntityMapEntityBase = trunkInfo.getEntityById(entityInfo.entityType, entityInfo.entityID) as CTrunkEntityMapEntityBase;
                        var monsterData:Monster = monsterTable.findByPrimaryKey(mapObjectData.spawnID) as Monster;
                        entityNameList.push(monsterData.Name);
                    }

                    subTargetTxt = entityNameList.join(",") + countTxt;
                    targetArray.push(subTargetTxt);
                }
                value = targetArray.join("\n");
            }

            ret = targetTxt.replace("{v1}", value);
        }



        return ret;
    }

    private var _isDispose:Boolean;
}
}
