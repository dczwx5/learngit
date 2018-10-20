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
import kof.table.PlayerBasic;
import kof.table.TeamAddition;
import kof.ui.master.JueseAndEqu.RoleItem02UI;
import kof.ui.master.taskcallup.TaskCallUpTeamItemUI;
import kof.ui.master.taskcallup.TaskCallUpTeamUI;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CTaskCallUpTeamViewHandler extends CViewHandler {

    private var _taskCallUpTeamUI : TaskCallUpTeamUI

    private var m_pCloseHandler : Handler;


    public function CTaskCallUpTeamViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _taskCallUpTeamUI = null;
    }
    override public function get viewClass() : Array {
        return [ TaskCallUpTeamUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_taskCallUpTeamUI ) {
            _taskCallUpTeamUI = new TaskCallUpTeamUI();

            _taskCallUpTeamUI.list.renderHandler = new Handler( renderItem );
            _taskCallUpTeamUI.list.dataSource = [];

            _taskCallUpTeamUI.closeHandler = new Handler( _onClose );
        }

        return _taskCallUpTeamUI;
    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is TaskCallUpTeamItemUI)) {
            return;
        }
        var taskCallUpTeamItemUI:TaskCallUpTeamItemUI = item as TaskCallUpTeamItemUI;
        if( taskCallUpTeamItemUI.dataSource ){
            var teamAddition : TeamAddition = taskCallUpTeamItemUI.dataSource as TeamAddition;
            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_BASIC );
            var playerBasic : PlayerBasic = pTable.findByPrimaryKey( teamAddition.heroId[0] );
            taskCallUpTeamItemUI.txt_name.text = playerBasic.teamName;
            taskCallUpTeamItemUI.list.renderHandler = new Handler( renderItemItem );
            taskCallUpTeamItemUI.list.dataSource = teamAddition.heroId;
            taskCallUpTeamItemUI.kofnum.num = int(( teamAddition.addition / 10000 )* 100 ) ;
        }
    }
    private function renderItemItem(item:Component, idx:int):void {
        if (!(item is RoleItem02UI)) {
            return;
        }
        var roleItem : RoleItem02UI = item as RoleItem02UI;
        if( roleItem.dataSource ){
            var heroData : CPlayerHeroData = _playerData.heroList.getHero( int(roleItem.dataSource) );
            if (!heroData) {
                roleItem.visible = false;
                return ;
            }
            roleItem.visible = true;
            roleItem.quality_clip.index = heroData.qualityLevelValue;
            roleItem.star_list.repeatX = heroData.star;
            roleItem.star_list.dataSource = new Array(heroData.star);
            roleItem.star_list.right = roleItem.star_list.right;

            roleItem.lv_txt.visible = false;
            roleItem.level_frame_img.visible = false;

            roleItem.icon_image.cacheAsBitmap = true;
            roleItem.hero_icon_mask.cacheAsBitmap = true;
            roleItem.icon_image.mask = roleItem.hero_icon_mask;
            roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
        }
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
        if ( _taskCallUpTeamUI ) {

            var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.TEAMADDITION );
            _taskCallUpTeamUI.list.dataSource = pTable.toArray();

            uiCanvas.addDialog( _taskCallUpTeamUI );
        }

    }

    public function removeDisplay() : void {
        if ( _taskCallUpTeamUI ) {
            _taskCallUpTeamUI.close( Dialog.CLOSE );

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
