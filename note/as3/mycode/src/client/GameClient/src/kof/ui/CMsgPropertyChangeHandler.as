//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/4.
 * Time: 15:33
 */
package kof.ui {

    import com.greensock.TweenLite;

    import kof.framework.CViewHandler;
    import kof.ui.component.CQueueTips;
    import kof.ui.master.attackAlertTip.PropertyChangeUI;
    import kof.util.TweenUtil;

    import morn.core.components.Label;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/4
     */
    public class CMsgPropertyChangeHandler extends CViewHandler {
        private var _proChangeView : PropertyChangeUI = null;
        private var _fadeTo1Tween : TweenLite = null;
        private var _fadeTo2Tween : TweenLite = null;
        private static var _delayTween : TweenLite = null;

        public function CMsgPropertyChangeHandler() {
            super( true );
        }

        override public function get viewClass() : Array {
            return [ PropertyChangeUI ];
        }

        public function show( addTxt : String ) : void {
            if ( !_proChangeView ) {
                _proChangeView = new PropertyChangeUI();
                _proChangeView.mouseEnabled = false;
                uiCanvas.addPopupDialog( _proChangeView );
            }
            (_proChangeView.tipBox.getChildByName( "txt" ) as Label).text = addTxt;
            if ( _delayTween ) {
                _delayTween.kill();
                _delayTween = null;
            }
            if ( _fadeTo1Tween ) {
                _fadeTo1Tween.kill();
                _fadeTo1Tween = null;
            }
            TweenLite.killTweensOf( _fadeToVisible, true );
            TweenLite.killTweensOf( _proChangeView, true );
            _proChangeView.visible = true;
            _proChangeView.alpha = 0;
            _fadeTo1Tween = TweenLite.to( _proChangeView, 0.5, {alpha : 1} );
            _delayTween = TweenLite.delayedCall( 1.5, _fadeToVisible );
        }

        private function _fadeToVisible() : void {
            if ( _fadeTo2Tween ) {
                _fadeTo2Tween.kill();
                _fadeTo2Tween = null;
            }
            _proChangeView.alpha = 1;
            _fadeTo2Tween = TweenLite.to( _proChangeView, 1, {alpha : 0, onComplete : _hideTip} );
        }

        private function _hideTip() : void {
            _proChangeView.visible = false;
        }
    }
}
