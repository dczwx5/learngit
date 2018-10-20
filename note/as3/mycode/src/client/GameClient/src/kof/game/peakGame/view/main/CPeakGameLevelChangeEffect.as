//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/3.
 */
package kof.game.peakGame.view.main {

import com.greensock.TweenLite;

import flash.display.Sprite;

import flash.geom.Point;

import kof.game.common.CDelayCall;
import kof.game.common.view.CChildView;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.view.CPeakGameLevelItemUtil;
import kof.game.player.data.CPlayerData;
import kof.table.PeakScoreLevel;
import kof.ui.master.PeakGame.PeakGameUI;

import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.handlers.Handler;


public class CPeakGameLevelChangeEffect extends CChildView {
    public function CPeakGameLevelChangeEffect() {
    }
    protected override function _onCreate() : void {
        // can not call super._onCreate in this class
        _hideEffect();

        _baseLevelItemUpPos = new Point(_ui.level_item_up.x, _ui.level_item_up.y);
    }

    private function _hideEffect() : void {
        _ui.level_up_eff_1.visible = _ui.level_up_eff_2.visible = _ui.level_up_eff_3.visible = _ui.level_up_eff_4_bz.visible = _ui.level_up_eff_5_sg.visible = false;
        _ui.star_down_eff_1.visible = _ui.star_down_eff_2.visible = _ui.star_down_eff_3.visible = false;
        _ui.star_up_eff_1.visible = _ui.star_up_eff_2.visible = _ui.star_up_eff_3.visible = false;
        _ui.level_item_up_box.visible = false;
        _ui.level_down_eff.visible = false;

        _ui.level_up_eff_1.autoPlay = _ui.level_up_eff_2.autoPlay = _ui.level_up_eff_3.autoPlay = _ui.level_up_eff_4_bz.autoPlay = _ui.level_up_eff_5_sg.autoPlay = false;
        _ui.star_down_eff_1.autoPlay = _ui.star_down_eff_2.autoPlay = _ui.star_down_eff_3.autoPlay = false;
        _ui.star_up_eff_1.autoPlay = _ui.star_up_eff_2.autoPlay = _ui.star_up_eff_3.autoPlay = false;
        _ui.level_down_eff.autoPlay = false;

        _ui.level_up_eff_1.stop(); _ui.level_up_eff_2.stop(); _ui.level_up_eff_3.stop(); _ui.level_up_eff_4_bz.stop(); _ui.level_up_eff_5_sg.stop();
        _ui.star_down_eff_1.stop(); _ui.star_down_eff_2.stop(); _ui.star_down_eff_3.stop();
        _ui.star_up_eff_1.stop(); _ui.star_up_eff_2.stop(); _ui.star_up_eff_3.stop();
        _ui.level_down_eff.stop();
    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        TweenLite.killTweensOf( _ui.level_item_up, true );

        _hideEffect();
        var pLevelRecord:PeakScoreLevel = _peakGameData.peakLevelRecord;
        CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, pLevelRecord.levelId, pLevelRecord.subLevelId, pLevelRecord.levelName);
        _ui.level_item.visible = true;

    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        if (!_peakGameData) return true;

        if (_peakGameData.isServerData == false) {
            return true;
        }

        return true;
    }

    public function playLevelChangeEffect(data:Array) : void {
        var isLevelUp:Boolean = data[0];
        var oldRecord:PeakScoreLevel = data[1];
        var newRecord:PeakScoreLevel = data[2];
        var processHandler:Function;
        if (isLevelUp) {
            // 升星
            if (oldRecord.levelId == newRecord.levelId) {
                // 只升星
                processHandler = _starUpHandler;
            } else {
                // 有升段
                processHandler = _levelUpHandler;
            }
        } else {
            if (oldRecord.levelId == newRecord.levelId) {
                // 只降星
                processHandler = _starDownHandler;
            } else {
                // 有降段
                processHandler = _levelDownHandler;
            }
        }
        processHandler(isLevelUp, oldRecord, newRecord);
    }
    private function _starUpHandler(isLevelUp:Boolean, oldRecord:PeakScoreLevel, newRecord:PeakScoreLevel) : void {
        _ui.level_item.visible = true;
        CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, oldRecord.levelId, oldRecord.subLevelId, oldRecord.levelName);

        delayCall(0.2, function () : void {
            var playEffect:FrameClip = _ui["star_up_eff_" + newRecord.subLevelId];
            playEffect.visible = true;
            playEffect.playFromTo(null, null, new Handler(function () : void {
                playEffect.visible = false;
            }));
            delayCall(0.2, function () : void {
                CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, newRecord.levelId, newRecord.subLevelId, newRecord.levelName);
            });
        });
    }
    private function _levelUpHandler(isLevelUp:Boolean, oldRecord:PeakScoreLevel, newRecord:PeakScoreLevel) : void {
        // levelitemup 初始scale是1.8,y坐标是93, 缩到1倍后，和levelItem重合的坐标是375,
        _ui.level_item.visible = false;
        _ui.level_item_up_box.visible = true;
        _ui.level_item_up.scale = 1;
        _ui.level_item_up.x = 34-32;
        _ui.level_item_up.y = 292;
        CPeakGameLevelItemUtil.setValueBig(_ui.level_item_up, oldRecord.levelId, oldRecord.subLevelId, oldRecord.levelName);
        _ui.level_item_up.name_txt.visible = false;
        // 上移
        TweenLite.to(_ui.level_item_up, 0.3, {x:-41-32, y:18, scale:1.8, onComplete:function () : void {
            _ui.level_up_eff_1.visible = true;
            // 播大爆炸
            _ui.level_up_eff_1.playFromTo(null, null, new Handler(function () : void {
                _ui.level_up_eff_1.visible = false;
                // 新段位
                CPeakGameLevelItemUtil.setValueBig(_ui.level_item_up, newRecord.levelId, newRecord.subLevelId, newRecord.levelName);
                _ui.level_item_up.name_txt.visible = false;
                _ui.level_item_up.star1.visible = false;
                _ui.level_up_eff_2.visible = true;
                // 星星出现特效
                _ui.level_up_eff_2.playFromTo(null, null, new Handler(function () : void {
                    _ui.level_up_eff_2.visible = false;
                    _ui.level_item_up.star1.visible = true;
                    // 过一会爆炸
                    delayCall(0.3, function () : void {
                        _ui.level_up_eff_3.visible = true;
                        // 爆炸
                        _ui.level_up_eff_3.playFromTo(null, null, new Handler(function () : void {
                            _ui.level_up_eff_3.visible = false;
                            // 缩小
                            TweenLite.to(_ui.level_item_up, 0.2, {x:34-32, scale:1, onComplete:function () : void {
                                // 下落
                                TweenLite.to(_ui.level_item_up, 0.3, {y:291, onComplete:function () : void {
                                    // 下落后爆炸和扫光
                                    _ui.level_up_eff_4_bz.visible = true;
                                    _ui.level_up_eff_4_bz.playFromTo(null, null, new Handler(function () : void {
                                        _ui.level_up_eff_4_bz.visible = false;
                                        CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, newRecord.levelId, newRecord.subLevelId, newRecord.levelName);
                                        _ui.level_item.visible = true;
                                        _ui.level_item_up_box.visible = false;
                                    }));
                                    _ui.level_up_eff_5_sg.visible = true;
                                    _ui.level_up_eff_5_sg.playFromTo(null, null, new Handler(function () : void {
                                        _ui.level_up_eff_5_sg.visible = false;
                                    }));
                                }});
                            }});
                        }));
                    });
                }));

            }));
        }});
    }
    private function _levelDownHandler(isLevelUp:Boolean, oldRecord:PeakScoreLevel, newRecord:PeakScoreLevel) : void {
        _starDownHandler(isLevelUp, oldRecord, newRecord);
    }
    private function _starDownHandler(isLevelUp:Boolean, oldRecord:PeakScoreLevel, newRecord:PeakScoreLevel) : void {
        _ui.level_item.visible = true;
        CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, oldRecord.levelId, oldRecord.subLevelId, oldRecord.levelName);

        new CDelayCall(function () : void {
            var star:Image = _ui.level_item["star" + oldRecord.subLevelId] as Image;
            star.visible = false;
            var playEffect:FrameClip = _ui["star_down_eff_" + oldRecord.subLevelId];
            playEffect.visible = true;
            playEffect.playFromTo(null, null, new Handler(function () : void {
                playEffect.visible = false;

                _ui.level_down_eff.visible = true;
                _ui.level_down_eff.playFromTo(null, null, new Handler(function () : void {
                    _ui.level_down_eff.visible = false;
                }));
                CPeakGameLevelItemUtil.setValueBigII(_ui.level_item, newRecord.levelId, newRecord.subLevelId, newRecord.levelName);

            }));
        }, 0.2);
    }

    [Inline]
    private function get _ui() : PeakGameUI {
        return rootUI as PeakGameUI;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return super._data[0] as CPeakGameData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }

    private var _baseLevelItemUpPos:Point;
}
}
