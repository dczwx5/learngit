//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/18.
 */
package kof.game.common.loading.movie {

import QFLib.Utils.FilterUtil;
import com.greensock.TweenLite;
import kof.game.common.uiMovie.CMovieCompoentBase;
import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;

public class CMatchLoadingSelectFinishMovieCompoent extends CMovieCompoentBase {

    private var _blackSort:Component;
    private var _whiteSort:Component;
    private var _sort:Component;
    private var _left:Component;
    private var _right:Component;
    private var _vs:Component;

    private var _hero11:Component;
    private var _hero12:Component;
    private var _hero13:Component;
    private var _hero21:Component;
    private var _hero22:Component;
    private var _hero23:Component;

    private var _num11:Component;
    private var _num12:Component;
    private var _num13:Component;
    private var _num21:Component;
    private var _num22:Component;
    private var _num23:Component;
    public function CMatchLoadingSelectFinishMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);

        _blackSort = componentList[0];
        _whiteSort = componentList[1];
        _sort = componentList[2];
        _left = componentList[3];
        _right = componentList[4];
        _vs = componentList[5];

        _hero11 = componentList[6];
        _hero12 = componentList[7];
        _hero13 = componentList[8];
        _hero21 = componentList[9];
        _hero22 = componentList[10];
        _hero23 = componentList[11];

        _num11 = componentList[12];
        _num12 = componentList[13];
        _num13 = componentList[14];
        _num21 = componentList[15];
        _num22 = componentList[16];
        _num23 = componentList[17];

    }
    public override function dispose() : void {
        super.dispose();
    }

    protected override function _initial() : void {
        // action列表
        _actionList.push(new CMovieAction(_actionLightVsNSort, 0.1));
        _actionList.push(new CMovieAction(_actionLightHeroNTrans, 1));
    }

    private function _actionLightVsNSort(action:CMovieAction) : void {
        // sort select
        _sort.visible = false;
        // vs 黑
        _vs.filters = FilterUtil.ALL_BLACK_FILTER;
        var sortFunc1:Function = function() : void {
            _blackSort.visible = false;
            _whiteSort.visible = true;
            _vs.filters = FilterUtil.ALL_WHITE_FILTER;

            var sortFunc2:Function = function() : void {
                _whiteSort.visible = false;
                _sort.visible = true;
                _blackSort.visible = true;
                _vs.filters = null;
                _nextAction(action);
            };
            delayCall(sortFunc2, action.duringTime/2);
        };
        delayCall(sortFunc1, action.duringTime/2);
    }
    private function _actionLightHeroNTrans(action:CMovieAction) : void {
        var smallTime:Number = action.duringTime/10;
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function  = function () : void {
            if (count == 5 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };

        var i:int = 0;
        var com:Component = null;
        // no.x hide
        for (i = 12; i <= 17; i++) {
            com = _imageList[i];
            com.visible = false;
        }
        for (i = 6; i <= 11; i++) {
            com = _imageList[i];
            com.filters = FilterUtil.ALL_BLACK_FILTER;
        }

        var heroBlackFinish:Function = function () : void {
            for (i = 6; i <= 11; i++) {
                com = _imageList[i];
                com.filters = FilterUtil.ALL_WHITE_FILTER;
            }
            var heroWhiteFinish:Function = function () : void {
                for (i = 6; i <= 11; i++) {
                    com = _imageList[i];
                    com.filters = null;
                }
                // 格斗家整体移动
                TweenLite.to(_left, smallTime*2, {x:_basePosList[3].x + 220, onComplete:function () : void {
                    TweenLite.to(_left, smallTime*3, {x:_basePosList[3].x - 450, onComplete:function () : void {
                        TweenLite.to(_left, smallTime, {x:_basePosList[3].x-61, onComplete:function () : void {
                            count++;
                            checkFunc();
                        }});
                    }});
                }});
                TweenLite.to(_right, smallTime*2, {x:_basePosList[4].x - 220, onComplete:function () : void {
                    TweenLite.to(_right, smallTime*3, {x:_basePosList[4].x + 450, onComplete:function () : void {
                        TweenLite.to(_right, smallTime, {x:_basePosList[4].x+61, onComplete:function () : void {
                            count++;
                            checkFunc();
                        }});
                    }});
                }});
            };
            delayCall(heroWhiteFinish, smallTime);
        };
        delayCall(heroBlackFinish, smallTime);
        // vs. sort . scale
        TweenLite.to(_sort, smallTime*3, {scaleY:0.00001, onComplete:function () : void {
            count++;
            _sort.visible = false;
            checkFunc();
        }});
        TweenLite.to(_blackSort, smallTime*3, {scaleY:0.00001, onComplete:function () : void {
            count++;
            _blackSort.visible = false;
            checkFunc();
        }});
        TweenLite.to(_vs, smallTime*3, {scaleY:0.00001, onComplete:function () : void {
            count++;
            _vs.visible = false;
            checkFunc();
        }});
    }

}
}

