//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.taskcallup.CTaskCallUpHandler;
import kof.table.CoupleRelationship;
import kof.ui.imp_common.RoleDetailsUI;
import kof.ui.master.JueseAndEqu.RoleItem02UI;
import kof.ui.master.taskcallup.TaskCallUpLoveItemUI;
import kof.ui.master.taskcallup.TaskCallUpLoveUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CTaskCallUpLoveViewHandler extends CViewHandler {

    private var _taskCallUpLoveUI : TaskCallUpLoveUI;

    private var m_pCloseHandler : Handler;


    public function CTaskCallUpLoveViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _taskCallUpLoveUI = null;
    }
    override public function get viewClass() : Array {
        return [ TaskCallUpLoveUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_taskCallUpLoveUI ) {
            _taskCallUpLoveUI = new TaskCallUpLoveUI();

            _taskCallUpLoveUI.list.renderHandler = new Handler( renderItem );
            _taskCallUpLoveUI.list.dataSource = [];

            _taskCallUpLoveUI.closeHandler = new Handler( _onClose );
        }

        return _taskCallUpLoveUI;
    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is TaskCallUpLoveItemUI)) {
            return;
        }
        var taskCallUpLoveItemUI:TaskCallUpLoveItemUI = item as TaskCallUpLoveItemUI;
        if( taskCallUpLoveItemUI.dataSource ){
            var coupleRelationship : CoupleRelationship = taskCallUpLoveItemUI.dataSource as CoupleRelationship;
            var index : int;
            for( index = 0 ; index < 3 ; index ++ ){
                _onItemInfoHandler( coupleRelationship.heroId[index] , taskCallUpLoveItemUI['item_' + index] );
            }

        }
    }
    private function _onItemInfoHandler( heroID : int ,roleItem : RoleItem02UI ):void{

        roleItem.visible = heroID > 0;
        if( heroID <= 0 )
                return;
        var heroData : CPlayerHeroData = _playerData.heroList.getHero( heroID );
        if (!heroData) {
            roleItem.visible = false;
            return ;
        }
        roleItem.visible = true;
        roleItem.quality_clip.index = heroData.qualityLevelValue;
//        roleItem.star_list.repeatX = heroData.star;
//        roleItem.star_list.dataSource = new Array(heroData.star);
//        roleItem.star_list.right = roleItem.star_list.right;

        roleItem.lv_txt.visible = false;
        roleItem.level_frame_img.visible = false;
        roleItem.star_list.visible = false;

        roleItem.icon_image.cacheAsBitmap = true;
        roleItem.hero_icon_mask.cacheAsBitmap = true;
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);


    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        if ( _taskCallUpLoveUI ) {

            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.COUPLERELATIONSHIP );
            _taskCallUpLoveUI.list.dataSource = pTable.toArray();

            uiCanvas.addDialog( _taskCallUpLoveUI );
        }

    }

    public function removeDisplay() : void {
        if ( _taskCallUpLoveUI ) {
            _taskCallUpLoveUI.close( Dialog.CLOSE );
        }
    }
    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }

    private function get _pTaskCallUpHandler():CTaskCallUpHandler{
        return system.getBean( CTaskCallUpHandler ) as CTaskCallUpHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

}
}
