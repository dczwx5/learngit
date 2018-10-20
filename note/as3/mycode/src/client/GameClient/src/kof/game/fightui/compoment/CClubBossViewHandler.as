//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/31.
 * Time: 15:41
 */
package kof.game.fightui.compoment {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CFacadeMediator;
import kof.game.character.fight.buff.CSelfBuffInitializer;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.clubBoss.CClubBossHandler;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.clubBoss.view.CBuffTips;
import kof.game.clubBoss.view.CCBFightResultView;
import kof.game.common.CLang;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.globalBoss.CWorldBossSystem;
import kof.game.globalBoss.datas.CWBDataManager;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneSystem;
import kof.table.Buff;
import kof.table.ClubBossBase;
import kof.table.ClubBossConstant;
import kof.table.ClubUpgradeBasic;
import kof.table.Damage;
import kof.table.PlayerLines;
import kof.table.WorldBossConstant;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.demo.FightUI;
import kof.ui.master.WorldBoss.WBDieUI;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;
import morn.core.components.Label;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/31
 */
public class CClubBossViewHandler extends CViewHandler {
    private var _fightUI : FightUI = null;
    private var _instanceIDArr : Array = [];
    private var _uiCanvas : IUICanvas = null;
    private var _bViewInitialized : Boolean = false;

    private var _cbReusltView : CCBFightResultView = null;
    private var _bFightUIInit : Boolean = false;

    private var _cbDataManager : CCBDataManager = null;
    private var _currentInstanceID : Number = 0;
    private var _heroReadyed : Boolean = false;
    private var _bcanShowReviveUI : Boolean = false;
    private var _intervelID : int = 0;
    private var _roleID : Number = 0;

    private var _cbDie : WBDieUI = null;
    private var _playerLineTable : CDataTable = null;
    private var _buffTips:CBuffTips = null;
    private var _recordReviveCount:int=0;

    public function CClubBossViewHandler( fightUI : FightUI, uiCanvas : IUICanvas ) {
        super();
        this._fightUI = fightUI;
        this._uiCanvas = uiCanvas;
    }

    override protected function onSetup() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            _addEvent();
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    private function _addEvent() : void {
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.EXIT_INSTANCE, _wbexitInstance );
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var cbBaseTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.CLUBBOSSBASE ) as CDataTable;
        var arr : Array = cbBaseTable.toArray();
        var len : int = arr.length;
        for ( var i : int = 0; i < len; i++ ) {
            var cbBase : ClubBossBase = arr[ i ];
            _instanceIDArr.push( cbBase.instanceID );
        }
        (system.stage.getSystem( CClubBossSystem ) as CClubBossSystem).excuteEndLeveInstance = _resultView;
    }

    private function _wbexitInstance( e : CInstanceEvent ) : void {
        if ( _instanceIDArr.indexOf( _currentInstanceID ) != -1 ) {
            _removeEvent();
             _setPlayEnable( true );
        }
    }

    private function _removeEvent() : void {
        _cbDataManager = (system.stage.getSystem( CClubBossSystem ) as CClubBossSystem).getBean( CCBDataManager ) as CCBDataManager;
        _cbDataManager.removeEventListener( EClubBossEventType.IN_BATTLE_INFO, _updateCBInfo );
        _cbDataManager.removeEventListener( EClubBossEventType.REVIVE, _reviveSuccess );
//        _cbDataManager.removeEventListener( EClubBossEventType.RESULT_REWARD, _resultView );
        (system.stage.getSystem( CECSLoop ) as CECSLoop ).removeEventListener( CCharacterEvent.DIE, _heroDie );
        (system.stage.getSystem( CSceneSystem ) as CSceneSystem).removeEventListener( CSceneEvent.HERO_READY, _playerReady );
        (system.stage.getSystem( CClubBossSystem ) as CClubBossSystem ).removeInstanceOverEvent();
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        _currentInstanceID = Number( e.data );
        if ( _instanceIDArr.indexOf( e.data ) != -1 ) {
            _fightUI.cbRank.visible = true;
//            _fightUI.wbAdd.visible = true;
            _fightUI.wbDie.visible = false;
            _fightUI.wbDie.talkImgBox.visible = false;
            _bcanShowReviveUI = true;
//            _fightUI.exit_btn.visible = true;
//            _fightUI.bossArriveTime.visible = true;
            _initEvent();
            _setRevieBossIcon( Number( e.data ) );
            if ( !_bFightUIInit ) {
                _bFightUIInit = true;
                _cbReusltView = new CCBFightResultView( uiCanvas, system );
                _buffTips = new CBuffTips();
            }
            _initView();
        } else {
            _fightUI.cbRank.visible = false;
//            _fightUI.wbAdd.visible = false;
            _fightUI.wbDie.visible = false;
            _fightUI.wbDie.talkImgBox.visible = true;
            _bcanShowReviveUI = false;
//            _fightUI.bossArriveTime.visible = false;
        }
    }
    //角色死亡后，弹出的boss半身像
    private function _setRevieBossIcon( instanceID : Number ) : void {
        var arr : Array = _cbDataManager.clubBossBaseTabel.toArray();
        var len : int = arr.length;
        for ( var i : int = 0; i < len; i++ ) {
            var cbBase : ClubBossBase = arr[ i ];
            if ( cbBase.instanceID == instanceID ) {
                _fightUI.wbDie.roleIcon.url = cbBase.reviveicon + cbBase.monsterId + ".png";
            }
        }
    }

    private function _initEvent() : void {
        _cbDataManager = (system.stage.getSystem( CClubBossSystem ) as CClubBossSystem).getBean( CCBDataManager ) as CCBDataManager;
        _cbDataManager.addEventListener( EClubBossEventType.IN_BATTLE_INFO, _updateCBInfo );
        _cbDataManager.addEventListener( EClubBossEventType.REVIVE, _reviveSuccess );
//        _cbDataManager.addEventListener( EClubBossEventType.RESULT_REWARD, _resultView );
        (system.stage.getSystem( CECSLoop ) as CECSLoop ).addEventListener( CCharacterEvent.DIE, _heroDie );
        (system.stage.getSystem( CSceneSystem ) as CSceneSystem).addEventListener( CSceneEvent.HERO_READY, _playerReady );
        (system.stage.getSystem( CClubBossSystem ) as CClubBossSystem ).addInstanceOverEvent();
    }

    private function _playerReady( e : CSceneEvent ) : void {
        if ( _instanceIDArr.indexOf( _currentInstanceID ) != -1 ){
            var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
            if ( playHandler.hero ){
                _playerGetReady();
                (playHandler.hero.getComponentByClass( CSelfBuffInitializer, true ) as CSelfBuffInitializer).addBuffsToSelf( [ _buffID ] );
            }
        }
    }

    private function _playerGetReady() : void {
        _heroReadyed = true;
    }
    private var _buffID:Number=0;
    private function _initView() : void {
        _recordReviveCount = 0;
        var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        _roleID = playerData.ID;
        _cbDie = _fightUI.wbDie;
        _cbDie.reviveBtn.clickHandler = new Handler( _revive );
        var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        _playerLineTable = pDatabaseSystem.getTable( KOFTableConstants.PLAYER_LINES ) as CDataTable;
        _fightUI.cbRank.clubList.dataSource = _cbDataManager.cbFightData.club;
        _fightUI.cbRank.personList.dataSource = _cbDataManager.cbFightData.personal;
        _fightUI.cbRank.clubList.renderHandler = new Handler( _rankClubRender );
        _fightUI.cbRank.personList.renderHandler = new Handler( _personRankRender );
        _fightUI.cbRank.selfDamage.text = 0 + "";
        _fightUI.cbRank.selfName.text = playerData.guideData.clubName;
        _fightUI.cbRank.selfRnk_Clip.visible = false;
        _fightUI.cbRank.selfRnk_label.text = "0";
        _fightUI.cbRank.selfRnk_label.visible = true;

        _fightUI.cbRank.selfDamage.visible = true;
        _fightUI.cbRank.selfKilled.visible = false;

        var clubLv:int = (system.stage.getSystem( CClubSystem ).getBean( CClubManager ) as CClubManager).selfClubData.level;
        var cbTable:CDataTable = pDatabaseSystem.getTable(KOFTableConstants.CLUBUPGRADEBASIC) as CDataTable;
        var cbUpgradeBasic:ClubUpgradeBasic = cbTable.findByPrimaryKey(clubLv) as ClubUpgradeBasic;
        var buffTable:CDataTable = pDatabaseSystem.getTable(KOFTableConstants.BUFF) as CDataTable;
        _buffID = cbUpgradeBasic.attackInspireBuff;
        var buffData:Buff = buffTable.findByPrimaryKey(_buffID) as Buff;
        _fightUI.cbRank.buffBg.toolTip = new Handler(_showBuffTips,[buffData.Description]);
        _fightUI.cbRank.buffClip1.index = clubLv-1;
        _fightUI.cbRank.buffClip2.index = clubLv-1;
        _fightUI.cbRank.buffClip3.index = clubLv-1;

        _fightUI.cbRank.rnkBox.mask = _fightUI.cbRank.mask1;
        _fightUI.cbRank.prnkBox.mask = _fightUI.cbRank.mask2;

        _fightUI.cbRank.clipBtn.addEventListener(MouseEvent.CLICK, _showOrHideCBRnk);
        _fightUI.cbRank.plipBtn.addEventListener(MouseEvent.CLICK, _showOrHidePersonRnk);
        _hideCBRnk();
        _hidePersonRnk();
    }

    private function _showCBRnk():void{
        _fightUI.cbRank.mask1.height = 80;
        _fightUI.cbRank.toggle1.y=115;
        _fightUI.cbRank.clipBtn.index = 0;
        _fightUI.cbRank.selfBox.y=131;
        _fightUI.cbRank.bg.height = 133;

        _fightUI.cbRank.personRnk.y=149;
        if(_fightUI.cbRank.plipBtn.index){
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+80;
        }else{
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+150;
        }
    }

    private function _showPersonRnk():void{
        _fightUI.cbRank.mask2.height = 80;
        _fightUI.cbRank.toggle2.y=115;
        _fightUI.cbRank.plipBtn.index = 0;
        _fightUI.cbRank.pselfBox.y=131;
        _fightUI.cbRank.pbg.height=133;
        _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+150;
    }

    private function _hideCBRnk():void{
        _fightUI.cbRank.mask1.height = 1;
        _fightUI.cbRank.toggle1.y=45;
        _fightUI.cbRank.clipBtn.index = 1;
        _fightUI.cbRank.selfBox.y=61;
        _fightUI.cbRank.bg.height = 60;

        _fightUI.cbRank.personRnk.y=80;
        if(_fightUI.cbRank.plipBtn.index){
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+80;
        }else{
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+150;
        }
    }

    private function _hidePersonRnk():void{
        _fightUI.cbRank.mask2.height = 1;
        _fightUI.cbRank.toggle2.y=45;
        _fightUI.cbRank.plipBtn.index = 1;
        _fightUI.cbRank.pselfBox.y=61;
        _fightUI.cbRank.pbg.height=60;

        if(_fightUI.cbRank.plipBtn.index){
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+80;
        }else{
            _fightUI.cbRank.buffBox.y=_fightUI.cbRank.personRnk.y+150;
        }
    }

    private function _showOrHideCBRnk(e:MouseEvent):void{
        if(_fightUI.cbRank.clipBtn.index){
            _showCBRnk();
        }else{
            _hideCBRnk();
        }
    }

    private function _showOrHidePersonRnk(e:MouseEvent):void{
        if(_fightUI.cbRank.plipBtn.index){
            _showPersonRnk();
        }else{
            _hidePersonRnk();
        }
    }

    private function _showBuffTips(str:String):void{
        _buffTips.showBuffTips(str);
    }

    private function _personRankRender( comp : Component, idx : int ) : void {
        var itemUI : Box = comp as Box;
        var data : Object = itemUI.dataSource;
        if ( !data )return;
        if ( data.rank > 2 ) {
            itemUI.getChildByName( "rankClip" ).visible = false;
            itemUI.getChildByName( "rankLabel" ).visible = true;
            Label( itemUI.getChildByName( "rankLabel" ) ).text = data.rank + "";
        } else {
            itemUI.getChildByName( "rankClip" ).visible = true;
            itemUI.getChildByName( "rankLabel" ).visible = false;
            Clip( itemUI.getChildByName( "rankClip" ) ).index = int( data.rank ) - 1;
        }
        var playerName : String = data.name;
        var index : int = playerName.indexOf( "." );
        Label( itemUI.getChildByName( "nameLabel" ) ).text = playerName.substr( index + 1 );
        var playerLines : PlayerLines = _playerLineTable.findByPrimaryKey( data.id ) as PlayerLines;
        Label( itemUI.getChildByName( "heroLabel" ) ).text = playerLines.PlayerName;
        var damageStr : String = "";
        if ( data.damage >= 10000 ) {
            damageStr = int( data.damage / 10000 ) + "W";
        } else {
            damageStr = data.damage + "";
        }
        Label( itemUI.getChildByName( "damageLabel" ) ).text = damageStr;
    }

    private function _rankClubRender( comp : Component, idx : int ) : void {
        var itemUI : Box = comp as Box;
        var data : Object = itemUI.dataSource;
        if ( !data )return;
        if ( data.rank > 2 ) {
            itemUI.getChildByName( "rankClip" ).visible = false;
            itemUI.getChildByName( "rankLabel" ).visible = true;
            Label( itemUI.getChildByName( "rankLabel" ) ).text = data.rank + "";
        } else {
            itemUI.getChildByName( "rankClip" ).visible = true;
            itemUI.getChildByName( "rankLabel" ).visible = false;
            Clip( itemUI.getChildByName( "rankClip" ) ).index = int( data.rank ) - 1;
        }
        Label( itemUI.getChildByName( "nameLabel" ) ).text = data.name;
        if(data.damage>=_cbDataManager.cbFightData.maxHP){
            Label( itemUI.getChildByName( "damageLabel" ) ).text = "100%";
            itemUI.getChildByName( "damageLabel" ).visible = false;
            itemUI.getChildByName( "killed" ).visible = true;
        }else{
            Label( itemUI.getChildByName( "damageLabel" ) ).text = int( data.damage * 100 / _cbDataManager.cbFightData.maxHP ) + "%";
            itemUI.getChildByName( "damageLabel" ).visible = true;
            itemUI.getChildByName( "killed" ).visible = false;
        }
    }

    private function _resultView() : void {
        clearInterval( _intervelID );
        _fightUI.wbDie.visible = false;
        _cbDie.close();
        _cbReusltView.show();
        var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
        var allMonster : Vector.<Object> = sceneSystem.findAllMonster();
        for each ( var obj : CGameObject in allMonster ) {
            var heroProperty : ICharacterProperty = (obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty);
            if ( heroProperty ) {
                heroProperty.HP = 0;
            }
            var pStateBoard : CCharacterStateBoard = (obj.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard);
            if ( pStateBoard ) {
                pStateBoard.setValue( CCharacterStateBoard.DEAD, true );
            }
            var m_pGameStateRef : CCharacterStateMachine = obj.getComponentByClass( CCharacterStateMachine, true ) as CCharacterStateMachine;
            m_pGameStateRef.actionFSM.on( CCharacterActionStateConstants.EVENT_DEAD );
        }
        _heroReadyed = false;
    }

    private function _updateCBInfo( e : Event ) : void {
        if ( !_heroReadyed )return;
        var clubData : Array = _cbDataManager.cbFightData.club;
        var len : int = clubData.length;
        _fightUI.cbRank.clubList.dataSource = clubData;
        for ( var i : int = 0; i < len; i++ ) {
            if ( clubData[ i ].self ) {
                if(clubData[ i ].damage>=_cbDataManager.cbFightData.maxHP){
                    _fightUI.cbRank.selfDamage.text = "100%";
                    _fightUI.cbRank.selfDamage.visible = false;
                    _fightUI.cbRank.selfKilled.visible = true;
                }else{
                    _fightUI.cbRank.selfDamage.text = int( clubData[ i ].damage * 100 / _cbDataManager.cbFightData.maxHP ) + "%";
                    _fightUI.cbRank.selfDamage.visible = true;
                    _fightUI.cbRank.selfKilled.visible = false;
                }
                _fightUI.cbRank.selfName.text = clubData[ i ].name + "";
                if ( i > 2 ) {
                    _fightUI.cbRank.selfRnk_Clip.visible = false;
                    _fightUI.cbRank.selfRnk_label.text = clubData[ i ].rank + "";
                    _fightUI.cbRank.selfRnk_label.visible = true;
                } else {
                    _fightUI.cbRank.selfRnk_Clip.visible = true;
                    _fightUI.cbRank.selfRnk_Clip.index = i;
                    _fightUI.cbRank.selfRnk_label.visible = false;
                }
                break;
            }
        }
        _fightUI.cbRank.personList.dataSource = _cbDataManager.cbFightData.personal;
        len = _cbDataManager.cbFightData.personal.length;
        var personData : Array = _cbDataManager.cbFightData.personal;
        for ( i = 0; i < len; i++ ) {
            if ( personData[ i ].self ) {
                _fightUI.cbRank.pselfDamage.text = personData[ i ].damage + "";
                var playerName : String = personData[ i ].name;
                var index : int = playerName.indexOf( "." );
                _fightUI.cbRank.pselfName.text = playerName.substr( index + 1 );
                var playerLines : PlayerLines = _playerLineTable.findByPrimaryKey( personData[ i ].id ) as PlayerLines;
                _fightUI.cbRank.pheroName.text = playerLines.PlayerName;
                if ( i > 2 ) {
                    _fightUI.cbRank.pselfRnk_Clip.visible = false;
                    _fightUI.cbRank.pselfRnk_label.text = personData[ i ].rank + "";
                    _fightUI.cbRank.pselfRnk_label.visible = true;
                } else {
                    _fightUI.cbRank.pselfRnk_Clip.visible = true;
                    _fightUI.cbRank.pselfRnk_Clip.index = i;
                    _fightUI.cbRank.pselfRnk_label.visible = false;
                }
                _cbDataManager.recordSelfDamage = personData[ i ].damage;
                var damageStr : String = "";
                if ( personData[ i ].damage >= 10000 ) {
                    damageStr = int( personData[ i ].damage / 10000 ) + "W";
                } else {
                    damageStr = personData[ i ].damage + "";
                }
                _fightUI.cbRank.pselfDamage.text = damageStr;
                break;
            }
        }
        //同步boss血量
        var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
        var allMoster : Vector.<Object> = sceneSystem.findAllMonster();
        for each ( var obj : CGameObject in allMoster ) {
            var heroProperty : ICharacterProperty = (obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty);
            if ( heroProperty ) {
                heroProperty.HP = _cbDataManager.cbFightData.bossHP;
            }
        }
    }

    private function _heroDie( e : CCharacterEvent ) : void {
        if ( CCharacterDataDescriptor.isHero( e.character.data ) && _bcanShowReviveUI ) {
             _setPlayEnable( false );
            clearInterval( _intervelID );
            _fightUI.wbDie.visible = true;
            _uiCanvas.addPopupDialog( _cbDie );
            var reviveTime : int = _cbDataManager.clubBossConstant.reviveTime;
            var shi : int = reviveTime / 10;
            var ge : int = reviveTime % 10;
            _cbDie.clipNu_1.index = shi;
            _cbDie.clipNu_2.index = ge;
            _intervelID = setInterval
            ( function () : void {
                reviveTime--;
                if ( reviveTime < 0 ) {
                    clearInterval( _intervelID );
                }
                shi = reviveTime / 10;
                ge = reviveTime % 10;
                _cbDie.clipNu_1.index = shi;
                _cbDie.clipNu_2.index = ge;
            }, 1000 );

            _cbDie.diamondLabel.text = _cbDataManager.revivePriceForCount( _cbDataManager.cbFightData.diamondReviveTimes + _recordReviveCount + 1 ) + "";
        }
    }
    //复活
    private function _revive() : void {
        var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
        var purpleDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.purpleDiamond;
        var price : int = _cbDataManager.revivePriceForCount( _recordReviveCount+_cbDataManager.cbFightData.diamondReviveTimes + 1 );

        if ( price > blueDiamond + purpleDiamond ) {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "bangzuan_lanzuan_notEnough" ) );
        } else {
            (system.stage.getSystem( CClubBossSystem ).getBean( CClubBossHandler ) as CClubBossHandler).cbNet.clubBossReviveRequest();
        }
    }

    private function _setPlayEnable( value : Boolean) : void{
            var pLoop:CECSLoop = system.stage.getSystem(CECSLoop) as CECSLoop;
            if (pLoop) {
                 var pPlayerHandler:CPlayHandler = pLoop.getBean(CPlayHandler) as CPlayHandler;
                 if (pPlayerHandler) {
                     pPlayerHandler.setEnable(value);
                }
            }
        }

    private function _reviveSuccess( e : Event ) : void {
        if ( _cbDataManager.revive == 1 ) {
                _recordReviveCount++;
        }
        var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
        var allPlayer : Vector.<Object> = sceneSystem.findAllPlayer();
        for each ( var obj : CGameObject in allPlayer ) {
            if ( CCharacterDataDescriptor.isHero( obj.data ) ) {
                var heroProperty : ICharacterProperty = (obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty);
                heroProperty.HP = heroProperty.MaxHP;
                var ret : Boolean = (obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator).revive( obj );
                if ( ret ) {
                    _fightUI.wbDie.visible = false;
                    _cbDie.close();
                    clearInterval( _intervelID );
                     _setPlayEnable( true );
                }
            }
        }
    }
}
}
