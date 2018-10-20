//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/24.
 */
package kof.game.common.loading.movie {

import QFLib.Math.CMath;
import QFLib.Utils.FilterUtil;

import com.greensock.TweenLite;
import kof.game.common.uiMovie.CMovieCompoentBase;
import kof.game.common.uiMovie.CMovieAction;
import kof.game.common.view.CViewBase;

import morn.core.components.Component;

public class CMatchLoadingSceneDisplayMovieCompoent extends CMovieCompoentBase {

    private var _white:Component;
    private var _scene:Component;
    private var _title:Component;
    private var _sceneName:Component;

    public function CMatchLoadingSceneDisplayMovieCompoent(dispatcher:CViewBase, componentList:Vector.<Component>, endFunc:Function) {
        super (dispatcher, componentList, endFunc);

        _white = componentList[0];
        _scene = componentList[1];
        _title = componentList[2];
        _sceneName = componentList[3];



    }
    public override function dispose() : void {
        super.dispose();
    }

    protected override function _initial() : void {
        // start

        // action列表
        _actionList.push(new CMovieAction(_actionShowScene, 1));
    }

    private function _actionShowScene(action:CMovieAction) : void {
        var end:Function  = function () : void {
            _nextAction(action);
        };

        var smallTime:Number = action.duringTime/14;
        _white.visible = true;
        _white.scaleY = CMath.EPSILON;
        _white.alpha = 1.0;
        TweenLite.to(_white, smallTime*5, {scaleY:1, onComplete:function () : void {
            _scene.visible = true;
            TweenLite.to(_white, smallTime*4, {alpha:0, onComplete:function () : void {
                _title.visible = true;
                _title.filters = FilterUtil.ALL_WHITE_FILTER;
                _sceneName.visible = true;
                _sceneName.filters = FilterUtil.ALL_WHITE_FILTER;
                _scene.visible = true;

                var whiteEndFunc:Function = function () : void {
                    _title.filters = null;
                    _sceneName.filters = null;
                    delayCall(end, smallTime*3);

                };
                delayCall(whiteEndFunc, smallTime);
            }});
        }});

    }
}
}
