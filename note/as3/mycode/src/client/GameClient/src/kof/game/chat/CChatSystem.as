//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.chat {

import flash.utils.Dictionary;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.KOFSysTags;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.chat.data.CChatChannel;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.table.Currency;
import kof.table.MarqueeInfo;
import kof.util.CQualityColor;

/**
 * 聊天系统
 *
 * @author eddy
 */
public class CChatSystem extends CBundleSystem {

    private var _domain : CChatMessageList;
    private var _chatViewHandler : CChatViewHandler;
    private var _chatFaceViewHandler : CChatFaceViewHandler;
    private var _chatInputViewHandler : CChatInputViewHandler;
    private var _chatHornViewHandler : CChatHornViewHandler;
    private var _chatMenuHandler : CChatMenuHandler;
    private var _itemGetTipsViewHandler : CItemGetTipsViewHandler;


    ////
    private var _oldGoldNum: int;
    private var _oldBlueDiamondNum: int;
    private var _oldPurpleDiamondNum: int;
    private var _oldVitNum: int;

    private var _itemGetTipsAry : Array;

    public function CChatSystem() {
        super();
    }

    public override function dispose() : void {
        super.dispose();

        if ( _chatViewHandler )
            _chatViewHandler.dispose();
        _chatViewHandler = null;

        if ( _chatFaceViewHandler )
            _chatFaceViewHandler.dispose();
        _chatFaceViewHandler = null;

        if ( _chatInputViewHandler )
            _chatInputViewHandler.dispose();
        _chatInputViewHandler = null;

        if ( _chatHornViewHandler )
            _chatHornViewHandler.dispose();
        _chatHornViewHandler = null;

        if ( _chatMenuHandler )
            _chatMenuHandler.dispose();
        _chatMenuHandler = null;

        if ( _itemGetTipsViewHandler )
            _itemGetTipsViewHandler.dispose();
        _itemGetTipsViewHandler = null;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.CHAT );
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var ret : Boolean = true;

        ret = ret && addBean( ( _domain = new CChatMessageList()) );
        ret = ret && addBean( _chatViewHandler = new CChatViewHandler( ) );
        ret = ret && addBean( _chatFaceViewHandler = new CChatFaceViewHandler() );
        ret = ret && addBean( _chatInputViewHandler = new CChatInputViewHandler() );
        ret = ret && addBean( _chatHornViewHandler = new CChatHornViewHandler());
        ret = ret && addBean( _chatMenuHandler = new CChatMenuHandler() );
        ret = ret && addBean( new CChatHandler() );
        ret = ret && addBean( _itemGetTipsViewHandler = new CItemGetTipsViewHandler() );

        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_START, _onSystemBundleStateChangedHandler, false,
                    CEventPriority.DEFAULT, true );
        }




        _playerSystem.addEventListener( CPlayerEvent.BEFORE_UPDATE_DATA ,_beforUpdateData );
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateMoneyData);
        _playerSystem.addEventListener( CPlayerEvent.PLAYER_VIT, _updateMoneyData);
        _playerSystem.addEventListener( CPlayerEvent.SHOWHIDE_COMBAT_EFFECT,_showItemGetTips);

        _itemGetTipsAry = [];

        return ret;
    }
    private function _onSystemBundleStateChangedHandler( event : CSystemBundleEvent ) : void {
        updateLabels();
    }
    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        var pView : CChatViewHandler = this.getBean( CChatViewHandler );
        pView.loadAssetsByView( pView.viewClass );
    }

    /**
     * 发送聊天请求
     */
    public function broadcastMessage( idChannel : int, msg : String, type : int = 0 ,receiverID : int = 0 , name : String = '') : void {
        // A facade API to broadcast chatting message.
        (handler as CChatHandler).broadcastMessage( idChannel,  msg,  type, receiverID ,name);
    }

    private function _beforUpdateData( evt : CPlayerEvent ):void{
        _oldGoldNum = _playerSystem.playerData.currency.gold;
        _oldBlueDiamondNum = _playerSystem.playerData.currency.blueDiamond;
        _oldPurpleDiamondNum = _playerSystem.playerData.currency.purpleDiamond;
        _oldVitNum = _playerSystem.playerData.vitData.physicalStrength;
    }
    private function _updateMoneyData( evt : CPlayerEvent ) : void {

        var goldNum : int  = _playerSystem.playerData.currency.gold;
        if( goldNum > _oldGoldNum ){
            addSystemMsg( 1 + "," + ( goldNum - _oldGoldNum ) , CChatChannel.GETITEM );
            _oldGoldNum = goldNum;
        }
        var blueDiamondNum : int = _playerSystem.playerData.currency.blueDiamond;
        if( blueDiamondNum > _oldBlueDiamondNum ){
            addSystemMsg( 3 + "," + ( blueDiamondNum - _oldBlueDiamondNum ) , CChatChannel.GETITEM );
            _oldBlueDiamondNum = blueDiamondNum;
        }
        var purpleDiamondNum : int  = _playerSystem.playerData.currency.purpleDiamond;
        if( purpleDiamondNum > _oldPurpleDiamondNum ){
            addSystemMsg( 2 + "," + ( purpleDiamondNum - _oldPurpleDiamondNum ) , CChatChannel.GETITEM );
            _oldPurpleDiamondNum = purpleDiamondNum;
        }
        var vitNum : int  = _playerSystem.playerData.vitData.physicalStrength;
        if( vitNum > _oldVitNum ){
            addSystemMsg( 4 + "," + ( vitNum - _oldVitNum ) , CChatChannel.GETITEM );
            _oldVitNum = vitNum;
        }

    }


    ////////////////////////////////////

    public function addSystemMsg( msg : String = '', channelType:int = 2 , marqueeInfo : MarqueeInfo = null , responseData:Dictionary = null):void{

        if( channelType == CChatChannel.GETITEM ){
            var goodsId : int = int( msg.split(',')[0] );
            var goodsNum : int = int( msg.split(',')[1] );
            var newMsg : String = '';
            if( goodsId > 100 ){
                var bagData : CBagData = _bagManager.getBagItemByUid( goodsId );
                newMsg = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[bagData.item.quality-1] + "'>" + bagData.item.name + "</font>" + "*" + goodsNum;
            }else{
                var pTable : IDataTable = ( stage.getSystem(CDatabaseSystem) as CDatabaseSystem ).getTable( KOFTableConstants.CURRENCY );
                var currency : Currency = pTable.findByPrimaryKey( goodsId );
                newMsg = currency.name + "+" + goodsNum;
            }
            _domain.addSystemMsg( newMsg ,channelType ,marqueeInfo );

            if( _itemGetTipsAry.length <= 300 )//限制300条
                _itemGetTipsAry.push( newMsg );
            _showItemGetTips();

            return;
        }

        _domain.addSystemMsg( msg ,channelType ,marqueeInfo , responseData);
    }
    private function _showItemGetTips( evt : CPlayerEvent = null ):void{

//        //如果在播放获得格斗家动画，就
//        var uiHandler:CPlayerUIHandler = _playerSystem.getHandler(CPlayerUIHandler) as CPlayerUIHandler;
//        var heroGetView:CPlayerHeroGetView = uiHandler.getCreatedWindow(EPlayerWndType.WND_PLAYER_HERO_GET) as CPlayerHeroGetView;
//        if(heroGetView && heroGetView._ui && heroGetView._ui.parent)
//        {
//            return;
//        }
        if( null == _chatViewHandler.m_chatUI )
                return;
        if( _itemGetTipsAry.length <= 0 )
                return;

        var msg : String = _itemGetTipsAry.shift();
        _itemGetTipsViewHandler.show( msg );
        _showItemGetTips();
    }

    public function updateLabels():void{
        _chatViewHandler.updateTabLabels();
        _chatInputViewHandler.updateComboxLabels();
    }

    public function mainUIHide():void{
        if ( _chatFaceViewHandler )
            _chatFaceViewHandler.removeDisplay();
    }


    override protected function onBundleStop( ctx : ISystemBundleContext ) : void {
        if ( _chatViewHandler )
            _chatViewHandler.hide();
    }

    private function get _bagManager():CBagManager{
        return ( stage.getSystem( CBagSystem ) as CBagSystem ).getBean( CBagManager ) as CBagManager
    }
    private function get _playerSystem():CPlayerSystem{
        return stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}
