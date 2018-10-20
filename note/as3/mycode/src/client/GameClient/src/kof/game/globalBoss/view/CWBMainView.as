//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/28.
 * Time: 11:32
 */
package kof.game.globalBoss.view {

    import QFLib.Foundation.CTime;
    import QFLib.Framework.CScene;

    import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.clearInterval;
    import flash.utils.setInterval;

    import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.framework.IDataTable;
    import kof.framework.IDatabase;
    import kof.game.KOFSysTags;
    import kof.game.bag.data.CBagData;
    import kof.game.bundle.CBundleSystem;
    import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
    import kof.game.character.NPC.CNPCByPlayer;
    import kof.game.character.handler.CPlayHandler;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.status.CGameStatus;
import kof.game.core.CECSLoop;
    import kof.game.core.CGameObject;
    import kof.game.embattle.CEmbattleEvent;
    import kof.game.embattle.CEmbattleSystem;
import kof.game.globalBoss.CWorldBossHandler;
import kof.game.globalBoss.CWorldBossViewHandler;
import kof.game.globalBoss.datas.CWBDataManager;
    import kof.game.globalBoss.net.CWBNet;
    import kof.game.instance.enum.EInstanceType;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.event.CPlayerEvent;
    import kof.game.scene.CSceneRendering;
    import kof.game.scene.CSceneSystem;
    import kof.table.InstanceType;
    import kof.table.Item;
import kof.table.WorldBossConstant;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.master.WorldBoss.WorldBossUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Component;
    import morn.core.components.Dialog;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/28
     */
    public class CWBMainView {
        protected var _uiContainer : IUICanvas = null;
        private var _pWBView : WorldBossUI = null;
        private var _closeHandler : Handler = null;
        protected var _appSystem : CAppSystem = null;
        private var _net : CWBNet = null;
        private var _wbDataManager : CWBDataManager = null;
        private var _wbTips : CWBTips = null;

        private var _treasureView : CTreasureView = null;
        private var _damageRankReward : CWBDamageRankReward = null;

        private var _timeStamp : int = 0;
        private var _timeStampIntervelID : int = 0;

        private var _heroEmbattleList:CHeroEmbattleListView;

        public function CWBMainView( uiContainer : IUICanvas ) {
            this._uiContainer = uiContainer;
            _pWBView = new WorldBossUI();
            this._uiContainer.addDialog( _pWBView );
            _pWBView.nameLable.text = "";
            _pWBView.last_kill_name_txt.text = "";
            this._pWBView.closeHandler = new Handler( _closeHandlerExecute );

            this._pWBView.battleBtn.clickHandler = new Handler( _joinBattleFunc );
            this._pWBView.embatlleBtn.clickHandler = new Handler( _opneEmBattleFunc );
            this._pWBView.rewardList.renderHandler = new Handler( _renderItemList );
            this._pWBView.treasureBtn.clickHandler = new Handler( _openTreasureFunc );
            this._pWBView.rewardTipBtn.clickHandler = new Handler( _openDamageRankRewardView );
            _wbTips = new CWBTips();
            _pWBView.bossClip.visible = false;
            CSystemRuleUtil.setRuleTips(_pWBView.helpTip,CLang.Get("worldboss_rule"));
        }

        private function _openDamageRankRewardView() : void {
            if ( !_damageRankReward ) {
                _damageRankReward = new CWBDamageRankReward( _uiContainer, _appSystem );
            }
            _damageRankReward.show();
        }

        private function _openTreasureFunc() : void {
            if ( !_treasureView ) {
                _treasureView = new CTreasureView( _uiContainer, _appSystem );
            }
            _treasureView.show();
        }

        private function _initView() : void {
            var startTime : String = _wbDataManager.worldBossConstant.worldBossStartTime;
            var arr : Array = startTime.split( "," );
            var tempStr : String = "";
            for ( var i : int = 0; i < arr.length; i++ ) {
                tempStr += " " + arr[ i ];
            }
            _pWBView.timeLable.text = tempStr;

            var itemArr : Array = [];
            var idArr : Array = _wbDataManager.worldBossConstant.showReward.split( "," );
            for ( var j : int = 0; j < idArr.length; j++ ) {
                itemArr.push( _wbDataManager.getItemForItemID( idArr[ j ] ) );
            }
            _pWBView.rewardList.dataSource = itemArr;

            var embattleSystem : CEmbattleSystem = _appSystem.stage.getSystem( CEmbattleSystem ) as CEmbattleSystem;
            var heroListData:Array = (_appSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_WORLD_BOSS);
            if ( heroListData.length == 0 ) {
                embattleSystem.requestBestEmbattle( EInstanceType.TYPE_WORLD_BOSS );
            }
            if ( _wbDataManager.wbData.state == 2 ) {
                _pWBView.bossClip.index = 2;
                _pWBView.battleBtn.visible = false;
                _pWBView.battleBtn.visible = false;
                _pWBView.countDown.visible = true;
                _pWBView.countDownTxt.visible = true;
//                ObjectUtils.gray( _pWBView.battleBtn, true );
                _pWBView.talkLabel.visible = true;
                _pWBView.talkLabel.text = _wbDataManager.getWorldBossChatContentForState( 2 );
            } else {
                _pWBView.bossClip.index = 0;
                _pWBView.battleBtn.visible = true;
                _pWBView.countDown.visible = false;
                _pWBView.countDownTxt.visible = false;
//                ObjectUtils.gray( _pWBView.battleBtn, false );
                _pWBView.talkLabel.visible = true;
                _pWBView.battleBtn.visible = true;
                if ( _wbDataManager.wbData.state == 1 ) {
                    _pWBView.talkLabel.text = _wbDataManager.getWorldBossChatContentForState( 1 );
                } else {
                    _pWBView.talkLabel.text = _wbDataManager.getWorldBossChatContentForState( 0 );
                }
            }
            _timeStamp = (_wbDataManager.wbData.startTime - CTime.getCurrServerTimestamp()) / 1000;
            clearInterval( _timeStampIntervelID );
            if ( _pWBView.countDown.visible ) {
                _countDown();
                _timeStampIntervelID = setInterval( _countDown, 1000 );
            }
            _pWBView.bossClip.visible = true;
        }

        private function _showEmbattleHero() : void {
            var embattleSystem : CEmbattleSystem = _appSystem.stage.getSystem( CEmbattleSystem ) as CEmbattleSystem;
            var heroListData:Array = (_appSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_WORLD_BOSS);
            if ( heroListData.length == 0 ) {
                embattleSystem.requestBestEmbattle( EInstanceType.TYPE_WORLD_BOSS );
            } else {
                _updateHookHeroData();
            }
        }

        private function _updateHookHeroData( e : Event = null ) : void {
            if (_heroEmbattleList == null) {
                _pWBView.hero_em_list.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
                    if (e.type == MouseEvent.CLICK) {
                        _opneEmBattleFunc();
                    }
                });
                _heroEmbattleList = new CHeroEmbattleListView(_appSystem, _pWBView.hero_em_list, EInstanceType.TYPE_WORLD_BOSS, null, null, false, false, false);
//                _heroEmbattleList = new CHeroEmbattleListView(_appSystem, _pWBView.hero_em_list, EInstanceType.TYPE_WORLD_BOSS, new Handler(_opneEmBattleFunc));
            }
            _heroEmbattleList.updateWindow();
        }

        private function _countDown() : void {
            if ( _timeStamp > 0 ) {
                _timeStamp--;
                var time : int = _timeStamp;
                var h : int = time / 3600;
                var m : int = time % 3600 / 60;
                var s : int = time % 3600 % 60;
                var sh : String = "";
                var sm : String = "";
                var ss : String = "";
                if ( h < 10 ) {
                    sh = "0" + h;
                } else {
                    sh = "" + h;
                }
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
                _pWBView.countDown.text = sh + ":" + sm + ":" + ss;
                if ( _timeStamp <= 180 ) {//开战前三分钟可以进入战场
                    (_appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.queryWorldBossInfoRequest();
                }
            }
        }

        private function _addDataUpdateEvent() : void {
            this._wbDataManager.addEventListener( "updateJoinFight", _joinFight );
            this._wbDataManager.addEventListener( "openView", _updateView );
            this._wbDataManager.addEventListener( "treasureInfo", _updateView );
        }

        private function _updateView( e : Event ) : void {
            if ( _wbDataManager.sLastHighDamageName == "" ) {
                _pWBView.nameLable.text = "无";
            } else {
                _pWBView.nameLable.text = _wbDataManager.sLastHighDamageName;
            }
            if ( _wbDataManager.lastFinaLDamagePlayer == "" ) {
                _pWBView.last_kill_name_txt.text = "无";
            } else {
                _pWBView.last_kill_name_txt.text = _wbDataManager.lastFinaLDamagePlayer;
            }

            _pWBView.treasureNuLabel.text = "(" + _wbDataManager.wbData.remainderTimes + /* "/" + _wbDataManager.wbData.totalTimes + */")";
            _initView();
            _showRedImg();
        }

        //参与封印
        private function _joinFight( e : Event ) : void {
            if ( this._wbDataManager.bCanJoinFight ) {
//                (_appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).enterInstance( _wbDataManager.worldBossConstant.instanceID );
            }
        }

        public function set appSystem( value : CAppSystem ) : void {
            this._appSystem = value;
            this._net = (this._appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet;
            this._wbDataManager = this._appSystem.getBean( CWBDataManager ) as CWBDataManager;
            _addDataUpdateEvent();
            _appSystem.stage.getSystem( CEmbattleSystem ).addEventListener( CEmbattleEvent.EMBATTLE_SUCC, _updateHookHeroData );
            _showEmbattleHero();
            _wbTips.appSystem = value;
        }

        private function _renderItemList( item : Component, idx : int ) : void {
            var itemUI : RewardItemUI = item as RewardItemUI;
            var data : Item = itemUI.dataSource as Item;
            if ( !data )return;
            itemUI.bg_clip.index = data.quality;
            itemUI.icon_image.url = data.smalliconURL + ".png";
            itemUI.num_lable.text = "";
            if(data.quality>=4){
                itemUI.clip_eff.play();
            }
            itemUI.box_eff.visible = data.effect;
            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = data.bigiconURL + ".png";
            var bagData : CBagData = _wbDataManager.getItemNuForBag( data.ID );
            if ( bagData ) {
                goods.txt.text = bagData.num + "";
            } else {
                goods.txt.text = "0";
            }
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID ] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
            _wbTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ) );
        }

        private function _opneEmBattleFunc() : void {
            var database : IDatabase = _appSystem.stage.getSystem( IDatabase ) as IDatabase;
            var instanceTypeTable : IDataTable = database.getTable( KOFTableConstants.INSTANCE_TYPE );
            var instanceTypeRecord : InstanceType = instanceTypeTable.findByPrimaryKey( EInstanceType.TYPE_WORLD_BOSS );
            var fighterCount : int = 3;
            if ( instanceTypeRecord ) {
                fighterCount = instanceTypeRecord.embattleNumLimit;
            }

            var pSystemBundleCtx : ISystemBundleContext = _appSystem.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
                pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args', [ EInstanceType.TYPE_WORLD_BOSS, fighterCount ] );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }

        //参与封印
        private function _joinBattleFunc() : void {
            if (!CGameStatus.checkStatus(_appSystem)){
                return;
            }
            var pDatabase:IDatabase = _appSystem.stage.getSystem(IDatabase) as IDatabase;
            var record:WorldBossConstant = (pDatabase.getTable(KOFTableConstants.WORLD_BOSS_CONSTANT ).toArray())[0] as WorldBossConstant;
            if (_wbDataManager.wbData.rankRewardedTimes >= record.rankRewardLimit) {
                var pUISystem:CUISystem = _appSystem.stage.getSystem(CUISystem) as CUISystem;
                pUISystem.showMsgBox(CLang.Get("world_boss_can_not_get_reward_tips"), function () : void {
                    _gotoDaSheNpc();
                });
            } else {
                _gotoDaSheNpc();
            }
        }

        //跑到世界boss NPC位置后再进入战斗
        private function _gotoDaSheNpc() : void {
            var pCSceneSystem : CSceneSystem = _appSystem.stage.getSystem( CSceneSystem ) as CSceneSystem;
            var pCGameObject : CGameObject = pCSceneSystem.findNPCByPrototypeID( _wbDataManager.worldBossConstant.NPCID );
            if ( pCGameObject && pCGameObject.transform ) {
                var hero : CGameObject = (pCSceneSystem.stage.getSystem( CECSLoop ).getBean( CPlayHandler ) as CPlayHandler).hero;
                var npc : CNPCByPlayer = hero.getComponentByClass( CNPCByPlayer, false ) as CNPCByPlayer;
                var scene : CScene = ((_appSystem.stage.getSystem( CSceneSystem ) as CSceneSystem).getBean( CSceneRendering ) as CSceneRendering).scene;
                npc.moveToWorldBossNPC( pCGameObject, scene, _joinInstance );
            }
        }

        private function _joinInstance() : void {
            _net.joinWorldBossRequest();
        }

        public function show() : void {
            (_appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.queryWorldBossInfoRequest();
            (_appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.queryWorldBossTreasureInfoRequest();
            _appSystem.stage.getSystem( CPlayerSystem ).addEventListener( CPlayerEvent.PLAYER_VIP_LEVEL, _updateVipTreasureCount );
//            this._uiContainer.addDialog( _pWBView );

            var pWorldBossViewHandler:CWorldBossViewHandler = (_appSystem.getBean(CWorldBossViewHandler) as CWorldBossViewHandler);
            pWorldBossViewHandler.setTweenData(KOFSysTags.WORLD_BOSS);
            pWorldBossViewHandler.showDialog(_pWBView);

            clearInterval( _timeStampIntervelID );

            _showRedImg();
        }

        private function _showRedImg() : void {
            if ( _wbDataManager.judgeTreasureRedPoint() ) {
                _pWBView.img_red.visible = true;
            } else {
                _pWBView.img_red.visible = false;
            }
        }

        private function _updateVipTreasureCount( e : CPlayerEvent ) : void {
            (_appSystem.getBean( CWorldBossHandler ) as CWorldBossHandler).WBNet.queryWorldBossTreasureInfoRequest();
        }

        public function close() : void {
            var pWorldBossViewHandler:CWorldBossViewHandler = (_appSystem.getBean(CWorldBossViewHandler) as CWorldBossViewHandler);
            pWorldBossViewHandler.closeDialog(function () : void {
                clearInterval( _timeStampIntervelID );
            });
        }

        private function _closeHandlerExecute( type : String = "" ) : void {
            if ( type == Dialog.CLOSE ) {
                _closeHandler.execute();
                clearInterval( _timeStampIntervelID );
            }
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = _appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (_appSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }
    }
}
