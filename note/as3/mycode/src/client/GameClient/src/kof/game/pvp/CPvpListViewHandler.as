//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/24.
 */
package kof.game.pvp {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.ui.demo.PVP.PvpListItemItemUI;
import kof.ui.demo.PVP.PvpListItemUI;
import kof.ui.demo.PVP.PvpListUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CPvpListViewHandler extends CViewHandler {

    private var _pvpListUI:PvpListUI;

    private var m_pCloseHandler : Handler;

    private var m_bViewInitialized : Boolean;

    public function CPvpListViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        // TODO: DISPOSE UI resources.
//        detachEventListeners();

        _pvpListUI = null;
    }

    override public function get viewClass() : Array {
        return [ PvpListUI ];
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( show );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !_pvpListUI ) {
                _pvpListUI = new PvpListUI();
                _pvpListUI.closeHandler = new Handler( _onClose );
                updateFun([]);
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    private function _addEventListeners():void {
//        _pvpListUI.btn_close.addEventListener(MouseEvent.CLICK ,_closeFun , false , 0, true );
        _pvpListUI.btn_createRoom.addEventListener(MouseEvent.CLICK ,_createRoom , false , 0, true );
        _pvpListUI.btn_return.addEventListener(MouseEvent.CLICK ,_returnRoomFun , false , 0, true );
        _pvpListUI.btn_fighting.addEventListener(MouseEvent.CLICK ,_fightingFun , false , 0, true );
        _pvpListUI.btn_lineup.addEventListener(MouseEvent.CLICK ,_lineupFun , false , 0, true );
    }

    private function _removeEventListeners():void {
        if(_pvpListUI){
//            _pvpListUI.btn_close.removeEventListener(MouseEvent.CLICK , _closeFun );
            _pvpListUI.btn_return.removeEventListener(MouseEvent.CLICK ,_returnRoomFun );
            _pvpListUI.btn_createRoom.removeEventListener(MouseEvent.CLICK ,_createRoom );
            _pvpListUI.btn_fighting.removeEventListener(MouseEvent.CLICK ,_fightingFun );
            _pvpListUI.btn_lineup.removeEventListener(MouseEvent.CLICK ,_lineupFun );
        }
    }

    private function _lineupFun(e:MouseEvent):void{
        var args : Array = [];
        switch ((system.getBean(CPvpHandler) as CPvpHandler).roomType)
        {
            case 1 :
                args = [EInstanceType.TYPE_PVP, 1];
                break;
            case 2 :
                args = [EInstanceType.TYPE_3V3, 3];
                break;
            case 3 :
                args = [EInstanceType.TYPE_3PV3P];
                break;
        }

        var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.EMBATTLE ) );
            pSystemBundleCtx.setUserData( pSystemBundle, 'embattle_args',args);
            pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
        }
    }

    private function _fightingFun(e:MouseEvent):void{
        (system.getBean(CPvpHandler) as CPvpHandler).fighttingRequest(0);
    }

    private function _returnRoomFun(e:MouseEvent):void{
        (system.getBean(CPvpHandler) as CPvpHandler).leaveRoomRequest(0);
    }

    private function _createRoom(e:MouseEvent):void{
        this.dispatchEvent(new CPvpEvent(CPvpEvent.CREATE_ROOM));
    }

    public function show():void {
        if ( _pvpListUI ) {
            uiCanvas.addDialog( _pvpListUI );
            _addEventListeners();
            _pvpListUI.pvp_list.renderHandler = new Handler(_renderItem);
            _pvpListUI.pvp_list.mouseHandler = new Handler(_listItemClickFun);
            var arr:Array = ["","拳皇争霸挑战赛--单挑挑战","拳皇争霸挑战赛--组队挑战","拳皇争霸挑战赛--小队挑战"];
            _pvpListUI.txt_roomName.text = arr[(system.getBean(CPvpHandler) as CPvpHandler).roomType];
        }
    }

    private function _listItemClickFun(evt:Event,idx : int ):void{
        if(evt.type == MouseEvent.CLICK){
            var item:PvpListItemUI = _pvpListUI.pvp_list.getCell(idx) as PvpListItemUI;
            var _pvpListData:CPvpListData;
            if(item.dataSource)
            {
                _pvpListData = item.dataSource as CPvpListData;
                var playerManager:CPlayerManager = system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
                var heroData:CPlayerData = playerManager.playerData;
                if(_pvpListData.createrInfo.roleId != heroData.ID)
                {
                    (system.getBean(CPvpHandler) as CPvpHandler).joinRoomRequest(item.dataSource.roomId);
                }
            }
        }
    }

    private function _renderItem(item:Component, idx:int) : void {
        if (!(item is PvpListItemUI)) {
            return ;
        }
        item.buttonMode = true;
        var data:Object = item.dataSource;
        if(data) {
            (item as PvpListItemUI).pvp_list_left.renderHandler = new Handler( _leftRenderItem );
            (item as PvpListItemUI).pvp_list_left.dataSource = data.leftArr;

            (item as PvpListItemUI).pvp_list_right.renderHandler = new Handler( _rightRenderItem );
            var rightArr:Array = data.rightArr;
            if( rightArr.length == 0 ){
                rightArr.push("");
            }
            (item as PvpListItemUI).pvp_list_right.dataSource = data.rightArr;
        }
        if((system.getBean(CPvpHandler) as CPvpHandler).roomType == 1){
            (item as PvpListItemUI).pvp_list_right.y = 130;
            (item as PvpListItemUI).pvp_list_left.y = 130;
        }
        else{
            (item as PvpListItemUI).pvp_list_right.y = 14;
            (item as PvpListItemUI).pvp_list_left.y = 14;
        }
    }

    private function _leftRenderItem(item:Component, idx:int):void{
        if(!(item is PvpListItemItemUI))
        {
            return;
        }

        var _item:PvpListItemItemUI = item as PvpListItemItemUI;
        var data:Object = _item.dataSource;
        var itemUI:PvpListItemItemUI = (_item as PvpListItemItemUI);
        if(data != null)
        {
            showItemUI(itemUI,data);
        }

    }

    private function _rightRenderItem(item:Component, idx:int):void{
        if(!(item is PvpListItemItemUI))
        {
            return;
        }

        var _item:PvpListItemItemUI = item as PvpListItemItemUI;
        var data:Object = _item.dataSource;
        var itemUI:PvpListItemItemUI = (_item as PvpListItemItemUI);
        if(data != null)
        {
            showItemUI(itemUI,data);
        }
    }

    private function showItemUI(itemUI:PvpListItemItemUI,data:Object):void{
        if(data == ""){
            itemUI.txt_name.visible = false;
            itemUI.img_icon.visible = false;
            itemUI.txt_level.visible = false;
            itemUI.txt_tips.visible = true;
            itemUI.icon_mask.visible = false;
            return;
        }
        else
        {
            itemUI.txt_name.visible = true;
            itemUI.img_icon.visible = true;
            itemUI.txt_level.visible = true;
            itemUI.txt_tips.visible = false;
            itemUI.icon_mask.visible = true;
        }

        var playerManager:CPlayerManager = system.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        var heroData:CPlayerData = playerManager.playerData;
        itemUI.txt_name.text = data.roleName;
        itemUI.txt_level.text = ""+data.roleLevel;
        itemUI.img_icon.url = CPlayerPath.getUIHeroIconBigPath(data.roleIcon);

        itemUI.img_icon.cacheAsBitmap = itemUI.icon_mask.cacheAsBitmap = true;
        itemUI.img_icon.mask = itemUI.icon_mask;

        if(data.roleId == heroData.ID){
//            _pvpListUI.btn_fighting.visible = false;
            _pvpListUI.btn_return.visible = true;
            _pvpListUI.btn_createRoom.visible = false;
            _pvpListUI.btn_lineup.visible = false;
        }
    }

    public function updateFun(arr:Array):void{
        _pvpListUI.pvp_list.dataSource = arr;

        _pvpListUI.txt_newRoom.visible = arr.length ? false : true;

        var playerManager:CPlayerManager = system.stage.getSystem(CPlayerSystem).getBean(CPlayerManager) as CPlayerManager;
        var heroData:CPlayerData = playerManager.playerData;

        for each(var obj:CPvpListData in arr){
            if(obj.createrInfo.roleId == heroData.ID){
                _pvpListUI.btn_fighting.visible = false;
                _pvpListUI.btn_return.visible = true;
                _pvpListUI.btn_createRoom.visible = false;
                _pvpListUI.btn_lineup.visible = false;
                if(obj.rightArr.length > 0)
                {
                    _pvpListUI.btn_fighting.visible = true;
                    _pvpListUI.btn_return.visible = true;
                    _pvpListUI.btn_createRoom.visible = false;
                    _pvpListUI.btn_lineup.visible = false;
                }
                return;
            }
        }
        _pvpListUI.btn_fighting.visible = false;
        _pvpListUI.btn_return.visible = false;
        _pvpListUI.btn_createRoom.visible = true;
        _pvpListUI.btn_lineup.visible = true;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function removeDisplay() : void {
        if ( _pvpListUI && _pvpListUI.parent) {
            _pvpListUI.close( "break" );
            _pvpListUI.remove();
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            case Dialog.CLOSE:
                (system.getBean(CPvpHandler) as CPvpHandler).leaveRoomRequest(0);
                _removeEventListeners();
                var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(KOFSysTags.PVP));
                bundleCtx.setUserData( bundle, "activated", true );
                break;
            case "break":
                (system.getBean(CPvpHandler) as CPvpHandler).leaveRoomRequest(0);
                _removeEventListeners();
                break;
            default:

                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }
}
}
