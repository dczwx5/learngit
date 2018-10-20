//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/10/10.
 * Time: 16:29
 */
package kof.game.currency.tipview {


import flash.utils.clearInterval;
import flash.utils.setInterval;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.currency.enum.ECardType;
import kof.game.platform.tx.data.CTXData;
import kof.game.platform.tx.enum.ETXIdentityType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.task.CTaskManager;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskData;
import kof.table.CardMonthConfig;
import kof.table.PassiveSkillPro;
import kof.table.VipPrivilege;
import kof.ui.demo.Currency.MoneyOneTipsUI;
import kof.ui.master.BargainCard.GoldtipsUI;
import kof.ui.master.BargainCard.SilvertipsUI;

import morn.core.components.TextArea;

    public class CTipsViewHandler extends CViewHandler {
        private var _isInit:Boolean=false;

        private var m_pUI : MoneyOneTipsUI;
        private var m_goldTips:GoldtipsUI=null;
        private var m_silverTips:SilvertipsUI=null;
        /**蓝钻*/
        public static const BLUE_DIAMOND : int = 1;
        /**紫钻*/
        public static const PURPLE_DIAMOND : int = 2;
        /**金币*/
        public static const GOLD : int = 3;
        /**体力*/
        public static const PHYSCAL_POWER : int = 4;
        /**周卡*/
        public static const WEEK_CARD : int = 5;
        /**月卡*/
        public static const MONTH_CARD : int = 6;

        private var m_sNu : String = "";

        public function CTipsViewHandler() {
            super( false ); // load view by default to call onInitializeView
        }

        override public function dispose() : void {
            super.dispose();
            m_pUI = null;
        }

        override public function get viewClass() : Array {
            return [ MoneyOneTipsUI , GoldtipsUI , SilvertipsUI];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            onInitializeView();
        }

        /* private function loadAssets() : Boolean { */
        /* if ( !App.loader.getResLoaded( "comp.swf" ) */
        /* || !App.loader.getResLoaded("tips.swf")) */
        /* { */
        /* App.loader.loadAssets( [ */
        /* "comp.swf", */
        /* "tips.swf" */
        /* ], */
        /* new Handler( _onAssetsCompleted ), null, null, false); */
        /* return false; */
        /* } */
        /* return true; */
        /* } */

        override protected function onInitializeView() : Boolean {
            if(!_isInit){
                m_pUI = m_pUI || new MoneyOneTipsUI();
                m_goldTips=m_goldTips||new GoldtipsUI();
                m_silverTips=m_silverTips||new SilvertipsUI();
                var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
                if ( txtArea ) {
                    txtArea.skin = null;
                    txtArea.isHtml = true;
                    txtArea.autoSize = "left";
                } else {
                    LOG.logWarningMsg( "The View CTipsViewHandler's UI page doesn't contains a TextArea named 'txtArea'." )
                }
                _isInit = true;
            }
            return Boolean( m_pUI );
        }

        protected function _showDisplay() : void {
            if ( onInitializeView() ) {
                invalidate();
                _showTips(_type,_str);
            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        }

        private function  _updateVit(e:CPlayerEvent):void{
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            _countDownMTime = heroData.vitData.remainTimeGetNextVit/1000;
            _countDownHTime = 0;
            var vitMax : int = heroData.vitMax;
            var vitDValue : int = vitMax - heroData.vitData.physicalStrength;
            vitDValue = vitMax - heroData.vitData.physicalStrength;
            _vitMaxTime = vitDValue * 5 * 60;
        }
        private var _type:int=0;
        private var _str:String="";
        /**
         * type 1蓝钻，2紫钻，3金币，4体力
         * */
        public function show( type : int = 1, str : String = null ) : void {
            _type = type;
            _str = str;
            this.loadAssetsByView( viewClass, _showDisplay );
        }

        private function _showTips(type : int = 1, str : String = null):void{
            if(system.stage.getSystem(CPlayerSystem).hasEventListener(CPlayerEvent.PLAYER_VIT)==false){
                system.stage.getSystem(CPlayerSystem).addEventListener( CPlayerEvent.PLAYER_VIT, _updateVit );
            }
            clearInterval(_timeStampIntervelID);
            m_sNu = "";
            if ( m_pUI ) {
                switch ( type ) {
                    case 1:
                        blueDiamond();
                        break;
                    case 2:
                        purpleDiamond();
                        break;
                    case 3:
                        gold();
                        break;
                    case 4:
                        physcalPower();
                        break;
                    case 5:
                        weekCard( ECardType.WEEK );
                        break;
                    case 6:
                        monthCard( ECardType.MONTH );
                        break;
                    default:
                        defaultShow( str );
                        break;
                }
                if(type==5){
                    App.tip.addChild(m_silverTips);
                }else if(type==6){
                    App.tip.addChild(m_goldTips);
                }else{
                    var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
                    txtArea.height = txtArea.textField.textHeight + 20;
                    m_pUI.getChildByName( "bg" ).height = txtArea.height;
                    App.tip.addChild( m_pUI );
                }
            }
        }

        private function defaultShow( str : String ) : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = "<font color = '#ffffff'>" + str + "\n" +
                    "</font>";
        }

        private function blueDiamond() : void {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = CLang.Get( "tips_blue_diamond", {v1 : modifyNuShow( heroData.currency.blueDiamond )} );
        }

        private function purpleDiamond() : void {
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = CLang.Get( "tips_purple_diamond", {v1 : modifyNuShow( heroData.currency.purpleDiamond )} );
        }

        private function gold() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            txtArea.text = CLang.Get( "tips_gold", {v1 : modifyNuShow( heroData.currency.gold )} );
        }

        private var _lastVitNu:int=0;
        private function physcalPower() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE ) as CDataTable;
            //vip等级
            var vipData : VipPrivilege = talble.findByPrimaryKey( heroData.vipData.vipLv );
            var vitToltalCount : int = vipData.phyCountLimit;

            var vitMax : int = heroData.vitMax;
            var vitDValue : int = vitMax - heroData.vitData.physicalStrength;
            var str : String = "";
            var nextTime : String = "";
            var totalTime : String = "";
            if ( vitDValue <= 0 ) {
                str = CLang.Get( "tips_vit_limit" );
                nextTime = "00:00:00";
                totalTime = "00:00:00";
                txtArea.text = CLang.Get( "tips_vit_tip", {
                    /*v1 : modifyNuShow( heroData.vitData.physicalStrength ),*/
                    v2 : heroData.vitData.buyPhysicalStrengthCount,
                    v3 : vitToltalCount,
                    v4 : nextTime,
                    v5 : totalTime,
                    v6 : str
                } );
            }
            else {
                str = CLang.Get( "tips_vit_5min" );
                if(_countDownMTime<=0||_lastVitNu!=vitDValue){
                    _lastVitNu=vitDValue;
                    _countDownMTime = heroData.vitData.remainTimeGetNextVit/1000;
                    _countDownHTime = 0;
                    vitDValue = vitMax - heroData.vitData.physicalStrength;
                    _vitMaxTime = vitDValue * 5 * 60;
                }
                nextTime = showTime( _countDownMTime );
                totalTime = showTime( _vitMaxTime - _countDownHTime );
                txtArea.text = CLang.Get( "tips_vit_tip", {
                    /* v1 : modifyNuShow( heroData.vitData.physicalStrength ),*/
                    v2 : heroData.vitData.buyPhysicalStrengthCount,
                    v3 : vitToltalCount,
                    v4 : nextTime,
                    v5 : totalTime,
                    v6 : str
                } );
                    _timeStampIntervelID = setInterval( function():void{
                        if(_countDownMTime<=0){
                            _countDownMTime = heroData.vitData.remainTimeGetNextVit/1000;
                            _countDownHTime = 0;
                            vitDValue = vitMax - heroData.vitData.physicalStrength;
                            _vitMaxTime = vitDValue * 5 * 60;
                        }
                        nextTime = showTime( _countDownMTime );
                        totalTime = showTime( _vitMaxTime - _countDownHTime );
                        txtArea.text = CLang.Get( "tips_vit_tip", {
                           /* v1 : modifyNuShow( heroData.vitData.physicalStrength ),*/
                            v2 : heroData.vitData.buyPhysicalStrengthCount,
                            v3 : vitToltalCount,
                            v4 : nextTime,
                            v5 : totalTime,
                            v6 : str
                        } );
                        _countDownMTime--;
                        _countDownHTime++;
                    }, 1000 );

            }
        }
        private var _vitMaxTime:int=0;
        private var _countDownMTime:int=0;
        private var _countDownHTime:int=0;
        private var _timeStampIntervelID:int = 0;

        private var playerData : CPlayerData = null;
        private var taskManager : CTaskManager = null;
        private var cardConfig : CardMonthConfig = null;

        private function card( cardType : int ) : void {
            var talble : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            talble = pDatabaseSystem.getTable( KOFTableConstants.CARD_MONTH_CONFIG ) as CDataTable;
            //vip等级
            cardConfig = talble.findByPrimaryKey( cardType );
            taskManager = system.stage.getSystem( CTaskSystem ).getBean( CTaskManager ) as CTaskManager;
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            playerData = playerManager.playerData;
        }
        //白银月卡
        private function weekCard( cardType : int ) : void {
            card( cardType );
//            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            // 0未购买 1购买
            if ( playerData.monthAndWeekCardData.silverCardState ) {
                var taskData : CTaskData = taskManager.getTaskDataByTaskID( cardConfig.taskID );
//                if ( !taskData ) {
//                    txtArea.text = CLang.Get( "weekCardBuyGet" );
//                } else {
//                    txtArea.text = CLang.Get( "weekCardBuyNotGet" );
//                }
                m_silverTips.notjh.visible = false;
                m_silverTips.jh.visible = true;
                m_silverTips.sclip.index=1;
            }
            else {
//                txtArea.text = CLang.Get( "weekCardNotBuy" );
                m_silverTips.notjh.visible = true;
                m_silverTips.jh.visible = false;
                m_silverTips.sclip.index=0;
            }
            m_silverTips.t1.isHtml = true;
            m_silverTips.t2.isHtml = true;
            var passiveSkillPro : PassiveSkillPro = _passiveSkillProTable.findByPrimaryKey( cardConfig.propertyID[0] );
            m_silverTips.t1.text = passiveSkillPro.name+"<font color = '#00ff00'>+"+cardConfig.propertyValue[0]+"</font>";
            m_silverTips.v1.visible = false;
            passiveSkillPro = _passiveSkillProTable.findByPrimaryKey( cardConfig.propertyID[1] );
            m_silverTips.t2.text = passiveSkillPro.name+"<font color = '#00ff00'>+"+cardConfig.propertyValue[1]+"</font>";
            m_silverTips.v2.visible = false;
            m_silverTips.dt.text = cardConfig.everydayRewardNum+"";
        }
        //黄金月卡
        private function monthCard( cardType : int ) : void {
            card( cardType );
//            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            // 0未购买 1购买
            if ( playerData.monthAndWeekCardData.goldCardState ) {
                var taskData : CTaskData = taskManager.getTaskDataByTaskID( cardConfig.taskID );
//                if ( !taskData ) {
//                    txtArea.text = CLang.Get( "monthCardBuyGet" );
//                } else {
//                    txtArea.text = CLang.Get( "monthCardBuyNotGet" );
//                }
                m_goldTips.notjh.visible = false;
                m_goldTips.jh.visible = true;
                m_goldTips.gclip.index=1;
            }
            else {
//                txtArea.text = CLang.Get( "monthCardNotBuy" );
                m_goldTips.notjh.visible = true;
                m_goldTips.jh.visible = false;
                m_goldTips.gclip.index=0;
            }
            m_goldTips.t1.isHtml = true;
            m_goldTips.t2.isHtml = true;
            var passiveSkillPro : PassiveSkillPro = _passiveSkillProTable.findByPrimaryKey( cardConfig.propertyID[0] );
            m_goldTips.t1.text = passiveSkillPro.name+"<font color = '#00ff00'>+"+cardConfig.propertyValue[0]+"</font>";
            m_goldTips.v1.visible = false;
            passiveSkillPro = _passiveSkillProTable.findByPrimaryKey( cardConfig.propertyID[1] );
            m_goldTips.t2.text = passiveSkillPro.name+"<font color = '#00ff00'>+"+cardConfig.propertyValue[1]+"</font>";
            m_goldTips.v2.visible = false;
            m_goldTips.dt.text = cardConfig.everydayRewardNum+"";
        }

        private function get _passiveSkillProTable() : CDataTable {
            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            return pDatabaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO ) as CDataTable;
        }

        private function showTime( nu : int ) : String {
            var s : int = nu % 60;
            var m : int = nu / 60 % 60;
            var h : int = nu / 60 / 60;
            return modityTimeNuShow( h ) + ":" + modityTimeNuShow( m ) + ":" + modityTimeNuShow( s );
        }

        private function modityTimeNuShow( nu : int ) : String {
            return nu < 10 ? "0" + nu : nu + "";
        }

        private function modifyNuShow( nu : Number ) : String {
            if ( nu < 1000 )return nu + "";
            var a : Number = int( nu / 1000 );
            var c : Number = int( nu % 1000 );
            var str : String = judgeNu( c );
            m_sNu = str + m_sNu;
            if ( a > 1000 ) {
                modifyNuShow( a );
            }
            else {
                m_sNu = a + m_sNu;
            }

            return m_sNu;
        }

        private function judgeNu( nu : Number ) : String {
            if ( nu < 10 ) {
                return ",00" + nu;
            }
            else if ( nu < 100 ) {
                return ",0" + nu;
            } else {
                return "," + nu;
            }
        }

        public function close() : void {
            if ( uiCanvas.rootContainer.contains( m_pUI ) ) {
                uiCanvas.rootContainer.removeChild( m_pUI );
            }
        }

        private function _isBlue() : Boolean {
            var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return false;

            return txData.isQGame;
        }

        private function _isYellow() : Boolean {
            var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return false;

            return txData.isQZone;
        }

        private function _hallInfoTips() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = CLang.Get( "hallInfo" );
        }

        private function _blueIntoTips() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = CLang.Get( "blueInto" );
        }

        private function _yellowIntoTips() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.text = CLang.Get( "yellowInto" );
        }

        private var _systag:String="";
        private var _isEntraceIcon:Boolean;
        public function showQQTips( systag : String, isEntraceIcon : Boolean = true ) : void {
            _systag = systag;
            _isEntraceIcon = isEntraceIcon;
            this.loadAssetsByView( viewClass, _showQQTipsDisplay );

        }

        private function _showQQTipsDisplay():void{
            if ( onInitializeView() ) {
                invalidate();
                _showQQTips();
            } else {
                // Show warning, error, etc.
                LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
            }
        }

        private function _showQQTips():void{
            var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) return ;

            var type : int = txData.getQQIdentity();
            if ( _isEntraceIcon ) {
                if ( _isBlue() && _systag == KOFSysTags.QQ_BLUE_DIAMOND ) {
                    _blueIntoTips();
                    _showText();
                } else if ( _isYellow() && _systag == KOFSysTags.QQ_YELLOW_DIAMOND ) {
                    _yellowIntoTips();
                    _showText();
                } else if ( _isBlue() && _systag == KOFSysTags.QQ_HALL ) {
                    _hallInfoTips();
                    _showText();
                }
            } else {
                switch ( type ) {
                    case ETXIdentityType.SUPER_BLUE_YEAR:
                        _superBlueYear();
                        break;
                    case ETXIdentityType.SUPER_BLUE:
                        _superBlue();
                        break;
                    case ETXIdentityType.BLUE_YEAR:
                        _blueYear();
                        break;
                    case ETXIdentityType.BLUE:
                        _blueTips();
                        break;
                    case ETXIdentityType.YELLOW_YEAR:
                        _yellowYear();
                        break;
                    case ETXIdentityType.YELLOW:
                        _yellow();
                        break;
                }

            }
        }

        private function _showText() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            txtArea.height = txtArea.textField.textHeight + 20;
            m_pUI.getChildByName( "bg" ).height = txtArea.height;
            App.tip.addChild( m_pUI );
        }

        private function _yellow() : void {
            var txtArea : TextArea = m_pUI.getChildByName( "txtArea" ) as TextArea;
            //战队数据
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var heroData : CPlayerData = playerManager.playerData;
            txtArea.text = CLang.Get( "tips_gold", {v1 : modifyNuShow( heroData.currency.gold )} );
        }

        private function _yellowYear() : void {

        }

        private function _blueTips() : void {

        }

        private function _blueYear() : void {

        }

        private function _superBlue() : void {

        }

        private function _superBlueYear() : void {

        }
    }
}
