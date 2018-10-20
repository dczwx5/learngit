
//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/8/17.
 */
package kof.game.Tutorial.tutorPlay {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.Tutorial.enum.ETutorFinsinCondType;
import kof.game.artifact.CArtifactSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.impression.CImpressionSystem;
import kof.game.impression.view.CImpressionDisplayViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.enum.EInstanceType;
import kof.game.newServerActivity.CNewServerActivityManager;
import kof.game.newServerActivity.CNewServerActivitySystem;
import kof.game.openServerActivity.COpenServerActivitySystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.game.recharge.firstRecharge.CFirstRechargeSystem;
import kof.game.recharge.firstRecharge.CTipsViewHandler;
import kof.game.scene.CSceneSystem;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;

import morn.core.components.Tab;

public class CTutorCondProcess {
    public function CTutorCondProcess(tutorPlay:CTutorPlay) {
        _pTutorPlay = tutorPlay;
    }

    public function dispose() : void {
        _pTutorPlay = null;
    }

    public function isCondFinish(finishCond:int, finishCondParams:Array) : Boolean {
        if (_pTutorPlay == null) return false;

        var process:Function = null;
        switch (finishCond) {
            case ETutorFinsinCondType.COND_DEFAULT :
                process = _checkDefault;
                break;
            case ETutorFinsinCondType.COND_INSTANCE_COMPLETED :
                process = _checkInstanceCompleted;
                break;
            case ETutorFinsinCondType.COND_HAS_HERO :
                process = _checkHasHero;
                break;
            case ETutorFinsinCondType.COND_TASK_FINISH :
                process = _checkTaskFinsi;
                break;
            case ETutorFinsinCondType.COND_IS_OPEN_SYSTEM_BUNDLE :
                process = _checkIsOpenSystemBundle;
                break;
            case ETutorFinsinCondType.COND_IS_SELECT_EQUIP_CAN_UPGRADE_QUALITY :
                process = _checkIsSelectEquipCanUpgradeQuality;
                break;

            case ETutorFinsinCondType.COND_IS_VIEW_CLOSE :
                process = _checkIsCloseView;
                break;
            case ETutorFinsinCondType.COND_IS_CLOSE_SYSTEM_BUNDLE :
                process = _checkIsCloseSystemBundle;
                break;


            case ETutorFinsinCondType.COND_IS_PLAYER_READY :
                process = _checkIsPlayerReady;
                break;
            case ETutorFinsinCondType.COND_IS_CHAPTER_REWARD_HAS_GETTED :
                process = _checkIsChapterRewardHasGetted;
                break;

            case ETutorFinsinCondType.COND_ARTIFACT_1_IS_UNLOCK :
                process = _checkIsArtifact1Unlock;

                break;
            case ETutorFinsinCondType.COND_SCENARIO_EMBATTLE_COUNT :
                process = _checkScenarioEmbattleCount;

                break;
            case ETutorFinsinCondType.COND_7_DAY_NEW_SERVER_IS_CLOSED :
                process = _check7DayNewServerIsClosed;
             break;
            case ETutorFinsinCondType.COND_7_DAY_NEW_SERVER_IS_SELECT_TAB1 :
                process = _check7DayNewServerSelectTab1;
                break;
            case ETutorFinsinCondType.COND_IS_VIEW_SHOW :
                process = _checkIsShowView;
                break;
            case ETutorFinsinCondType.COND_IS_CARNIVAL_CLOSED :
                process = _checkIsCarnivalClosed;
                break;
            case ETutorFinsinCondType.COND_IS_SELECT_TAB :
                process = _checkIsSelectTab;
                break;
        }

        if (process != null) {
            return process(finishCondParams);
        }
        return false;
    }

    private function _checkDefault(finishCondParams:Array) : Boolean {
        return false;
    }
    private function _checkInstanceCompleted(finishCondParams:Array) : Boolean {
        var pInstanceSystem:CInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var instanceID:int = (int)(finishCondParams[0]);
        if (instanceID > 0) {
            var pInstanceData:CChapterInstanceData = pInstanceSystem.getInstanceByID(instanceID);
            if (pInstanceData) {
                return pInstanceData.isCompleted;
            }
        }

        return false;
    }

    private function _checkHasHero(finishCondParams:Array) : Boolean {
        var heroID:int = (int)(finishCondParams[0]);
        if (heroID > 0) {
            var pPlayerSystem:CPlayerSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var hasHero:Boolean = pPlayerSystem.playerData.heroList.hasHero(heroID);
            return hasHero;
        }
        return false;
    }

    private function _checkTaskFinsi(finishCondParams:Array) : Boolean {
        var taskID:int = (int)(finishCondParams[0]);
        if (taskID > 0) {
            var pTaskSystem:CTaskSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CTaskSystem) as CTaskSystem;
            var isFinish:Boolean = pTaskSystem.getTaskStateByTaskID(taskID) >= CTaskStateType.FINISH;
            return isFinish;
        }
        return false;
    }

    private function _checkIsOpenSystemBundle(finishCondParams:Array) : Boolean {
        var sTagID:String = finishCondParams[0] as String;
        if (sTagID && sTagID.length > 0) {
            var pSystemBundleCtx:ISystemBundleContext = _pTutorPlay.tutorManager.system.stage.getSystem(ISystemBundleContext) as
                    ISystemBundleContext;
            if (pSystemBundleCtx) {
                var pSystemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(sTagID));
                var bBundleActived:Boolean = pSystemBundleCtx.getUserData(pSystemBundle, CBundleSystem.ACTIVATED);
                return bBundleActived;
            }
        }
        return false;
    }
    private function _checkIsCloseSystemBundle(finishCondParams:Array) : Boolean {
        var sTagID:String = finishCondParams[0] as String;
        if (sTagID && sTagID.length > 0) {
            var pSystemBundleCtx:ISystemBundleContext = _pTutorPlay.tutorManager.system.stage.getSystem(ISystemBundleContext) as
                    ISystemBundleContext;
            if (pSystemBundleCtx) {
                var pSystemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(sTagID));
                var bBundleActived:Boolean = pSystemBundleCtx.getUserData(pSystemBundle, CBundleSystem.ACTIVATED);
                return !bBundleActived;
            }
        }
        return false;
    }
    private function _checkIsSelectEquipCanUpgradeQuality(finishCondParams:Array) : Boolean {
        var playerSystem:CPlayerSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var playMainView:CPlayerMainViewHandler = playerSystem.getBean(CPlayerMainViewHandler) as CPlayerMainViewHandler; // playerSystem.uiHandler.getWindow(EPlayerWndType.WND_HERO_MAIN) as CPlayerHeroView;
        if (playMainView && playMainView.isViewShow) {
            if (playMainView.isEquipTrainPage) {
                if (playMainView.equipTrainPage && playMainView.equipTrainPage.currentEquipData) {
                    return playMainView.equipTrainPage.currentEquipData.isUpgradeQualityState;
                }
            }
        }
        return false;
    }

    private function _checkIsChapterRewardHasGetted(finishCondParams:Array) : Boolean {
        var pInstanceSystem:CInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;

        var iRewardIndex:int = (int)(finishCondParams[0]);
        var chapterData:CChapterData = pInstanceSystem.instanceData.chapterList.getFirstChapter(EInstanceType.TYPE_MAIN);
        if (chapterData) {
            var isReward:Boolean =  chapterData.isRewarded(iRewardIndex);
            return isReward;
        }

        return false;
    }
    private function _checkIsPlayerReady(finishCondParams:Array) : Boolean {
        var pCSceneSystem : CSceneSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var hero:CGameObject = (pCSceneSystem.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        var isHeroReady:Boolean = (hero && hero.isRunning);
        return isHeroReady;
    }

    private function _checkIsArtifact1Unlock(finishCondParams:Array) : Boolean {
        var pArtifactSystem:CArtifactSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CArtifactSystem) as CArtifactSystem;
        if (pArtifactSystem) {
            return pArtifactSystem.isOpenFirst();
        }
        return false;
    }
    private function _checkScenarioEmbattleCount(finishCondParams:Array) : Boolean {
        var iCount:int = (int)(finishCondParams[0]);
        var playerSystem:CPlayerSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        if (playerSystem) {
            var emListData:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(EInstanceType.TYPE_MAIN);
            if (emListData) {
                return emListData.getHeroCount() >= iCount;
            }
        }

        return false;
    }
    private function _check7DayNewServerIsClosed(finishCondParams:Array) : Boolean {
        var pNewServerSystem:CNewServerActivitySystem = _pTutorPlay.tutorManager.system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem;
        if (pNewServerSystem) {
            var manager:CNewServerActivityManager = pNewServerSystem.getBean(CNewServerActivityManager) as CNewServerActivityManager;
            if (manager) {
                return manager.isActivityClosed();
            }
        }
        return true;
    }
    private function _check7DayNewServerSelectTab1(finishCondParams:Array) : Boolean {
        var pNewServerSystem:CNewServerActivitySystem = _pTutorPlay.tutorManager.system.stage.getSystem(CNewServerActivitySystem) as CNewServerActivitySystem;
        if (pNewServerSystem) {
            return pNewServerSystem.isSelectFirstActivity();
        }
        return true;
    }
    // 是否关闭非bundle界面
    private function _checkIsCloseView(finishCondParams:Array) : Boolean {
        var sViewName:String = finishCondParams[0] as String;
        if (!sViewName || sViewName.length == 0) {
            return false;
        }
        var pInstanceSystem:CInstanceSystem;
        switch (sViewName) {
            case "ROLE_TRAIN" :
                    var pSystem:CPlayerSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                    if (pSystem) {
                        return !pSystem.isHeroMainNiewShow();
                    }
                break;

            case "SCENARIO_DETAIL" :
                    pInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                    if (pInstanceSystem) {
                        return !pInstanceSystem.isScenarioDetailViewShow();
                    }
                break;
            case "SCENARIO_SWEEP" :
                pInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if (pInstanceSystem) {
                    return !pInstanceSystem.isScenarioSweepViewShow();
                }
                break;
            case "FIRST_RECHARGE_TIPS" :
                var pFirstRechargeSystem:CFirstRechargeSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem;
                if (pFirstRechargeSystem) {
                    var pTipsViewHandler:CTipsViewHandler = pFirstRechargeSystem.getBean(CTipsViewHandler) as CTipsViewHandler;
                    return !pTipsViewHandler.isViewShow;
                }
                break;
            case "IMPRESSION_UPGRADE" :
                var pImpressionSystem:CImpressionSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CImpressionSystem) as CImpressionSystem;
                if (pImpressionSystem) {
                    // 培养
                    var pDisplayViewHandler:CImpressionDisplayViewHandler = pImpressionSystem.getBean(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler;
                    return !pDisplayViewHandler.isViewShow;
                }
                break;

        }
        return false;
    }
    // 是否打开非bundle界面
    private function _checkIsShowView(finishCondParams:Array) : Boolean {
        var sViewName:String = finishCondParams[0] as String;
        if (!sViewName || sViewName.length == 0) {
            return false;
        }
        var pInstanceSystem:CInstanceSystem;
        switch (sViewName) {
            case "ROLE_TRAIN" :
                var pSystem:CPlayerSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                if (pSystem) {
                    return pSystem.isHeroMainNiewShow();
                }
                break;

            case "SCENARIO_DETAIL" :
                pInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if (pInstanceSystem) {
                    return pInstanceSystem.isScenarioDetailViewShow();
                }
                break;
            case "SCENARIO_SWEEP" :
                pInstanceSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if (pInstanceSystem) {
                    return pInstanceSystem.isScenarioSweepViewShow();
                }
                break;
            case "FIRST_RECHARGE_TIPS" :
                var pFirstRechargeSystem:CFirstRechargeSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CFirstRechargeSystem) as CFirstRechargeSystem;
                if (pFirstRechargeSystem) {
                    var pTipsViewHandler:CTipsViewHandler = pFirstRechargeSystem.getBean(CTipsViewHandler) as CTipsViewHandler;
                    return pTipsViewHandler.isViewShow;
                }
                break;
            case "IMPRESSION_UPGRADE" :
                var pImpressionSystem:CImpressionSystem = _pTutorPlay.tutorManager.system.stage.getSystem(CImpressionSystem) as CImpressionSystem;
                if (pImpressionSystem) {
                    // 培养
                    var pDisplayViewHandler:CImpressionDisplayViewHandler = pImpressionSystem.getBean(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler;
                    return pDisplayViewHandler.isViewShow;
                }
                break;

        }
        return false;
    }


    private function _checkIsCarnivalClosed(finishCondParams:Array) : Boolean {
        var bundleCtx : ISystemBundleContext = _pTutorPlay.tutorManager.system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var iStateValue : int = bundleCtx.getSystemBundleState( bundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.CARNIVAL_ACTIVITY ) ) );
        if( iStateValue != CSystemBundleContext.STATE_STARTED ){
            return true;
        }
        return false;
    }

    private function _checkIsSelectTab(finishCondParams:Array) : Boolean {
        var compID:String = finishCondParams[0];
        var tabIndex:int = (int)(finishCondParams[1]);
        var tab:Tab = CTutorUtil.GetComponentWithOutLoad(_pTutorPlay.tutorManager.system, compID) as Tab;
        if (tab) {
            return tab.selectedIndex == tabIndex;
        } else {
            return false;
        }
    }

    private var _pTutorPlay:CTutorPlay;

}
}

