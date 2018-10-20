//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/12/14.
 */
package kof.game.player.view.playerNew {

import QFLib.Utils.PathUtil;

import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.table.FlagDes;
import kof.ui.master.jueseNew.panel.SkillTagItemUI;
import kof.ui.master.jueseNew.panel.SkillTagUI;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CSkillTagViewHandler extends CViewHandler {

    private var _skillTagUI : SkillTagUI;

    public function CSkillTagViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function get viewClass() : Array {
        return [ SkillTagUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_skillTagUI ){
            _skillTagUI = new SkillTagUI();
            initUI();
        }
        return Boolean( _skillTagUI );
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
    public function _addToDisplay( ):void {
        if( !_skillTagUI.parent )
            uiCanvas.addPopupDialog( _skillTagUI );
    }
    public function removeDisplay() : void {
        if ( _skillTagUI ) {
            _skillTagUI.close( Dialog.CLOSE );
        }
    }
    private function initUI():void{
        _skillTagUI.list.renderHandler = new Handler(_renderSkillTag);
        var pTable : IDataTable  = _databaseSystem.getTable( KOFTableConstants.FLAGDES );
        _skillTagUI.list.dataSource = pTable.toArray();
    }
    private function _renderSkillTag(item:Component, idx:int):void {
        if ( !(item is SkillTagItemUI) ) {
            return;
        }
        var skillTagItemUI : SkillTagItemUI = item as SkillTagItemUI;
        if ( skillTagItemUI.dataSource ) {
            var flagDes : FlagDes = skillTagItemUI.dataSource as FlagDes;
            skillTagItemUI.imgView.img.url = PathUtil.getVUrl( flagDes.IconName );
            skillTagItemUI.txt_desc.addEventListener( Event.CHANGE, _onItemTxtChange );
            skillTagItemUI.txt_desc.text = flagDes.Description;
        }
    }
    private function _onItemTxtChange( evt : Event ):void{
        var label: Label = evt.currentTarget as Label;
        label.centerY = 0;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
