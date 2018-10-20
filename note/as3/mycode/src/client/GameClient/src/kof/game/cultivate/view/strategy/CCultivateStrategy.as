//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/15.
 */
package kof.game.cultivate.view.strategy {

import kof.game.common.CLang;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateBuffData;
import kof.game.cultivate.data.cultivate.CCultivateData;
import kof.game.common.view.CRootView;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.cultivate.imp.CCultivateUtils;
import kof.game.player.data.CPlayerData;
import kof.ui.master.cultivate.CultivateSListNewUI;
import kof.ui.master.cultivate.CultivateStrategyUI;
import morn.core.components.Component;
import morn.core.components.FrameClip;

import morn.core.handlers.Handler;

// 策略
public class CCultivateStrategy extends CRootView {
    public function CCultivateStrategy() {
        var childList:Array = null;
        super(CultivateStrategyUI, null, childList, false);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }
    protected override function _onCreate() : void {
        _ui.embattle_btn.label = CLang.Get("common_ok");
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.reselect_btn.clickHandler = new Handler(_onReSelect);
        _ui.list.selectedIndex = -1;
        _ui.list.selectHandler = new Handler(_onSelectBuff);
        _ui.list.renderHandler = new Handler(_onRenderItem);
        _ui.embattle_btn.clickHandler = new Handler(_onOk);

        _ui.buff_effect_fly_start_clip_1.visible = _ui.buff_effect_fly_start_clip_1.visible = _ui.buff_effect_fly_start_clip_1.visible = false;
        _ui.buff_effect_fly_start_clip_1.stop();
        _ui.buff_effect_fly_start_clip_2.stop();
        _ui.buff_effect_fly_start_clip_3.stop();
        _selectIndex = -1;
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.reselect_btn.clickHandler = null;
        _ui.list.selectHandler = null;
        _ui.list.renderHandler = null;
        _ui.embattle_btn.clickHandler = null;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _ui.list.dataSource = _climpData.cultivateData.otherData.selectBuffList.list;

        var randomBuffCountMax:int = _playerData.vipHelper.climpRandomBuffCount;
        var leftCount:int = randomBuffCountMax - _climpData.cultivateData.otherData.rerandBuffNum;
        if (leftCount < 0) {
            leftCount = 0;
        }

        _ui.left_txt.visible = false;
//        _ui.left_txt.text = CLang.Get("cultivate_random_buff_count_left", {v1:leftCount, v2:randomBuffCountMax});
        _ui.reselect_btn.btnLabel.text = CLang.Get("cultivate_random_buff_count_left", {v1:leftCount, v2:randomBuffCountMax});

        if (-1 == _ui.list.selectedIndex) {
            _ui.list.selectedIndex = 0;
        } else {
            _onSelectBuff(_ui.list.selectedIndex);
        }

        this.addToPopupDialog();
        return true;
    }

    public function set visible(v:Boolean) : void {
        _ui.visible = v;
    }

    private function _onReSelect() : void {
        this.sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.STRATEGY_CLICK_RESELECT));
    }
    private function _onOk() : void {
        if (_selectIndex >= 0) {
            var movie:FrameClip = _ui["buff_effect_fly_start_clip_" + (_selectIndex+1)];
            if (movie) {
                movie.visible = true;
                movie.playFromTo(null, null, new Handler(function () : void {
                    movie.visible = false;
                    if (!isShowState) {
                        return ; // 中途界面被关了
                    }
                    sendEvent(new CViewEvent(CViewEvent.UI_EVENT, ECultivateViewEventType.STRATEGY_CLICK_BUFF, _selectIndex));
                    close();
                }));
            }
        }
    }

    private function _onSelectBuff(idx:int) : void {
        if (idx == -1) return ;

        _selectIndex = idx;

        if (_ui.list.dataSource == null) return ;

        if (idx >= _ui.list.dataSource.length) {
            return ;
        }

        var buffData:CCultivateBuffData = _ui.list.dataSource[idx] as CCultivateBuffData;
        if (!buffData) return ;
        _ui.buff_name.text = buffData.name;
        _ui.buff_desc.text = CLang.Get("cultivate_buff_desc_simple", {v1:buffData.desc, v2:buffData.percent});
    }
    private function _onRenderItem(com:Component, idx:int) : void {
        var item:CultivateSListNewUI = com as CultivateSListNewUI;
        if (!item) return ;

        if (!item.dataSource) {
            item.visible = false;
        }
        item.visible = true;

        var buffData:CCultivateBuffData = item.dataSource as CCultivateBuffData;
        CCultivateUtils.buffViewRenderSimple(buffData, item);
    }

    public function get selectIndex() : int {
        return _selectIndex;
    }
    private var _selectIndex:int = -1;

    [Inline]
    public function get _ui() : CultivateStrategyUI {
        return (rootUI as CultivateStrategyUI);
    }
    [Inline]
    private function get _climpData() : CClimpData {
        return super._data[0] as CClimpData;
    }
    [Inline]
    private function get _cultivateData() : CCultivateData {
        return _climpData.cultivateData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
