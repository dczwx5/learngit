//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/16.
 */
package kof.game.player.view.playerNew.panel {

    import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
    import kof.game.bag.CBagEvent;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
import kof.game.bundle.CChildSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
    import kof.game.common.CLang;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.itemGetPath.CItemGetSystem;
    import kof.game.player.CEquipmentNetHandler;
    import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CHeroEquipData;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.data.CPlayerHeroData;
    import kof.game.player.event.CPlayerEvent;
    import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.game.player.view.playerNew.view.equipDevelop.CAwakePart;
    import kof.game.player.view.playerNew.view.equipDevelop.CEquipItemListPart;
    import kof.game.player.view.playerNew.view.equipDevelop.CEquipLvAndQualityPart;
    import kof.game.player.view.playerNew.view.equipDevelop.CEqustoneView;
import kof.table.BundleEnable;
import kof.table.Currency;
    import kof.table.GamePrompt;
    import kof.table.Item;
    import kof.ui.CMsgAlertHandler;
    import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.jueseNew.panel.EquipUI;

    /**
     * 装备养成
     */
    public class CEquipDevelopPanel extends CPlayerPanelBase {
        private var _equipUI : EquipUI = null;
        private var _pLvAndQuality : CEquipLvAndQualityPart = null;
        private var _pEquipItemList : CEquipItemListPart = null;
        private var _pAwake : CAwakePart = null;
        private var _equipStone : CEqustoneView = null;

        private var _currentAttack : Number = 0;
        private var _currentDefense : Number = 0;
        private var _currentHP : Number = 0;
        private var _currentPower : Number = 0;
        private var _addPower : Number = 0;
        private var _addAttack : Number = 0;
        private var _addDefense : Number = 0;
        private var _addHP : Number = 0;
        private var _currentEquipData : CHeroEquipData = null;
        private var _currentHeroData : CPlayerHeroData = null;

        public static const UPDATE_STONE : String = "updateStone";

        public function CEquipDevelopPanel() {
            super();
        }

        public function get currentEquipData() : CHeroEquipData {
            return _currentEquipData;
        }

        public function get equipUI() : EquipUI {
            return this._equipUI;
        }

        public function get equipItemPart() : CEquipItemListPart {
            return _pEquipItemList;
        }

        public function get lvAndQuality() : CEquipLvAndQualityPart {
            return _pLvAndQuality;
        }

        public function get awake() : CAwakePart {
            return _pAwake;
        }

        public function get equiStone() : CEqustoneView {
            return _equipStone;
        }

        /**判断装备页面的红点*/
        public function judgeRedPt() : Boolean {
            if(!isEquipStrengOpen())
            {
                return false;
            }

            _currentHeroData = (system.getBean( CPlayerMainViewHandler ) as CPlayerMainViewHandler).currSelHeroData;
//            if(!_playerHelper.isHeroInEmbattle(_currentHeroData.prototypeID))
//            {
//                return false;
//            }

            var arr : Array = _currentHeroData.equipList.toArray();
            var len : int = arr.length;
            var bool : Boolean = false;
            for ( var i : int = 0; i < len; i++ ) {
                bool = _pLvAndQuality.judgeRedPt( arr[ i ] as CHeroEquipData );
                if ( bool ) {
                    return true;
                }
            }
            return false;
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && onInitialize();
            if ( loadViewByDefault ) {
                ret = ret && loadAssetsByView( viewClass );
                ret = ret && onInitializeView();
            }
            return ret;
        }

        override public function initializeView() : void {
            super.initializeView();
            _equipUI = new EquipUI();
            this.view = _equipUI;
            _pLvAndQuality = new CEquipLvAndQualityPart( this );
            _pAwake = new CAwakePart( this );
            _pEquipItemList = new CEquipItemListPart( this );
            _equipStone = new CEqustoneView( this );
        }

        private function _showPrompt( e : CPlayerEvent ) : void {
            _showPropertyAddTips();
            _pEquipItemList.data = _currentHeroData;
            _pLvAndQuality.selectEquipIndex = _pEquipItemList.currentEquipIndex;
            _pAwake.selectEquipIndex = _pEquipItemList.currentEquipIndex;
        }

        private function _updateUI( e : CBagEvent ) : void {
            _pEquipItemList.data = _currentHeroData;
            _pLvAndQuality.selectEquipIndex = _pEquipItemList.currentEquipIndex;
            _pAwake.selectEquipIndex = _pEquipItemList.currentEquipIndex;
            _updatePlayerBattleValue();
        }

        private function _updateUICurrency( e : CPlayerEvent ) : void {
            _pEquipItemList.data = _currentHeroData;
            _pLvAndQuality.selectEquipIndex = _pEquipItemList.currentEquipIndex;
            _pAwake.selectEquipIndex = _pEquipItemList.currentEquipIndex;
            _updatePlayerBattleValue();
        }

        override protected function _addListeners() : void {
            super._addListeners();
            system.addEventListener( CPlayerEvent.EQUIP_DATA, _showPrompt );
            system.stage.getSystem( CBagSystem ).addEventListener( CBagEvent.BAG_UPDATE, _updateUI );
            system.addEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateUICurrency );
            system.addEventListener( CPlayerEvent.PLAYER_LEVEL_UP, _updateUICurrency );
            system.addEventListener( CChildSystemBundleEvent.CHILD_BUNDLE_START, _updateTabState );
        }

        override protected function _removeListeners() : void {
            super._removeListeners();
            system.removeEventListener( CPlayerEvent.EQUIP_DATA, _showPrompt );
            system.stage.getSystem( CBagSystem ).removeEventListener( CBagEvent.BAG_UPDATE, _updateUI );
            system.removeEventListener( CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _updateUICurrency );
            system.removeEventListener( CPlayerEvent.PLAYER_LEVEL_UP, _updateUICurrency );
            system.removeEventListener( CChildSystemBundleEvent.CHILD_BUNDLE_START, _updateTabState );
        }

        override protected function _initView() : void {
            _pEquipItemList.currentTabIndex = 0;
            equipUI.visible = true;
            if ( _currentEquipData ) {
                recordCurrentPropertyValue( _currentEquipData );
                _currentPower = this._currentBattleValue();
            }

            _initTab();
        }

        private function _initTab():void
        {
            var labels:String = "";
            if(isEquipStrengOpen())
            {
                labels = "强化";
            }

            if(isEquipBreakOpen())
            {
                labels += ",觉醒";
            }

            equipUI.tab.labels = labels;

            var arr:Array = labels.split(",");
            if(arr.length > 1)
            {
                equipUI.tab.x = 670;
                equipUI.img_red1.x = 758;
                equipUI.img_red2.x = 865;
            }
            else
            {
                equipUI.tab.x = 670 + 111;
                equipUI.img_red1.x = 758 + 111;
                equipUI.img_red2.x = 865 + 111;
            }
        }

        private function _updateTabState(e:CChildSystemBundleEvent):void
        {
            if( e.data == KOFSysTags.EQP_STRONG || e.data == KOFSysTags.EQP_BREAK)
            {
                _initTab();
            }
        }

        override public function set data( value : * ) : void {
            this._currentHeroData = value;
            if ( m_bViewInitialized ) {
                _pAwake.data = value as CPlayerHeroData;
                _pLvAndQuality.data = value as CPlayerHeroData;
                _pEquipItemList.data = value as CPlayerHeroData;
                _pEquipItemList.currentTabIndex = 0;
                _currentEquipData = (value as CPlayerHeroData).equipList.toArray()[ 0 ];
            }
        }

        public function get bagManager() : CBagManager {
            return (system.stage.getSystem( CBagSystem ) as CBagSystem).getBean( CBagManager ) as CBagManager;
        }

        public function get playerData() : CPlayerData {
            return (system as CPlayerSystem).playerData;
        }

        public function getItemPath( itemID : Number ,costNum:int) : void {
            (system.stage.getSystem( CItemGetSystem ) as CItemGetSystem).showItemGetPath( itemID ,null,costNum);
        }

        public function getCurrency( type : Number ) : Currency {
            var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.CURRENCY ) as CDataTable;
            return wbInstanceTable.findByPrimaryKey( type );
        }

        public function getItem( type : Number ) : Item {
            var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return wbInstanceTable.findByPrimaryKey( type );
        }

        public function getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (system.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        public function requestEquipUpgrade( heroUniID : Number, equipUniID : Number, type : int, itemList : Array ) : void {
            (system.getHandler( CEquipmentNetHandler ) as CEquipmentNetHandler).sendEquipLevelUp( heroUniID, equipUniID, type, itemList );
        }

        public function requestEquipQuality( heroUniID : Number, equipUniID : Number ) : void {
            (system.getHandler( CEquipmentNetHandler ) as CEquipmentNetHandler).sendEquipQualityUp( heroUniID, equipUniID );
        }

        public function requestEquipStar( heroUniID : Number, equipUniID : Number, itemList : Array ) : void {
            (system.getHandler( CEquipmentNetHandler ) as CEquipmentNetHandler).sendEquipStarUp( heroUniID, equipUniID, itemList );
        }

        override public function removeDisplay() : void {
            equipUI.visible = false;
        }

        public function recordCurrentPropertyValue( equipData : CHeroEquipData ) : void {
            if ( equipData.part > 4 ) {
                _currentAttack = equipData.propertyData.PercentEquipATK;
                _currentDefense = equipData.propertyData.PercentEquipDEF;
                _currentHP = equipData.propertyData.PercentEquipHP;
            } else {
                _currentAttack = equipData.propertyData.Attack;
                _currentDefense = equipData.propertyData.Defense;
                _currentHP = equipData.propertyData.HP;
            }
            _currentEquipData = equipData;
        }

        private function _currentBattleValue() : int {
            //战队数据
            var playerManager : CPlayerManager = system.getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData.teamData.battleValue;
        }

        private function _updatePlayerBattleValue() : void {
//            _addPower = this._currentBattleValue() - _currentPower;
//            _currentPower = this._currentBattleValue();
        }

        private function _showPropertyAddTips() : void {
            if ( !_currentEquipData )return;
            if ( _currentEquipData.part > 4 ) {
                _addAttack = _currentEquipData.propertyData.PercentEquipATK - _currentAttack;
                _addDefense = _currentEquipData.propertyData.PercentEquipDEF - _currentDefense;
                _addHP = _currentEquipData.propertyData.PercentEquipHP - _currentHP;
            } else {
                _addAttack = _currentEquipData.propertyData.Attack - _currentAttack;
                _addDefense = _currentEquipData.propertyData.Defense - _currentDefense;
                _addHP = _currentEquipData.propertyData.HP - _currentHP;
            }
            var txt : String = "";
//            if ( !_addPower == 0 ) {
//                txt += CLang.Get( "battleValue" ) + "+" + _addPower + " ";
//            }
            var str : String = gamePrompt( 2003 );
            var isShowAdd : Boolean = false;
            str = str.replace( "{0}", "" );
            str = str.replace( "{1}", "" );
            str = str.replace( "+", "" );
            str = str.replace( "：", "" );
            if ( !_addAttack == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt = CLang.Get( "player_attack" ) + " + " + (_addAttack / 100).toFixed( 2 ) + "%" + " ";
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
                } else {
                    txt = CLang.Get( "player_attack" ) + " + " + _addAttack + " ";
                    (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(CLang.Get( "player_attack" ), _addAttack, CMsgAlertHandler.NORMAL);
                }
                isShowAdd = true;
//                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( str, CMsgAlertHandler.NORMAL );
//                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
            }
            if ( !_addDefense == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt = CLang.Get( "player_denfense" ) + " + " + (_addDefense / 100).toFixed( 2 ) + "%" + " ";
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
                } else {
                    txt = CLang.Get( "player_denfense" ) + " + " + _addDefense + " ";
                    (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(CLang.Get( "player_denfense" ), _addDefense, CMsgAlertHandler.NORMAL);
                }
                if ( !isShowAdd )
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( str, CMsgAlertHandler.NORMAL );
                isShowAdd = true;
//                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
            }
            if ( !_addHP == 0 ) {
                if ( _currentEquipData.part > 4 ) {
                    txt = CLang.Get( "player_hp" ) + " + " + (_addHP / 100).toFixed( 2 ) + "%" + " ";
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
                } else {
                    txt = CLang.Get( "player_hp" ) + " + " + _addHP + " ";
                    (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(CLang.Get( "player_hp" ), _addHP, CMsgAlertHandler.NORMAL);
                }
//                if ( !isShowAdd )
//                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( str, CMsgAlertHandler.NORMAL );
                isShowAdd = true;
//                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( txt, CMsgAlertHandler.NORMAL );
            }
            _addPower = 0;
            _addAttack = 0;
            _addDefense = 0;
            _addHP = 0;
        }

        public function showAddGoldView() : void {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_MONEY ) );
                if ( pSystemBundle ) {
                    pSystemBundleCtx.setUserData( pSystemBundle, "activated", true );
                    (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "goldNotEnough" ) );
                }
            }
        }

        public function gamePrompt( id : Number ) : String {
            var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
            return GamePrompt( wbInstanceTable.findByPrimaryKey( id ) ).content;
        }

        /**
         * 装备是否已开启
         * @param equipData
         * @return
         */
        public function isEquipOpen(equipData:CHeroEquipData):Boolean {
            var sysTag:String = equipData.getSysTag();
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(sysTag);
    //            if(equipData && equipData.part > 4)
    //            {
    //                var sysTag:String = equipData.part == 5 ? KOFSysTags.EQP_ATTSTRONG : KOFSysTags.EQP_HPSTRONG;
    //
    //                return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(sysTag);
    //            }
            return true;
        }

        /**
         * 装备开启等级
         * @param equipData
         * @return
         */
        public function getEquipOpenLevel(equipData:CHeroEquipData):int
        {
            var sysTag:String = equipData.getSysTag();
            var pDatabase : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
            var sysIdTable : IDataTable = pDatabase.getTable( KOFTableConstants.BUNDLE_ENABLE );
            var theFindResult : Array = sysIdTable.findByProperty( "TagID", sysTag );

            if ( theFindResult && theFindResult.length ) {
                var bundleEnable : BundleEnable = theFindResult[ 0 ] as BundleEnable;
                return bundleEnable.MinLevel;
            }
            return 0;
        }

        /**
         * 装备强化是否已开启
         * @return
         */
        public function isEquipStrengOpen():Boolean
        {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_STRONG);
        }

        /**
         * 装备觉醒是否已开启
         * @return
         */
        public function isEquipBreakOpen():Boolean
        {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_BREAK);
        }
        public function isSwordOpen() : Boolean {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_SWORD);
        }
        public function isClothOpen() : Boolean {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_CLOTHES);
        }
        public function isTrousersOpen() : Boolean {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_TROUSERS);
        }
        public function isShoesOpen() : Boolean {
            return ((system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler) as CPlayerHelpHandler).isChildSystemOpen(KOFSysTags.EQP_SHOES);
        }
    }
}
