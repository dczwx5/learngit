//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/2.
 */
package kof.game.peakpk.view {

import QFLib.Foundation.free;

import kof.framework.CViewHandler;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroListItemRender;
import kof.game.common.tips.ITips;
import kof.game.im.data.CIMFriendsData;
import kof.game.im.data.CIMFriendsData;
import kof.game.item.view.part.CRewardItemListViewV;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.peakpk.CPeakpkSystem;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.peakpk.peakPKTipsUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CPeakpkPlayerTips extends CViewHandler implements ITips {

    public function CPeakpkPlayerTips() {
        super(false);

    }
    public override function get viewClass() : Array {
        return [peakPKTipsUI];
    }
    public function addTips(box:Component, args:Array = null) : void {
        _sourceItem = box;
        this.loadAssetsByView(viewClass, _showDisplay);
    }
    protected function _showDisplay():void {
        if (onInitializeView()) {
            updateData();
            App.tip.addChild(_ui);
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg("Initialized \"" + viewClass + "\" failed by requesting display shown.");
        }
    }
    override protected function onInitializeView():Boolean {
        if (!super.onInitializeView())
            return false;

        if (!_isInitial) {
            _isInitial = true;
            _ui = new peakPKTipsUI();
            _heroListItemRender = new CHeroListItemRender();
            _ui.hero_list.renderHandler = new Handler(_heroListItemRender.renderRoleItem03UI);
        }

        return _isInitial;
    }

    override protected virtual function updateData():void {
        super.updateData();

         var friendData:CIMFriendsData = _sourceItem.dataSource as CIMFriendsData; // _data[0] as CIMFriendsData;
        if(friendData){
            _ui.title_txt.text = friendData.name;
            _ui.player_lv_txt.text = CLang.Get("common_level_en", {v1:friendData.level});
            if (friendData.clubName && friendData.clubName.length > 0) {
                _ui.guild_txt.text = CLang.Get("common_club") + "：" + friendData.clubName;
            } else {
                _ui.guild_txt.text = CLang.Get("common_club") + "：" + CLang.Get("common_none");
            }
            _ui.peak_lv_txt.text = CLang.Get("common_peak_level_title");

            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var heroListData:Array = new Array(friendData.fairPeakHeroIds.length);
            for (var i:int = 0; i < friendData.fairPeakHeroIds.length; i++) {
                heroListData[i] = playerData.heroList.createHero(friendData.fairPeakHeroIds[i]);
            }
            _ui.hero_list.dataSource = heroListData;

            var pkData:CPeakpkData = (system.stage.getSystem(CPeakpkSystem) as CPeakpkSystem).data;
            var findScoreLevelRecord:PeakScoreLevel = CPeakGameData.findScoreLevelRecordByScore(pkData.scoreLevelDataList, friendData.fairPeakScore);
             CPeakGameLevelItemUtil.setValueBig(_ui.level_item, findScoreLevelRecord.levelId, findScoreLevelRecord.subLevelId, findScoreLevelRecord.levelName);
         }
    }

    public function hideTips():void{
        _ui.remove();
    }

    private var _ui:peakPKTipsUI;
    private var _sourceItem:Component;
    private var _isInitial:Boolean;
    private var _heroListItemRender:CHeroListItemRender;


}
}
