//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/21.
 */
package kof.game.common.loading.movie {

import QFLib.Utils.FilterUtil;
import com.greensock.TweenLite;
import flash.geom.Point;
import kof.game.common.uiMovie.CMovieCompoentBase;
import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Clip;
import morn.core.components.Component;

public class CMatchLoadingSelectMovieCompoent extends CMovieCompoentBase {
    private var _selectBox:Component;
    private var _selectClip:Component;

    private var _hero1:Component;
    private var _hero2:Component;
    private var _hero3:Component;
    private var _num1:Component;
    private var _num2:Component;
    private var _num3:Component;


    public function CMatchLoadingSelectMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);
        _selectBox = componentList[0];
        _selectClip = componentList[1];

        _hero1 = componentList[2];// 2
        _hero2 = componentList[3];// 3
        _hero3 = componentList[4];// 1

        _num1 = componentList[5];
        _num2 = componentList[6];
        _num3 = componentList[7];

        _heroBasePos = new Vector.<Point>(3);
        // 从之前到这里时，格子的顺序
        _heroBasePos[0] = _basePosList[2];// _basePosList[4]; // 上面
        _heroBasePos[1] = _basePosList[3];// _basePosList[2]; // 中间
        _heroBasePos[2] = _basePosList[4];// _basePosList[3]; // 下面
        
    }
    public override function dispose() : void {
        super.dispose();

    }

    protected override function _initial() : void {
        this._actionList.push(new CMovieAction(_actionChange12Pos, 0.2));
        this._actionList.push(new CMovieAction(_actionSelect1, 0.7));
        this._actionList.push(new CMovieAction(_actionStop1, 0.3));
        this._actionList.push(new CMovieAction(_actionSelect2, 0.7));
    }

    private function _actionChange12Pos(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };
        TweenLite.to(_hero1, action.duringTime, { y : _heroBasePos[2].y, onComplete : function () : void {
            count++;
            checkFunc();
        }});
        TweenLite.to(_hero2, action.duringTime, { y : _heroBasePos[1].y, onComplete : function () : void {
            count++;
            checkFunc();
        }});
    }

    private function _actionSelect1(action:CMovieAction) : void {
        var smallTime:Number = action.duringTime/10;
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 4 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };
        // 黑掉1
        _hero1.filters = FilterUtil.ALL_BLACK_FILTER;
        var hero1BlackEnd:Function = function () : void {
            // 变白
            _hero1.filters = FilterUtil.ALL_WHITE_FILTER;
            var hero1WhiteEnd:Function = function () : void {
                // 人物移到上面
                _hero1.filters = null;
                _hero1.y = _heroBasePos[0].y - 600;
                TweenLite.to(_hero1, smallTime*3, { y : _heroBasePos[0].y, onComplete : function () : void {
                    _num1.visible = true;
                    count++;
                    checkFunc();
                }});
            };
            delayCall(hero1WhiteEnd, smallTime);

            // select Box movie
            var selectBoxMovieFinish:Function = function () : void {
                count++;
                checkFunc();
            };
            selectBoxMovieFunctionB(_selectBox, _selectClip, 1, smallTime, selectBoxMovieFinish);

        };
        delayCall(hero1BlackEnd, smallTime*2);

        // 另两个人物, 下移
        TweenLite.to(_hero2, smallTime*3, { y : _heroBasePos[2].y, onComplete : function () : void {
            count++;
            checkFunc();
        }});
        TweenLite.to(_hero3, smallTime*3, { y : _heroBasePos[1].y, onComplete : function () : void {
            count++;
            checkFunc();
        }});
    }

        private function selectBoxMovieFunctionB(box:Component, selectClip:Component, clipIndex:int, smallTime:Number, callback:Function) : void {
            // 缩小select
            TweenLite.to(box, smallTime*3, {scaleY:0.00001, onComplete:function () : void {
                // select change to 2
                (selectClip as Clip).index = clipIndex;
                // 还原
                TweenLite.to(box, smallTime*3, {scaleY:0.9, onComplete:function () : void {
                    // 变黑
                    box.filters = FilterUtil.ALL_BLACK_FILTER;
                    var leftSelectBoxBlackFunc:Function = function () : void {
                        // 变白
                        box.filters = FilterUtil.ALL_WHITE_FILTER;
                        var leftSelectBoxWhiteFunc : Function = function () : void {
                            // 还原
                            box.filters = null;
                            callback();
                        };
                        delayCall(leftSelectBoxWhiteFunc, smallTime);
                    };
                    delayCall(leftSelectBoxBlackFunc, smallTime);

                }});
            }});
        }

    private function _actionStop1(action:CMovieAction) : void {
        _normalAction(action);
    }

    private function _actionSelect2(action:CMovieAction) : void {
        var smallTime:Number = action.duringTime/10;
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 3 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };
        // 黑掉1
        _hero2.filters = FilterUtil.ALL_BLACK_FILTER;
        var hero2BlackEnd:Function = function () : void {
            // 变白
            _hero2.filters = FilterUtil.ALL_WHITE_FILTER;
            var hero2WhiteEnd:Function = function () : void {
                // 人物移到上面
                _hero2.filters = null;
                TweenLite.to(_hero2, smallTime*2, { y : _heroBasePos[1].y, onComplete : function () : void {
                    _num2.visible = true;
                    count++;
                    checkFunc();
                }});
                // 3移下去
                TweenLite.to(_hero3, smallTime*2, { y : _heroBasePos[2].y, onComplete : function () : void {
                    _num3.visible = true;
                    count++;
                    checkFunc();
                }});
            };
            delayCall(hero2WhiteEnd, smallTime);

            // select Box movie
            TweenLite.to(_selectBox, smallTime*3, {scaleY:0.00001, onComplete:function () : void {
                count++;
                checkFunc();
            }});
        };
        delayCall(hero2BlackEnd, smallTime);
    }


    private var _heroBasePos:Vector.<Point>; // 0第一格, 1第二格, 2第三格
}
}

