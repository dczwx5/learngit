//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/20.
 * 这个界面不用了
 */
package kof.game.npc {

import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.instance.config.CInstancePath;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.table.NPC;
import kof.ui.master.NPC.NPCDialogueUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CNPCSelectViewHandler extends CNPCViewHandlerBase {
    private var m_npcViewUI:NPCDialogueUI;

    private var m_pDate:NPC;
    private var m_position:CVector3;
    private var m_bViewInitialized : Boolean;
    public function CNPCSelectViewHandler() {
        super();
    }

    override public function updateFun(data:Object, position:CVector3):void
    {
        m_npcViewUI.txt_name.text = data.name;
        m_position = position;
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.NPC);
        var iNpcID : int = CCharacterDataDescriptor.getPrototypeID( data );
        m_pDate = pTable.findByPrimaryKey( iNpcID ) as NPC;
        m_npcViewUI.txt_describe.text = m_pDate.panelDesc;
        m_npcViewUI.img_bust.url = CInstancePath.getInstanceBGIcon(m_pDate.bustResource);
        var len:int = 4;
        for(var i:int = 0; i < len; i++)
        {
            if(m_pDate["function"+i ].Type == ""){
                m_npcViewUI["box_"+i ].visible = false;
            }
            else{
                m_npcViewUI["box_"+i ].visible = true;
                m_npcViewUI["btn_text_"+i].label = m_pDate["function"+i ].Desc;
                m_npcViewUI.btn_text_0.addEventListener(MouseEvent.CLICK, clickFun);
            }
        }
    }

    private function clickFun(e:MouseEvent):void{
        var openViewParam:String;
        switch (e.target){
            case  m_npcViewUI.btn_text_0 :
                openViewParam = m_pDate.function0.Param;
                break;
            case  m_npcViewUI.btn_text_1 :
                openViewParam = m_pDate.function1.Param;
                break;
            case  m_npcViewUI.btn_text_2 :
                openViewParam = m_pDate.function2.Param;
                break;
            case  m_npcViewUI.btn_text_3 :
                openViewParam = m_pDate.function3.Param;
                break;
        }
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(openViewParam));
        bundleCtx.setUserData( bundle, "activated", true );
        removeDisplay();
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_npcViewUI ) {
                m_npcViewUI = new NPCDialogueUI();

                m_npcViewUI.closeHandler = new Handler( _onClose );

                m_npcViewUI.btn_text_0.addEventListener(MouseEvent.CLICK, clickFun);
                m_npcViewUI.btn_text_1.addEventListener(MouseEvent.CLICK, clickFun);
                m_npcViewUI.btn_text_2.addEventListener(MouseEvent.CLICK, clickFun);
                m_npcViewUI.btn_text_3.addEventListener(MouseEvent.CLICK, clickFun);
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    override public function get viewClass() : Array {
        return [ /*NPCDialogueUI*/ ];
    }

    override public function _addToDisplay() : void {
        if ( m_npcViewUI ){
            uiCanvas.addPopupDialog( m_npcViewUI );
            super._addToDisplay();

            var vector3:CVector3 = CObject.get2DPositionFrom3D( m_position.x, m_position.z, m_position.y );
            var vector2:CVector2 = new CVector2(vector3.x, vector3.y);
            var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            if (scene) {
                scene.mainCamera.worldToScreen(vector2);
            }

            if(vector2.x < system.stage.flashStage.width/2){
                m_npcViewUI.x += m_npcViewUI.width/1.5;
            }else{
                m_npcViewUI.x -= m_npcViewUI.width/1.5;
            }
        }
    }

    override public function removeDisplay() : void {
        if ( m_npcViewUI ) {
            m_npcViewUI.close( Dialog.CLOSE );
            m_npcViewUI.remove();
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
