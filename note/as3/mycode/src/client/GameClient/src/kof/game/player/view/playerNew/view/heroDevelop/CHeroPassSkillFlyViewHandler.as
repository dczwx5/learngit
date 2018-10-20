//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/3/12.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import com.greensock.TweenLite;
import com.greensock.easing.Back;
import com.greensock.easing.Expo;

import flash.display.Bitmap;

import flash.display.DisplayObject;

import flash.events.Event;
import flash.events.KeyboardEvent;

import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import kof.SYSTEM_ID;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CUIFactory;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.master.NoviceTutor.NTFlyIconUI;
import kof.ui.master.NoviceTutor.NTOpeningUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 格斗家升星解锁的被动技能开启
 */
public class CHeroPassSkillFlyViewHandler extends CViewHandler {

    static public const EVENT_TWEEN_FINISHED : String = "_TWEEN_FINISHED";

    /** @private */
    private var m_pPromptUI : NTOpeningUI;
    private var m_pFlyIconUI : NTFlyIconUI;
    private var m_pFlyIcon:DisplayObject;

    private var m_sSkillName : String;
    private var m_sSysTag : String;
    private var m_sIconUrl : String;
    private var m_sFlyIconUrl : String;

    private var m_iCount:int;
    private const _CloseCountdownNum:int = 60;

    /** @private */
    private var m_theDisplayQueue : Vector.<CDisplayQueueItem>;

    public function CHeroPassSkillFlyViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        m_pPromptUI = null;
    }

    /** @inheritDoc */
    override public function get viewClass() : Array {
        return [ NTOpeningUI, NTFlyIconUI ];
    }

    /** @inheritDoc */
    override protected function onInitialize() : Boolean {
        if ( !super.onInitialize() )
            return false;

        m_theDisplayQueue = m_theDisplayQueue || new Vector.<CDisplayQueueItem>();
        return true;
    }

    /** @inheritDoc */
    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_pPromptUI ) {
            m_pPromptUI = new NTOpeningUI();
            m_pPromptUI.fxStarting.visible = false;
            m_pPromptUI.iconComp.visible = false;
        }

        if ( !m_pFlyIconUI ) {
            m_pFlyIconUI = new NTFlyIconUI();
            m_pFlyIconUI.fxExplose.visible = false;
            m_pFlyIconUI.fxExplose.autoPlay = false;

            m_pFlyIconUI.fxIconBg.visible = true;
            m_pFlyIconUI.fxIconBg.autoPlay = true;
        }

        return Boolean( m_pPromptUI );
    }

    override protected function onShutdown() : Boolean {
        if ( !super.onShutdown() )
            return false;

        this.enableClick( false );
        this.enableKeyboard( false );

        return true;
    }

    override protected function updateData() : void {
        super.updateData();

        if ( m_pPromptUI ) {
            m_pPromptUI.iconComp.url = this.iconUrl;
            m_pPromptUI.txtName.text = this.skillName;
        }

//        if ( m_pFlyIconUI ) {
//            m_pFlyIconUI.clipIcon.url = this.flyIconUrl;
//        }
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();
    }

    public function get skillName() : String {
        return m_sSkillName;
    }

    public function set skillName( value : String ) : void {
        if ( m_sSkillName == value ) return;
        m_sSkillName = value;
        invalidateData();
    }

    public function get sysTag() : String {
        return m_sSysTag;
    }

    public function set sysTag( value : String ) : void {
        if ( m_sSysTag == value ) return;
        m_sSysTag = value;
        invalidateData();
    }

    public function get iconUrl() : String {
        return m_sIconUrl;
    }

    public function set iconUrl( value : String ) : void {
        if ( m_sIconUrl == value ) return;
        m_sIconUrl = value;
        invalidateData();
    }

    public function get flyIconUrl() : String { return m_sFlyIconUrl; }
    public function set flyIconUrl( value : String ) : void {
        if ( m_sFlyIconUrl == value ) return;
        m_sFlyIconUrl = value;
        invalidateData();
    }

    public function get flyIconAvailable() : Boolean {
        var ret : Boolean = true;
        var pCtx : ISystemBundleContext =  system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pCtx ) {
            var pBundle : ISystemBundle = pCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.INSTANCE ) );
            if ( pBundle && pCtx.getUserData( pBundle, CBundleSystem.ACTIVATED, false ) )
                ret = false;

            if ( ret ) {
                pBundle = pCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.ELITE ) );
                if ( pBundle && pCtx.getUserData( pBundle, CBundleSystem.ACTIVATED, false ))
                    ret = false;
            }
        }
        return ret;
    }

    public function addToDisplayQueue( sSysTag : String, sBundleName : String, sIconUrl : String, sFlyIconUrl : String, pfnCallback : Function = null, ... args ) : void {
        var pItem : CDisplayQueueItem = new CDisplayQueueItem;
        pItem.sysTag = sSysTag;
        pItem.bundleName = sBundleName;
        pItem.iconUrl = sIconUrl;
        pItem.flyIconUrl = sFlyIconUrl;
        pItem.callback = pfnCallback;
        pItem.callback_args = args;

        m_theDisplayQueue.push( pItem );

        if ( m_theDisplayQueue.length == 1 ) {
            this.fillView();
            addDisplay();
        }
    }

    public function flySkillIcon(tag:String, skillIcon:DisplayObject, skilName:String, callBack : Function = null, ... callBackArgs):void
    {
        var pItem : CDisplayQueueItem = new CDisplayQueueItem;
        pItem.sysTag = sysTag;
        pItem.flyIcon = skillIcon;
        m_pFlyIcon = skillIcon;
        pItem.callback = callBack;
        pItem.callback_args = callBackArgs;

        skillName = skilName;
        sysTag = tag;

        m_theDisplayQueue.push( pItem );

        if ( m_theDisplayQueue.length == 1 ) {
//            this.fillView();
            addDisplay();
        }
    }

    public function clearDisplayQueue() : void {
        if ( m_theDisplayQueue && m_theDisplayQueue.length )
            m_theDisplayQueue.splice( 0, m_theDisplayQueue.length );
    }

    public function addDisplay() : void {
        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_3, function():void{
                loadAssetsByView( viewClass, _addDisplay );
            });
        }
    }

    private function _addDisplay() : void {
        if ( this.onInitializeView() ) {
//            this.invalidate();

            if ( m_pPromptUI && m_pFlyIcon) {
                uiCanvas.addPopupDialog( m_pPromptUI );
//                uiCanvas.addPopupDialog( m_pFlyIcon );
                m_pPromptUI.parent.addChild( m_pFlyIcon);
                m_pFlyIcon.x = (m_pPromptUI.parent.width - m_pFlyIcon.width >> 1) - 10-2;
                m_pFlyIcon.y = (m_pPromptUI.parent.height - m_pFlyIcon.height >> 1) - 10-13;

                this.enableClick(true);
                this.enableKeyboard( true );
                m_pPromptUI.img_title.visible = false;
                m_pPromptUI.txtName.visible = true;
                m_pPromptUI.fxStarting.visible = true;
                m_pPromptUI.fxKuoSan.visible = true;
                m_pPromptUI.fxStarting.playFromTo(null, null, new Handler( _fxStarting_playToComplete ) );
                m_pPromptUI.fxKuoSan.play();
                m_pPromptUI.txtName.text = skillName;

                m_iCount = _CloseCountdownNum;
                m_pPromptUI.txt_leftTime.text = m_iCount +"秒";

//                delayCall( 30, next );
                schedule(1, _onScheduleHandler);
            }
        }
    }

    private function _onScheduleHandler(delta : Number):void
    {
        m_iCount--;
        if(m_iCount <= 0)
        {
            next();
        }
        else
        {
            m_pPromptUI.txt_leftTime.text = m_iCount +"秒";
        }
    }

    protected function enableClick( value : Boolean ) : void {
        if ( value ) {
            system.stage.flashStage.addEventListener( MouseEvent.CLICK, _all_mouseClickEventHandler, false, CEventPriority.DEFAULT, true );
        } else {
            system.stage.flashStage.removeEventListener( MouseEvent.CLICK, _all_mouseClickEventHandler );
        }
    }

    protected function enableKeyboard(value:Boolean):void
    {
        if ( value ) {
            system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, CEventPriority.DEFAULT, true);
        } else {
            system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);
        }
    }

    private function _fxStarting_playToComplete() : void {
        m_pPromptUI.fxStarting.visible = false;
        CAssertUtils.assertFalse( m_pPromptUI.fxStarting.isPlaying );
    }

    public function removeDisplay() : void {
        if ( m_pPromptUI ) {

            this.enableClick(false);
            this.enableKeyboard( false );
            m_pPromptUI.fxKuoSan.visible = false;
            m_pPromptUI.fxKuoSan.stop();
            m_pPromptUI.close();
        }

        if(m_pFlyIcon && m_pFlyIcon)
        {
            (m_pFlyIcon as Component).remove();
            m_pFlyIcon = null;

            m_pPromptUI.close();
        }

        if ( m_pFlyIconUI ) {
            m_pFlyIconUI.remove();
        }

        var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if(pReciprocalSystem){
            pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_3 );
        }

        unschedule(_onScheduleHandler);
    }

    protected function fillView() : void {
        var pItem : CDisplayQueueItem = m_theDisplayQueue[ 0 ];
        this.skillName = pItem.bundleName;
        this.sysTag = pItem.sysTag;
        this.iconUrl = pItem.iconUrl;
        this.flyIconUrl = pItem.flyIconUrl;
    }

    protected function next() : void {
        // 1. 手动点击或是自动计时触发
        // 2. 此处关闭原本显示的UI并播放Icon飞入动作
        // 3. Icon消失继续下一个或结束
        // 这里开始展示动画表现
        // 1. 大图标居中缩小
        // 2. 产生小图标飞往开启位置
        // 3. 到达目的地特效表现？
        // 4. next()

        unschedule( next );
        unschedule( _onScheduleHandler );
        this.enableClick( false );
        this.enableKeyboard( false );
        m_pPromptUI.centerX = m_pPromptUI.centerY = 0;
        m_pPromptUI.cacheAsBitmap = true;

        TweenLite.to( this.m_pPromptUI, 0.75, {
            ease : Back.easeIn,
            scale : 0,
            centerX : 0,
            centerY : 0,
            alpha : 0,
            onComplete : function () : void {
                if ( !flyIconAvailable ) {
                    // end if no fly icon available.
                    tweenFinishedComplete();
                }
            }
        } );

        // 产生小图标
//        var iconClip : NTFlyIconUI;

        if ( flyIconAvailable ) {
//            iconClip = this.m_pFlyIconUI;
//            iconClip.clipIcon.url = this.flyIconUrl;

            var targetLoc : Point;

            var pLobbySystem : CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
            if ( pLobbySystem ) {
                var pLobbyView : CLobbyViewHandler = pLobbySystem.getHandler( CLobbyViewHandler ) as CLobbyViewHandler;
                if ( pLobbyView ) {
                    targetLoc = pLobbyView.getIconGlobalPoint( this.sysTag );
                }
            }

            if ( !targetLoc )
                targetLoc = new Point( 0, 0 );

//            m_pPromptUI.parent.addChildAt( iconClip, m_pPromptUI.parent.getChildIndex( m_pPromptUI ) );
//            iconClip.centerX = iconClip.centerY = 0;

            TweenLite.to( m_pFlyIcon, 1.5, {
//            ease : Circ.easeIn,
                ease : Expo.easeIn,
                delay : 0.125,
                x : targetLoc.x,
                y : targetLoc.y,
//                onStart : function () : void {
//                    iconClip.visible = true;
//                    iconClip.fxIconBg.visible = true;
//                    iconClip.centerY = iconClip.centerX = NaN;
//                },
                onComplete : tweenFinished
            } );

//            function highlightBundleIcon() : void {
//                TweenLite.to( iconClip, 0.25, {
//                    onComplete : function () : void {
//                        iconClip.fxExplose.playFromTo( null, null );
//                        iconClip.fxExplose.visible = true;
//                        iconClip.fxIconBg.visible = false;
//                        tweenFinished();
//                    }
//                } );
//            }
        } else {
            // ignore.
        }

        function tweenDone() : void {
            m_pPromptUI.scale = 1.0;
            m_pPromptUI.alpha = 1.0;
            m_pPromptUI.centerX = m_pPromptUI.centerY = NaN;
            m_pPromptUI.cacheAsBitmap = false;
//            if ( iconClip )
//                iconClip.remove();
            if(m_pFlyIcon && m_pFlyIcon is Bitmap)
            {
                _disposeBmp();
            }

            removeDisplay();
            _finished();
        }

        function tweenFinishedComplete() : void {
            dispatchEvent( new Event( EVENT_TWEEN_FINISHED ) );
            tweenDone();
        }

        function tweenFinished() : void {
//            if ( iconClip ) {
//                TweenLite.to( iconClip, 0.75, {
//                    onComplete : tweenFinishedComplete
//                } );
//            } else {
                tweenFinishedComplete();
//            }
        }
    }

    private function _finished() : void {
        if ( !m_theDisplayQueue.length )
            return;

        if ( null != m_theDisplayQueue[0].callback) {
            m_theDisplayQueue[ 0 ].callback( m_theDisplayQueue[ 0 ].callback_args );
        }

        m_theDisplayQueue.shift();

        if ( m_theDisplayQueue.length ) {
            this.fillView();
            addDisplay();
        }
    }

    private function _disposeBmp():void
    {
        var bmp:Bitmap = m_pFlyIcon as Bitmap;
        bmp.bitmapData.dispose();
        bmp.bitmapData = null;

        CUIFactory.disposeBitmap(bmp);

        m_pFlyIcon = null;
    }

    /** @private */
    private function _all_mouseClickEventHandler( event : MouseEvent ) : void {
        next();
    }

    private function _onKeyboardUp(e:KeyboardEvent) : void
    {
        if(e.keyCode == Keyboard.SPACE)
        {
            if(((system.stage.getSystem(CLobbySystem) as CLobbySystem).getHandler(CLobbyViewHandler) as CLobbyViewHandler).isTweening)
            {
                return;
            }

            next();
        }
    }

}
}

import flash.display.DisplayObject;

/** @private */
class CDisplayQueueItem {

    public var bundleName : String;
    public var sysTag : String;
    public var iconUrl : String;
    public var flyIconUrl : String;
    public var callback : Function;
    public var callback_args : Array;
    public var flyIcon:DisplayObject;

    public function CDisplayQueueItem() {
        super();
    }
}