//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.view.instanceResult {


import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.player.config.CPlayerPath;
import kof.table.PlayerLines;
import kof.ui.instance.InstancePvpWinUI;
// pvp 回合结算, 巅峰赛
public class CInstancePvpWinView extends CRootView {

    public function CInstancePvpWinView() {
        super(InstancePvpWinUI, [], EInstanceWndResType.INSTANCE_PVP_ROUND_RESULT, false)
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _coundDownComponent = new CCountDownCompoent(this, null, 2000, _onCountDownEnd, CLang.Get("peak_count_down_prefix"), CLang.Get("peak_count_down_buffix"));

        this.setNoneData();
        invalidate();
    }
    protected override function _onHide() : void {
        _coundDownComponent.dispose();
        _coundDownComponent = null;
    }
    private function _onCountDownEnd() : void {
        this.close();
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _coundDownComponent.tick();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _ui.hero_icon_img.icon_image.url = "";
        _ui.hero_name_txt.text = "";

        // playerName:response.name, heroID:response.prosession
        var playerName:String = _data["playerName"];
        var heroID:int = _data["heroID"] as int;
        var result:int = _data["result"] as int; // 1: 胜负已分  2: 平局
        var table:IDataTable = ((uiCanvas as CAppSystem).stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.PLAYER_LINES);
        var playerLines:PlayerLines = table.findByPrimaryKey(heroID);
        if (playerLines) {
            _ui.hero_icon_img.icon_image.cacheAsBitmap = true;
            _ui.hero_icon_img.hero_icon_mask.cacheAsBitmap = true;
            _ui.hero_icon_img.icon_image.mask = _ui.hero_icon_img.hero_icon_mask;
            _ui.hero_icon_img.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroID);

            _ui.hero_icon_img.lv_txt.visible = false;
            _ui.hero_icon_img.star_list.visible = false;
//            _ui.hero_icon_img.star_bg_list.visible = false;
            _ui.hero_icon_img.level_frame_img.visible = false;
            _ui.hero_name_txt.text = playerLines.PlayerName;
        }

        if (result == 1) {
            _ui.win_box.visible = true;
            _ui.tie_box.visible = false;
        } else {
            // 2平局
            _ui.win_box.visible = false;
            _ui.tie_box.visible = true;
        }
        _ui.player_name_txt.text = playerName;

        this.addToDialog();

        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    private function get _ui() : InstancePvpWinUI {
        return rootUI as InstancePvpWinUI;
    }

    private var _coundDownComponent:CCountDownCompoent;
}
}
