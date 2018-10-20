//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/11/9.
 */
package kof.game.embattle {

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.InstanceType;

import morn.core.handlers.Handler;

public class CEmbattleSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;
    private var _embattleManager:CEmbattleManager;
    private var _embattleHandler:CEmbattleHandler;
    private var _embattleViewHandler:CEmbattleViewHandler;

    public function CEmbattleSystem() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        _embattleManager.dispose();
        _embattleHandler.dispose();
        _embattleViewHandler.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _embattleManager = new CEmbattleManager() );
            this.addBean( _embattleHandler = new CEmbattleHandler() );
            this.addBean( _embattleViewHandler = new CEmbattleViewHandler() );
            this.addBean(new CEmbattleUtil());
        }

        _embattleViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.EMBATTLE );
    }
    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CEmbattleViewHandler = this.getHandler( CEmbattleViewHandler ) as CEmbattleViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        pView.isProcessHp = false;
        pView.isShowFight = false;
        pView.isShowQuality = true;
        pView.isShowLevel = true;
        pView.enemyList = null;
        var argsArr : * = ctx.getUserData( this, "embattle_args", false );
        if( argsArr ){
            (getBean(CEmbattleHandler ) as CEmbattleHandler).type = argsArr[0];
//            argsArr[1] ? (getBean(CEmbattleHandler ) as CEmbattleHandler).limit = argsArr[1]  : (getBean(CEmbattleHandler ) as CEmbattleHandler).limit = 3;

            if (argsArr is Array && (argsArr as Array).length > 2) {
                var isProcessHp:Boolean = (argsArr as Array)[2] as Boolean;
                pView.isProcessHp = isProcessHp;
            }
            if (argsArr is Array && (argsArr as Array).length > 3) {
                var isShowQuality:Boolean = (argsArr as Array)[3] as Boolean;
                pView.isShowQuality = isShowQuality;
            }
            if (argsArr is Array && (argsArr as Array).length > 4) {
                var isShowLevel:Boolean = (argsArr as Array)[4] as Boolean;
                pView.isShowLevel = isShowLevel;
            }
            if (argsArr is Array && (argsArr as Array).length > 5) {
                var enemyList:Array = (argsArr as Array)[5] as Array;
                pView.enemyList = enemyList;
            }
            if (argsArr is Array && (argsArr as Array).length > 6) {
                var isShowEmbattleBtn:Boolean = (argsArr as Array)[6] as Boolean;
                pView.isShowFight = isShowEmbattleBtn;
            }

        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }


    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    public function requestBestEmbattle(embattleType:int, exceptHpZero:Boolean = false) : void {
        var obj:Object;
        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var playerData:CPlayerData = playerSystem.playerData;
        var playList : Array = playerData.heroList.getCommentList(embattleType) as Array;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.INSTANCE_TYPE );
        var instanceType : InstanceType  = pTable.findByPrimaryKey( embattleType );
        var playerHeroData:CPlayerHeroData;
        var embattleMessageList:Array = [];
        var pushCount:int = 0;
        for(var i:int = 0 ;pushCount < instanceType.embattleNumLimit && i < playList.length ; i++) {
            playerHeroData = playList[i] as CPlayerHeroData;
            var needRemove:Boolean = false;
            if (exceptHpZero) {
                var extendsData:CHeroExtendsData = playerHeroData.extendsData as CHeroExtendsData;
                if (extendsData && extendsData.hp == 0) {
                    needRemove = true;
                }
            }
            if (!needRemove) {
                if(playerHeroData){
                    obj = {};
                    obj.heroID = playerHeroData.ID;
                    obj.prosession = playerHeroData.prototypeID;
                    obj.position = pushCount+1;
                    embattleMessageList.push(obj);
                    pushCount++;
                }
            }

        }
        (getBean(CEmbattleHandler ) as CEmbattleHandler).type = embattleType;
        (getBean(CEmbattleHandler) as CEmbattleHandler).onEmbattleMessageRequest(embattleMessageList);
    }

    // add by auto
    public function requestEmbattle(embattleType:int) : void {
        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var playerData:CPlayerData = playerSystem.playerData;
        var embattleList:CEmbattleListData = playerData.embattleManager.getByType(embattleType);  //.heroList.getCommentList(embattleType) as Array;
        if (embattleList) {
            var embattleMessageList:Array = embattleList.export();
            (getBean(CEmbattleHandler ) as CEmbattleHandler).type = embattleType;
            (getBean(CEmbattleHandler) as CEmbattleHandler).onEmbattleMessageRequest(embattleMessageList);
        }
    }

    // heroList : 完整的列表[heroData1, heroData2, heroData3]; // 如果有null, [heroData1, null, heroData2]
    // index为position
    public function requestEmbattleByList(embattleType:int, heroList:Array) : void {
        var embattleMessageList:Array = new Array();
        var len:int = heroList ? heroList.length : 0;
        for(var i:int = 0 ;i < len ; i++) {
            var playerHeroData:CPlayerHeroData = heroList[i] as CPlayerHeroData;
            var obj:Object;
            if(playerHeroData){
                obj = {};
                obj.heroID = playerHeroData.ID;
                obj.prosession = playerHeroData.prototypeID;
                obj.position = i+1;
                embattleMessageList[embattleMessageList.length] = (obj);
            }
        }
        (getBean(CEmbattleHandler ) as CEmbattleHandler).type = embattleType;
        (getBean(CEmbattleHandler) as CEmbattleHandler).onEmbattleMessageRequest(embattleMessageList);
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }

    public function openEmbattleViewByInstanceType(instanceType:int) : void {
        if ( ctx ) {
            var database:IDatabase = stage.getSystem(IDatabase) as IDatabase;
            var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
            var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(instanceType);
            var fighterCount:int = 3;
            if (instanceTypeRecord) {
                fighterCount = instanceTypeRecord.embattleNumLimit;
            }

            ctx.setUserData( this, 'embattle_args',[instanceType, fighterCount]);
            ctx.setUserData( this, CBundleSystem.ACTIVATED, true );
        }
    }

}
}
