//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/17.
 */
package kof.game.playerTeam.view {

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bundle.CChildSystemBundleEvent;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerBaseData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.subData.CTeamData;
import kof.game.player.data.subData.CVitData;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.common.view.CRootView;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.game.switching.CSwitchingSystem;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.table.BundleEnable;
import kof.table.MainView;
import kof.ui.master.player_team.TeamUpLVUI;

import morn.core.handlers.Handler;


public class CPlayerTeamLevelUpViewHandler extends CRootView {

    private var m_iCount:int;
    private const _CloseCountdownNum:int = 30;

    public function CPlayerTeamLevelUpViewHandler() {
        super(TeamUpLVUI, null, EPlayerWndResType.PLAYER_TEAM_LEVEL_UP, false);
        viewId = EPopWindow.POP_WINDOW_1;
    }

    protected override function _onCreate() : void {
        _ui.ok_btn.label = CLang.Get("common_ok");
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        _ui.ok_btn.clickHandler = new Handler(_onOk);

        m_iCount = _CloseCountdownNum;
        _ui.ok_btn.label = "确 定("+ m_iCount +"s)";

        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        bundleCtx.addEventListener(CSystemBundleEvent.BUNDLE_START, _onBundleStartHandler);
        bundleCtx.addEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildBundleStartHandler);

        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true);

        schedule(1, _onScheduleHandler);
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_iCount--;
        if(m_iCount <= 0)
        {
//            hide();
            this.close();
        }
        else
        {
            _ui.ok_btn.label = "确 定("+ m_iCount +"s)";
        }
    }

    private function _onKeyboardUp(e:KeyboardEvent) : void
    {
        e.stopImmediatePropagation();

        if(e.keyCode == Keyboard.SPACE)
        {
//            this.hide();
            this.close();
        }
    }

    protected override function _onHide() : void {
        var playerData:CPlayerData = _data as CPlayerData;
        if (playerData) {
            playerData.isLevelUp = false;
        }
        _ui.ok_btn.clickHandler = null;
        _ui.clip_circleEffect.stop();
        _ui.clip_titleEffect.stop();

//        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
//        reciprocalSystem.removeEventPopWindow( this.viewId );

        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        bundleCtx.removeEventListener(CSystemBundleEvent.BUNDLE_START, _onBundleStartHandler);
        bundleCtx.removeEventListener(CChildSystemBundleEvent.CHILD_BUNDLE_START, _onChildBundleStartHandler);

        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);

        unschedule(_onScheduleHandler);
    }

    public override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var playerData:CPlayerData = _data as CPlayerData;
        if (playerData.backupData) {
            var backData:CPlayerBaseData = playerData.backupData as CPlayerBaseData;
            _ui.last_level_label.text = (backData.data[CTeamData._level]).toString();
            _ui.last_max_level_label.text = (backData.data[CTeamData._level]).toString();
            _ui.last_vit_label.text = (backData.data[CVitData._physicalStrength]).toString();
            _ui.last_max_vit_label.text = playerData.getTeamLevelTable(backData.data[CTeamData._level]).VitMax.toString(); // playerData.vitMax.toString(); // backData.physicalStrength.toString();
        }
        _ui.cur_level_label.text = playerData.teamData.level.toString();
        _ui.cur_max_level_label.text = playerData.teamData.level.toString();
        _ui.cur_vit_label.text = playerData.vitData.physicalStrength.toString();
        _ui.cur_max_vit_label.text = playerData.vitMax.toString(); // playerData.physicalStrength.toString();

        _ui.level_label.text = CLang.Get("player_team_level");
        _ui.max_level_label.text = CLang.Get("player_hero_max_level");
        _ui.vit_label.text = CLang.Get("player_hero_cur_vit");
        _ui.max_vit_label.text = CLang.Get("player_hero_max_vit");

        _updateSysOpenInfo();

        _ui.clip_titleEffect.visible = true;
        _ui.clip_titleEffect.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
        }

        this.addToPopupDialog();

        return true;
    }

    private function _updateSysOpenInfo():void
    {
        _ui.open_title_label.text = CLang.Get("player_lv_up_open_title");

        _ui.open_name_label.text = CLang.Get("common_none");
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var bundleEnbatleRecord:BundleEnable = _getCurrOpenSystem();
        var hasOpenNewSystem:Boolean;
        if(bundleEnbatleRecord)
        {
            var pMainViewTable:IDataTable = pDatabase.getTable( KOFTableConstants.MAIN_VIEW );
            if (pMainViewTable) {
                var pMainViewRecordList:Array = pMainViewTable.findByProperty("Tag", bundleEnbatleRecord.TagID);
                if (pMainViewRecordList) {
                    var mainViewRecord:MainView = pMainViewRecordList[0] as MainView;
                    if (mainViewRecord && mainViewRecord.Visible) {
                        _ui.open_title_label.text = CLang.Get("player_lv_up_open_title");
                        _ui.open_name_label.text = mainViewRecord.Name;
                        _ui.img_maxLevelBg.visible = false;
                        _ui.box_openInfo.visible = true;
                        _ui.img_sysIcon.url = _getSysIconUrl(mainViewRecord);
                        _ui.img_iconText.url = _getSysIconTextUrl(mainViewRecord);
                        _ui.clip_circleEffect.autoPlay = true;
                        _ui.txt_nextOpenLevel.text = "";
                        hasOpenNewSystem = true;
                    }
                }
            }
        }

        if(!hasOpenNewSystem)
        {
            var nextOpenSystem:BundleEnable = _getNextOpenSystem();
            if(nextOpenSystem)// 功能预告
            {
                _ui.img_maxLevelBg.visible = false;
                _ui.box_openInfo.visible = true;
                _ui.clip_circleEffect.autoPlay = true;
                _ui.open_title_label.text = "功能预告";
                pMainViewTable = pDatabase.getTable( KOFTableConstants.MAIN_VIEW );
                pMainViewRecordList = pMainViewTable.findByProperty("Tag", nextOpenSystem.TagID);
                if (pMainViewRecordList) {
                    mainViewRecord = pMainViewRecordList[0] as MainView;
                    if (mainViewRecord) {
                        _ui.open_name_label.text = mainViewRecord.Name;
                        _ui.img_sysIcon.url = _getSysIconUrl(mainViewRecord);
                        _ui.img_iconText.url = _getSysIconTextUrl(mainViewRecord);
                        var openInfo:String;
                        if(nextOpenSystem.TaskDoneID)
                        {
                            openInfo = nextOpenSystem.MinLevel + "级主线开启";
                        }
                        else
                        {
                            openInfo = nextOpenSystem.MinLevel + "级开启";
                        }

                        _ui.txt_nextOpenLevel.text = openInfo;
                    }
                }
            }
            else// 暂无
            {
                _ui.img_maxLevelBg.visible = true;
                _ui.box_openInfo.visible = false;
                _ui.clip_circleEffect.autoPlay = false;
                _ui.open_title_label.text = CLang.Get("player_lv_up_open_title");
//                _ui.open_name_label.text = CLang.Get("common_none");
                _ui.open_name_label.text = "敬请期待";
                _ui.txt_nextOpenLevel.text = "";
            }
        }
    }

    private function _onBundleStartHandler(e:CSystemBundleEvent):void
    {
        _updateSysOpenInfo();
    }

    private function _onChildBundleStartHandler(e:CChildSystemBundleEvent):void
    {
        _updateSysOpenInfo();
    }

    private function _onOk() : void {
        var playerData:CPlayerData = _data as CPlayerData;
        playerData.isLevelUp = false;
        close();


    }
    private function get _ui():TeamUpLVUI {
        return rootUI as TeamUpLVUI;
    }

    private function _getNextOpenSystem():BundleEnable
    {
        return ((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).getHandler(CSwitchingValidatorSeq)
            as CSwitchingValidatorSeq).queryComingShowItem();
    }

    private function _getCurrOpenSystem():BundleEnable
    {
//        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        if (pDatabase) {
            var pBundleEnableTable : IDataTable = pDatabase.getTable( KOFTableConstants.BUNDLE_ENABLE );
            if ( pBundleEnableTable ) {
                var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                var bundleEnableRecordList:Array = pBundleEnableTable.findByProperty("MinLevel", playerData.teamData.level);
                if (bundleEnableRecordList && bundleEnableRecordList.length) {
                    for each(var info:BundleEnable in bundleEnableRecordList)
                    {
                        if((system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(info.TagID))
                        {
                            return info;
                        }
                    }
                }
            }
        }

        return null;
    }

    private function _getSysIconUrl(mainView:MainView):String
    {
        if(mainView)
        {
            var arr:Array = mainView.Icon.split(".");
            var iconUrl:String = arr[arr.length-1] as String;
            return "icon/sysIcon/" + iconUrl + ".png";
        }

        return "";
    }

    private function _getSysIconTextUrl(mainView:MainView):String
    {
        if(mainView)
        {
            var arr:Array = mainView.IconText.split(".");
            var iconUrl:String = arr[arr.length-1] as String;
            return "icon/sysIcon/" + iconUrl + ".png";
        }

        return "";
    }

}
}

