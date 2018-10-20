//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/15.
 * Time: 11:29
 */
package kof.game.itemGetPath {

    import kof.SYSTEM_ID;
import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.KOFSysTags;
    import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.table.GamePrompt;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/15
     */
    public class CItemGetSystem extends CBundleSystem {
        private var _bIsInitialize : Boolean = false;
        private var _itemGetView : CItemGetViewHandler = null;
        public var currentInstanceData : CChapterInstanceData = null;
        public var itemID:Number=0;
        public var needNu:int=0;

        public function CItemGetSystem() {
            super();
        }

        override public function get bundleID() : * {
            return SYSTEM_ID( KOFSysTags.ITEM_GET_PATH );
        }

        override public function initialize() : Boolean {
            if ( !super.initialize() )
                return false;
            if ( !_bIsInitialize ) {
                _bIsInitialize = true;
                this.addBean( _itemGetView = new CItemGetViewHandler() );
                this._initialize();
            }
            return _bIsInitialize;
        }

        private function _initialize() : void {
            this._itemGetView = getBean( CItemGetViewHandler );
            _itemGetView.closeHandler = new Handler( _closeView );
        }

        override protected function onActivated( value : Boolean ) : void {
            super.onActivated( value );
            if ( value ) {
                _itemGetView.show();
            }
        }

        private function _closeView() : void {
            this.setActivated( false );
        }

        /**
         * @param itemId 物品id
         * @param closePopupUI 关闭正在获取物品的这个系统的二级界面，当物品获取系统跳转去商店等等后，会调用这个关闭函数，如果有的话
         * @param needNu 需要物品的数量，装配培养、角色培养，需要的物品数量
         *
         * */
        public function showItemGetPath( itemId : Number, closePopupUI : Function = null , needNu:int=0) : void {
            _closePopupUIFunc = closePopupUI;
            this.needNu = needNu;
            itemID = itemId;
            _itemGetView.itemId = itemId;
            this.setActivated( true );
        }

        private var _closePopupUIFunc : Function = null;

        public function get closePopupUI() : Function {
            return _closePopupUIFunc;
        }

        public function openPower():void {
            var pSystemBundleCtx : ISystemBundleContext = this.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var systemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.BUY_POWER ) );
                pSystemBundleCtx.setUserData( systemBundle, CBundleSystem.ACTIVATED, true );
            }

            var gamePrompt : GamePrompt = this._gamePromptTable.findByPrimaryKey( 206 ) as GamePrompt;
            if ( gamePrompt ) {
                var msg : String = gamePrompt.content;
                (this.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg );
            }
        }

            /**获取错误提示表*/
            private function get _gamePromptTable() : CDataTable {
                var pDatabaseSystem : CDatabaseSystem = this.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
                return pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
            }
    }
}
