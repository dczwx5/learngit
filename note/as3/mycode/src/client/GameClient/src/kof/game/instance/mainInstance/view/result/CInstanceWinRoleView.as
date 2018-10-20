//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result {

import flash.events.Event;

import kof.game.common.view.CChildView;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleUtil;
import kof.game.embattle.CEmbattleUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.ui.instance.InstanceWinUI;

import morn.core.components.Box;
import morn.core.components.Image;
import morn.core.events.UIEvent;


public class CInstanceWinRoleView extends CChildView {
    public function CInstanceWinRoleView() {
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        this.setNoneData();
        _loadHeroImgTotalCount = 0;
        _loadHeroImgCount = 0;
        role1.url = null;
        role2.url = null;
        role3.url = null;
    }

    protected override function _onHide() : void {

    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (!embattleSystem) { return true; }

        var heroIDlList:Array = (embattleSystem.getBean(CEmbattleUtil) as CEmbattleUtil).getHeroIDListInEmbattleByCurrentInstance();
        var newHeroIDList:Array = new Array();
        for (var index:int = 0; index < heroIDlList.length; index++) {
            if (heroIDlList[index] != null) {
                newHeroIDList[newHeroIDList.length] = heroIDlList[index];
            }
        }

        var heroID:int = 0;
        if (newHeroIDList && newHeroIDList.length > 0) {
            var roleX:Image = null;
            for (var i:int = 0; i < 3; i++) {
                heroID = newHeroIDList[i];
                if (heroID > 0) {
                    _loadHeroImgTotalCount++;
                    roleX = null;
                    if (i == 0) roleX = role1;
                    if (i == 1) roleX = role2;
                    if (i == 2) roleX = role3;
                    roleX.removeEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
                    roleX.addEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
                    if (i == 0) {
                        roleX.url = CPlayerPath.getUIHeroFacePath(heroID);
                        roleWhite.url = CPlayerPath.getUIHeroFacePath(heroID);
                    } else {
                        roleX.url = CPlayerPath.getUIHeroFacePath(heroID);
                    }
                }
            }
        }

        return true;
    }

    private var _loadHeroImgTotalCount:int = 0;
    private var _loadHeroImgCount:int = 0;
    private function _onHeroLoaded(e:Event) : void {
        var img:Image = e.currentTarget as Image;
        img.removeEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _loadHeroImgCount++;
    }
    public function isLoadResFinish() : Boolean {
        return _loadHeroImgCount > 0 && _loadHeroImgCount >= _loadHeroImgTotalCount;
    }
    
    private function get _mainUI() : InstanceWinUI {
        return rootUI as InstanceWinUI;
    }
    public function get _ui() : Box {
        return _mainUI.role_box;
    }
    public function get role1Box() : Box {
        return _mainUI.role_1_box;
    }
    // 纯白
    public function get roleWhiteBox() : Box {
        return _mainUI.role_11_box;
    }
    public function get role2Box() : Box {
        return _mainUI.role_2_box;
    }
    public function get role3Box() : Box {
        return _mainUI.role_3_box;
    }
    public function get role1() : Image {
        return _mainUI.hero_icon1_img;
    }
    public function get roleWhite() : Image {
        return _mainUI.hero_icon11_img;
    }
    public function get role2() : Image {
        return _mainUI.hero_icon2_img;
    }
    public function get role3() : Image {
        return _mainUI.hero_icon3_img;
    }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }
}
}
