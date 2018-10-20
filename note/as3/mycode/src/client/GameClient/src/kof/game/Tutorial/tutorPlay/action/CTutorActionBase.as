//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation.CMap;
import QFLib.Foundation.CWeakRef;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import kof.framework.CAppSystem;
import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorManager;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.enum.ETutorActionType;
import kof.game.Tutorial.tutorPlay.CTutorPlay;
import kof.game.Tutorial.tutorPlay.CTutorUtil;
import kof.game.Tutorial.view.CTutorArrowView;
import kof.game.Tutorial.view.CTutorDialogView;
import kof.game.Tutorial.view.CTutorMask;
import kof.game.Tutorial.view.CTutorView;
import kof.game.audio.IAudio;
import kof.game.chat.CChatInputViewHandler;
import kof.game.chat.CChatSystem;
import kof.game.common.CTest;
import kof.game.common.view.CTweenViewHandler;
import kof.game.core.CECSLoop;
import kof.game.instance.CInstanceSystem;
import kof.game.loading.CSceneLoadingViewHandler;
import kof.game.scene.CSceneSystem;
import kof.ui.CUISystem;

import morn.core.components.Component;
import morn.core.components.Dialog;

public class CTutorActionBase implements IUpdatable, IDisposable {

    public function CTutorActionBase(actionInfo:CTutorActionInfo, system:CAppSystem) {
        _info = actionInfo;
        _infoID = _info.ID;
        _system = system;
        _isCondFinish = false;
        if (!_playedAudioMap) {
            _playedAudioMap = new CMap();
        }
    }

    private function get _tutorView() : CTutorView {
        return _tutorPlay.tutorView;
    }
    private function get _tutorArrow() : CTutorArrowView {
        return _tutorPlay.tutorArrow;
    }
    private function get _tutorDialogView() : CTutorDialogView {
        return _tutorPlay.dialogView;
    }

    public virtual function dispose() : void { // 结束
        if (_info) {
            CTest.log("tutor dispose : ID : " + _info.ID);
        }

        if (_tutorSystem) {
            _tutorSystem.uiHandler.hideDialogTutor();
            if (_tutorView) {
                _tutorView.visible = false;
            }
            if (_tutorArrow) {
                _tutorArrow.clearHoleTarget();
                _tutorArrow.visible = false;
            }
        }

        if (_pMaskView) {
            _pMaskView.drawHole(null, _info);
        }
        _pMaskView = null;

        if (_pDialog) {
            _pDialog.removeEventListener(CTweenViewHandler.EVENT_TWEENING_FINISH, _onTweening);
            _pDialog.removeEventListener(CTweenViewHandler.EVENT_TWEENING, _onTweening);
        }

        _holeTarget = null;
        _info = null;
        if (App.stage) {
            App.stage.removeEventListener(MouseEvent.CLICK, _onStageClick);
            App.stage.removeEventListener(MouseEvent.CLICK, _onPlayerControl);
            App.stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onPlayerControl);
            App.stage.removeEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
            if (_system) {
                var pChatSystem:CChatSystem = (_system.stage.getSystem(CChatSystem) as CChatSystem);
                if (pChatSystem) {
                    var pChatView:CChatInputViewHandler = pChatSystem.getBean(CChatInputViewHandler) as CChatInputViewHandler;
                    if (pChatView && pChatView.txtInput) {
                        pChatView.txtInput.removeEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
                    }
                }
            }
        }
        _system = null;

    }

    public virtual function start() : void { // 开始
        CTest.log("tutor start : ID : " + _info.ID);
        _autoPassStartTime = _startTime = getTimer();
        _iFirstShowArrowTime = -1;
        _isFirst = true;
        _isRunning = true;

        CTutorUtil.GetComponent(_system, _info.maskHoleTargetID, _onGetComponent);

        if (App.stage) {
            if (_info.isAutoPass) {
                App.stage.addEventListener(MouseEvent.CLICK, _onPlayerControl);
                var pChatSystem:CChatSystem = (_system.stage.getSystem(CChatSystem) as CChatSystem);
                if (pChatSystem) {
                    var pChatView:CChatInputViewHandler = pChatSystem.getBean(CChatInputViewHandler) as CChatInputViewHandler;
                    if (pChatView && pChatView.txtInput) {
                        pChatView.txtInput.addEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
                    }
                }
            }
            if (_info.autoPassBySpace) {
                App.stage.addEventListener(KeyboardEvent.KEY_DOWN, _onPlayerControl);
                App.stage.addEventListener(KeyboardEvent.KEY_UP, _onPlayerControl);
            }
        }
        if (App.stage && _info.hasMask) {
            App.stage.removeEventListener(MouseEvent.CLICK, _onStageClick);
            App.stage.addEventListener(MouseEvent.CLICK, _onStageClick);
        }
    }

    private function getComponentRoot(comp:Component) : Dialog {
        var pParent:DisplayObject = comp.parent;
        while (pParent) {
            if (pParent is Dialog) {
                return pParent as Dialog;
            }
            pParent = pParent.parent;
        }
        return null;
    }

    private function _onGetComponent(comp : Component) : void {
        if (_isRunning) {
            startByUIComponent(comp);
            _pDialog = getComponentRoot(comp);
            if (_pDialog) {
                _pDialog.removeEventListener(CTweenViewHandler.EVENT_TWEENING_FINISH, _onTweening);
                _pDialog.removeEventListener(CTweenViewHandler.EVENT_TWEENING, _onTweening);
                _pDialog.addEventListener(CTweenViewHandler.EVENT_TWEENING_FINISH, _onTweening);
                _pDialog.addEventListener(CTweenViewHandler.EVENT_TWEENING, _onTweening);
            }
        } else {
            CTest.log("---------------------tutor " + infoID + " startByUIComponent fail");
        }
    }

    virtual protected function startByUIComponent( comp : Component ) : void {
        void(comp);
    }


    private function _onStageClick(e:MouseEvent) : void {
        var tempTarget:Component = holeTarget;
        if (tempTarget) {
            if (e.currentTarget != tempTarget) {
                CTest.log("点了其他地方");
                var pArrowView:CTutorArrowView = _tutorArrow;
                if (pArrowView) {
                    pArrowView.showBigEffect();
                }
            }
        }
    }
    private function _onPlayerControl(e:Event) : void {
//        trace("__________________________________________________ every control");
        _autoPassStartTime = getTimer();
        if (_forceStop || !_isRunning || _tutorPlay.isForceHide) {
            return ;
        }

        var pInstanceSystem:CInstanceSystem = _tutorSystem.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var isInMainCity:Boolean = false;
        if (pInstanceSystem) {
            isInMainCity = pInstanceSystem.isMainCity;
        }
        if (!isInMainCity) {
            return ;
        }

        if ( e is KeyboardEvent ) {
            var pKeyboardEvt:KeyboardEvent = e as KeyboardEvent;
            if (pKeyboardEvt.type == KeyboardEvent.KEY_UP && pKeyboardEvt.keyCode == Keyboard.SPACE &&
                    (_info && _info.actionID == ETutorActionType.GUIDE_CLICK || _info.actionID == ETutorActionType.SYSTEM_BUNDLE_GUIDE_CLICK))
            {
                if (_info.actionID == ETutorActionType.GUIDE_CLICK) {
                    _isPassBySpaceTriggered = true;
                } else if (_info.actionID == ETutorActionType.SYSTEM_BUNDLE_GUIDE_CLICK) {
                    _isPassBySpaceTriggered = true;
                }
                e.stopImmediatePropagation();
                return ;
            }
        }
    }

    public function stop() : void {  // 中途停止
        _isRunning = false;
        _forceStop = true;
    }

    public virtual function update(delta:Number) : void { // 更新
        var pTutorView:CTutorView = _tutorView;
        var pArrowView:CTutorArrowView = _tutorArrow;
        var pDialogView:CTutorDialogView = _tutorDialogView;

        if ( pTutorView && pArrowView ) {
            var holeTargetVisible:Boolean = !_isViewTweening && this.holeTarget && this.holeTarget.stage && isCompVisible( this.holeTarget );

            if (holeTargetVisible) {
                // 蒙板
                pTutorView.maskView.visible = _info.hasMask;
                pTutorView.visible = _info.hasMask;
                if (_info.hasMask) {
                    if ( !_pMaskView ) {
                        _pMaskView = pTutorView.maskView;
                    }
                    if ( _pMaskView ) {
                        if ( this.holeTarget && this.holeTarget.stage ) {
                            // draw hole.
                            _pMaskView.drawHole( this.holeTarget, _info, this.maskAlpha );
                        } else {
                            _pMaskView.drawHole( null, _info, this.maskAlpha );
                        }
                    }
                }
            } else {
                pTutorView.maskView.visible = false;
                pTutorView.visible = false;
            }

            if (_info.isForceShowMask) {
                pTutorView.forceMask.visible = true;
                pTutorView.visible = true; // 如果有forceMask的话. view要设置为可见
            } else {
                pTutorView.forceMask.visible = false;
            }


            // 箭头
            var isArrowVisible:Boolean = false;
            if ( _info.uiType == 1 ) { // 箭头指引
                if ( holeTargetVisible) {
                    isArrowVisible = true;
                } else {
                }
            } else if ( _info.uiType == 2 ) { // 小框提示
                // TODO:
                if ( holeTargetVisible ) {
                    isArrowVisible = true;
                } else {
                    _tutorSystem.uiHandler.hideDialogTutor();
                }
            }

            if (isArrowVisible) {
                var curTime:int = getTimer();
                if (_iFirstShowArrowTime == -1) {
                    _iFirstShowArrowTime = curTime;
                }
                if (curTime - _iFirstShowArrowTime > 500) {
                    pArrowView.visible = isArrowVisible;
                    pArrowView.arrowTargetTo( this.holeTarget, _info, _isFirst );
                    _isFirst = false;
                } else {
                    pArrowView.visible = false;
                    pArrowView.arrowTargetTo( null, _info, false );
                }
            } else {
                pArrowView.visible = false;
                pArrowView.arrowTargetTo( null, _info, false );

            }

            if (!pArrowView.isTweening() && pArrowView.visible && _info.uiType == 2) {
                if (pDialogView) {
                    pDialogView.visible = true;
                    pDialogView.updatePosition(_info, pArrowView.arrowX, pArrowView.arrowY, pArrowView.arrowRotation, this.holeTarget != null);
                }
            } else {
                if (pDialogView) {
                    pDialogView.visible = false;
                }
            }
        }

        // 升级界面。没有没有没有蒙板
    }

    public static function isCompVisible( comp : DisplayObject ) : Boolean {
        if ( !comp )
            return false;
        var bVisible : Boolean = comp.visible;
        var parent : DisplayObjectContainer;
        while ( bVisible ) {
            parent = comp.parent;
            if (!parent)
                break;
            bVisible = parent.visible;
            comp = parent;
            if ( !bVisible )
                break;
        }
        return bVisible;
    }
    private function _onTweening(e:Event) : void {
        if ( e.type == CTweenViewHandler.EVENT_TWEENING_FINISH) {
            _isViewTweening = false;
        } else if ( e.type == CTweenViewHandler.EVENT_TWEENING) {
            _isViewTweening = true;
        }
    }

    final public function get maskAlpha() : Number {
        return _maskAlpha;
    }

    final public function set maskAlpha( value : Number ) : void {
        _maskAlpha = value;
    }

    // 动作是否完成
    final public function isActionFinish() : Boolean {
        return _forceStop || (_actionValue && otherCondition) || _isCondFinish;
    }

    // =======================get===========================
    protected virtual function get otherCondition() : Boolean {
        return true;
    }
    public function get actionValue() : Boolean {
        return _actionValue;
    }
    final public function get info() : CTutorActionInfo {
        return _info;
    }
    final protected function get _gameSystem() : CECSLoop {
        return _system.stage.getSystem(CECSLoop) as CECSLoop;
    }
    final protected function get _sceneSystem() : CSceneSystem {
        return _system.stage.getSystem(CSceneSystem) as CSceneSystem;
    }
    [Inline]
    final protected function get _tutorSystem() : CTutorSystem {
        return _system as CTutorSystem;
    }
    [Inline]
    final protected function get _tutorManager() : CTutorManager {
        return _tutorSystem.getBean(CTutorManager) as CTutorManager;
    }
    protected function get _tutorPlay() : CTutorPlay {
        return _tutorManager.tutorPlay;
    }
    [Inline]
    final public function isRunning() : Boolean {
        return _isRunning;
    }
    [Inline]
    final public function isStop() : Boolean {
        return _forceStop;
    }
    public function get holeTarget() : Component {
        if ( !_holeTarget )
            return null;
        return _holeTarget.ptr as Component;
    }

    public function set holeTarget(value:Component):void {
        _holeTarget = _holeTarget || new CWeakRef();
        if ( _holeTarget.ptr == value )
            return;
        _holeTarget.ptr = value;
        this.onHoleTargetChanged();
    }

    virtual protected function onHoleTargetChanged() : void {
        if ( this.holeTarget ) {
            playAudio();
        }
    }

    public function saveToServerIfAbsent() : void {
        if ( !_isSave ) {
            _isSave = true;
            var pHandler : CTutorHandler = _system.getHandler( CTutorHandler ) as CTutorHandler;
            if ( pHandler ) {
                pHandler.sendTutorFinish( _info.ID );
            }
        }
    }

    public function playAudio( sAudioName : String = null ) : void {
        if ( _system ) {
            var sAudioNamePlayedByThis:String = _playedAudioMap.find(_infoID);
            if (sAudioNamePlayedByThis != null && sAudioNamePlayedByThis.length > 0) {
                return ; // 已播放过
            }
            var pAudioSys : IAudio = _system.stage.getSystem( IAudio ) as IAudio;
            if ( pAudioSys ) {
                if ( !sAudioName ) {
                    // Find the audio name
                    sAudioName = _info.audioName;
                }

                if ( sAudioName ) {
                    _playedAudioMap.add(_infoID, sAudioName);
                    pAudioSys.playAudioByName( sAudioName );
                }
            }
        }
    }
    private static var _playedAudioMap:CMap;
    public function get infoID() : int {
        return _infoID;
    }

    // 没有设置mornui指向的步骤, 不会回滚
    public function get needRollback() : Boolean {
        var bRollback:Boolean = info.hasMaskHoleTarget;
        if (!bRollback) return false;

        var isCompVisible:Boolean = holeTarget && holeTarget.stage && CTutorActionBase.isCompVisible(holeTarget);
        var holeTargetIsUnValid:Boolean = (holeTarget == null || !isCompVisible);
        bRollback = bRollback && holeTargetIsUnValid;

        return bRollback;
    }

    public virtual function autoPassProcess() : Boolean {
        _autoPassStartTime = getTimer();

        if (_system) {
            var pUISystem:CUISystem = _system.stage.getSystem(CUISystem) as CUISystem;
            if (pUISystem) {
                var pSceneLoadingViewHandler:CSceneLoadingViewHandler =  pUISystem.getBean(CSceneLoadingViewHandler);
                if (pSceneLoadingViewHandler) {
                    return !(pSceneLoadingViewHandler.isViewShow);
                }
            }
        }

        return true;
    }

    protected var _info:CTutorActionInfo;
    protected var _infoID:int; // _info会设为null, 但是dispose之后还需要访问_infoID
    protected var _system:CAppSystem;
    protected var _actionValue:Boolean; // 供上层使用的一个变量, 想用来干嘛都行
    private var _isCondFinish:Boolean; // 条件是否完成
    private var _isRunning:Boolean;

    private var _forceStop:Boolean; // 强制停止

    private var _holeTarget:CWeakRef;
    private var _pMaskView:CTutorMask;
    private var _maskAlpha:Number;
    private var _isSave : Boolean;

    public function get isCondFinish():Boolean {
        return _isCondFinish;
    }
    public function set isCondFinish(value:Boolean):void {
        _isCondFinish = value;
    }
    public function get isAutoPassTimeOut() : Boolean {
        if (_info) {
            if (lastForceHideTime > _autoPassStartTime) {
                _autoPassStartTime = lastForceHideTime;
            }
            return getTimer() - _autoPassStartTime > _info.autoPassTimeOut;
        }
        return false;
    }
    public function get isAutoPass() : Boolean {
        if (_info) {
            return _info.isAutoPass;
        }
        return false;
    }
    public function get isPassBySpaceTriggered() : Boolean {
        return _isPassBySpaceTriggered;
    }

    private var _iFirstShowArrowTime:int;
    private var _isFirst:Boolean;
    private var _isViewTweening:Boolean;
    private var _pDialog:Dialog; // 目前所在的dialog, 如果不是dialog则没有
    private var _startTime:int;
    private var _autoPassStartTime:int;
    private var _isPassBySpaceTriggered:Boolean;
    public var lastForceHideTime:int;
}
}
