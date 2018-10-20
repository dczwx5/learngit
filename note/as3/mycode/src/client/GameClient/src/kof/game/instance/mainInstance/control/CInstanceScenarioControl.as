//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.control {


import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.data.CInstanceDataManager;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;
import kof.table.InstanceType;

public class CInstanceScenarioControl extends CInstanceControler{
    public function CInstanceScenarioControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var dataCollection:CInstanceDataCollection;
        var instanceData:CChapterInstanceData;
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_EMBATTLE:
                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var database:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
                    var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
                    var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_MAIN);
                    var fighterCount:int = 3;
                    if (instanceTypeRecord) {
                        fighterCount = instanceTypeRecord.embattleNumLimit;
                    }

                    var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
                    pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[EInstanceType.TYPE_MAIN, fighterCount]);
//                    pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[EInstanceType.TYPE_MAIN, 2]);//todo eddy
                    pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
                }

                break;
            case EInstanceViewEventType.INSTANCE_CLICK:
                dataCollection = e.data[0] as CInstanceDataCollection;
                instanceData = e.data[1] as CChapterInstanceData;
                errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
                if (errorData.isError) {
                    uiCanvas.showMsgAlert(errorData.errorString);
                } else {
                    // open other view
                    win = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
                    if (!win) {
                        if (instanceData.isElite) {
                            uiHandler.showScenarioDetailWindow(instanceData);
                        } else {
                            if (instanceData.isCompleted) {
                                uiHandler.showScenarioDetailWindow(instanceData);
                            } else {
                                if (CGameStatus.checkStatus(system)){
                                    // 第一次进主线副本, 直接进
                                    errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 1, false, false);
                                    if (errorData.isError == false) {
                                        system.listenEvent(_onInstanceEvent);
                                        system.enterInstance(instanceData.instanceID);
                                    } else {
                                        uiCanvas.showMsgAlert(errorData.errorString);
                                    }
                                }
                            }
                        }
                    } else {
                        uiHandler.hideScenarioDetailWindow();
                    }
                }
                break;
            case EInstanceViewEventType.INSTANCE_EXTRA_CLICK:
                dataCollection = e.data[0] as CInstanceDataCollection;
                instanceData = e.data[1] as CChapterInstanceData;
                errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
                if (errorData.isError) {
                    uiCanvas.showMsgAlert(errorData.errorString);
                } else {
                    // open other view
                    win = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_EXTRA_DETAIL);
                    if (!win) {
                        uiHandler.showScenarioExtraDetailWindow(instanceData);
                    } else {
                        uiHandler.hideScenarioExtraDetailWindow();
                    }
                }
                break;
            case EInstanceViewEventType.INSTANCE_OPEN_CHAPTER_LIST :
                uiHandler.showChapterListView();
                break;
            case EInstanceViewEventType.CLICK_STAGE:
//                win = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
//                if (win) {
//                    uiHandler.hide(win.type);
//                }
                break;
            case EInstanceViewEventType.INSTANCE_GET_CHAPTER_REWARD:
                dataCollection = e.data[0] as CInstanceDataCollection;
                var chapterData:CChapterData = e.data[1] as CChapterData;
                var rewardIndex:int = e.data[2] as int;
                var canGetReward:Boolean = (false == chapterData.isRewarded(rewardIndex+1));
                canGetReward = canGetReward && chapterData.isCanGetReward(rewardIndex);
                if (canGetReward) {
                    mainNetHandler.sendChapterGetReward(chapterData.chapterID, rewardIndex+1);
                }
                break;
            case EInstanceViewEventType.INSTANCE_ADD_VIT:
                playerSystem.inverseBuyVitView();
                break;

            case EInstanceViewEventType.INSTANCE_CLICK_EXTENDS_REWARD :
                instanceData = e.data[0] as CChapterInstanceData;
                if (instanceData && instanceData.isServerData && instanceData.isDrawReard == false) {
                    mainNetHandler.sendGetExtendsReward(instanceData.instanceID);
                }
                break;
            case EInstanceViewEventType.INSTANCE_NEW_CHAPTER_OPEN :
                dataCollection = e.data as CInstanceDataCollection;
                dataCollection.instanceDataManager.instanceData.mainChapterOpenFlag = false;
                system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_CHAPTER_OPEN, null));
                break;
            case EInstanceViewEventType.INSTANCE_ONE_KEY_REWARD_CLICK :
                var isScenarioNotify:Boolean = system.instanceData.chapterList.isScenarioHasReward();
                if (isScenarioNotify) {
                    dataCollection = e.data as CInstanceDataCollection;

                    var dataManager:CInstanceDataManager = dataCollection.instanceDataManager;
                    var data:CInstanceDataCollection = new CInstanceDataCollection();
                    data.instanceDataManager = dataManager;
                    data.instanceType =  system.mainNetHandler.lastInstanceTypeByOneKeyReward;
                    uiHandler.showOneKeyRewardView(data);

                } else {
                    uiCanvas.showMsgAlert(CLang.Get("instance_no_reward"));
                }
                break;
        }

    }

    private function _onHide(e:CViewEvent) : void {
        uiHandler.hideAll();
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            _wnd.DelayCall(0.5, uiHandler.hideAllSystem);
            system.unListenEvent(_onInstanceEvent);
            if (system.isShowViewWhenReturnMainCity) {
                // 特殊处理, 为了第一次打完第一章的时候, 不切到第二章
                // 判断条件为, 第一章未通关时, 切到第一章
                var openList:Array = system.instanceData.chapterList.getOpenList(EInstanceType.TYPE_MAIN);
                if (openList.length <= 1) {
                    // 只开了第一章, 即第一 章未通关
                    system.addExitProcess(CInstanceScenarioView, CInstanceExitProcess.FLAG_INSTANCE, _openViewByTutorialB, null, 9999);
                } else {
                    system.addExitProcess(CInstanceScenarioView, CInstanceExitProcess.FLAG_INSTANCE, system.setActived, [true], 9999);
                }
            }
        }
    }

    private function _openViewByTutorialB() : void {
        system.tab = 0;
        system.isActived = true;
    }
}
}
