//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/30.
 */
package kof.game.playerTeam.view.team_new {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.game.bundle.CBundleSystem;

import kof.game.bundle.ISystemBundleContext;

import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CPlayerVisitData;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.title.CTitleSystem;
import kof.game.title.data.CTitleData;
import kof.game.title.event.CTitleEvent;
import kof.game.title.titlePath.CTitlePath;
import kof.table.TitleConfig;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.master.player_team.PlayerTeamBaseInfoUI;
import kof.ui.master.player_team.PlayerTeamUI;

import morn.core.handlers.Handler;


public class CTeamBaseView extends CChildView {
    public function CTeamBaseView() {
    }
    protected override function _onCreate() : void {
        _baseui.level_label_title.text = CLang.Get("player_level") + "：";
        _baseui.vip_title.text = CLang.Get("team_vip_title");
        _baseui.guide_label.text = CLang.Get("common_club") + "：";
        _baseui.sign_label.text = CLang.Get("player_intro_title");
        _baseui.hero_collection_title.text = CLang.Get("team_hero_collection_title");

        _baseui.guide_name_label.text = CLang.Get("player_team_guide_default_name");
        _baseui.sign_input_label.text = CLang.Get("player_team_default_sign");
        _strDefaultSign = _baseui.sign_input_label.text;
        _sDefaultClubName = _baseui.guide_name_label.text;

        _baseui.role_model_mask_icon_img.cacheAsBitmap = true;
        _baseui.role_model_icon_img.cacheAsBitmap = true;
        _baseui.role_model_icon_img.mask = _baseui.role_model_mask_icon_img;
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _baseui.change_name_btn.clickHandler = new Handler(_onChangeName);
        _baseui.change_icon_btn.clickHandler = new Handler(_onChangeIcon);
        _baseui.change_model_btn.clickHandler = new Handler(_onChangeModel);
        _baseui.change_model_btn.visible = false;

        flashStage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);

        _baseui.property_battle_value_num.addEventListener(Event.CHANGE, _onBattleValueChange);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _baseui.change_name_btn.clickHandler = null;
        _baseui.change_icon_btn.clickHandler = null;
        _baseui.change_model_btn.clickHandler = null;
        _baseui.change_model_btn.visible = false;
        flashStage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);

        _baseui.property_battle_value_num.removeEventListener(Event.CHANGE, _onBattleValueChange);
        var clip:CCharacterFrameClip = _baseui.box_role.getChildAt(0) as CCharacterFrameClip;
        CHeroSpriteUtil.setSkin( system, clip, null, false);


    }

    private var _selectRect:Rectangle;
    private var _mouseLocalPos:Point;
    private function _onMouseMove(e:MouseEvent) : void {
        if (!isSelf) return ;

        if (!_selectRect) {
            _selectRect = new Rectangle(_baseui.selelct_img.x, _baseui.selelct_img.y, _baseui.selelct_img.width, _baseui.selelct_img.height);
        }
        if (_mouseLocalPos == null) {
            _mouseLocalPos = new Point();
        }

        _mouseLocalPos.setTo(e.stageX, e.stageY);
        _mouseLocalPos = _baseui.globalToLocal(_mouseLocalPos);

        var isInAran:Boolean = _selectRect.contains(_mouseLocalPos.x, _mouseLocalPos.y);
        _baseui.change_model_btn.visible = isInAran;

    }

    private var _isSelf:Boolean;
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_ui.tab.selectedIndex != 0) return true;

        _isSelf = _visitPlayerData.isSelf;

        if (_isSelf) {
            _updateSelfView();
        } else {
            _updateOtherView();
        }

        return true;
    }

    private function _updateSelfView() : void {
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        if (!playerData) return ;

        _baseui.change_icon_btn.visible = _baseui.change_model_btn.visible = _baseui.change_name_btn.visible = true;

        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        pPlayerSystem.platform.signatureRender.renderSignature(pPlayerSystem.playerData.vipData.vipLv, pPlayerSystem.platform.data, _baseui.signature, pPlayerSystem.playerData.teamData.name);

        _baseui.level_label.text = playerData.teamData.level.toString();

        _baseui.clipVIP.index =
                        Math.floor(playerData.vipData.vipLv);

        if (playerData.guideData.clubName && playerData.guideData.clubName.length > 0) {
            _baseui.guide_name_label.text = playerData.guideData.clubName;
        } else {
            _baseui.guide_name_label.text = _sDefaultClubName;
        }
        _baseui.property_battle_value_num.num = playerData.teamData.battleValue;

        _baseui.sign_input_label.text = CLang.Get("player_team_default_sign");
        if (playerData.teamData.sign && playerData.teamData.sign.length > 0) {
            _baseui.sign_input_label.text = playerData.teamData.sign;
        }

        var heroCount:int = playerData.heroList.list.length;
        _baseui.hero_collection.text = heroCount.toString();

        // 形象
        var heroData:CPlayerHeroData = playerData.heroList.createHero(playerData.teamData.prototypeID);
        var clip:CCharacterFrameClip = _baseui.box_role.getChildAt(0) as CCharacterFrameClip;
        CHeroSpriteUtil.setSkin( system, clip, heroData, false);

        _baseui.role_model_icon_img.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);

        // 头像
        var iconRender:Function = CItemUtil.getBigItemRenderByHeroDataFunc(system);
        _baseui.role_icon_view.dataSource = playerData.teamData.useHeadID;
        iconRender(_baseui.role_icon_view, 0);

        _baseui.sign_input_label.editable = true;

        // 称号
        var pTitleSystem:CTitleSystem = system.stage.getSystem(CTitleSystem) as CTitleSystem;
        var titleData:CTitleData = pTitleSystem.data;
        if (titleData.curTitleItem) {
            _baseui.title_img.url = CTitlePath.getTitleUrl(titleData.curTitleItem.itemRecord.image);
            _baseui.title_none_txt.visible = false;
        } else {
            _baseui.title_img.url = null;
            _baseui.title_none_txt.visible = true;
        }

        const pCtx:ISystemBundleContext = pTitleSystem.ctx;
        var changeTitleHandler:Handler = new Handler(function () : void {
            pCtx.setUserData( pTitleSystem, CBundleSystem.VISITOR_DATA, null );
            pCtx.setUserData( pTitleSystem, CBundleSystem.ACTIVATED, true );
        });
        _baseui.change_title_btn.clickHandler = changeTitleHandler;
        _baseui.change_title_btn_old.clickHandler = changeTitleHandler;
        _baseui.look_title_btn.clickHandler = changeTitleHandler;
        _baseui.look_title_btn.visible = false;
        _baseui.change_title_btn.visible = titleData.curTitleItem != null;
        _baseui.change_title_btn_old.visible = !_baseui.change_title_btn.visible;

    }
    private function _updateOtherView() : void {
        if (!_visitPlayerData) return ;

        _baseui.change_icon_btn.visible = _baseui.change_model_btn.visible = _baseui.change_name_btn.visible = false;

        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        pPlayerSystem.platform.signatureRender.renderSignature(_visitPlayerData.vipLv, _visitPlayerData.platformData, _baseui.signature, _visitPlayerData.name);


        _baseui.level_label.text = _visitPlayerData.level.toString();

        _baseui.clipVIP.index = Math.floor(_visitPlayerData.vipLv);

        if (_visitPlayerData.clubName && _visitPlayerData.clubName.length > 0) {
            _baseui.guide_name_label.text = _visitPlayerData.clubName;
        } else {
            _baseui.guide_name_label.text = _sDefaultClubName;
        }
        _baseui.property_battle_value_num.num = _visitPlayerData.battleValue;

        _baseui.sign_input_label.text = CLang.Get("player_team_default_sign");
        if (_visitPlayerData.sign && _visitPlayerData.sign.length > 0) {
            _baseui.sign_input_label.text = _visitPlayerData.sign;
        }

        var heroCount:int = _visitPlayerData.heroCount;
        _baseui.hero_collection.text = heroCount.toString();

        // 形象
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroData:CPlayerHeroData = playerData.heroList.createHero(_visitPlayerData.prototypeID);
        var clip:CCharacterFrameClip = _baseui.box_role.getChildAt(0) as CCharacterFrameClip;
        CHeroSpriteUtil.setSkin( system, clip, heroData, false);
        _baseui.role_model_icon_img.url = CPlayerPath.getPeakUIHeroFacePath(heroData.prototypeID);

        // 头像
        var iconRender:Function = CItemUtil.getBigItemRenderByHeroDataFunc(system);
        _baseui.role_icon_view.dataSource = _visitPlayerData.useHeadID;
        iconRender(_baseui.role_icon_view, 0);

        _baseui.sign_input_label.editable = false;

        // 称号
        var pTitleSystem:CTitleSystem = system.stage.getSystem(CTitleSystem) as CTitleSystem;
        var titleData:CTitleData = pTitleSystem.data;
        if (_visitPlayerData.curTitleID > 0) {
            var titleConfigRecord:TitleConfig = titleData.itemTable.findByPrimaryKey(_visitPlayerData.curTitleID) as TitleConfig;
            _baseui.title_img.url = CTitlePath.getTitleUrl(titleConfigRecord.image);
            _baseui.title_none_txt.visible = false;
        } else {
            _baseui.title_img.url = null;
            _baseui.title_none_txt.visible = true;
        }

        const pCtx:ISystemBundleContext = pTitleSystem.ctx;
        var changeTitleHandler:Handler = new Handler(function () : void {
            var friendDataHandler:Function = function (e:CTitleEvent) : void {
                pTitleSystem.removeEventListener(CTitleEvent.FRIEND_DATA_EVENT, friendDataHandler);
                var titleData:CTitleData = e.data as CTitleData;
                pCtx.setUserData( pTitleSystem, CBundleSystem.VISITOR_DATA, [_visitPlayerData, titleData] );
                pCtx.setUserData( pTitleSystem, CBundleSystem.ACTIVATED, true );
            };
            pTitleSystem.addEventListener(CTitleEvent.FRIEND_DATA_EVENT, friendDataHandler);
            pTitleSystem.netHandler.sendGetOtherData(_visitPlayerData.id);
        });
        _baseui.change_title_btn.clickHandler = changeTitleHandler;
        _baseui.change_title_btn_old.clickHandler = changeTitleHandler;
        _baseui.look_title_btn.clickHandler = changeTitleHandler;
        _baseui.change_title_btn.visible = _baseui.change_title_btn_old.visible = false;
        _baseui.look_title_btn.visible = true;
    }

    private function _onChangeName() : void {
        if (_visitPlayerData.isSelf == false) return ;

        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_CHANGE_NAME_CLICK));
    }
    private function _onChangeIcon() : void {
        if (_visitPlayerData.isSelf == false) return ;
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_CHANGE_ICON_CLICK));
    }
    private function _onChangeModel() : void {
        if (_visitPlayerData.isSelf == false) return ;
        this.rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EPlayerViewEventType.EVENT_CHANGE_ROLE_MODEL_CLICK));
    }

    private function _onBattleValueChange(e:Event) : void {
        _baseui.battle_fight_box.centerX = _baseui.battle_fight_box.centerX;
    }

    [Inline]
    private function get _ui() : PlayerTeamUI {
        return rootUI as PlayerTeamUI;
    }
    private function get _baseui() : PlayerTeamBaseInfoUI {
        return _ui.base_view;
    }

    [Inline]
    private function get _visitPlayerData() : CPlayerVisitData {
        return super._data as CPlayerVisitData;
    }

    public function get isDefaultSign() : Boolean {
        return _baseui.sign_input_label.text == _strDefaultSign;
    }
    public function get isSelf() : Boolean {
        return _isSelf;
    }

    private var _strDefaultSign:String;
    private var _sDefaultClubName:String;
}
}
