//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/29.
 */
package kof.game.instance.mainInstance.view.result.winMovie {

import com.greensock.TweenLite;

import flash.events.IEventDispatcher;
import flash.geom.Point;

import kof.framework.CAppSystem;

import kof.game.audio.IAudio;
import kof.game.common.CLang;

import kof.game.common.uiMovie.CMovieCompoentBase;

import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CProgressBarMovie;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.data.CInstancePassRewardData;
import kof.game.instance.mainInstance.view.result.CInstanceWinMovieProcess;
import kof.game.instance.mainInstance.view.result.CInstanceWinView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.imp_common.RewardItemUI;
import kof.ui.imp_common.RewardListUI;

import morn.core.components.Component;
import morn.core.components.FrameClip;
import morn.core.components.FrameClip;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.components.ProgressBar;
import morn.core.handlers.Handler;

public class CInstanceWinShowDescEffectMovieCompoent extends CMovieCompoentBase {
    private var role1:Component;
    private var role2:Component;
    private var role3:Component;
    private var sayBox:Component;
    private var descUI:Component;

    private var condEffect1:Component;
    private var condEffect2:Component;
    private var condEffect3:Component;
    private var starEffect1:Component;
    private var starEffect2:Component;
    private var starEffect3:Component;
    private var condItem1:Component;
    private var condItem2:Component;
    private var condItem3:Component;
    private var starBox:Component;
    private var expTitle:Component;
    private var expLine:Component;
    private var expLv:Component;
    private var expBar:Component;
    private var expAdd:Component;
    private var expUp:Component;
    private var rewardTitle:Component;
    private var rewardLine:Component;
    private var rewardList:RewardListUI;
    private var rewardListMask:Component;
    private var rewardEffect1:Component;
    private var rewardEffect2:Component;
    private var rewardEffect3:Component;
    private var rewardEffect4:Component;
    private var rewardEffect5:Component;
    private var rewardEffect6:Component;

    private var expBaseBar:Component;
    private var expWhiteBar:Component;

    private var firstPassImg:Component;
    private var firstPassMv:FrameClip;

    private var rwd_img_1:Component;
    private var rwd_count_img_1:Component;
    private var rwd_img_2:Component;
    private var rwd_count_img_2:Component;
    private var rwd_img_3:Component;
    private var rwd_count_img_3:Component;
    private var _rootView:CInstanceWinMovieProcess;

    public function CInstanceWinShowDescEffectMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function, rootView:CInstanceWinMovieProcess) {
        super (dispatcher, componentList, endFunc);

        _rootView = rootView;

        role1 = componentList[0];
        role2 = componentList[1];
        role3 = componentList[2];
        sayBox = componentList[3];
        descUI = componentList[4];

        condEffect1 = componentList[6];
        condEffect2 = componentList[7];
        condEffect3 = componentList[8];
        starEffect1 = componentList[9];
        starEffect2 = componentList[10];
        starEffect3 = componentList[11];
        condItem1 = componentList[12];
        condItem2 = componentList[13];
        condItem3 = componentList[14];
        starBox = componentList[15];
        expTitle = componentList[16];
        expLine = componentList[17];
        expLv = componentList[18];
        expBar = componentList[19];
        expAdd = componentList[20];
        expUp = componentList[21];
        rewardTitle = componentList[22];
        rewardLine = componentList[23];
        rewardList = componentList[24] as RewardListUI;
        rewardListMask = componentList[25];
        rewardEffect1 = componentList[26];
        rewardEffect2 = componentList[27];
        rewardEffect3 = componentList[28];
        rewardEffect4 = componentList[29];
        rewardEffect5 = componentList[30];
        rewardEffect6 = componentList[31];
        expBaseBar = componentList[32];
        expWhiteBar = componentList[33];
        firstPassImg = componentList[34];
        firstPassMv = componentList[35] as FrameClip;

        rwd_img_1 = componentList[36];
        rwd_count_img_1 = componentList[37];
        rwd_img_2 = componentList[38];
        rwd_count_img_2 = componentList[39];
        rwd_img_3 = componentList[40];
        rwd_count_img_3 = componentList[41];
    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function _initial() : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        _actionList.push(new CMovieAction(_actionMove, 3));
    }
    private function _actionMove(action:CMovieAction) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        var win : CInstanceWinView = _dispatcher as CInstanceWinView;
        var pInstanceSystem : CInstanceSystem = win.system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        var needShowStarEffect : Boolean = !(EInstanceType.isMainExtra( pInstanceSystem.instanceType ));

        var targetCount : int = 0;
        var count : int = 0;
        var isFinish : Boolean = false;
        var checkFunc : Function = function () : void {
            count++;
            if ( count == targetCount && isFinish == false ) {
                isFinish = true;
                _nextAction( action );
            }
        };
        var showExpEnd : Function = function () : void {
            checkFunc();
            _showReward( action, checkFunc );
        };

        if ( needShowStarEffect ) {
            // 显示星星
            var star : int = 0;
            var rewardData : CInstancePassRewardData = win.data.instanceDataManager.instanceData.lastInstancePassReward;
            if ( rewardData && win.data.instanceDataManager.instanceData.lastInstancePassReward.isServerData ) {
                star = rewardData.star;
                targetCount = 3 * 2; // star * 2;
            }
            if ( targetCount > 0 ) {
                _showCond1( action, checkFunc );
                delayCall( _showCond2, action.duringTime * 0.1, action, checkFunc, star > 1, rewardData.isStarPassByIndex( 1 ) );
                delayCall( _showCond3, action.duringTime * 0.2, action, checkFunc, star > 2, rewardData.isStarPassByIndex( 2 ) );
            }
            targetCount += 2;
            delayCall( _showExp, action.duringTime * 0.06, action, showExpEnd );
        } else {
            // 不显示星星
            targetCount = 2;
            _showExp(action, showExpEnd);
        }
    }

    // condtion
    private function _showCond1(action:CMovieAction, finishFunc:Function, isShowStar:Boolean = true, isShowCond:Boolean = true) : void {
        _showCondB(0, condEffect1 as FrameClip, starEffect1 as FrameClip, action, finishFunc, isShowStar, isShowCond);

    }
    private function _showCond2(action:CMovieAction, finishFunc:Function, isShowStar:Boolean = true, isShowCond:Boolean = true) : void {
        _showCondB(1, condEffect2 as FrameClip, starEffect2 as FrameClip, action, finishFunc, isShowStar, isShowCond);

    }
    private function _showCond3(action:CMovieAction, finishFunc:Function, isShowStar:Boolean = true, isShowCond:Boolean = true) : void {
        _showCondB(2, condEffect3 as FrameClip, starEffect3 as FrameClip, action, finishFunc, isShowStar, isShowCond);
    }
    private function _showCondB(idx:int, condEffect:FrameClip, starEffect:FrameClip, action:CMovieAction, finishFunc:Function, isShowStar:Boolean = true, isShowCond:Boolean = true) : void {
        var win:CInstanceWinView = _dispatcher as CInstanceWinView;
        var func:Function = function () : void {
            condEffect.visible = false;
            win._descView.setCondition(idx);
            finishFunc();
        };

        if (isShowCond) {
            condEffect.visible = true;
        } else {
            condEffect.visible = false;
        }
        condEffect.playFromTo(null, null, new Handler(func));

        var showStarFunc:Function = function () : void {
            var starFinish:Function = function () : void {
                starEffect.visible = false;
                win._descView.setStar(idx);
                finishFunc();
            };

            if (isShowStar) {
                starEffect.visible = true;
                var audio:IAudio = (viewBase.uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
                audio.playAudioByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_STAR_AUDIO_NAME), 1, 1);
            } else {
                starEffect.visible = false;
            }
            starEffect.playFromTo(null, null, new Handler(starFinish));
        };
        delayCall(showStarFunc, action.duringTime*0.04);
    }

    private function _showExp(action:CMovieAction, finishFunc:Function) : void {

        expTitle.x = 1550;
        expTitle.visible = true;
        tweenToX(expTitle, action.duringTime*0.09, _basePosList[16].x);

        expLine.x = 1550;
        expLine.visible = true;
        tweenToX(expLine, action.duringTime*0.07, _basePosList[17].x);

        if (rwd_img_1.visible) {
            rwd_img_1.alpha = 1;
            rwd_count_img_1.alpha = 1;
        }
        if (rwd_img_2.visible) {
            rwd_img_2.alpha = 1;
            rwd_count_img_2.alpha = 1;
        }
        if (rwd_img_3.visible) {
            rwd_img_3.alpha = 1;
            rwd_count_img_3.alpha = 1;
        }

        rwd_img_1.x = 1550;
        rwd_img_1.visible = true;
        tweenToX(rwd_img_1, action.duringTime*0.07, _basePosList[36].x);
        rwd_count_img_1.x = 1650;
        rwd_count_img_1.visible = true;
        tweenToX(rwd_count_img_1, action.duringTime*0.07, _basePosList[37].x);

        rwd_img_2.x = 1750;
        rwd_img_2.visible = true;
        tweenToX(rwd_img_2, action.duringTime*0.07, _basePosList[38].x);
        rwd_count_img_2.x = 1850;
        rwd_count_img_2.visible = true;
        tweenToX(rwd_count_img_2, action.duringTime*0.07, _basePosList[39].x);

        rwd_img_3.x = 1950;
        rwd_img_3.visible = true;
        tweenToX(rwd_img_3, action.duringTime*0.07, _basePosList[40].x, 0, finishFunc);
        rwd_count_img_3.x = 2050;
        rwd_count_img_3.visible = true;
        tweenToX(rwd_count_img_3, action.duringTime*0.07, _basePosList[41].x, 0, finishFunc);

    }

    // exp -> 改为显示战队经验等奖励
    /** private function _showExp(action:CMovieAction, finishFunc:Function) : void {
        expTitle.x = 1550;
        expTitle.visible = true;
        tweenToX(expTitle, action.duringTime*0.09, _basePosList[16].x);

        expLine.x = 1550;
        expLine.visible = true;
        tweenToX(expLine, action.duringTime*0.07, _basePosList[17].x);

        // content
        var delayTime:Number = action.duringTime*0.05;
        var subX:int = 1550 - expLv.x;
        expLv.x = _basePosList[18].x + subX;
        expLv.visible = true;
        tweenToX(expLv, action.duringTime*0.09, _basePosList[18].x, delayTime);


        expBar.x = _basePosList[19].x + subX;
        expBar.visible = true;
        (expBar as ProgressBar).bar.visible = false;

        tweenToX(expBar, action.duringTime*0.09, _basePosList[19].x, delayTime);

        expAdd.x = _basePosList[20].x + subX;
        expAdd.visible = true;
        tweenToX(expAdd, action.duringTime*0.09, _basePosList[20].x, delayTime);

        expUp.x = _basePosList[21].x + subX;
        expUp.visible = true;
        tweenToX(expUp, action.duringTime*0.09, _basePosList[21].x, delayTime, finishFunc);


        expBaseBar.x = _basePosList[32].x + subX;
        expBaseBar.visible = true;
        tweenToX(expBaseBar, action.duringTime*0.09, _basePosList[32].x, delayTime);

        expWhiteBar.x = _basePosList[33].x + subX;
        expWhiteBar.visible = true;
        tweenToX(expWhiteBar, action.duringTime*0.09, _basePosList[33].x, delayTime, function () : void {
            _showExpMovie(action, finishFunc);
        });

    }
    private function _showExpMovie(action:CMovieAction, finishFunc:Function) : void {
        var pPlayerSystem:CPlayerSystem = (viewBase.system).stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pPlayerData:CPlayerData = pPlayerSystem.playerData;
        var lastLv:int = pPlayerData.lastLevel;
        var lv:int = pPlayerData.teamData.level;
        var valueLast:Number = pPlayerData.lastExp/pPlayerData.lastTotalExp;
        var valueNew:Number = pPlayerData.teamData.exp/pPlayerData.nextLevelExpCost;

        var levelUpCallback:Function = function () : void {
            (expLv as Label).text = CLang.Get("common_level2", {v1:lv});
        };
        var playTime:Number = 1.0;
        new CProgressBarMovie(expBar as ProgressBar, expWhiteBar as ProgressBar, expBaseBar as ProgressBar,
                valueLast, valueNew, lv > lastLv, playTime, levelUpCallback);
    }*/



//    private function _showExpMovieB(action:CMovieAction, finishFunc:Function) : void {
//        var bar:Image = (expWhiteBar as ProgressBar).bar;
//        var pPlayerSystem:CPlayerSystem = (viewBase.system).stage.getSystem(CPlayerSystem) as CPlayerSystem;
//        var pPlayerData:CPlayerData = pPlayerSystem.playerData;
//        var lastLv:int = pPlayerData.lastLevel;
//        var lv:int = pPlayerData.teamData.level;
//        var allWidth:int = (expBar.width);
//        var barWidth:int = (expBar as ProgressBar).bar.width;
//        if (lv > lastLv) {
//            bar.visible = true;
//            TweenLite.to(bar, action.duringTime * 0.09, {width:allWidth, onComplete : function () : void {
//                // 再从0到value
//                // 设置visible
//                expBaseBar.visible = true; // 文本要显示
//                (expBaseBar as ProgressBar).bar.visible = false;// 这里不需要显示原本的进度表了
//                _updateProgressBarVisibleByValue(expWhiteBar as ProgressBar, (expBar as ProgressBar).value);
//                (expLv as Label).text = CLang.Get("common_level2", {v1:lv});
//                if (bar.visible) {
//                    bar.width = 6;
//                    TweenLite.to(bar, action.duringTime * 0.09, {width:barWidth}); // step 1
//                }
//            }});
//        } else {
//            _updateProgressBarVisibleByValue(expBaseBar as ProgressBar, (expBaseBar as ProgressBar).value);
//            _updateProgressBarVisibleByValue(expWhiteBar as ProgressBar, (expBar as ProgressBar).value);
//            TweenLite.to(bar, action.duringTime * 0.09, {width:barWidth});
//        }
//    }
//    private function _updateProgressBarVisibleByValue(progressBar:ProgressBar, value:Number) : void {
//        if (progressBar.sizeGrid) {
//            var grid:Array = progressBar.sizeGrid.split(",");
//            var left:Number = grid[0];
//            var right:Number = grid[2];
//            var max:Number = progressBar.width - left - right;
//            var sw:Number = max * value;
//            progressBar.bar.visible = left + right + sw > left + right;
//        }
//    }


    private function _showReward(action:CMovieAction, finishFunc:Function) : void {

        // rewardTitle
        rewardTitle.x = 1550;
        rewardTitle.visible = true;
        tweenToX(rewardTitle, action.duringTime*0.11, _basePosList[22].x, -1, _showRewardEffect, [action, finishFunc]);

        rewardLine.x = 1550;
        rewardLine.visible = true;
        tweenToX(rewardLine, action.duringTime*0.07, _basePosList[23].x);
    }

    private var _showRewardCount:int = 0;
    private function _showRewardEffect(action:CMovieAction, finishFunc:Function) : void {
        if (_rootView.isForceStop) {
            forceFinish();
            return
        }

        rewardListMask.setPosition(rewardList.x, rewardList.y);
        rewardListMask.width = 1;

        var count:int = 0;
        var win:CInstanceWinView = _dispatcher as CInstanceWinView;
        var repeatX:int = win._descView._rewardView.repeatX;


        var clipFinish:Function = function (rClip:FrameClip) : void {
            rClip.visible = false;
            rClip.stop();
            count++;
            if (count == repeatX) {
                finishFunc();
            }
        };
        var playRewardEffectFunc:Function = function (index:int) : void {
            _showRewardCount++;
            var rewardItem:RewardItemUI = rewardList.item_list.getCell(index) as RewardItemUI;
            var tox:int = rewardItem.icon_image.x;
            var toy:int = rewardItem.icon_image.y;
            var pos:Point = new Point(tox,toy);
            pos = rewardItem.localToGlobal(pos);
            pos = rewardList.parent.globalToLocal(pos);

            var clip:FrameClip = list[index] as FrameClip;
            clip.setPosition(pos.x + clip.width/2-6, pos.y + clip.height/2-3);
            clip.visible = true;
            clip.playFromTo(null, null, new Handler(clipFinish, [clip]));
            rewardListMask.width = pos.x + rewardItem.width + 2 - rewardListMask.x;
            var audio:IAudio = (viewBase.uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
            audio.playAudioByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_ITEM_AUDIO_NAME), 1);

            if (_showRewardCount == repeatX) {
                if (firstPassImg.visible) {
                    // firstPassImg 如果是首通, visible为true, alpha开始设为0
                    firstPassMv.visible = true;
                    firstPassMv.playFromTo(null, null, new Handler(function () : void {
                        firstPassMv.visible = false;
                        firstPassImg.alpha = 1;
                    }));
                }
            }
        };

        rewardList.visible = true;
        var list:Array = [rewardEffect1, rewardEffect2, rewardEffect3, rewardEffect4, rewardEffect5, rewardEffect6];

        for (var i:int = 0; i < repeatX; i++) {
            delayCall(playRewardEffectFunc, action.duringTime*0.09*i, i);
        }
    }
}
}
