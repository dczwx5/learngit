//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/9.
 */
package kof.game.npc {

import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.instance.config.CInstancePath;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.table.NPC;
import kof.ui.master.NPC.NPCOnlyDialogueUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CNPCDialogueViewHandler extends CNPCViewHandlerBase {

    private var m_npcDialogueViewUI:NPCOnlyDialogueUI;
    private var m_pDate:NPC;

    private var m_bViewInitialized : Boolean;
    private var m_data:Object;
    private var m_position:CVector3;
    public function CNPCDialogueViewHandler() {
        super();
    }

    override public function updateFun(data:Object, position:CVector3):void
    {
        m_data = data;
        m_position = position;
        if(m_npcDialogueViewUI){
            m_npcDialogueViewUI.txt_name.text = data.name;
            var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.NPC);
            var iNpcID : int = CCharacterDataDescriptor.getPrototypeID( data );
            m_pDate = pTable.findByPrimaryKey( iNpcID ) as NPC;
            m_npcDialogueViewUI.txt_describe.text = m_pDate.panelDesc;
            m_npcDialogueViewUI.img_icon.url = CInstancePath.getNPCSmallIcon(m_pDate.bustResource);
        }
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_npcDialogueViewUI ) {
                m_npcDialogueViewUI = new NPCOnlyDialogueUI();

                m_npcDialogueViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

                if(m_data){
                    updateFun(m_data,m_position);
                }
            }
        }

        return m_bViewInitialized;
    }

    override public function get viewClass() : Array {
        return [ NPCOnlyDialogueUI ];
    }

    override public function _addToDisplay() : void {
        if ( m_npcDialogueViewUI ){
            uiCanvas.addPopupDialog( m_npcDialogueViewUI );
            super._addToDisplay();
            var vector3:CVector3 = CObject.get2DPositionFrom3D( m_position.x, m_position.z, m_position.y );
            var vector2:CVector2 = new CVector2(vector3.x, vector3.y);
            var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            if (scene) {
                scene.mainCamera.worldToScreen(vector2);
            }

            if(vector2.x < system.stage.flashStage.width/2){
                m_npcDialogueViewUI.x += m_npcDialogueViewUI.width/1.5;
            }else{
                m_npcDialogueViewUI.x -= m_npcDialogueViewUI.width/1.5  ;
            }
        }
    }

    override public function removeDisplay() : void {
        if ( m_npcDialogueViewUI ) {
            m_npcDialogueViewUI.close( Dialog.CLOSE );
            m_npcDialogueViewUI.remove();
            super.removeDisplay();
        }
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            case Dialog.CLOSE:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                    super.removeDisplay();
                }
                break;
        }
    }
}
}
