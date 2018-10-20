//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.reciprocation {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.reciprocation.marquee.CMarqueeData;
import kof.game.reciprocation.marquee.CMarqueeHandler;
import kof.game.reciprocation.marquee.CMarqueeViewHandler;
import kof.game.reciprocation.popWindow.CEventPopWindowHandler;
import kof.net.CNetworkSystem;
import kof.ui.CMsgAlertHandler;
import kof.ui.CMsgBoxHandler;
    import kof.ui.CMsgPropertyChangeHandler;
import kof.ui.CUISystem;

/**
 * 交互系统
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CReciprocalSystem extends CAppSystem {

    public function CReciprocalSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        // Sub view handlers.
        ret = ret && addBean( new CDisconnectViewHandler() );
        ret = ret && addBean( new CDisconnectNetHandler() );
        ret = ret && addBean( new CAntiAddictionHandler() );

        var pMarqueeData : CMarqueeData;
        ret = ret && addBean( ( pMarqueeData = new CMarqueeData() ) );
        ret = ret && addBean( new CMarqueeHandler() );
        ret = ret && addBean( new CMarqueeViewHandler( pMarqueeData) );

        ret = ret && addBean( new CGetPropsViewHandler() );
        ret = ret && addBean( new CMsgBoxHandler() );
        ret = ret && addBean( new CMsgAlertHandler() );

        ret = ret && addBean( new CMsgPropertyChangeHandler() );
        ret = ret && addBean( new CCostBdDiamondViewHandler() );
        ret = ret && addBean( new CFlyItemViewHandler() );
        ret = ret && addBean( new CAntiAddictionViewHandler() );
        ret = ret && addBean( new CFocusLostViewHandler() );
        ret = ret && addBean( new CEventPopWindowHandler() );

        return ret && initialize();
    }

    protected function initialize() : Boolean {
        {
            // listen networking.
            var pNetworking : CNetworkSystem = stage.getSystem( CNetworkSystem ) as CNetworkSystem;
            if ( pNetworking ) {
                pNetworking.addEventListener( Event.CLOSE, _onNetworkingCloseEventHandler, false, 0, true );
            }
        }

        return true;
    }

    public function showCostBdDiamondMsgBox( costNum : int, backFunc : Function = null ):void{
        var viewHandler : CCostBdDiamondViewHandler = getBean( CCostBdDiamondViewHandler ) as CCostBdDiamondViewHandler;
        if ( viewHandler )
            viewHandler.show( costNum, backFunc);
    }

    public function showAppMsgBox( msg : String, okFun : Function = null, closeFun : Function = null, cancelIsVisible : Boolean = true,
                                okLable:String = null, cancelLable:String = null, closeBtnIsVisible:Boolean = true,showType : String = "") : void {
        var viewHandler : CMsgBoxHandler = getBean( CMsgBoxHandler ) as CMsgBoxHandler;
        if ( viewHandler )
            viewHandler.show( msg, okFun, closeFun, cancelIsVisible, okLable, cancelLable, closeBtnIsVisible, showType, true);
    }

    public function showMsgBox( msg : String, okFun : Function = null, closeFun : Function = null, cancelIsVisible : Boolean = true,
                                okLable:String = null, cancelLable:String = null, closeBtnIsVisible:Boolean = true,showType : String = "") : void {
        var viewHandler : CMsgBoxHandler = getBean( CMsgBoxHandler ) as CMsgBoxHandler;
        if ( viewHandler )
            viewHandler.show( msg, okFun, closeFun, cancelIsVisible, okLable, cancelLable, closeBtnIsVisible, showType);
    }
    public function closeAllMsgBox() : void {
        var viewHandler : CMsgBoxHandler = getBean( CMsgBoxHandler ) as CMsgBoxHandler;
        if ( viewHandler )
            viewHandler.closeAllDialog();
    }

    public function showMsgAlert( msg : String, type : int = CMsgAlertHandler.WARNING, playSound : Boolean = true ) : void {
        var viewHandler : CMsgAlertHandler = getBean( CMsgAlertHandler ) as CMsgAlertHandler;
        if ( viewHandler )
            viewHandler.show( msg, type, playSound );
    }
    public function showMsgProperChange(addTxt:String="") : void {
        var viewHandler : CMsgPropertyChangeHandler = getBean( CMsgPropertyChangeHandler ) as CMsgPropertyChangeHandler;
        if ( viewHandler )
            viewHandler.show(addTxt);
    }

    public function showPropMsgAlert(attrName : String, value:int, type : int = CMsgAlertHandler.WARNING, playSound : Boolean = true ):void
    {
        var viewHandler : CMsgAlertHandler = getBean( CMsgAlertHandler ) as CMsgAlertHandler;
        if ( viewHandler )
            viewHandler.showProp( attrName, value, playSound );
    }

    public function showQuickUseView(id : int, num : int, completeBackFunc : Function = null):void{
        var viewHandler : CGetPropsViewHandler = getBean( CGetPropsViewHandler ) as CGetPropsViewHandler;
        viewHandler.show(id,num,completeBackFunc);
    }

    public function isEnoughToPay(costNum:int) : Boolean {
        var purpleDiamond:int = playSystem.playerData.currency.purpleDiamond + playSystem.playerData.currency.blueDiamond;
        return purpleDiamond >= costNum;
    }
    public function showCanNotBuyTips() : void {
        showMsgAlert(CLang.Get("bangzuan_lanzuan_notEnough"));
    }

    public function isWaitShowQuickUse( value:Boolean ):void {
        var viewHandler : CGetPropsViewHandler = getBean( CGetPropsViewHandler ) as CGetPropsViewHandler;
        viewHandler.isWaitShow = value;
    }

    public function addEventPopWindow( viewId:int, openFunc:Function ,subType : int = 0 ):void {
        var popHandler:CEventPopWindowHandler = getBean( CEventPopWindowHandler ) as CEventPopWindowHandler;
        popHandler.addView( viewId, openFunc ,subType);
    }

    public function removeEventPopWindow( viewId:int ):void {
        var popHandler:CEventPopWindowHandler = getBean( CEventPopWindowHandler ) as CEventPopWindowHandler;
        popHandler.removeView( viewId );
    }
    public function hasEventPopWindow() : Boolean {
        var popHandler:CEventPopWindowHandler = getBean( CEventPopWindowHandler ) as CEventPopWindowHandler;
        return popHandler.getEventPopListLength() > 0;
    }

    private function get playSystem() : CPlayerSystem {
        return stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    override protected virtual function onShutdown() : Boolean {
        return super.onShutdown();
    }

    private function _onNetworkingCloseEventHandler( event : Event ) : void {
        var pView : CDisconnectViewHandler = getBean( CDisconnectViewHandler ) as CDisconnectViewHandler;
        if ( pView ) {
            pView.show();
        }
    }

}
}
