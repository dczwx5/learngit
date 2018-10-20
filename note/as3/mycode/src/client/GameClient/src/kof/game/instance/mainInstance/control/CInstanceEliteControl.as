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
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.table.InstanceType;

public class CInstanceEliteControl extends CInstanceControler{
    public function CInstanceEliteControl() {
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
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_EMBATTLE:

                var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var database:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
                    var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
                    var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_ELITE);
                    var fighterCount:int = 3;
                    if (instanceTypeRecord) {
                        fighterCount = instanceTypeRecord.embattleNumLimit;
                    }

                    var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
                    pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',[EInstanceType.TYPE_ELITE, fighterCount]);
                    pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
                }
                break;
            case EInstanceViewEventType.INSTANCE_CLICK:
                dataCollection = e.data[0] as CInstanceDataCollection;
                var instanceData:CChapterInstanceData = e.data[1] as CChapterInstanceData;
                errorData = dataCollection.instanceDataManager.instanceData.checkInstanceCanFight(instanceData.instanceID, 0, false, true);
                if (errorData.isError) {
                    uiCanvas.showMsgAlert(errorData.errorString);
                } else {
                    // open other view
                    win = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL);
                    if (!win) {
                        uiHandler.showEliteDetailWindow(instanceData);
                    } else {
                        uiHandler.updateEliteDetailWindow(instanceData);
                    }
                }
                break;
            case EInstanceViewEventType.INSTANCE_OPEN_CHAPTER_LIST :
                uiHandler.showChapterListView();
                break;
            case EInstanceViewEventType.CLICK_STAGE:
//                win = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL);
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
            case EInstanceViewEventType.INSTANCE_ONE_KEY_REWARD_CLICK :
                var isNotify:Boolean = system.instanceData.chapterList.isEliteHasReward() ||
                        system.instanceData.instanceList.isEliteHasExternsReward();
                if (isNotify) {
                    dataCollection = e.data as CInstanceDataCollection;
                    mainNetHandler.sendGetOneKeyReward(dataCollection.instanceType);
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("instance_no_reward"));
                }
                break;
        }

    }

    private function _onHide(e:CViewEvent) : void {
        uiHandler.hideAll();
    }
}
}
