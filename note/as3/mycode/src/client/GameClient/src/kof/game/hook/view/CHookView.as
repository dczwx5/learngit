//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 11:38
 */
package kof.game.hook.view {

    import flash.events.Event;
    import flash.events.MouseEvent;
import flash.geom.Point;
import flash.system.Security;

import kof.SYSTEM_ID;

import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.hook.CHookClientFacade;
import kof.game.hook.CHookSystem;
import kof.game.hook.net.CHookNet;
    import kof.game.hook.net.CHookNetDataManager;
    import kof.game.hook.view.childViews.CHangUpIncomeView;
    import kof.game.hook.view.childViews.CHangUpResultView;
    import kof.game.hook.view.childViews.CRecommendVideoView;
    import kof.game.hook.view.childViews.CVideoListView;
    import kof.game.hook.view.childViews.CVideoPlayView;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.table.Item;
    import kof.ui.IUICanvas;
    import kof.ui.master.JueseAndEqu.RolePieceItemUI;
import kof.ui.master.hangup.HangUpRuleTipUI;
import kof.ui.master.hangup.HangUpUI;
    import kof.ui.master.messageprompt.GoodsItemUI;

    import morn.core.components.Component;
    import morn.core.components.Dialog;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/17
     */
    public class CHookView {
        private var _hookUI : HangUpUI = null;
        private var _uiContainer : IUICanvas = null;
        private var _closeHandler : Handler = null;
        private var _hookNet : CHookNet = null;
        private var _bStartHook : Boolean = false;
        private var _nElapseTime : Number = 0;
        private var _nTickTime : Number = 1;
        private var _totalTime : Number = 0;
        private var _hookTips : CHookTips = null;
        private var _video : CVideoPlayView = null;
        private var _ruleTipsUI:HangUpRuleTipUI=null;
        private var _system:CHookSystem=null;
        //---------childView----------
        private var _hangUpIncomeView : CHangUpIncomeView = null;
        private var _recommendVideoView : CRecommendVideoView = null;
        private var _videoListView : CVideoListView = null;
        public function CHookView( hookNet : CHookNet ) {
            this._hookNet = hookNet;
            _hookUI = new HangUpUI();
            _hookUI.closeHandler = new Handler( _closeHandlerExecute );
//            _hookUI.itemList.renderHandler = new Handler( _renderProp );
//            _hookUI.propPreviewLabel.toolTip = new Handler( _propPreviewToolTips );
            _hookTips = new CHookTips();

            CHookNetDataManager.instance.addEventListener( "updateHookGetDropData", _updateDrop );
            CHookNetDataManager.instance.addEventListener( "hookSuccess", _startHook );

            _video = new CVideoPlayView( this );
            _video.parent = _hookUI;

            _initChildView();
            _hookUI.tabRight.selectHandler = new Handler( _tabRightSelect );
            _hookUI.tabRight.selectedIndex = 0;
            _hookUI.tabLeft.selectedIndex = 0;
            _hookUI.rule.toolTip = new Handler(_ruleTipFunc);
            _ruleTipsUI = new HangUpRuleTipUI();
            CSystemRuleUtil.setRuleTips(_hookUI.rule,CLang.Get("videoHangUp_rule"));
        }

        public function _ruleTipFunc():void{
            App.tip.addChild(_ruleTipsUI);
        }

        public function get hookUI() : HangUpUI {
            return _hookUI;
        }

        private function _initChildView() : void {
            _hangUpIncomeView = new CHangUpIncomeView( _hookUI );
            _recommendVideoView = new CRecommendVideoView( this );
            _videoListView = new CVideoListView( this );
        }

        private function _tabRightSelect( selectIndex : int ) : void {
            if ( selectIndex == 0 ) {
                _hangUpIncomeView.hide();
                _recommendVideoView.show();
            } else if ( selectIndex == 1 ) {
                _recommendVideoView.hide();
                _hangUpIncomeView.show();
            }
        }

        public function dispose() : void {
            CHookNetDataManager.instance.removeEventListener( "updateHookGetDropData", _updateDrop );
            CHookNetDataManager.instance.removeEventListener( "hookSuccess", _startHook );
            _hookUI = null;
            _uiContainer = null;
            _closeHandler = null;
            _hookNet = null;
            _hookTips = null;
        }

        private function _startHook( e : Event ) : void {
            _bStartHook = true;
        }

        private function _closeHandlerExecute( type : String = "" ) : void {
            if ( type == Dialog.CLOSE ) {
                _closeHandler.execute();
            }
        }

        public function set uiContainer( ui : IUICanvas ) : void {
            this._uiContainer = ui;
            this._uiContainer.addDialog( this._hookUI );
        }

        public function get uiContainer() : IUICanvas {
            return _uiContainer;
        }

        public function showRecommendVideoView() : void {
            _videoListView.show();
        }

        public function show() : void {
            CHookNetDataManager.instance.clearData();
            _hookNet.hangUpInfoRequest();

            var pViewHandler:CTweenViewHandler = system.getBean(CTweenViewHandler);
            pViewHandler.setTweenData(KOFSysTags.HOOK, new Point(941, 550));
            pViewHandler.showDialog(_hookUI);

            _showVideo();
            _video.show();
            _bStartHook = true;
            _hangUpIncomeView.initEvent();
            _hookUI.tabRight.selectedIndex = 0;
            _hookUI.videoPanel.visible = false;
        }

        public function close() : void {
            var pViewHandler:CTweenViewHandler = system.getBean(CTweenViewHandler);
            pViewHandler.closeDialog(_closeB);

        }
        private function _closeB() : void {
            _hookNet.cancelHangUpRequest();
            _bStartHook = false;
            _totalTime = 0;
            _video.pause();

            _hangUpIncomeView.dispose();
//            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
//            if ( pSystemBundleCtx ) {
//                var systemBundle:ISystemBundle = pSystemBundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.HANGUP_RESULT));
//                pSystemBundleCtx.setUserData( systemBundle , "activated", true );
//            }
        }

        public function set closeHandler( value : Handler ) : void {
            this._closeHandler = value;
        }

        private function _updateDrop( e : Event ) : void {
//            _hookUI.itemList.dataSource = CHookNetDataManager.instance.getTotalProp();
        }

        private function _renderProp( item : Component, idx : int ) : void {
            var itemUI : RolePieceItemUI = item as RolePieceItemUI;
            var data : Object = item.dataSource;
            var itemTable : Item = CHookClientFacade.instance.getItemForItemID( data.itemId );
            itemUI.qualityClip.index = itemTable.quality;
            itemUI.icon_img.url = itemTable.bigiconURL + ".png";
//            itemUI.txt = data.count + "";
            var goods : GoodsItemUI = new GoodsItemUI();
            goods.img.url = itemUI.icon_img.url;
            goods.quality_clip.index = itemUI.qualityClip.index;
            goods.txt.text = data.count + "";
            itemUI.toolTip = new Handler( _showItemTips, [ goods, data.itemId ] );
        }

        private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
            _hookTips.showItemTips( goods, _getItemTableData( id ), _getItemData( id ) );
        }

        private function _getItemTableData( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        private function _getItemData( itemID : int ) : CItemData {
            var itemData : CItemData = (CHookClientFacade.instance.hookSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        private function _propPreviewToolTips() : void {
            var dropID : int = CHookClientFacade.instance.getDropPropID();
            _hookTips.showPreviewProp( dropID );
        }

        public function updateAnimation( delta : Number ) : void {
            if ( _bStartHook ) {
                _nElapseTime += delta;
                if ( _canUpdateTime ) {
                    _nElapseTime -= _nTickTime;
                    _totalTime++;
                    _hookUI.hangupTotalTime.text = _getTimeStringForTotalTime( _totalTime );
                    CHookNetDataManager.instance.totalTime = _hookUI.hangupTotalTime.text;
                }

                _video.update();
            }
        }

        private function get _canUpdateTime() : Boolean {
            return _nElapseTime >= _nTickTime;
        }

        private function _getTimeStringForTotalTime( nu : Number ) : String {
            var h : int = 0;
            var m : int = 0;
            var s : int = 0;
            var sh : String = "";
            var sm : String = "";
            var ss : String = "";
            s = nu % 3600 % 60;
            m = nu % 3600 / 60;
            h = nu / 3600;

            if ( s < 10 ) {
                ss = "0" + s;
            } else {
                ss = s + "";
            }
            if ( m < 10 ) {
                sm = "0" + m;
            } else {
                sm = "" + m;
            }
            if ( h < 10 ) {
                sh = "0" + h;
            } else {
                sh = "" + h;
            }
            return sh + ":" + sm + ":" + ss;
        }

        private function _showVideo() : void {
            _video.play();
        }

        public function playVideo( url : String, videoName : String ) : void {
            _videoListView.hide();
            _video.playSteam( url, videoName );
            _video.show();
        }

        public function set system(value:CHookSystem):void{
            _system = value;
        }

        public function get system():CHookSystem{
            return _system;
        }
    }
}
