//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/20.
 */
package kof.game.resourceInstance.view {

import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.resourceInstance.CResourceInstanceManager;
import kof.table.ResourceInstance;
import kof.ui.master.ResourceInstance.ResourceInstancItemGoldUI;
import kof.ui.master.ResourceInstance.ResourceInstancItemTrainUI;
import kof.ui.master.ResourceInstance.ResourceInstanceViewUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

/**
 * 资源副本界面
 *
 * @author dendi (dendi@qifun.com)
 */
public class CResourceInstanceViewHandler extends CTweenViewHandler {

    private var m_pViewUI : ResourceInstanceViewUI;
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;


    public function CResourceInstanceViewHandler( ) {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        removeDisplay();
        m_pViewUI = null;
    }

    override public function get viewClass() : Array {
        return [ ResourceInstanceViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_pViewUI ) {
                m_pViewUI = new ResourceInstanceViewUI();
                var data:Array = (system.getHandler(CResourceInstanceManager) as CResourceInstanceManager).m_data;
                if(data){
                    update(data);
                }
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tips, CLang.Get("resourceInstance_rule"));
            }
        }

        return m_bViewInitialized;
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

    public function changeSite():void{
        m_pViewUI.list_gold.selectedIndex = 2;
        m_pViewUI.list_train.selectedIndex = 2;
    }

    public function update(data:Object):void{
        if(m_pViewUI){
            var resourceInstanceTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.RESOURCEINSTANCE);
            var instanceArray:Array;
            var resItem:ResourceInstance;
            for each( var item:Object in data) {
                instanceArray = resourceInstanceTable.findByProperty( "ID", int(item.type) );
                resItem = instanceArray[0 ] as ResourceInstance;


                if ( item.type == EInstanceType.TYPE_GOLD_INSTANCE ) {
                    (m_pViewUI.list_gold.getCell(0 )as ResourceInstancItemGoldUI).txt_time.text = (resItem.ChallengeNum - item.challengeNum)+"/"+resItem.ChallengeNum;
                }else if(item.type == EInstanceType.TYPE_TRAIN_INSTANCE ){
                    (m_pViewUI.list_train.getCell(0 )as ResourceInstancItemTrainUI).txt_time.text = (resItem.ChallengeNum - item.challengeNum)+"/"+resItem.ChallengeNum;
                }
            }




        }
    }

    private function _addToDisplay() : void {
        setTweenData(KOFSysTags.ACTIVITY);
        showDialog(m_pViewUI, false, _addToDisplayB);
    }
    private function _addToDisplayB() : void {
        uiCanvas.addDialog( m_pViewUI );
        m_pViewUI.list_gold.addEventListener(MouseEvent.CLICK, listClickFun, false, 0, true);
        m_pViewUI.list_train.addEventListener(MouseEvent.CLICK, listClickFun, false, 0, true);
    }
    public function removeDisplay() : void {
        closeDialog(_removeDisplayB);
    }
    private function _removeDisplayB() : void {
        if ( m_pViewUI ) {
            m_pViewUI.list_gold.removeEventListener(MouseEvent.CLICK, listClickFun);
            m_pViewUI.list_train.removeEventListener(MouseEvent.CLICK, listClickFun);
        }
    }

    private function listClickFun(e:MouseEvent):void{
        switch( e.currentTarget ){
            case  m_pViewUI.list_gold:
                (system.getBean(CGoldInstanceViewHandler) as CGoldInstanceViewHandler).addDisplay();
                break;
            case  m_pViewUI.list_train:
                (system.getBean(CTrainInstanceViewHandler) as CTrainInstanceViewHandler).addDisplay();
                break;
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
}
}
