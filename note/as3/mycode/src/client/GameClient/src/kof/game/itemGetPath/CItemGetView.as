//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/15.
 * Time: 11:39
 */
package kof.game.itemGetPath {

    import QFLib.Foundation;

    import kof.SYSTEM_ID;
    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;
    import kof.game.bundle.CSystemBundleContext;
    import kof.game.bundle.ISystemBundle;
    import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.itemGetPath.getPaths.CGetPathContext;
    import kof.game.itemGetPath.getPaths.paths.CInstancePath;
    import kof.game.itemGetPath.getPaths.paths.CShopPath;
    import kof.game.itemGetPath.getPaths.paths.CSystemUIPath;
    import kof.table.Item;
    import kof.table.ItemGetPath;
    import kof.ui.IUICanvas;
    import kof.ui.imp_common.GetItemPathItemUI;
    import kof.ui.imp_common.getItemPathUI;

    import morn.core.components.Component;

    import morn.core.components.Dialog;

    import morn.core.handlers.Handler;
    import morn.core.utils.ObjectUtils;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/15
     */
    public class CItemGetView {
        private var _itemGetView : getItemPathUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _closeHandler : Handler = null;
        protected var _appSystem : CAppSystem = null;
        private var _itemId : Number = 0;
        private var _getPathContext : CGetPathContext = null;
        private var _sweepView : CSweepView = null;

        public function CItemGetView( uiContainer : IUICanvas ) {
            this._uiContainer = uiContainer;
            _itemGetView = new getItemPathUI();
            _itemGetView.closeHandler = new Handler( _closeHandlerExecute );
            _itemGetView.pathList.renderHandler = new Handler( _renderPathItem );

            _getPathContext = new CGetPathContext();
            _sweepView = new CSweepView( uiContainer );
            _itemGetView.item.txt_num.align = "center";
            _itemGetView.item.txt_num.letterSpacing = 0;
            _itemGetView.item.txt_num.bold = false;
        }

        public function showSweep() : void {
            _sweepView.show();
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }

        public function set appSystem( value : CAppSystem ) : void {
            _appSystem = value;
            _sweepView.appSystem = value;
        }

        public function get appSystem() : CAppSystem {
            return _appSystem;
        }

        public function show() : void {
            _uiContainer.addPopupDialog( _itemGetView );
            _addListeners();
        }

        private function _addListeners():void
        {
            var instanceSystem:CInstanceSystem = _appSystem.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            instanceSystem.addEventListener(CInstanceEvent.INSTANCE_BUY_COUNT, _onBuyCountSuccHandler);
        }

        private function _removeListeners():void
        {
            var instanceSystem:CInstanceSystem = _appSystem.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            instanceSystem.removeEventListener(CInstanceEvent.INSTANCE_BUY_COUNT, _onBuyCountSuccHandler);
        }

        private function _onBuyCountSuccHandler(e:CInstanceEvent):void
        {
            _itemGetView.pathList.refresh();
        }

        private function _closeHandlerExecute( type : String = "" ) : void {
            _closeHandler.execute();
        }

        public function close() : void {
            _closeHandler.execute();
            _itemGetView.close( Dialog.CLOSE );
            _removeListeners();
        }

        public function set itemId( value : Number ) : void {
            _itemId = value;
            _showGetItemPath();
        }

        private function _showGetItemPath() : void {
            var itemTable : Item = _getItemForItemID( _itemId );
            _itemGetView.item.img.url = itemTable.bigiconURL + ".png";
            _itemGetView.itemName.text = itemTable.name;
            _itemGetView.item.clip_bg.index = itemTable.quality;
            var bagData : CBagData = (this._appSystem.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( _itemId );
            var needNu:int = CItemGetSystem(this._appSystem).needNu;
            if ( bagData ) {
                if(needNu>bagData.num){
                    _itemGetView.item.txt_num.text = "<font color='#ff0000'>"+ bagData.num + "/"+needNu+"</font>";
                }else{
                    _itemGetView.item.txt_num.text = "<font color='#ffffff'>"+bagData.num + "/"+needNu+"</font>";
                }
                _itemGetView.itemNu.text = bagData.num + "";
            } else {
                _itemGetView.item.txt_num.text = "<font color='#ff0000'>"+ 0 + "/"+needNu+"</font>";
                _itemGetView.itemNu.text = "0";
            }
            _itemGetView.item.txt_num.isHtml=true;
            _itemGetView.item.box_effect.visible = itemTable.effect > 0 ? (itemTable.extraEffect == 0 || needNu >= itemTable.extraEffect) : false;
            if ( itemTable.path1 == "" ) {
//                _itemId = 30100001;
//                itemTable = _getItemForItemID( _itemId );
                _itemGetView.notProduce.visible = true;
                _itemGetView.pathList.visible=false;
                return;
            }
            _itemGetView.notProduce.visible=false;
            _itemGetView.pathList.visible=true;
            var iconURL : String = "";
            var arrPath : Array = [];
            var logS : String = "";
            for ( var i : int = 1; i <= 8; i++ ) {
                if ( itemTable[ "path" + i ] != "" ) {
                    arrPath.push( itemTable[ "path" + i ] );
                    logS += itemTable[ "path" + i ];
                }
            }
            _itemGetView.pathList.dataSource = arrPath;
            Foundation.Log.logMsg( "物品id:" + _itemId + "名称:" + itemTable.name + "获取途径:" + logS );
        }

        private function _getItemForItemID( id : int ) : Item {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( id );
        }

        private function _resetState( itemUI : GetItemPathItemUI ) : void {
            itemUI.btn1.label = "挑战";
            itemUI.btn1.visible = true;
            itemUI.btn2.visible = true;
            itemUI.btn3.visible = true;
            itemUI.isunLock.visible = true;
            ObjectUtils.gray( itemUI.btn2, false );
            ObjectUtils.gray( itemUI.btn3, false );
            itemUI.btn2.mouseEnabled = true;
            itemUI.btn3.mouseEnabled = true;
            itemUI.btn_add.visible = false;
        }

        private function _renderPathItem( item : Component, idx : int ) : void {
            var itemUI : GetItemPathItemUI = item as GetItemPathItemUI;
            var path : String = String( item.dataSource );
            if ( path == "null" || path == "" )return;
            var pathArr : Array = path.split( ":" );
            _resetState( itemUI );
            if ( pathArr.length > 0 ) {
                if ( pathArr[ 0 ] != "" ) {
                    var id : int = pathArr[ 0 ];
                    _setIcomSkin( path, itemUI, id );
                }
            }
        }

        private function _setIcomSkin( path : String, itemUI : GetItemPathItemUI, type : int ) : void {
            itemUI.lock.visible = true;
            itemUI.itemBox.visible = true;
            itemUI.desTxt.visible = false;
            var arr : Array = path.split( ":" );
            var pathId : int = arr[ 0 ];
            if ( pathId == 0 )return;
            var systag : String = _itemGetPath( pathId ).sysTag;
            var path2:String = "";

            switch ( type ) {
                case EItemGetPathType.PUTONG_INSTANCE:
                case EItemGetPathType.JINYING_INSTANCE:
                    _getPathContext.path = new CInstancePath( this );
                    _getPathContext.getPath( path, itemUI );
                    _isOpenSystem( systag, itemUI );//系统未开启直接锁住
                    break;
                case EItemGetPathType.SHOP:
                    _getPathContext.path = new CShopPath( this );
                    _getPathContext.getPath( path, itemUI );
                    _isOpenSystem( systag, itemUI );
                    break;
                case EItemGetPathType.HERO_ZHAOMU:
                case EItemGetPathType.ACTIVE_INSTANCE:
                case EItemGetPathType.DAILY_TASK:
                case EItemGetPathType.KING_FIGHTER:
                case EItemGetPathType.KING_FIGHTER_FAIR:
                case EItemGetPathType.SIGN:
                case EItemGetPathType.GEDOU_ZHAOJI:
                case EItemGetPathType.JINGJI_DATING:
                case EItemGetPathType.ACTIVE_HALL:
                case EItemGetPathType.HOOK:
                case EItemGetPathType.NIUDANJI:
//                case EItemGetPathType.SHE_TUAN:
//                case EItemGetPathType.SHI_LIAN_DI:
//                case EItemGetPathType.WORLD_BOSS:
                    _getPathContext.path = new CSystemUIPath( this );
                    _getPathContext.getPath( path, itemUI );
                    _isOpenSystem( systag, itemUI );
                    break;
                case EItemGetPathType.DESCRIBE:
                    itemUI.lock.visible = false;
                    itemUI.itemBox.visible = false;
                    itemUI.desTxt.visible = true;
                    itemUI.desTxt.text = arr[ 1 ];
                    break;
                case EItemGetPathType.PUTONG_INSTANCE_LAST:
                    path2 = _getLastInstancePath(EInstanceType.TYPE_MAIN);

                    _getPathContext.path = new CInstancePath( this );
                    _getPathContext.getPath( path2, itemUI );
                    _isOpenSystem( "INSTANCE", itemUI );//系统未开启直接锁住
                    break;
                case EItemGetPathType.JINYING_INSTANCE_LAST:
                    path2 = _getLastInstancePath(EInstanceType.TYPE_ELITE);

                    _getPathContext.path = new CInstancePath( this );
                    _getPathContext.getPath( path2, itemUI );
                    _isOpenSystem( "ELITE", itemUI );//系统未开启直接锁住
                    break;
            }
        }

        private function _isOpenSystem( systags : String, itemUI : GetItemPathItemUI ) : Boolean {
            var pSystemBundleCtx : ISystemBundleContext = _appSystem.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( systags ) );
                var state : int = pSystemBundleCtx.getSystemBundleState( pSystemBundle );
                if ( CSystemBundleContext.STATE_STARTED == state ) {
                    itemUI.lock.visible = false;
                    return true;
                }
                else {
                    itemUI.lock.visible = true;
                    itemUI.isunLock.text = ("(系统未开启)");
                    return false;
                }
            }
            return false;
        }

        private function _itemGetPath( id : int ) : ItemGetPath {
            var dataBaseSys : CDatabaseSystem = _appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemGetDataTable : CDataTable = dataBaseSys.getTable( KOFTableConstants.ITEM_GET_PATH ) as CDataTable;
            return itemGetDataTable.findByPrimaryKey( id ) as ItemGetPath;
        }

        /**
         * 当前章节最后一个三星通关的副本路径
         * @param instanceType
         * @return
         */
        private function _getLastInstancePath(instanceType:int):String
        {
            var path:String = "";
            var instanceData:CInstanceData = (_appSystem.stage.getSystem(CInstanceSystem) as CInstanceSystem).instanceData;
            if(instanceData)
            {
                var chapterDataArr:Array = instanceData.chapterList.getChapterListByType(instanceType);
                for(var i:int = chapterDataArr.length-1; i >= 0; i--)
                {
                    var chapterData:CChapterData = chapterDataArr[i] as CChapterData;
                    if(chapterData && instanceData.isChapterOpen(instanceType, chapterData.chapterID))
                    {
                        var instanceArr:Array = instanceData.instanceList.getByChapterID(instanceType, chapterData.chapterID);
                        for(var j:int = instanceArr.length - 1; j >= 0; j--)
                        {
                            var data:CChapterInstanceData = instanceArr[j] as CChapterInstanceData;
                            if(data.star == 3)
                            {
                                path = instanceType == EInstanceType.TYPE_MAIN ? ("1:" + data.instanceID) : ("2:" + data.instanceID);
                                return path;
                            }
                        }
                    }
                }
            }

            return path;
        }
    }
}
