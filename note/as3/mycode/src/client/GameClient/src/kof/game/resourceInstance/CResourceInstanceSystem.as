//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/20.
 */
package kof.game.resourceInstance {

import QFLib.Math.CVector2;

import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.common.view.CViewBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.resourceInstance.control.CInstanceGoldWinControl;
import kof.game.resourceInstance.control.CInstanceTrainWinControl;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.data.CInstanceDataManager;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.view.instanceResult.CInstanceGoldWinView;
import kof.game.instance.view.instanceResult.CInstanceTrainWinView;
import kof.game.item.CItemData;
import kof.game.resourceInstance.view.CGoldInstanceViewHandler;
import kof.game.resourceInstance.view.CResourceInstanceViewHandler;
import kof.game.resourceInstance.view.CTrainInstanceViewHandler;
import kof.message.Instance.ExpInstanceUpResourceResponse;
import kof.table.ResourceInstance;

import morn.core.handlers.Handler;

/**
 * 资源副本系统
 *
 * @author dendi (dendi@qifun.com)
 */
public class CResourceInstanceSystem extends CAppSystemImp {

    private var m_bInitialized : Boolean;
    private var m_handler:CResourceInstanceHandler;
    private var m_manager:CResourceInstanceManager;
    private var m_viewHandler:CResourceInstanceViewHandler;
    private var m_goldView:CGoldInstanceViewHandler;
    private var m_trainView:CTrainInstanceViewHandler;
    private var _goldInstanceOverHandler:CInstanceOverHandler;
    private var _trainInstanceOverHandler:CInstanceOverHandler;
    public function CResourceInstanceSystem( ) {
        super(  );
    }
    override public function dispose() : void {
        super.dispose();
        m_handler = null;
        m_goldView = null;
        m_trainView = null;
        m_viewHandler = null;
        m_manager = null;
        (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).unListenEvent(_onInstanceEvent);
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( m_viewHandler = new CResourceInstanceViewHandler() );
            this.addBean( m_goldView = new CGoldInstanceViewHandler() );
            this.addBean( m_trainView = new CTrainInstanceViewHandler() );
            this.addBean( m_handler = new CResourceInstanceHandler());
            this.addBean( m_manager = new CResourceInstanceManager() );
            this.addBean(_goldInstanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_GOLD_INSTANCE,
                            new Handler(showGoldResultWinView)));
            this.addBean(_trainInstanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_TRAIN_INSTANCE,
                            new Handler(showTrainResultWinView)));
            m_goldView.closeHandler = new Handler( _onDifficultyViewClosed );
            m_trainView.closeHandler = new Handler( _onDifficultyViewClosed );
            var uiHandler:CInstanceUIHandler = (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).uiHandler;
            uiHandler.addViewClassHandler(EInstanceWndType.WND_INSTANCE_RESULT_GOLD_WIN, CInstanceGoldWinView, CInstanceGoldWinControl);//金币副本
            uiHandler.addViewClassHandler(EInstanceWndType.WND_INSTANCE_RESULT_TRAIN_WIN, CInstanceTrainWinView, CInstanceTrainWinControl);//经验副本
        }

        m_viewHandler = m_viewHandler || this.getHandler( CResourceInstanceViewHandler ) as CResourceInstanceViewHandler;
        m_viewHandler.closeHandler = new Handler( _onViewClosed );

        this.registerEventType(CInstanceEvent.ENTER_INSTANCE);

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.ACTIVITY );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CResourceInstanceViewHandler = this.getHandler( CResourceInstanceViewHandler ) as CResourceInstanceViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            m_handler.onResourceInstanceInfoRequest();
            pView.addDisplay();
        } else {
            pView.removeDisplay();
            m_goldView.removeDisplay();
            m_trainView.removeDisplay();
        }
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }

        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).addExitProcess(null, null, openView, [ e.data ], 9999);
            _goldInstanceOverHandler.listenEvent();
            _trainInstanceOverHandler.listenEvent();
        } else if( e.type == CInstanceEvent.INSTANCE_PASS_REWARD && (pInstanceSystem.instanceType == EInstanceType.TYPE_GOLD_INSTANCE || pInstanceSystem.instanceType == EInstanceType.TYPE_TRAIN_INSTANCE)){
            _goldInstanceOverHandler.instanceOverEventProcess(null);
            _trainInstanceOverHandler.instanceOverEventProcess(null);
        } else if( e.type == CInstanceEvent.EXIT_INSTANCE　&& (pInstanceSystem.instanceType == EInstanceType.TYPE_GOLD_INSTANCE || pInstanceSystem.instanceType == EInstanceType.TYPE_TRAIN_INSTANCE)) {
            (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).unListenEvent( _onInstanceEvent );
//            _instanceOverHandler.unlistenEvent();
        }
    }

    public function addEvent():void{
        (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).listenEvent(_onInstanceEvent);
    }

    public function unEvent():void{
        (this.stage.getSystem( CInstanceSystem ) as CInstanceSystem).unListenEvent( _onInstanceEvent );
    }

    private function openView(data:int):void{
        var instanceType:int = (stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(data ).instanceType;
        if(instanceType == EInstanceType.TYPE_GOLD_INSTANCE){
            m_goldView.addDisplay();
        }else if(instanceType == EInstanceType.TYPE_TRAIN_INSTANCE){
            m_trainView.addDisplay();
        }

        const pCtx : ISystemBundleContext = this.ctx;
        pCtx.setUserData( this, ACTIVATED, true );

    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    private function _onDifficultyViewClosed():void{
        (this.getHandler( CResourceInstanceViewHandler ) as CResourceInstanceViewHandler).changeSite();
    }

    public function updateDamageValue(value:int):void{
        var data:Object = {damage:value};
        var event:CGoldInstanceEvent = new CGoldInstanceEvent(CGoldInstanceEvent.UPDATE_DAMAGE, data);
        dispatchEvent(event);
    }

    public function round(obj:Object):void{
        var event:CTrainInstanceEvent = new CTrainInstanceEvent(CTrainInstanceEvent.ROUND, obj);
        dispatchEvent(event);
    }

    public function updateExpAward(obj:Object):void{
        var list:Array = (obj as ExpInstanceUpResourceResponse).rewardList;
        list.sortOn("ID",Array.NUMERIC);
        var itemData:CItemData;
        for(var i:int = 0; i<list.length;i++){
            itemData = new CItemData();
            itemData.databaseSystem = stage.getSystem(IDatabase) as IDatabase;
            itemData.updateDataByData(list[i ]);
            list[i] = itemData;
        }
        var event:CTrainInstanceEvent = new CTrainInstanceEvent(CTrainInstanceEvent.UPDATE_AWARD, list);
        dispatchEvent(event);
    }

    public function startTime(value:int):void{
        var data:Object = {time:value};
        var event:CGoldInstanceEvent = new CGoldInstanceEvent(CGoldInstanceEvent.START_TIME, data);
        dispatchEvent(event);
    }

    public function showGoldFlyView(_goldNum:int,_startPos:CVector2,_countArr:Array):void{
        var data:Object = {goldNum:_goldNum,startPos:_startPos,countArr:_countArr};
        var event:CGoldInstanceEvent = new CGoldInstanceEvent(CGoldInstanceEvent.ADD_GOLD, data);
        setTimeout(function():void{dispatchEvent(event);},1000);
    }

    //小红点
    public function onRedPoint( ):void{
        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext)
        {
            var bool:Boolean;
            var resourceInstanceTable:IDataTable = (stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEINSTANCE);
            var _playerData:CPlayerData = (this.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var id:int = m_trainView.initListData()[0 ].InstanceID;
            var _instanceDate:CChapterInstanceData = (this.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(id);
            var openLevel:Boolean = _playerData.teamData.level>=_instanceDate.condLevel;

            for each( var item:Object in m_manager.m_data){
                var instanceArray:Array = resourceInstanceTable.findByProperty( "ID", item.type );
                var resItem:ResourceInstance = instanceArray[0 ] as ResourceInstance;
                if(item.challengeNum < resItem.ChallengeNum){
                    if(resItem.ID == EInstanceType.TYPE_TRAIN_INSTANCE ){
                        bool = openLevel;
                    }else {
                        bool = true;
                    }
                    break;
                }else{
                    bool = false;
                }
            }
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, bool);
        }
    }


    public function showGoldResultWinView(callback:Function = null) : void {
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;

        var instanceContentID:int = pInstanceSystem.instanceContentID;

        var dataManager:CInstanceDataManager = pInstanceSystem.instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        var instanceData:CChapterInstanceData = dataManager.instanceData.instanceList.getByID(instanceContentID);
        data.curInstanceData = instanceData;
        var uiHandler:CInstanceUIHandler = this.stage.getSystem(CInstanceSystem).getBean(CInstanceUIHandler) as CInstanceUIHandler;
        uiHandler.show(EInstanceWndType.WND_INSTANCE_RESULT_GOLD_WIN, null, callback, data);
    }

    public function showTrainResultWinView(callback:Function = null):void{
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        var instanceContentID:int = pInstanceSystem.instanceContentID;
        var uiHandler:CInstanceUIHandler = this.stage.getSystem(CInstanceSystem).getBean(CInstanceUIHandler) as CInstanceUIHandler;

        var dataManager:CInstanceDataManager = pInstanceSystem.instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        var instanceData:CChapterInstanceData = dataManager.instanceData.instanceList.getByID(instanceContentID);
        data.curInstanceData = instanceData;
        uiHandler.show(EInstanceWndType.WND_INSTANCE_RESULT_TRAIN_WIN, null, callback, data);
    }
}
}
