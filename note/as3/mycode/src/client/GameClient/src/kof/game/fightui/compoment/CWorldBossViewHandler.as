//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/29.
 * Time: 12:26
 */
package kof.game.fightui.compoment {

    import QFLib.Foundation.CTime;

    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.clearInterval;
    import flash.utils.setInterval;
    import flash.utils.setTimeout;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CViewHandler;
import kof.framework.fsm.CStateEvent;
import kof.game.character.CCharacterDataDescriptor;
    import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.CTarget;
import kof.game.character.fight.buff.CSelfBuffInitializer;
    import kof.game.character.handler.CPlayHandler;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.character.state.CCharacterActionStateConstants;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.character.state.CCharacterStateMachine;
    import kof.game.common.CLang;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.common.view.CTweenViewHandler;
import kof.game.core.CECSLoop;
    import kof.game.core.CGameObject;
    import kof.game.globalBoss.CWorldBossHandler;
    import kof.game.globalBoss.CWorldBossSystem;
    import kof.game.globalBoss.Event.CWBEventType;
    import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.globalBoss.view.CWBResultView;
    import kof.game.globalBoss.view.CWBTips;
    import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
    import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.game.scene.CSceneEvent;
    import kof.game.scene.CSceneSystem;
import kof.table.GamePrompt;
import kof.table.PlayerLines;
    import kof.table.WorldBossConstant;
    import kof.ui.CUISystem;
    import kof.ui.IUICanvas;
    import kof.ui.demo.FightUI;
    import kof.ui.master.WorldBoss.WBAddUI;
    import kof.ui.master.WorldBoss.WBDieUI;
    import kof.ui.master.WorldBoss.WBRankUI;

    import morn.core.components.Box;
    import morn.core.components.Clip;
    import morn.core.components.Component;
    import morn.core.components.Label;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/29
     */
    public class CWorldBossViewHandler extends CTweenViewHandler {
        private var _fightUI : FightUI = null;
        private var _instanceID : Number = 0;
        private var _bViewInitialized : Boolean = false;
        private var _bcanShowReviveUI : Boolean = false;

        private var _wbDie : WBDieUI = null;
        private var _wbRank : WBRankUI = null;
        private var _wbAdd : WBAddUI = null;
        private var _bRankNormalView : Boolean = true;
        private var _bFightUIInit : Boolean = false;
        private var _wbReusltView : CWBResultView = null;
        private var _intervelID : int = 0;
        private var _iInspireType : int = 0;
        private var _roleID : Number = 0;

        private var _pRankData : Array = [];
        private var _wbDataManager : CWBDataManager = null;
        private var _wbTips : CWBTips = null;

        private var _recordReviveCount : int = 0;
        private var _uiCanvas : IUICanvas = null;
        private var _levelReadyed : Boolean = false;
        private var _currentInstanceID : Number = 0;

        public function CWorldBossViewHandler( fightUI : FightUI, uiCanvas : IUICanvas ) {
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
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
            var wbConstant : WorldBossConstant = wbInstanceTable.findByPrimaryKey( 1 );
            if ( wbConstant ) {
                _instanceID = wbConstant.instanceID;
            }
            (system.stage.getSystem( CWorldBossSystem ) as CWorldBossSystem).excuteEndLeveInstance = _resultView;
        }

        private function _heroDie( e : CCharacterEvent ) : void {
            _setPlayEnable( false );
            _heroDeadInState( e );
//            return;
//            if ( CCharacterDataDescriptor.isHero( e.character.data ) && _bcanShowReviveUI ) {
//                var hero : CGameObject = e.character;
//                if( hero ) {
//                    var pStateBoard : CCharacterStateBoard = hero.getComponentByClass( CCharacterStateBoard , false ) as CCharacterStateBoard;
//                    if( pStateBoard ){
//                        var bOnGround : Boolean = pStateBoard.getValue( CCharacterStateBoard.ON_GROUND );
//                        if( bOnGround ) _showReviveWindow();
//                        else {
//                             var pEventMediator : CEventMediator = hero.getComponentByClass( CEventMediator , false ) as CEventMediator;
//                            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE , _dieLand );
//                        }
//                    }
//                }
//            }
        }

        private function _heroDeadInState( e : CCharacterEvent ) : void {
            if ( CCharacterDataDescriptor.isHero( e.character.data ) && _bcanShowReviveUI ) {
                var hero : CGameObject = e.character;
                if( hero ) {
                    var pStateMachine : CCharacterStateMachine = hero.getComponentByClass( CCharacterStateMachine , false ) as CCharacterStateMachine;
                    if( pStateMachine && pStateMachine.actionFSM )
                    {
                        pStateMachine.actionFSM.addEventListener( CStateEvent.ENTER, _onEnterDead );
                    }
                }
            }
        }

        private function _onEnterDead( e : CStateEvent ) : void{

            if( e.to != CCharacterActionStateConstants.DEAD) return ;
            var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
            var hero : CGameObject;
            if( playHandler )
                hero =  playHandler.hero;
            if( hero == null )
                    return;
            var pStateMachine : CCharacterStateMachine = hero.getComponentByClass( CCharacterStateMachine , false ) as CCharacterStateMachine;
            if( pStateMachine && pStateMachine.actionFSM ) {
                pStateMachine.actionFSM.removeEventListener( CStateEvent.ENTER, _onEnterDead );
            }
            _showReviveWindow();
        }

        private function _showReviveWindow() : void{
                clearInterval( _intervelID );
                _fightUI.wbDie.visible = true;
                _uiCanvas.addPopupDialog( _wbDie );
                var reviveTime : int = _wbDataManager.worldBossConstant.reviveTime;
                var shi : int = reviveTime / 10;
                var ge : int = reviveTime % 10;
                _wbDie.clipNu_1.index = shi;
                _wbDie.clipNu_2.index = ge;
                _intervelID = setInterval
                ( function () : void {
                    reviveTime--;
                    if ( reviveTime < 0 ) {
                        clearInterval( _intervelID );
                    }
                    shi = reviveTime / 10;
                    ge = reviveTime % 10;
                    _wbDie.clipNu_1.index = shi;
                    _wbDie.clipNu_2.index = ge;
                }, 1000 );

                _wbDie.diamondLabel.text = _wbDataManager.revivePriceForCount( _recordReviveCount + _wbDataManager.wbData.diamondReviveTimes + 1 ) + "";
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

        private function _wbexitInstance( e : CInstanceEvent ) : void {
            if ( _currentInstanceID == _instanceID ) {
                _removeEvent();
                clearInterval( _intervelID );
                _fightUI.wbDie.visible = false;
                _wbDie.close();
                 _setPlayEnable(true);
            }
        }

        private function _removeEvent() : void {
            _wbDataManager.removeEventListener( CWBEventType.UPDATE_WBINFO, _updateWBInfo );
            _wbDataManager.removeEventListener( CWBEventType.START_FIGHT, _startFight );
            _wbDataManager.removeEventListener( CWBEventType.REVIVE, _reviveSuccess );
//            _wbDataManager.removeEventListener( CWBEventType.RESULT, _resultView );
            (system.stage.getSystem( CECSLoop ) as CECSLoop ).removeEventListener( CCharacterEvent.DIE, _heroDie );
//            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.LEVEL_READY, _levelReady );
            (system.stage.getSystem( CSceneSystem ) as CSceneSystem).removeEventListener( CSceneEvent.HERO_READY, _playerReady );
            (system.stage.getSystem( CWorldBossSystem ) as CWorldBossSystem ).removeInstanceOverEvent();
        }

        private function _enterInstance( e : CInstanceEvent ) : void {
            _currentInstanceID = Number( e.data );
            if ( e.data == _instanceID ) {
                _fightUI.wbRank.visible = true;
                _fightUI.wbAdd.visible = true;
                _fightUI.wbDie.visible = false;
                _bcanShowReviveUI = true;
//                _fightUI.exit_btn.visible = true;
                _fightUI.bossArriveTime.visible = true;
                _recordReviveCount = 0;//重置上一次在副本中钻石复活的次数
                _wbDataManager = (system.stage.getSystem( CWorldBossSystem ) as CWorldBossSystem).getBean( CWBDataManager );
                _timeStamp = (_wbDataManager.wbData.startTime - CTime.getCurrServerTimestamp()) / 1000;
                _countDown();
                clearInterval( _timeStampIntervelID );
                _timeStampIntervelID = setInterval( _countDown, 1000 );
                if ( !_bFightUIInit ) {
                    _bFightUIInit = true;
                    _wbReusltView = new CWBResultView( uiCanvas, system );
                    _initView();
                }
                if(_wbDataManager.wbData.state==2)
                {
                    _resultView();
                    _updateWBInfo(null);
                }
                _initEvent();
            } else {
                _fightUI.wbRank.visible = false;
                _fightUI.wbAdd.visible = false;
                _fightUI.wbDie.visible = false;
                _bcanShowReviveUI = false;
                _fightUI.bossArriveTime.visible = false;
            }
        }

        private function _initEvent() : void {
            _wbDataManager.addEventListener( CWBEventType.UPDATE_WBINFO, _updateWBInfo );
            _wbDataManager.addEventListener( CWBEventType.START_FIGHT, _startFight );
            _wbDataManager.addEventListener( CWBEventType.REVIVE, _reviveSuccess );
//            _wbDataManager.addEventListener( CWBEventType.RESULT, _resultView );
            (system.stage.getSystem( CECSLoop ) as CECSLoop ).addEventListener( CCharacterEvent.DIE, _heroDie );
            (system.stage.getSystem( CSceneSystem ) as CSceneSystem).addEventListener( CSceneEvent.HERO_READY, _playerReady );
//            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.LEVEL_READY, _levelReady );
            (system.stage.getSystem( CWorldBossSystem ) as CWorldBossSystem ).addInstanceOverEvent();
        }

        private function _playerReady( e : CSceneEvent ) : void {
            if ( _currentInstanceID == _instanceID ){
                var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
                if ( playHandler.hero )
                    _playerGetReady();
            }
        }

//        private function _levelReady( e : CInstanceEvent ) : void {
//            _playerGetReady();
//        }

        private function _playerGetReady() : void {
            _wbAdd.addAttackLabel.text = CLang.Get( "currentAttackAdd" ) + "暂无";
            _levelReadyed = true;
            if ( _wbDataManager.wbData.goldInspireTimes > 0 ) {
                for ( var i : int = 0; i < _wbDataManager.wbData.goldInspireTimes; i++ ) {
                    _iInspireType = 0;
                    _inspireResponse( null );
                }
            }
            if ( _wbDataManager.wbData.diamondInsoireTimes > 0 ) {
                setTimeout( function () : void {
                    for ( var j : int = 0; j < _wbDataManager.wbData.diamondInsoireTimes; j++ ) {
                        _iInspireType = 1;
                        _inspireResponse( null );
                    }
                }, 2000 );
            }
        }

        private function _startFight( e : Event ) : void {
            _wbDataManager.removeEventListener( CWBEventType.START_FIGHT, _startFight );
            _fightUI.bossArriveTime.visible = false;
        }

        private function _resultView() : void {
            clearInterval( _intervelID );
            _fightUI.wbDie.visible = false;
            _wbDie.close();
            _wbReusltView.show();

            //将boss血量置0，并置为死亡状态
            var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
            _levelReadyed = false;
            var allPlayer : Vector.<Object> = sceneSystem.findAllPlayer();
            for each ( var pObj : CGameObject in allPlayer ) {
                if ( CCharacterDataDescriptor.isHero( pObj.data ) ) {
                    var targetComp : CTarget = pObj.getComponentByClass( CTarget , false) as CTarget;
                    if( targetComp )
                        targetComp.setTargetObjects( null );
                }
            }
        }

       private function _bossDead() : void{
           var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
            var allMonster : Vector.<Object> = sceneSystem.findAllMonster();
            for each ( var obj : CGameObject in allMonster ) {
                if(!obj.isRunning) continue;
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
       }
        //复活成功
        private function _reviveSuccess( e : Event ) : void {
            if ( _wbDataManager.wbFightData.result == 1 ) {
//                _recordReviveCount++;
            }
            var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
            var allPlayer : Vector.<Object> = sceneSystem.findAllPlayer();
            for each ( var obj : CGameObject in allPlayer ) {
                if ( CCharacterDataDescriptor.isHero( obj.data ) ) {
                     _setPlayEnable( true );
                    var heroProperty : ICharacterProperty = (obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty);
                    heroProperty.HP = heroProperty.MaxHP;
                    var ret : Boolean = (obj.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator).revive( obj );
                    if ( ret ) {
                        _fightUI.wbDie.visible = false;
                        _wbDie.close();
                        clearInterval( _intervelID );
                    }
                }
            }
        }
        //更新世界boss信息
        private function _updateWBInfo( e : Event ) : void {
            if ( !_levelReadyed )return;
            _pRankData = _wbDataManager.wbFightData.rank;
            _wbRank.rankList.dataSource = _pRankData;
            _wbRank.nameList.dataSource = _pRankData;
            _wbRank.damageList.dataSource = _pRankData;
            _wbRank.heroList.dataSource = _pRankData;


            if (_wbDataManager.wbFightData.selfData) {
                var selfData:Object = _wbDataManager.wbFightData.selfData;
                _wbRank.selfDamage.text = selfData.damage + "";
                _wbRank.selfName.text = selfData.name + "";
                var playerLines : PlayerLines = _playerLineTable.findByPrimaryKey( selfData.heroId ) as PlayerLines;
                _wbRank.selfHero.text = playerLines.PlayerName;
                if ( selfData.rank > 3 ) {
                    _wbRank.selfRnk_Clip.visible = false;
                    _wbRank.selfRnk_label.text = selfData.rank + "";
                    _wbRank.selfRnk_label.visible = true;
                } else if (selfData.rank <= 0) {
                    _wbRank.selfRnk_Clip.visible = false;
                    _wbRank.selfRnk_label.text = CLang.Get("common_none");
                    _wbRank.selfRnk_label.visible = true;
                } else {
                    _wbRank.selfRnk_Clip.visible = true;
                    _wbRank.selfRnk_Clip.index = selfData.rank-1;
                    _wbRank.selfRnk_label.visible = false;
                }
                _wbAdd.addGoldLabel.text = CLang.Get( "currentGoldReward" ) + _wbDataManager.getGoldReward( selfData.damage );
            }


            //同步boss血量
            var sceneSystem : CSceneSystem = system.stage.getSystem( CSceneSystem ) as CSceneSystem;
            var allMoster : Vector.<Object> = sceneSystem.findAllMonster();
            for each ( var obj : CGameObject in allMoster ) {
                if( obj == null || !obj.isRunning ) break;
                var heroProperty : ICharacterProperty = (obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty);
                if ( heroProperty ) {
                    heroProperty.HP = _wbDataManager.wbFightData.bossHP;
                    if( heroProperty.HP == 0 )
                        _bossDead();
                }

            }
            if ( _wbDataManager.wbData.state == 1 ) {
                _fightUI.bossArriveTime.visible = false;
            }
        }

        private var _playerLineTable : CDataTable = null;

        private function _initView() : void {
            _recordReviveCount = 0;
            _wbTips = new CWBTips();
            var playerManager : CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            _roleID = playerData.ID;
            _wbAdd = _fightUI.wbAdd;
            _wbDie = _fightUI.wbDie;
            _wbDie.roleIcon.url = "icon/worldboss/dashe.png";
            _wbRank = _fightUI.wbRank;
            _wbDie.reviveBtn.clickHandler = new Handler( _revive );
            _clickClipBtn( null );
            _wbRank.clipBtn.addEventListener( MouseEvent.CLICK, _clickClipBtn );
            _wbRank.diamondInspire.clickHandler = new Handler( _diamondInspire );
            _wbRank.goldInspire.clickHandler = new Handler( _goldInspire );
            _wbRank.diamondInspire.toolTip = new Handler( _showInspireTip, [ 2 ] );
            _wbRank.goldInspire.toolTip = new Handler( _showInspireTip, [ 1 ] );
            _wbRank.txt_diamondTips.text = "剩余次数:" + (_wbDataManager.worldBossConstant.diamondInspireCount - _wbDataManager.wbData.diamondInsoireTimes);
            _wbRank.txt_goldTips.text = "剩余次数:" + (_wbDataManager.worldBossConstant.goldInspireCount - _wbDataManager.wbData.goldInspireTimes);
            system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ).addEventListener( CWBEventType.INSPIRE_RESPONSE, _inspireResponse );

            var pDatabaseSystem : CDatabaseSystem = this.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            _playerLineTable = pDatabaseSystem.getTable( KOFTableConstants.PLAYER_LINES ) as CDataTable;
            _wbRank.rankList.dataSource = _pRankData;
            _wbRank.nameList.dataSource = _pRankData;
            _wbRank.damageList.dataSource = _pRankData;
            _wbRank.heroList.dataSource = _pRankData;
            _wbRank.rankList.renderHandler = new Handler( _rankRender );
            _wbRank.nameList.renderHandler = new Handler( _nameRender );
            _wbRank.damageList.renderHandler = new Handler( _damageRender );
            _wbRank.heroList.renderHandler = new Handler( _heroRender );
        }

        private var _timeStamp : int = 0;
        private var _timeStampIntervelID : int = 0;

        private function _countDown() : void {
            if ( _timeStamp > 0 ) {
                _timeStamp--;
                var time : int = _timeStamp;
//                var h : int = time / 3600;
                var m : int = time % 3600 / 60;
                var s : int = time % 3600 % 60;
                var sh : String = "";
                var sm : String = "";
                var ss : String = "";
//                if ( h < 10 ) {
//                    sh = "0" + h;
//                } else {
//                    sh = "" + h;
//                }
                if ( m < 10 ) {
                    sm = "0" + m;
                } else {
                    sm = "" + m;
                }
                if ( s < 10 ) {
                    ss = "0" + s;
                } else {
                    ss = "" + s;
                }
                _fightUI.arriveTime.text = /*sh + ":" + */sm + "：" + ss;
            } else {
                clearInterval( _timeStampIntervelID );
                _fightUI.bossArriveTime.visible = false;
            }
        }

        //鼓舞tips
        private function _showInspireTip( type : int ) : void {
            var count : String = "";
            if ( type == 1 ) {
//                var goldNu : int = _wbDataManager.worldBossConstant.goldInspireCount - _wbDataManager.wbData.goldInspireTimes;
                count = (_wbDataManager.worldBossConstant.goldInspireCount - _wbDataManager.wbData.goldInspireTimes) + "/" + _wbDataManager.worldBossConstant.goldInspireCount;
                _wbTips.showInspire( type, _wbDataManager.worldBossConstant.goldInspirePrice, _wbDataManager.worldBossConstant.goldInspireAdd, count );
            } else {
//                var diamondNu : int = _wbDataManager.worldBossConstant.diamondInspireCount - _wbDataManager.wbData.diamondInsoireTimes;
                count = (_wbDataManager.worldBossConstant.diamondInspireCount - _wbDataManager.wbData.diamondInsoireTimes) + "/" + _wbDataManager.worldBossConstant.diamondInspireCount;
                _wbTips.showInspire( type, _wbDataManager.worldBossConstant.diamondInspirePrice, _wbDataManager.worldBossConstant.diamondInspireAdd, count );
            }
        }

        //鼓舞成功加buff
        private function _inspireResponse( e : Event ) : void {
            if(e){
                var gamePrompt:GamePrompt = _gamePrompt(3106);
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( gamePrompt.content, gamePrompt.type );
            }
            var wbDataManager : CWBDataManager = system.stage.getSystem( CWorldBossSystem ).getBean( CWBDataManager ) as CWBDataManager;
            var playHandler : CPlayHandler = (system.stage.getSystem( CECSLoop ) as CECSLoop).getBean( CPlayHandler ) as CPlayHandler;
            var buffID : Number = 0;
            //gold
            if ( _iInspireType == 0 ) {
                buffID = wbDataManager.worldBossConstant.goldInspireBuff;
                (playHandler.hero.getComponentByClass( CSelfBuffInitializer, true ) as CSelfBuffInitializer).addBuffsToSelf( [ buffID ] );
            } else if ( _iInspireType == 1 ) {//diamond
                buffID = wbDataManager.worldBossConstant.diamondInspireBuff;
                (playHandler.hero.getComponentByClass( CSelfBuffInitializer, true ) as CSelfBuffInitializer).addBuffsToSelf( [ buffID ] );
            }
            _wbAdd.addAttackLabel.text = CLang.Get( "currentAttackAdd" ) + (_wbDataManager.wbData.goldInspireTimes * 2 + _wbDataManager.wbData.diamondInsoireTimes * 4) + "%";
            _wbRank.txt_diamondTips.text = "剩余次数:" + (_wbDataManager.worldBossConstant.diamondInspireCount - _wbDataManager.wbData.diamondInsoireTimes);
            _wbRank.txt_goldTips.text = "剩余次数:" + (_wbDataManager.worldBossConstant.goldInspireCount - _wbDataManager.wbData.goldInspireTimes);
        }
    //提示
    private function _gamePrompt( id : Number ) : GamePrompt {
        var pDatabaseSystem : CDatabaseSystem = system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
        return wbInstanceTable.findByPrimaryKey( id );
    }

        private function _revive() : void {
            var blueDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.blueDiamond;
            var purpleDiamond : int = (system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager).playerData.currency.purpleDiamond;
            var price : int = _wbDataManager.revivePriceForCount( _recordReviveCount + _wbDataManager.wbData.diamondReviveTimes + 1 );

            if ( price > blueDiamond + purpleDiamond ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "bangzuan_lanzuan_notEnough" ) );
            } else {
                (system.stage.getSystem( CWorldBossSystem ).getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.reviveRequest();
//                _reviveSuccess( null );
                _recordReviveCount++;
            }
        }

        private function _heroRender( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : Object = item.dataSource;
            if ( !data )return;
            var playerLines : PlayerLines = _playerLineTable.findByPrimaryKey( data.heroId ) as PlayerLines;
            (itemUI.getChildByName( "heroLabel" ) as Label).text = playerLines.PlayerName;
        }

        private function _damageRender( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : Object = item.dataSource;
            if ( !data )return;
            (itemUI.getChildByName( "damageLabel" ) as Label).text = data.damage + "";
        }

        private function _nameRender( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : Object = item.dataSource;
            if ( !data )return;
            (itemUI.getChildByName( "nameLabel" ) as Label).text = data.name;
        }

        private function _rankRender( item : Component, idx : int ) : void {
            var itemUI : Box = item as Box;
            var data : Object = item.dataSource;
            if ( !data )return;
            if ( idx < 3 ) {
                (itemUI.getChildByName( "rankClip" ) as Clip).visible = true;
                (itemUI.getChildByName( "rankClip" ) as Clip).index = idx;
                (itemUI.getChildByName( "rankLabel" ) as Label).text = "";
            } else {
                (itemUI.getChildByName( "rankClip" ) as Clip).visible = false;
                (itemUI.getChildByName( "rankLabel" ) as Label).text = (idx + 1) + "";
            }

        }

        private function _goldInspire() : void {
            if ( _wbDataManager.wbData.goldInspireTimes >= _wbDataManager.worldBossConstant.goldInspireCount ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "goldInspireCountMax" ) + _wbDataManager.worldBossConstant.goldInspireCount + "！" );
            } else {
                _iInspireType = 0;
                (system.stage.getSystem( CWorldBossSystem ).getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.worldBossInspireRequest( 0 );
            }
        }

        private function _diamondInspire() : void {
            if ( _wbDataManager.wbData.diamondInsoireTimes >= _wbDataManager.worldBossConstant.diamondInspireCount ) {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( CLang.Get( "diamondInspireCountMin" ) + _wbDataManager.worldBossConstant.diamondInspireCount + "！" );
            } else {
                _iInspireType = 1;
                (system.stage.getSystem( CWorldBossSystem ).getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.worldBossInspireRequest( 1 );
            }
        }

        private function _clickClipBtn( e : MouseEvent ) : void {
            _bRankNormalView = !_bRankNormalView;
            if ( _bRankNormalView ) {
                _normal();
            } else {
                _narrow();
            }
        }

        private function _narrow() : void {
            _wbRank.bg.height = 133;
            _wbRank.clipBtn.y = 106;
            _wbRank.clipBtn.scaleY = -1;
            _wbRank.selfBox.y = 111;
            _wbRank.diamondInspire.y = 134;
            _wbRank.goldInspire.y = 134;
            _wbRank.txt_diamondTips.y = _wbRank.diamondInspire.y + 60;
            _wbRank.txt_goldTips.y = _wbRank.goldInspire.y + 60;

            _wbRank.rankList.repeatY = 3;
            _wbRank.nameList.repeatY = 3;
            _wbRank.damageList.repeatY = 3;
            _wbRank.heroList.repeatY = 3;
        }

        private function _normal() : void {
            _wbRank.bg.height = 288;
            _wbRank.clipBtn.y = 250;
            _wbRank.clipBtn.scaleY = 1;
            _wbRank.selfBox.y = 267;
            _wbRank.diamondInspire.y = 294;
            _wbRank.goldInspire.y = 294;
            _wbRank.txt_diamondTips.y = _wbRank.diamondInspire.y + 60;
            _wbRank.txt_goldTips.y = _wbRank.goldInspire.y + 60;

            _wbRank.rankList.repeatY = 10;
            _wbRank.nameList.repeatY = 10;
            _wbRank.damageList.repeatY = 10;
            _wbRank.heroList.repeatY = 10;
        }
    }
}
