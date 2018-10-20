//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/19.
 */
package kof.game.common.view {

import com.greensock.TweenLite;
import com.greensock.easing.Linear;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;

import kof.framework.CShowDialogTweenData;

import kof.framework.CViewHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CLobbySystem;
import morn.core.components.Dialog;

// 只有一级界面才使用此类
public class CTweenViewHandler extends CViewHandler{
    public static const EVENT_TWEENING:String = "TWEENING";
    public static const EVENT_TWEENING_FINISH:String = "TWEENING_FINISH";

    public function CTweenViewHandler(bLoadViewByDefault : Boolean = false) {
        super( bLoadViewByDefault );
    }

    public function showDialog(dialog : DisplayObject, closeOther : Boolean = false, onShowEnd:Function = null) : void {
        _dialog = dialog as Dialog;
        if (_showTweenData) {
            _showTweenDialog(closeOther, onShowEnd);
        } else {
            _showNormalView(closeOther, onShowEnd);
        }

    }
    private function _showNormalView(closeOther : Boolean = false, onShowEnd:Function = null) : void {
        if (_dialog) {
            uiCanvas.addDialog(_dialog, closeOther, _showTweenData);
            _dialog.dispatchEvent(new Event(EVENT_TWEENING_FINISH));
        }
        if (null != onShowEnd) {
            onShowEnd();
        }
    }
    private function _showTweenDialog(closeOther : Boolean = false, onShowEnd:Function = null) : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;

        var isTweening:Boolean = pSystemBundleCtx.getUserData(system as ISystemBundle, CBundleSystem.TWEENING, false);
        if (isTweening) {
            return ;
        }

        pSystemBundleCtx.setUserData(system as ISystemBundle, CBundleSystem.TWEENING, true);

        _dialog.dispatchEvent(new Event(EVENT_TWEENING));

        // 准备tween数据
        var startX:int, startY:int, targetX:int, targetY:int;
        var viewWidth:int = -1, viewHeight:int = -1;
        if ( _showTweenData.size ) {
            viewWidth = _showTweenData.size.x;
            viewHeight = _showTweenData.size.y;
        } else {
            viewWidth = _dialog.width;
            viewHeight = _dialog.height;
        }

        targetX = (system.stage.flashStage.stageWidth - viewWidth) * 0.5;
        targetY = (system.stage.flashStage.stageHeight - viewHeight) * 0.5;

        if ( _showTweenData.startX != -1 && _showTweenData.startY != -1 ) {
            startX = _showTweenData.startX;
            startY = _showTweenData.startY;
        } else {
            startX = (system.stage.flashStage.stageWidth) * 0.5;
            startY = (system.stage.flashStage.stageHeight) * 0.5;
        }

        _dialog.alpha = 0;

        uiCanvas.addDialog( _dialog, closeOther, _showTweenData );

        _dialog.x = startX;
        _dialog.y = startY;
        _dialog.scaleX = 0.01;
        _dialog.scaleY = 0.01;


        // tween start
        TweenLite.to( _dialog, 0.35, {alpha : 1.0,
            x : targetX, y : targetY, scaleX : 1, scaleY : 1,
            onUpdate : function () : void {
            }, onComplete : function () : void {
                if ( null != onShowEnd ) {
                    onShowEnd();
                }
                _dialog.alpha = 1.0;
                _dialog.dispatchEvent( new Event( EVENT_TWEENING_FINISH ) );
                pSystemBundleCtx.setUserData( system as ISystemBundle, CBundleSystem.TWEENING, false );
            }, ease : Linear.easeInOut
        } );
    }

    public function closeDialog(onCloseCallback:Function = null) : void {
        if (!_showTweenData) {
            _closeNormalView(onCloseCallback);
        } else {
            _closeTweenDialog(onCloseCallback);
        }
    }
    private function _closeNormalView(onCloseCallback:Function = null) : void {
        if (_dialog && _dialog.parent) {
            _dialog.close( Dialog.CLOSE);
            _dialog.dispatchEvent(new Event(EVENT_TWEENING_FINISH));
        }
        if (null != onCloseCallback) {
            onCloseCallback();
        }
    }
    private function _closeTweenDialog(onCloseCallback:Function = null) : void {
        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;

        var isTweening:Boolean = pSystemBundleCtx.getUserData(system as ISystemBundle, CBundleSystem.TWEENING, false);
        if (isTweening) {
            return ;
        }

        pSystemBundleCtx.setUserData(system as ISystemBundle, CBundleSystem.TWEENING, true);

        _dialog.dispatchEvent(new Event(EVENT_TWEENING));

        var targetX:int, targetY:int;
        if (_showTweenData.startX != -1 && _showTweenData.startY != -1) {
            targetX = _showTweenData.startX;
            targetY = _showTweenData.startY;
        } else {
            targetX = (system.stage.flashStage.stageWidth) * 0.5;
            targetY = (system.stage.flashStage.stageHeight) * 0.5;
        }

        _dialog.alpha = 1.0;
        TweenLite.to(_dialog, 0.35, {alpha : 0, scaleX:0.01, scaleY:0.01, x:targetX, y:targetY,
            onUpdate:function() : void {
            }, onComplete:function ():void {
                if (_dialog.parent) {
                    _dialog.close( Dialog.CLOSE);
                    _dialog.dispatchEvent(new Event(EVENT_TWEENING_FINISH));
                }
                if (null != onCloseCallback) {
                    onCloseCallback();
                }
                _dialog.alpha = 1.0;
                pSystemBundleCtx.setUserData(system as ISystemBundle, CBundleSystem.TWEENING, false);
            }, ease : Linear.easeInOut
        });
    }

    // KOFSysTags : 用于绑定某个系统, 和定位坐标
    // 如果传入坐标, 则不使用sysTag自动寻找坐标
    public function setTweenData(sysTag:String, size:Point = null, startPos:Point = null) : void {
        var iconPoint:Point;
        if (startPos) {
            iconPoint = startPos;
        } else {
            var pLobbySystem:CLobbySystem = system.stage.getSystem(CLobbySystem) as CLobbySystem;
            iconPoint = pLobbySystem.getIconGlobalPointCenter(sysTag);
        }
        if (!_showTweenData) {
            _showTweenData = new CShowDialogTweenData(iconPoint);
        } else {
            if (iconPoint) {
                _showTweenData.startX = iconPoint.x;
                _showTweenData.startY = iconPoint.y;
            }
            _showTweenData.size = size;
        }
    }

    protected var _showTweenData:CShowDialogTweenData;
    protected var _dialog:Dialog;
}
}
