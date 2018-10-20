//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import QFLib.Graphics.RenderCore.starling.display.DisplayObject;

import com.greensock.TweenLite;
import com.greensock.easing.Back;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.SYSTEM_TAG;
import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IDataHolder;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.ui.master.main.MainUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * 游戏大厅（游戏主城）视图控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLobbyViewHandler extends CViewHandler {

    private var m_pMainUI : MainUI;
    private var m_pMainMask : Box;
    private var m_bIsTweening:Boolean;

    /**
     * Creates a new CLobbyViewHandler.
     */
    public function CLobbyViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        if ( m_pMainUI )
            m_pMainUI.remove();

        m_pMainUI = null;

        if ( m_pMainMask )
            m_pMainMask.remove();
        m_pMainMask = null;
    }

    override public function get viewClass() : Array {
        return [ MainUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "main_fx.swf",
            "frameclip_gift.swf",
            "frameclip_light_huang.swf",
            "frameclip_peakgamefair_hover.swf"
        ];
    }

    override protected function onInitialize() : Boolean {
        if ( !super.onInitialize() )
            return false;

        this.addBean( new CPrimarySystemViewHandler() );
        this.addBean( new CSecondarySystemViewHandler() );
        this.addBean( new CAdditionalSystemViewHandler() );
        this.addBean( new CEmBattleInLobbyViewHandler() );
        this.addBean( new CIconInteractEffectHandler() );

        var pContext : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pContext ) {
            pContext.defaultMatchingFilter = filterSystemBundleUserDataDirty;
        }

        return true;
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_pMainUI ) {
            m_pMainUI = new MainUI();
        }

        if ( !m_pMainMask ) {
            m_pMainMask = new Box();
        }

        (system.getBean( CPlayerHeadViewHandler ) as CPlayerHeadViewHandler).initWith( m_pMainUI.headView );

        var vPrimaryVH : CPrimarySystemViewHandler = this.getBean( CPrimarySystemViewHandler ) as CPrimarySystemViewHandler;
        var vSecondaryVH : CSecondarySystemViewHandler = this.getBean( CSecondarySystemViewHandler ) as CSecondarySystemViewHandler;
        var vAdditionalVH : CAdditionalSystemViewHandler = this.getBean( CAdditionalSystemViewHandler ) as CAdditionalSystemViewHandler;
        var vEmBattleVH : CEmBattleInLobbyViewHandler = this.getBean( CEmBattleInLobbyViewHandler ) as CEmBattleInLobbyViewHandler;
//        var vGMVH : CGMViewHandler = this.getBean( CGMViewHandler ) as CGMViewHandler;

        vPrimaryVH.initWith( m_pMainUI.listPrimary, m_pMainUI.listPrimary_1 );
        vSecondaryVH.initWith( m_pMainUI, m_pMainUI.listSecondary, m_pMainUI.listSecondary_1, m_pMainUI.listSecondary_2, m_pMainUI.listSecondary_3 );
        vAdditionalVH.initWith( m_pMainUI.listAdditional );
        vEmBattleVH.initWith( m_pMainUI.listEmbattle );
//        vGMVH.initWith( m_pMainUI.listGM );

        m_pMainUI.btn_openRank.clickHandler = new Handler(_openRankHandler);

        vPrimaryVH.addEventListener( "dataListDirty", _onDataListDirty, false, CEventPriority.DEFAULT_HANDLER, true );
        vSecondaryVH.addEventListener( "dataListDirty", _onDataListDirty, false, CEventPriority.DEFAULT_HANDLER, true );
        vAdditionalVH.addEventListener( "dataListDirty", _onDataListDirty, false, CEventPriority.DEFAULT_HANDLER, true );

        m_pMainUI.btnRTSlideIn.addEventListener( MouseEvent.CLICK, _btnSlideInOut_mouseClickEventHandler, false, CEventPriority.DEFAULT, true );
        m_pMainUI.btnRTSlideOut.addEventListener( MouseEvent.CLICK, _btnSlideInOut_mouseClickEventHandler, false, CEventPriority.DEFAULT, true );

        m_pMainUI.btnRTSlideIn.visible = true;
        m_pMainUI.btnRTSlideOut.visible = false;

//        m_pMainUI.listSecondary.cacheAsBitmap = true;
//        m_pMainUI.listSecondary_2.mask = m_pMainUI.mark_rt;
//        m_pMainUI.listSecondary_1.mask = m_pMainUI.mark_rt;
//        m_pMainUI.listSecondary.mask = m_pMainUI.mark_rt;
        m_pMainUI.boxRTLists.cacheAsBitmap = true;
        m_pMainUI.boxRTLists.mask = m_pMainUI.mark_rt;

        m_pMainUI.box_primaryLists.cacheAsBitmap = true;

        return Boolean( m_pMainUI );
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        this.removeDisplay();

        return ret;
    }

    override protected virtual function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );
    }

    override protected function updateData() : void {
        super.updateData();
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();
    }

    public function addDisplay( bTween : Boolean = false ) : void {
        this.invalidate();
        this.callLater( _addDisplay, bTween );
    }

    private function _addDisplay( bTween : Boolean ) : void {
        if ( m_pMainUI ) {
            this.uiCanvas.rootContainer.addChild( m_pMainUI );

            if ( bTween ) {
                tweenOut();
            }
        } else {
            callLater( _addDisplay, bTween );
        }
    }

    /**
     * @private
     */
    private var m_fTweenDuration : Number = 0.75;

    public function removeDisplay( bTween : Boolean = false ) : void {
        if ( this.m_pMainUI ) {
            if ( bTween ) {
                tweenIn( _onFinished );
            } else {
                _onFinished();
            }
        }

        function _onFinished() : void {
            m_pMainUI.remove();
        }
    }

    protected function addMask() : void {
        if ( !m_pMainMask )
            return;

        m_pMainMask.graphics.clear();
        m_pMainMask.graphics.beginFill( 0xFFFFFF, 0.0 );
        m_pMainMask.graphics.drawRect( 0, 0, uiCanvas.rootContainer.width, uiCanvas.rootContainer.height );
        m_pMainMask.graphics.endFill();

        if ( !m_pMainMask.parent ) {
            m_pMainUI.addChild( m_pMainMask );
        }
    }

    protected function removeMask() : void {
        m_bIsTweening = false;
        if ( !m_pMainMask )
            return;
        m_pMainMask.remove();
    }

    /** @private */
    public function tweenIn( pfnFinished : Function, ... argsFinished ) : void {
        this.endTween(); // if needed.

        m_bIsTweening = true;

        var pTop : Component = m_pMainUI.getChildByName( "top" ) as Component;
        var pLeftTop : Component = m_pMainUI.getChildByName( "left_top" ) as Component;
        var pLeftBottom : Component = m_pMainUI.getChildByName( "left_bottom" ) as Component;
        var pRightTop : Component = m_pMainUI.getChildByName( "right_top" ) as Component;
        var pRightBottom : Component = m_pMainUI.getChildByName( "right_bottom" ) as Component;
        var pLeft : Component = m_pMainUI.getChildByName( "left" ) as Component;
        var pRight : Component = m_pMainUI.getChildByName( "right" ) as Component;

        if ( pTop ) {
            TweenLite.fromTo( pTop, m_fTweenDuration, {top : 0}, {top : -pTop.height, ease : Back.easeIn} );
        }

        if ( pLeftTop ) {
            TweenLite.fromTo( pLeftTop, m_fTweenDuration, {left : 0}, {left : -pLeftTop.width, ease : Back.easeIn} );
        }

        if ( pLeftBottom ) {
            TweenLite.fromTo( pLeftBottom, m_fTweenDuration, {left : 0}, {
                left : -pLeftBottom.width,
                ease : Back.easeIn
            } );
        }

        if ( pRightTop ) {
            TweenLite.fromTo( pRightTop, m_fTweenDuration, {right : 0}, {
                right : -pRightTop.width,
                ease : Back.easeIn
            } );
        }

        if ( pRightBottom ) {
            TweenLite.fromTo( pRightBottom, m_fTweenDuration, {right : 0}, {
                right : -pRightBottom.width,
                ease : Back.easeIn
            } );
        }

        if ( pLeft ) {
            TweenLite.fromTo( pLeft, m_fTweenDuration, {
                left : 0
            }, {left : -pLeft.width, ease : Back.easeIn} );
        }

        if ( pRight ) {
            TweenLite.fromTo( pRight, m_fTweenDuration, {
                right : 0
            }, {right : -pRight.width, ease : Back.easeIn} );
        }

        this.addMask();

        delayCall( m_fTweenDuration, function() : void {
            removeMask();
        });

        if ( null != pfnFinished )
            delayCall.apply( null, [ m_fTweenDuration, pfnFinished ].concat( argsFinished ) );
    }

    /** @private */
    public function tweenOut( pfnFinished : Function = null, ... argsFinished ) : void {
        this.endTween(); // if needed.

        m_bIsTweening = true;

        var pTop : Component = m_pMainUI.getChildByName( "top" ) as Component;
        var pLeftTop : Component = m_pMainUI.getChildByName( "left_top" ) as Component;
        var pLeftBottom : Component = m_pMainUI.getChildByName( "left_bottom" ) as Component;
        var pRightTop : Component = m_pMainUI.getChildByName( "right_top" ) as Component;
        var pRightBottom : Component = m_pMainUI.getChildByName( "right_bottom" ) as Component;
        var pLeft : Component = m_pMainUI.getChildByName( "left" ) as Component;
        var pRight : Component = m_pMainUI.getChildByName( "right" ) as Component;

        if ( pTop ) {
            TweenLite.fromTo( pTop, m_fTweenDuration, {
                top : -pTop.height
            }, {top : 0, ease : Back.easeOut} );
        }

        if ( pLeftTop ) {
            TweenLite.fromTo( pLeftTop, m_fTweenDuration, {
                left : -pLeftTop.width
            }, {left : 0, ease : Back.easeOut} );
        }

        if ( pLeftBottom ) {
            TweenLite.fromTo( pLeftBottom, m_fTweenDuration, {
                left : -pLeftBottom.width
            }, {left : 0, ease : Back.easeOut} );
        }

        if ( pRightTop ) {
            TweenLite.fromTo( pRightTop, m_fTweenDuration, {
                right : -pRightTop.width
            }, {right : 0, ease : Back.easeOut} );
        }

        if ( pRightBottom ) {
            TweenLite.fromTo( pRightBottom, m_fTweenDuration, {
                right : -pRightBottom.width
            }, {right : 0, ease : Back.easeOut} );
        }

        if ( pLeft ) {
            TweenLite.fromTo( pLeft, m_fTweenDuration, {
                left : -pLeft.width
            }, {left : 0, ease : Back.easeOut} );
        }

        if ( pRight ) {
            TweenLite.fromTo( pRight, m_fTweenDuration, {
                right : -pRight.width
            }, {right : 0, ease : Back.easeOut} );
        }

        addMask();

        delayCall( m_fTweenDuration, function() : void {
            removeMask();
        });

        if ( null != pfnFinished )
            delayCall.apply( null, [ m_fTweenDuration, pfnFinished ].concat( argsFinished ) );
    }

    /** @private */
    private function endTween() : void {
        var pTop : Component = m_pMainUI.getChildByName( "top" ) as Component;
        var pLeftTop : Component = m_pMainUI.getChildByName( "left_top" ) as Component;
        var pLeftBottom : Component = m_pMainUI.getChildByName( "left_bottom" ) as Component;
        var pRightTop : Component = m_pMainUI.getChildByName( "right_top" ) as Component;
        var pRightBottom : Component = m_pMainUI.getChildByName( "right_bottom" ) as Component;
        var pLeft : Component = m_pMainUI.getChildByName( "left" ) as Component;
        var pRight : Component = m_pMainUI.getChildByName( "right" ) as Component;

        if ( pTop ) TweenLite.killTweensOf( pTop, true );
        if ( pLeftTop ) TweenLite.killTweensOf( pLeftTop, true );
        if ( pLeftBottom ) TweenLite.killTweensOf( pLeftBottom, true );
        if ( pRightTop ) TweenLite.killTweensOf( pRightTop, true );
        if ( pRightBottom ) TweenLite.killTweensOf( pRightBottom, true );
        if ( pLeft ) TweenLite.killTweensOf( pLeft, true );
        if ( pRight ) TweenLite.killTweensOf( pRight, true );
    }

    public function get pMainUI() : MainUI {
        return m_pMainUI;
    }

    public function getPrimaryIconGlobalPoint( sysTagName : String ) : Point {
        return (getBean( CPrimarySystemViewHandler ) as CPrimarySystemViewHandler).getPrimaryIconGlobalPoint( sysTagName );
    }

    public function getPrimaryIconGlobalPointCenter( sysTagName : String ) : Point {
        return (getBean( CPrimarySystemViewHandler ) as CPrimarySystemViewHandler).getPrimaryIconGlobalPointCenter( sysTagName );
    }

    public function getSecondaryIconGlobalPoint( sysTagName : String ) : Point {
        return (getBean( CSecondarySystemViewHandler ) as CSecondarySystemViewHandler ).getIconGlobalPoint( sysTagName );
    }

    public function getSecondaryIconGlobalPointCenter( sysTagName : String ) : Point {
        return (getBean( CSecondarySystemViewHandler ) as CSecondarySystemViewHandler ).getIconGlobalPointCenter( sysTagName );
    }

    public function getAddtionalIconGlobalPoint( sysTagName : String ) : Point {
        return (getBean( CAdditionalSystemViewHandler ) as CAdditionalSystemViewHandler ).getAdditionalIconGlobalPoint( sysTagName );
    }

    public function getAddtionalIconGlobalPointCenter( sysTagName : String ) : Point {
        return (getBean( CAdditionalSystemViewHandler ) as CAdditionalSystemViewHandler ).getAdditionalIconGlobalPointCenter( sysTagName );
    }

    public function getIconLocation( sysTagName : String ) : int {
        var point : Point = this.getPrimaryIconGlobalPoint( sysTagName );
        if ( point ) return 0;
        point = this.getSecondaryIconGlobalPoint( sysTagName );
        if ( point ) return 1;
        point = this.getAddtionalIconGlobalPoint( sysTagName );
        if ( point ) return 2;
        return -1;
    }

    public function getIconGlobalPoint( sysTagName : String ) : Point {
        var point : Point = this.getPrimaryIconGlobalPoint( sysTagName );
        if ( !point ) {
            point = this.getSecondaryIconGlobalPoint( sysTagName );
        }
        if ( !point ) {
            point = this.getAddtionalIconGlobalPoint( sysTagName );
        }
        return point;
    }

    public function getIconGlobalPointCenter( sysTagName : String ) : Point {
        var point : Point = this.getPrimaryIconGlobalPointCenter( sysTagName );
        if ( !point ) {
            point = this.getSecondaryIconGlobalPointCenter( sysTagName );
        }
        if ( !point ) {
            point = this.getAddtionalIconGlobalPointCenter( sysTagName );
        }
        return point;
    }

    public function shineIcon( sysTagName : String ) : void {
        (getBean( CPrimarySystemViewHandler ) as CPrimarySystemViewHandler).shineIcon( sysTagName );
    }

    protected function filterSystemBundleUserDataDirty( pCtx : ISystemBundleContext, pBundle : ISystemBundle,
                                                        sProperty : String, oldValue : *, newValue : * ) : Boolean {
        if ( !sProperty )
            return true;

        if ( sProperty == CBundleSystem.NOTIFICATION ) {
            // 这里针对QQ的蓝钻和黄钻的图标进行特殊处理，出现小红点和小红点消失需要更换主界面的图标
            if ( pBundle.bundleID == SYSTEM_ID( KOFSysTags.QQ_BLUE_DIAMOND ) || pBundle.bundleID == SYSTEM_ID( KOFSysTags.QQ_YELLOW_DIAMOND ) ) {
                var pDataHolder : IDataHolder = system.getBean( IDataHolder );
                if ( pDataHolder ) {
                    var sIcon : String = null;
                    var vOriginDataList : Array = pDataHolder.data as Array;
                    for ( var i : int = 0; i < vOriginDataList.length; ++i ) {
                        if ( vOriginDataList[ i ].Tag == SYSTEM_TAG( pBundle.bundleID ) ) {
                            sIcon = vOriginDataList[ i ].Icon;
                        }
                    }

                    if ( sIcon ) {
                        if ( newValue ) {
                            pCtx.setUserData( pBundle, CBundleSystem.ICON, sIcon + "2" );
                        } else {
                            pCtx.setUserData( pBundle, CBundleSystem.ICON, null );
                        }
                    }

                    pCtx.setUserData( pBundle, CBundleSystem.GLOW_EFFECT, newValue );
                }
            }
        }

        if ( sProperty == CBundleSystem.ACTIVATED ) {
            if ( newValue == true )
                return false;
        }

        return oldValue == newValue;
    }

    private function _onDataListDirty( event : Event ) : void {
        // ignore.
    }

    public function get visible() : Boolean {
        if ( m_pMainUI ) {
            return m_pMainUI.visible;
        }
        return false;
    }

    public function set visible( v : Boolean ) : void {
        if ( m_pMainUI ) {
            m_pMainUI.visible = v;
        }
    }

    public function get isTweening():Boolean
    {
        return m_bIsTweening;
    }

    private function _btnSlideInOut_mouseClickEventHandler( event : MouseEvent ) : void {
        if ( event.currentTarget == m_pMainUI.btnRTSlideOut ) {
            m_pMainUI.btnRTSlideOut.visible = false;
            m_pMainUI.btnRTSlideIn.visible = true;
        } else {
            m_pMainUI.btnRTSlideIn.visible = false;
            m_pMainUI.btnRTSlideOut.visible = true;
        }

        var bListVisible : Boolean = m_pMainUI.btnRTSlideIn.visible;

        TweenLite.killTweensOf( m_pMainUI.listSecondary, true );
        TweenLite.killTweensOf( m_pMainUI.listSecondary_1, true );
        TweenLite.killTweensOf( m_pMainUI.listSecondary_2, true );
        TweenLite.killTweensOf( m_pMainUI.listSecondary_3, true );

        var rx : int = m_pMainUI.boxRTLists.x + m_pMainUI.boxRTLists.width;

        if ( bListVisible ) { // false -> true
            TweenLite.to( m_pMainUI.listSecondary, 0.75, {ease : Back.easeOut, right : 0} );
            TweenLite.to( m_pMainUI.listSecondary_1, 0.75, {ease : Back.easeOut, right : 0} );
            TweenLite.to( m_pMainUI.listSecondary_2, 0.75, {ease : Back.easeOut, right : 0} );
            TweenLite.to( m_pMainUI.listSecondary_3, 0.75, {ease : Back.easeOut, right : 0} );
        } else { // true -> false
            TweenLite.to( m_pMainUI.listSecondary, 1.0, {ease : Back.easeIn, right : -rx} );
            TweenLite.to( m_pMainUI.listSecondary_1, 1.0, {ease : Back.easeIn, right : -rx} );
            TweenLite.to( m_pMainUI.listSecondary_2, 1.0, {ease : Back.easeIn, right : -rx} );
            TweenLite.to( m_pMainUI.listSecondary_3, 1.0, {ease : Back.easeIn, right : -rx} );
        }

//        m_pMainUI.listSecondary.visible = bListVisible;
//        m_pMainUI.listSecondary_1.visible = bListVisible;
//        m_pMainUI.listSecondary_2.visible = bListVisible;
    }

    private function _openRankHandler():void
    {
        //打开排行榜界面
        var pBundle:ISystemBundle = (system as CBundleSystem).ctx.getSystemBundle(SYSTEM_ID(KOFSysTags.RANKING));
        (system as CBundleSystem).ctx.setUserData(pBundle, CBundleSystem.ACTIVATED, true);
    }

}
}
