//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/24.
 */
package kof.game.common.loading.movie {

import com.greensock.TweenLite;
import kof.game.common.uiMovie.CMovieCompoentBase;
import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;

public class CMatchLoadingEndMovieCompoent extends CMovieCompoentBase {
    private var _leftHeroBox:Component;
    private var _rightHeroBox:Component;

    private var _white:Component;
    private var _top:Component;
    private var _bottom:Component;
    private var _parent:Component;

    public function CMatchLoadingEndMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);
        _leftHeroBox = componentList[0];
        _rightHeroBox = componentList[1];

        _white = componentList[2];
        _top = componentList[3];
        _bottom = componentList[4];
        _parent = componentList[5];

    }
    public override function dispose() : void {
        super.dispose();

    }

    protected override function _initial() : void {
        this._actionList.push(new CMovieAction(_actionMoveHero, 0.6));
        this._actionList.push(new CMovieAction(_actionHide, 0.7));
    }

    private function _actionMoveHero(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };
        TweenLite.to(_leftHeroBox, action.duringTime, { x : _basePosList[0].x - 400, onComplete : function () : void {
            count++;
            checkFunc();
        }});
        TweenLite.to(_rightHeroBox, action.duringTime, { x : _basePosList[1].x + 400, onComplete : function () : void {
            count++;
            checkFunc();
        }});
    }

    private function _actionHide(action:CMovieAction) : void {
        var count:int = 0;
        var isFinish:Boolean = false;
        var checkFunc:Function = function () : void {
            if (count == 2 && isFinish == false) {
                isFinish = true;
                _nextAction(action);
            }
        };
        var smallTime:Number = action.duringTime/8;
        _white.visible = true;
        _white.alpha = 0;
        TweenLite.to(_white, smallTime*4, {alpha : 0.8, onComplete : function () : void {
            _top.height = 1;
            _bottom.height = 1;
            _top.visible = true;
            _bottom.visible = true;
            var subHeight:int = _parent.height/2+100;
            TweenLite.to(_top, smallTime*4, {height : subHeight, onComplete : function () : void {
                count++;
                checkFunc();
            }});
            TweenLite.to(_bottom, smallTime*4, {height : subHeight, onComplete : function () : void {
                count++;
                checkFunc();
            }});
        }});
    }
    }
}

