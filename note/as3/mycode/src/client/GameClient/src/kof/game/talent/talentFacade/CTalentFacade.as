//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:06
 */
package kof.game.talent.talentFacade {

import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.shop.CShopSystem;
import kof.game.shop.enum.EShopType;
import kof.game.switching.CSwitchingSystem;
import kof.game.talent.CTalentSystem;
import kof.game.talent.talentFacade.talentSystem.enums.EPeakTalentGridBgColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentColorType;
import kof.game.talent.talentFacade.talentSystem.enums.EBenYuanTalentGridBgColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentIcoURL;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentMainType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentWareType;
import kof.game.talent.talentFacade.talentSystem.events.CTalentEvent;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentNetProxy;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentAllPointData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentConditionData;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentPointData;
import kof.game.talent.talentFacade.talentSystem.view.CTalentBagView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentFastSellView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentMainView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentPointSelectView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentSellView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentSuitTipsView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentTipsView;
import kof.table.GamePrompt;
import kof.table.Item;
import kof.table.PassiveSkillPro;
import kof.table.TalentConstant;
import kof.table.TalentSoul;
import kof.table.TalentSoulPoint;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

public class CTalentFacade {
    private static var _instance : CTalentFacade = null;
    private var _rootContainer : IUICanvas = null;
    private var _talentMediator : CTalentMediator = null;
    private var _mainView : CTalentMainView = null;
    private var _tipsView : CTalentTipsView = null;
    private var _suitTipsView : CTalentSuitTipsView = null;
    private var _talentPointSelectView : CTalentPointSelectView = null;
    private var _talentBagView : CTalentBagView = null;
    private var _talentSellView : CTalentSellView = null;
    private var _talentFastSellView : CTalentFastSellView = null;

    private var _talentNetProxy : CTalentNetProxy = null;
    private var _netWork : INetworking = null;

    private var _talentSysytem : CAppSystem = null;

    private var _eventDispatch : EventDispatcher = null;
    //当前点击的斗魂点的位置
    private var _currentClickTalentPointID : int = 0;

    private var _bIsInitializedView : Boolean = false;

    public final function set currentClickTalentPointID( pointID : int ) : void {
        this._currentClickTalentPointID = pointID;
    }

    public final function get currentClickTalentPointID() : int {
        return this._currentClickTalentPointID;
    }

    public final function dispose() : void {
        _instance = null;
        _rootContainer = null;
        _talentMediator = null;
        _mainView = null;
        _tipsView = null;
        _suitTipsView = null;
        _talentPointSelectView = null;
        _talentBagView = null;
        _talentSellView = null;
        _talentFastSellView = null;
        _talentNetProxy = null;
        _netWork = null;
        _talentSysytem = null;
        _eventDispatch = null;
        CTalentDataManager.getInstance().dispose();
    }

    public function CTalentFacade( cls : PrivateCls ) {
        _eventDispatch = new EventDispatcher();
        _addEvents();
    }

    private function _addEvents() : void {
        addEventListener( CTalentEvent.UPDATE_DATA, _updateView );
//            addEventListener( CTalentEvent.ADD, _promptAdd );
//            addEventListener( CTalentEvent.DELETE, _promptDelete );
        addEventListener( CTalentEvent.REPLACE, _prompReplace );
        addEventListener(CTalentEvent.UpdateMeltInfo, _updateMeltInfoHandler)
    }

    private function _formatStr( str : String ) : String {
        str = str.replace( "[", "" );
        str = str.replace( "]", "" );
        return str;
    }

    private function _promptAdd( e : CTalentEvent ) : void {
        var data : CTalentPointData = e.data as CTalentPointData;
        var msg : String = (this._gamePromptTable.findByPrimaryKey( 2003 ) as GamePrompt).content;
        msg.replace( "{0}", "" );
        msg.replace( "{1}", "" );
        msg.replace( "：", "" );
        (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg, CMsgAlertHandler.NORMAL );
        var talentSoul : TalentSoul = getTalentSoul( data.soulConfigID );
        var sProperty : String = _formatStr( talentSoul.propertysAdd );
        var dataArr : Array = sProperty.split( ";" );
        var dataLen : int = dataArr.length;
        var usedNu : int = 0;
        for ( var i : int = 0; i < dataLen; i++ ) {
            var str : String = String( dataArr[ i ] );
            if ( !str || str == "" ) {
                return;
            }
            var pro : Array = str.split( ":" );
            var addvalue : int = int( pro[ 1 ] );
            var percent : Number = int( pro[ 2 ] ) / 10000 * 100;
            var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) );
            if ( addvalue != 0 ) {
                usedNu++;
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( passiveSkillPro.name, CMsgAlertHandler.NORMAL );
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( " + " + addvalue, CMsgAlertHandler.NORMAL );
                (_talentSysytem.stage.getSystem( IUICanvas ) as CUISystem).showPropMsgAlert( passiveSkillPro.name, addvalue, CMsgAlertHandler.NORMAL );
            }
            if ( percent != 0 ) {
                usedNu++;
                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( passiveSkillPro.name + CLang.Get( "bafenbi" ), CMsgAlertHandler.NORMAL );
                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( " + " + percent + "%", CMsgAlertHandler.NORMAL );
            }
        }
    }

    private function _promptDelete( e : CTalentEvent ) : void {
        var data : CTalentPointData = e.data as CTalentPointData;
        var msg : String = (this._gamePromptTable.findByPrimaryKey( 2004 ) as GamePrompt).content;
        msg.replace( "{0}", "" );
        msg.replace( "{1}", "" );
        msg.replace( "：", "" );
        (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg, CMsgAlertHandler.NORMAL );
        var talentSoul : TalentSoul = getTalentSoul( data.soulConfigID );
        var sProperty : String = _formatStr( talentSoul.propertysAdd );
        var dataArr : Array = sProperty.split( ";" );
        var dataLen : int = dataArr.length;
        var usedNu : int = 0;
        for ( var i : int = 0; i < dataLen; i++ ) {
            var str : String = String( dataArr[ i ] );
            if ( !str || str == "" ) {
                return;
            }
            var pro : Array = str.split( ":" );
            var addvalue : int = int( pro[ 1 ] );
            var percent : Number = int( pro[ 2 ] ) / 10000 * 100;
            var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) );
            if ( addvalue != 0 ) {
                usedNu++;
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( passiveSkillPro.name, CMsgAlertHandler.NORMAL );
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( " + " + addvalue, CMsgAlertHandler.NORMAL );
                (_talentSysytem.stage.getSystem( IUICanvas ) as CUISystem).showPropMsgAlert( passiveSkillPro.name, addvalue, CMsgAlertHandler.NORMAL );

            }
            if ( percent != 0 ) {
                usedNu++;
                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( passiveSkillPro.name + CLang.Get( "bafenbi" ), CMsgAlertHandler.NORMAL );
                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( " + " + percent + "%", CMsgAlertHandler.NORMAL );
            }
        }
    }

    private function _prompReplace( e : CTalentEvent ) : void {
        var addDic : Dictionary = new Dictionary();
        var subDic : Dictionary = new Dictionary();

        var oldData : CTalentPointData = e.data.oldSoul as CTalentPointData;
        var oldDic : Dictionary = new Dictionary();
        if ( oldData.soulConfigID != 0 ) {
            _calcaulatorProperty( oldData, oldDic );
        }
        var newData : CTalentPointData = e.data.newSoul as CTalentPointData;
        var newDic : Dictionary = new Dictionary();
        if ( newData.soulConfigID != 0 ) {
            _calcaulatorProperty( newData, newDic );
        }
        var isSameKey : Boolean = false;
        for ( var key : String in newDic ) {
            for ( var oldKey : String in oldDic ) {
                if ( key == oldKey ) {
                    isSameKey = true;
                    if ( newDic[ key ] - oldDic[ oldKey ] > 0 ) {
                        addDic[ key ] = newDic[ key ] - oldDic[ oldKey ];
                    } else if ( newDic[ key ] - oldDic[ oldKey ] < 0 ) {
                        subDic[ key ] = oldDic[ oldKey ] - newDic[ key ];
                    }
                }
            }
            if ( !isSameKey ) {
                addDic[ key ] = newDic[ key ];
            }
            isSameKey = false;
        }
        isSameKey = false;
        for ( var key1 : String in oldDic ) {
            for ( var newKey : String in newDic ) {
                if ( key1 == newKey ) {
                    isSameKey = true;
                }
            }
            if ( !isSameKey ) {
                subDic[ key1 ] = oldDic[ key1 ];
            }
            isSameKey = false;
        }

        var isAddShow : Boolean = false;
        var msg : String = "";
        for ( var addKey : String in addDic ) {
            if ( !isAddShow ) {
//                msg = (this._gamePromptTable.findByPrimaryKey( 2003 ) as GamePrompt).content;
//                msg = msg.replace( "{0}", "" );
//                msg = msg.replace( "{1}", "" );
//                msg = msg.replace( "：", "" );
//                msg = msg.replace( "+", "" );
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg, CMsgAlertHandler.NORMAL );
            }
            isAddShow = true;
            var addStr : String = "";
            addStr += addKey;
            if ( addKey.indexOf( CLang.Get( "bafenbi" ) ) != -1 ) {
                addStr += "  + " + addDic[ addKey ] + "%";
            } else {
                addStr += "  + " + addDic[ addKey ];
            }
            (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( addStr, CMsgAlertHandler.NORMAL );
        }
        var isSubShow : Boolean = false;
        for ( var subKey : String in subDic ) {
            if ( !isSubShow ) {
//                msg = (this._gamePromptTable.findByPrimaryKey( 2004 ) as GamePrompt).content;
//                msg = msg.replace( "{0}", "" );
//                msg = msg.replace( "{1}", "" );
//                msg = msg.replace( "：", "" );
//                msg = msg.replace( "+", "" );
//                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg, CMsgAlertHandler.NORMAL );
            }
            isSubShow = true;
            var subStr : String = "";
            subStr += subKey;
            if ( subKey.indexOf( CLang.Get( "bafenbi" ) ) != -1 ) {
                subStr += "  <font color='#ff0000'>- " + subDic[ subKey ] + "%" + "</font>";
            } else {
                subStr += "  <font color='#ff0000'>- " + subDic[ subKey ] + "</font>";
            }
            (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( subStr, CMsgAlertHandler.NORMAL );
        }
    }

    private function _calcaulatorProperty( data : CTalentPointData, dic : Dictionary ) : void {
        var talentSoul : TalentSoul = getTalentSoul( data.soulConfigID );
        var sProperty : String = _formatStr( talentSoul.propertysAdd );
        var dataArr : Array = sProperty.split( ";" );
        var dataLen : int = dataArr.length;
        for ( var i : int = 0; i < dataLen; i++ ) {
            var str : String = String( dataArr[ i ] );
            if ( !str || str == "" ) {
                return;
            }
            var pro : Array = str.split( ":" );
            var addvalue : int = int( pro[ 1 ] );
            var percent : Number = int( pro[ 2 ] ) / 10000 * 100;
            var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) );
            if ( addvalue != 0 ) {
                dic[ passiveSkillPro.name ] = addvalue;
            }
            if ( percent != 0 ) {
                dic[ passiveSkillPro.name + CLang.Get( "bafenbi" ) ] = percent;
            }
        }
    }

    public function initTalentView() : Boolean {
        if ( !_bIsInitializedView ) {
            _bIsInitializedView = true;
            _talentMediator = new CTalentMediator();
            _mainView = new CTalentMainView( _talentMediator );
            _tipsView = new CTalentTipsView( _talentMediator );
            _suitTipsView = new CTalentSuitTipsView( _talentMediator );
            _talentPointSelectView = new CTalentPointSelectView( _talentMediator );
            _talentBagView = new CTalentBagView( _talentMediator );
            _talentSellView = new CTalentSellView( _talentMediator );
            _talentFastSellView = new CTalentFastSellView( _talentMediator );
            _talentMediator.talentMainView = _mainView;
            _talentMediator.talentTipsView = _tipsView;
            _talentMediator.talentSuitTipsView = _suitTipsView;
            _talentMediator.talentSelectPointView = _talentPointSelectView;
            _talentMediator.talentBagView = _talentBagView;
            _talentMediator.talentSellView = _talentSellView;
            _talentMediator.talentFastSellView = _talentFastSellView;
            _talentPointSelectView.parentContainer = _mainView.ui;
        }
        return _bIsInitializedView;
    }

    public function initTalentNetProxy() : void {
        _talentNetProxy = new CTalentNetProxy();
    }

    public function show() : void {
        _talentNetProxy.talentInfoRequest();
        _mainView.show();
    }

    public function close() : void {
        _mainView.close();
        _tipsView.close();
        _suitTipsView.close();
        _talentPointSelectView.close();
        _talentBagView.close();
        _talentSellView.close();
        _talentFastSellView.close();
    }

    public static function getInstance() : CTalentFacade {
        if ( !_instance ) {
            _instance = new CTalentFacade( new PrivateCls() );
        }
        return _instance;
    }

    public function set closeHandler( closeHandler : Handler ) : void {
        _mainView.closeHanlder = closeHandler;
    }

    public function dispatchEvent( type : String, data : Object ) : void {
        _eventDispatch.dispatchEvent( new CTalentEvent( type, data ) );
    }

    public function addEventListener( type : String, func : Function ) : void {
        _eventDispatch.addEventListener( type, func );
    }

    //更新视图显示，同时判断是否显示红点
    private function _updateView( e : CTalentEvent ) : void {
//        var nextPointArr : Array = CTalentFacade.getInstance().nextOpenSePointID();
//        var nextPoint : int = 0;
//        var isShowRedPoint : Boolean = false;
//        var page : int = 0;
//        if ( nextPointArr.length != 0 ) {
//            for ( var j : int = 0; j < nextPointArr.length; j++ ) {
//                if ( isShowRedPoint ) {
//                    break;
//                }
//                if ( j == 0 ) {
//                    page = ETalentPageType.BEN_YUAN;
//                } else {
//                    page = ETalentPageType.PEAK;
//                }
//                nextPoint = nextPointArr[ j ];
//                var openLv : int = CTalentFacade.getInstance().getTalentOpenLv( nextPoint, page );
//                if ( openLv == -1 ) {
//                    continue;
//                }
//                if ( openLv <= teamLevel ) { //开启等级<=战队等级，说明有格子可以开启，则显示红点
//                    isShowRedPoint = true;
//                    (_talentSysytem as CTalentSystem).updateSystemRedPoint( true );
//                } else {
//                    if ( _ergodic() ) {
//                        isShowRedPoint = true;
//                        (_talentSysytem as CTalentSystem).updateSystemRedPoint( true );
//                    } else {
//                        (_talentSysytem as CTalentSystem).updateSystemRedPoint( false );
//                    }
//                }
//            }
//        } else {
//            if ( _ergodic() ) {
//                (_talentSysytem as CTalentSystem).updateSystemRedPoint( true );
//            } else {
//                (_talentSysytem as CTalentSystem).updateSystemRedPoint( false );
//            }
//        }
//
//        if ( !isShowRedPoint ) {
//            var bool : Boolean = _judgeRed( ETalentPageType.BEN_YUAN );
//            if ( !bool ) {
//                bool = _judgeRed( ETalentPageType.PEAK );
//            }
//            (_talentSysytem as CTalentSystem).updateSystemRedPoint( bool );
//        }

        var isCanOperate:Boolean = _helper.isCanOperate();
        (_talentSysytem as CTalentSystem).updateSystemRedPoint(isCanOperate);

        if ( !_bIsInitializedView )return;
        if ( _mainView.isShow ) {
            _mainView.update();
            _talentBagView.update();
            _talentSellView.update();
            _tipsView.update();
            _suitTipsView.update();
            _talentPointSelectView.update();
            _talentFastSellView.update();
        }
    }

    private function _updateMeltInfoHandler(e:CTalentEvent):void
    {
        if ( !_bIsInitializedView )
            return;

        if ( _mainView.isShow )
        {
            _mainView.updateMeltInfo();
        }
    }

    //遍历本源、拳皇大赛的斗魂数据，如果有格子打开了并且可以镶嵌，并且斗魂库中有相应的斗魂，则返回true
    private function _ergodic() : Boolean {
        var talentPageData : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( ETalentPageType.BEN_YUAN );
        var talentPointDataVec : Vector.<CTalentPointData> = null;
        var len : int = 0;
        var talentPointData : CTalentPointData = null;
        var j : int = 0;
        var i : int = 0;
        if ( talentPageData ) {
            talentPointDataVec = talentPageData.pointInfos;
            len = talentPointDataVec.length;
            talentPointData = null;
            for ( j = 0; j < len; j++ ) {
                talentPointData = talentPointDataVec[ j ];
                for ( i = 1; i <= 30; i++ ) {
                    if ( i == talentPointData.soulPointConfigID ) {
                        if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                            if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i, ETalentPageType.BEN_YUAN ).length ) {
                                return true;
                            }
                        }
                    }
                }
            }
        }

        if ( !(_talentSysytem.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem).isSystemOpen( KOFSysTags.TALENT_PEAK ) ) {
            return false;
        }

        talentPageData = CTalentDataManager.getInstance().getTalentPagePointData( ETalentPageType.PEAK );
        if ( talentPageData ) {
            talentPointDataVec = talentPageData.pointInfos;
            len = talentPointDataVec.length;
            talentPointData = null;
            for ( j = 0; j < len; j++ ) {
                talentPointData = talentPointDataVec[ j ];
                for ( i = 1; i <= 15; i++ ) {
                    if ( i == talentPointData.soulPointConfigID ) {
                        if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                            if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i, ETalentPageType.PEAK ).length ) {
                                return true;
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    //-----------------------------------------------
    //------------------client相关-------------------
    //-----------------------------------------------
    public function set talentRootUIContainer( ui : IUICanvas ) : void {
        _rootContainer = ui;
        _mainView.parent = _rootContainer;
        _talentPointSelectView.parent = _rootContainer;
        _talentBagView.parent = _rootContainer;
        _talentSellView.parent = _rootContainer;
        _talentFastSellView.parent = _rootContainer;
    }

    public function set netWork( value : INetworking ) : void {
        _netWork = value;
        _talentNetProxy.network = _netWork;
        _talentNetProxy.talentInfoRequest();
    }

    public function set talentAppSystem( value : CAppSystem ) : void {
        _talentSysytem = value;
        _talentSysytem.stage.getSystem( CPlayerSystem ).addEventListener( CPlayerEvent.PLAYER_TALENT, _updateTalentBagView );
        _talentSysytem.stage.getSystem( CPlayerSystem ).addEventListener( CPlayerEvent.PLAYER_EQUIP_CARD, _updateTalentBagView );
    }

    public function get talentAppSystem() : CAppSystem {
        return _talentSysytem;
    }

    private function _updateTalentBagView( e : CPlayerEvent ) : void {
        if ( _mainView && _mainView.isShow ) {
            _talentBagView.updateTalentPointNu();
        }
    }

    /**战队拥有的钻石*/
    public function get teamDiamond() : Number {
        var playerManager : CPlayerManager = _talentSysytem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData.currency.blueDiamond; //钻石
    }

    /**战队拥有的金币*/
    public function get teamGold() : Number {
        var playerManager : CPlayerManager = _talentSysytem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData.currency.gold; //金币
    }

    /**战队拥有的天赋点*/
    public function get talentPoint() : int {
        var playerManager : CPlayerManager = _talentSysytem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData.currency.talentPoint; //天赋点
    }

    /**扭蛋币*/
    public function get niudanbi() : int {
        var playerManager : CPlayerManager = _talentSysytem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData.currency.eggCoin; //扭蛋币
    }

    /**战队等级*/
    public final function get teamLevel() : int {
        var playerManager : CPlayerManager = _talentSysytem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData.teamData.level; //战队等级
    }

    /**弹出alert窗口*/
    public final function showAlertWindow( okCallFunc : Function ) : void {
        (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgBox( "确定将已镶嵌的斗魂全部卸下么？", okCallFunc );
    }

    //-------------------------------------------------------
    //---------------------斗魂数据表相关----------------------
    //-------------------------------------------------------
    public function getTalentConstant() : TalentConstant {
        var talentSoulPointTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        talentSoulPointTable = pDatabaseSystem.getTable( KOFTableConstants.TALENT_CONSTANT ) as CDataTable;
        return talentSoulPointTable.findByPrimaryKey( 1 ) as TalentConstant;
    }

    /**
     * @pointID 斗魂主类型
     * @return 返回斗魂点的颜色索引
     **/
    public function getTalentPointColorIndexForTalentMainType( mainType : int ) : int {
        var color : int = mainType + 1;
        if ( color == ETalentColorType.BLUE ) {
            return ETalentColorType.BLUE;
        }
        if ( color == ETalentColorType.GREEN ) {
            return ETalentColorType.GREEN;
        }
        if ( color == ETalentColorType.ORANGE ) {
            return ETalentColorType.ORANGE;
        }
        if ( color == ETalentColorType.PURPLE ) {
            return ETalentColorType.PURPLE;
        }
        return 0;
    }

    /**获取斗魂网格颜色 本源
     * @mainType 斗魂主类型
     * @return 返回斗魂格子的颜色
     * */
    public function getBenYuanTalentGridBgColorForTalentMainType( mainType : int ) : int {
        if ( mainType == ETalentMainType.ATTACK ) {
            return EBenYuanTalentGridBgColorType.PURPLE
        }
        if ( mainType == ETalentMainType.DEFENSE ) {
            return EBenYuanTalentGridBgColorType.GREEN
        }
        if ( mainType == ETalentMainType.SPECIAL ) {
            return EBenYuanTalentGridBgColorType.BLUE;
        }
        return 0;
    }

    /**获取斗魂网格颜色 拳皇大赛
     * @mainType 斗魂主类型
     * @return 返回斗魂格子的颜色
     * */
    public function getPeakTalentGridBgColorForTalentMainType( mainType : int ) : int {
        if ( mainType == ETalentMainType.ATTACK ) {
            return EPeakTalentGridBgColorType.PURPLE
        }
        if ( mainType == ETalentMainType.DEFENSE ) {
            return EPeakTalentGridBgColorType.GREEN
        }
        if ( mainType == ETalentMainType.SPECIAL ) {
            return EPeakTalentGridBgColorType.YELLOW;
        }
        return 0;
    }

    public final function get talentSoulPointTable() : TalentSoulPoint {
        var talentSoulPointTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        talentSoulPointTable = pDatabaseSystem.getTable( KOFTableConstants.TALENT_SOUL_POINT ) as CDataTable;
        var len : int = talentSoulPointTable.toVector().length;
        for ( var i : int = 1; i <= len; i++ ) {
            var talentSoulPoint : TalentSoulPoint = talentSoulPointTable.findByPrimaryKey( i );
//            if ( teamLevel >= talentSoulPoint.openLevel ) {
//                return talentSoulPoint;
//            }

            if(_helper.isTalentCanOpen(talentSoulPoint))
            {
                return talentSoulPoint;
            }
        }
        return null;
    }

    /**根据斗魂点位置获取位置表中的斗魂镶嵌类型描述*/
    public final function getTalentPointMosaicTypeDesc( pointID : int ) : String
    {
        var arr:Array = _talentSoulPointTable.findByProperty("pageID", currentPageType);
        for each ( var talentSoulPoint : TalentSoulPoint in arr )
        {
            if (talentSoulPoint && talentSoulPoint.pointID == pointID)
            {
                return talentSoulPoint.mosaicTypeDesc;
            }
        }

        return null;
    }

    /**根据斗魂点位置获取斗魂位置表中的斗魂镶嵌类型
     * @param pointID 位置
     * @param page 斗魂页
     * */
    public final function getTalentPointMosaicTypeForTalentSoulPointTable( pointID : int, page : int ) : int {
        var vec : Vector.<Object> = this._talentSoulPointTable.toVector();
        for each( var value : Object in vec ) {
            var talentSoulPoint : TalentSoulPoint = TalentSoulPoint( value );
            if ( pointID == talentSoulPoint.pointID && page == talentSoulPoint.pageID ) {
                return talentSoulPoint.mosaicType;
            }
        }
        return -1;
    }

    /**获取斗魂的名字*/
    public final function getTalentName( ID : int ) : String {
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return Item( itemTable.findByPrimaryKey( ID ) ).name;
    }

    /**根据开启顺序返回下一个开启的位置
     *
     * page -1为检查所有页面,返回结果一次为本源、拳皇大赛的开启位置
     *
     * */
    public final function nextOpenSePointID( page : int = -1 ) : Array {
        var pointIDArr : Array = [];
        var vec : Vector.<Object> = this._talentSoulPointTable.toVector();
        var nextPointID_benyuan : int = -1;
        var nextPointID_peak : int = -1;
        var nextOpenID_benyuan : int = int.MAX_VALUE;//开启顺序
        var nextOpenID_peak : int = int.MAX_VALUE;
        var curNextPointID : int = 0;
        var curNextOpenID : int = int.MAX_VALUE;
        var alreadyHighestSe_benyuan : int = CTalentDataManager.getInstance().getTalentAlreadyOpenHighestSequence( ETalentPageType.BEN_YUAN );
        var alreadyHighestSe_peak : int = CTalentDataManager.getInstance().getTalentAlreadyOpenHighestSequence( ETalentPageType.PEAK );
        var curAlreadyHighestSe : int = CTalentDataManager.getInstance().getTalentAlreadyOpenHighestSequence( page );
        for each( var value : Object in vec ) {
            var talentSoulPoint : TalentSoulPoint = TalentSoulPoint( value );
            if ( page == -1 ) {
                if ( ETalentPageType.BEN_YUAN == talentSoulPoint.pageID ) {
                    if ( alreadyHighestSe_benyuan < talentSoulPoint.openID ) {
                        if ( nextOpenID_benyuan > talentSoulPoint.openID ) {
                            nextPointID_benyuan = talentSoulPoint.pointID;
                            nextOpenID_benyuan = talentSoulPoint.openID;
                        }
                    }
                } else if ( ETalentPageType.PEAK == talentSoulPoint.pageID ) {
                    if ( alreadyHighestSe_peak < talentSoulPoint.openID ) {
                        if ( nextOpenID_peak > talentSoulPoint.openID ) {
                            nextPointID_peak = talentSoulPoint.pointID;
                            nextOpenID_peak = talentSoulPoint.openID;
                        }
                    }
                }
            } else {
                if ( TalentSoulPoint( value ).pageID == page ) {
                    if ( curAlreadyHighestSe < talentSoulPoint.openID ) {
                        if ( curNextOpenID > talentSoulPoint.openID ) {
                            curNextPointID = talentSoulPoint.pointID;
                            curNextOpenID = talentSoulPoint.openID;
                        }
                    }
                }
            }
        }
        if ( page == -1 ) {
            pointIDArr.push( nextPointID_benyuan );
            pointIDArr.push( nextPointID_peak );
        } else {
            pointIDArr.push( curNextPointID );
        }
        return pointIDArr;
    }

    public function get currentPageType() : int {
        return _talentMediator.talentMainView.currentPage;
    }

    public function get currentTalentSoulWareType() : int {
        if ( currentPageType == ETalentPageType.BEN_YUAN ) {
            return ETalentWareType.BENYUAN_WARE;
        } else {
            return ETalentWareType.PEAK_WARE;
        }
    }

    /**根据斗魂点位置获取开启等级*/
    public final function getTalentOpenLv( pointID : int, page : int = 0 ) : int {
        if ( page == ETalentPageType.PEAK && !(_talentSysytem.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem).isSystemOpen( KOFSysTags.TALENT_PEAK ) ) {
            return -1;
        }

        var openLv : int = -1;
        var vec : Vector.<Object> = this._talentSoulPointTable.toVector();
        for each( var value : Object in vec ) {
            var talentSoulPoint : TalentSoulPoint = TalentSoulPoint( value );
            if (talentSoulPoint && pointID == talentSoulPoint.pointID && page == talentSoulPoint.pageID) {
//                    if(talentSoulPoint.pageID==page)
//                    {
//                        openLv=talentSoulPoint.openLevel;
//                    }

                var arr:Array = _helper.getOpenConditionInfo(talentSoulPoint.openConditionID, page);
                if(arr && arr.length)
                {
                    var conditionData:CTalentConditionData = arr[0] as CTalentConditionData;
                    return conditionData.targetValue;
                }
            }
        }
        return openLv;
    }

    /**
     * @param soulConfigID 斗魂唯一ID
     * @return 返回斗魂表中对应ID的数据
     * */
    public final function getTalentSoul( soulConfigID : int ) : TalentSoul {
        var talentSoul : TalentSoul = talentSoulTable.findByPrimaryKey( soulConfigID );
        return talentSoul;
    }

    /**
     * @param ID 斗魂位置表ID
     * @return 返回该页该位置对应的斗魂位置表数据
     * */
    public final function getTalentPointSoulForID( ID : int ) : TalentSoulPoint {
        var vec : Vector.<Object> = _talentSoulPointTable.toVector();
        for each( var value : Object in vec ) {
            if ( TalentSoulPoint( value ).ID == ID ) {
                return TalentSoulPoint( value );
            }
        }
        return null;
    }

    /**
     * @param pointID 斗魂位置表pointID（斗魂的位置）
     * @param page 页面
     * @return 返回该页该位置对应的斗魂位置表数据
     * */
    public final function getTalentPointSoulForPointIDAndPage( pointID : int, page : int ) : TalentSoulPoint {
        var vec : Vector.<Object> = _talentSoulPointTable.toVector();
        for each( var value : Object in vec ) {
            if ( TalentSoulPoint( value ).pointID == pointID && page == TalentSoulPoint( value ).pageID ) {
                return TalentSoulPoint( value );
            }
        }
        return null;
    }

    /**获取斗魂位置表数据*/
    private function get _talentSoulPointTable() : CDataTable {
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        return pDatabaseSystem.getTable( KOFTableConstants.TALENT_SOUL_POINT ) as CDataTable;
    }

    /**获取斗魂表数据*/
    public function get talentSoulTable() : CDataTable {
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        return pDatabaseSystem.getTable( KOFTableConstants.TALENT_SOUL ) as CDataTable;
    }

    /**获取属性序号、字段表*/
    private function get _passiveSkillProTable() : CDataTable {
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        return pDatabaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO ) as CDataTable;
    }

    /**
     * @param id PassiveSkillPro表中的id
     * @return 返回PassiveSkillPro表中对应id的数据
     * */
    public function getPassiveSkillProData( id : int ) : PassiveSkillPro {
        var passiveSkillPro : PassiveSkillPro = _passiveSkillProTable.findByPrimaryKey( id );
        return passiveSkillPro;
    }

    /**
     * 显示错误提示
     * @param gamePromptID 提示码
     * */
    public function showGamePrompt( gamePromptID : int ) : void {
        if ( gamePromptID != 0 ) {
            var gamePromp:GamePrompt = this._gamePromptTable.findByPrimaryKey( gamePromptID ) as GamePrompt;
            if(gamePromp)
            {
                var msg : String = gamePromp.content;
                (_talentSysytem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( _format( msg, getTalentOpenLv( this._currentClickTalentPointID ) ) );
            }
        }
    }

    /**
     * 跳转到商店
     *
     * */
    public function showShopTalent( currentPage : int ) : void {
        if ( currentPage == ETalentPageType.BEN_YUAN ) {
            CViewManagerHandler.OpenViewByBundle( _talentSysytem, KOFSysTags.MALL, "shop_type", [ EShopType.SHOP_TYPE_8 ] );
        }
        else if ( currentPage == ETalentPageType.PEAK ) {
            CViewManagerHandler.OpenViewByBundle( _talentSysytem, KOFSysTags.MALL, "shop_type", [ EShopType.SHOP_TYPE_10 ] );
        }

    }

    /**获取错误提示表*/
    private function get _gamePromptTable() : CDataTable {
        var pDatabaseSystem : CDatabaseSystem = this._talentSysytem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        return pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
    }

    /**格式化*/
    private function _format( str : String, ... args ) : String {
        for ( var i : int = 0; i < args.length; i++ ) {
            str = str.replace( new RegExp( "\\{" + i + "\\}", "g" ), args[ i ] );
        }
        return str;
    }

    //--------------------------
    //----Network相关------------
    //--------------------------
    /**
     * 斗魂点开启请求
     * @param soulPointConfigID 斗魂点配置表唯一ID
     * @param openType 开启类型:0正常开启 1付费开启
     * */
    public function requestOpenTalentPoint( soulPointConfigID : int, openType : int ) : void {
        _talentNetProxy.openSoulPointRequest( soulPointConfigID, openType );
    }

    /** 镶嵌或替换斗魂操作
     * @param ID 斗魂位置表ID
     * @param soulID 斗魂配置表唯一ID
     **/
    public final function requestMosaicReplace( ID : int, soulID : int ) : void {
        _talentNetProxy.mosaicReplaceRequest( ID, soulID );
    }

    /**
     * 卸下已镶嵌的斗魂
     * @param type 卸下类型： 0 卸下当前斗魂点上的斗魂 ; 1 一键卸下当前斗魂页所有斗魂
     * @param pageType 斗魂页类型: 1 本源; 2 出战; 3 特质; 4 相克; 5 招式
     * @param pointID 斗魂位置表ID
     *
     **/
    public final function requestTakeOff( type : int, pageType : int, ID : int ) : void {
        _talentNetProxy.takeOffRequest( type, pageType, ID );
    }

    /**斗魂出售请求
     * @param type 出售类型： 0 单一出售 ; 1 批量出售
     * @param soulID 斗魂配置表唯一ID
     * @param sellNum 出售数量
     * @param sellQualityArr 批量出售选择的品质
     * @param mainType 批量出售的主类型 0-代表全部 1-攻击类 2-防御类 3-特殊类 4-唯一类
     * @param batchSellWarehouseType 批量出售库类型 1 本源斗魂库 ; 2 拳皇大赛斗魂库
     * */
    public final function requestSoulSell( type : int, soulID : int, sellNum : int, sellQualityArr : Array, mainType : int, batchSellWarehouseType : int ) : void {
        _talentNetProxy.soulSellRequest( type, soulID, sellNum, sellQualityArr, mainType, batchSellWarehouseType );
    }

    /**斗魂库筛选品质请求
     *
     * @quality 斗魂库筛选品质记录  1-白 2-绿 3-蓝 4-紫 5-橙 (整个发送)
     *
     * */
    public final function requestWarehouseSelect( qualityArr : Array ) : void {
        _talentNetProxy.warehouseSelectRequest( qualityArr );
    }

    /**
     * 斗魂信息请求
     *
     * */
    public final function requestTalentInfoRequest() : void {
        _talentNetProxy.talentInfoRequest();
    }

    /**
     * 斗魂回收请求
     */
    public final function requestSoulRecycle(meltType:int, recycleSoul:Array):void
    {
        _talentNetProxy.soulRecycleRequest(meltType, recycleSoul);
    }

    //------------------
    //----ico path相关--
    //-----------------
    public final function getTalentIcoPath( icoName : String ) : String {
        return ETalentIcoURL.PATH + icoName + ".png";
    }

    //是否由可以镶嵌的格子红点检测
    private function _judgeRed( page : int ) : Boolean {
        if ( page == ETalentPageType.PEAK && !(_talentSysytem.stage.getSystem( CSwitchingSystem ) as CSwitchingSystem).isSystemOpen( KOFSysTags.TALENT_PEAK ) ) {
            return false;
        }

        var talentPageData : CTalentAllPointData = CTalentDataManager.getInstance().getTalentPagePointData( page );
        var i : int = 0;
        var openLv : int = 0;
        var talentPointSoul : TalentSoulPoint = null;
        var isShowTabRedPoint : Boolean = false;
        if ( talentPageData ) {
            var talentPointDataVec : Vector.<CTalentPointData> = talentPageData.pointInfos;
            var len : int = talentPointDataVec.length;
            var talentPointData : CTalentPointData = null;
            for ( var j : int = 0; j < len; j++ ) {
                if ( isShowTabRedPoint ) {
                    break;
                }
                talentPointData = talentPointDataVec[ j ];
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForID( talentPointData.soulPointConfigID )
                for ( i = 1; i <= 30; i++ ) {
                    if ( isShowTabRedPoint ) {
                        break;
                    }
                    if ( i == talentPointSoul.pointID ) {
                        if ( talentPointData.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                            if ( CTalentDataManager.getInstance().getTalentPointForWarehouse( i, page ).length ) {
                                isShowTabRedPoint = true;
                            }
                        }
                    }
                }
            }
            //下一个开启的位置
            var nextPointArr : Array = CTalentFacade.getInstance().nextOpenSePointID( page );
            var nextPoint : int = nextPointArr.length > 0 ? nextPointArr[ 0 ] : 0;
            if ( nextPoint > 0 ) {
                talentPointSoul = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage( nextPoint, page );
                openLv = getTalentOpenLv( talentPointSoul.pointID, page );
                if ( openLv <= CTalentFacade.getInstance().teamLevel ) {
                    isShowTabRedPoint = true;
                }
            }
        }

        return isShowTabRedPoint;
    }

    private function get _helper():CTalentHelpHandler
    {
        return CTalentFacade.getInstance().talentAppSystem.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
    }
}
}

class PrivateCls {

}
