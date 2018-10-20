//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/16.
 */
package kof.game.character.NPC {

import QFLib.Framework.CScene;
import QFLib.Math.CAABBox2;
import QFLib.Math.CVector2;

import flash.display.Stage;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.core.CSubscribeBehaviour;
import kof.game.instance.IInstanceFacade;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;

public class CNPCHandler extends CGameSystemHandler {

    private var m_currentMouseSelectNPC:CGameObject;
//    private var m_currentHeroMoveSelectNPC:CGameObject;
//    private var m_currentClickSelectNPC:CGameObject;

    private var m_isInBubble:Boolean;
    public function CNPCHandler( ... comps ) {
        super( CSubscribeBehaviour );
    }

    override protected virtual function onSetup() : Boolean {

        system.stage.flashStage.addEventListener( MouseEvent.CLICK, _onMouseClick, false, 0, true );
        system.stage.flashStage.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove, false, 0, true );
        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_DOWN, _onKeyboardDown, false, 0, true );
        var pInstanceSys : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            pInstanceSys.eventDelegate.addEventListener( "ENTER_INSTANCE", _onEnterInstance );
        }
        return true;
    }

    private function _onEnterInstance(e:Event):void{
//        m_currentMouseSelectNPC = m_currentHeroMoveSelectNPC = null;
        m_currentMouseSelectNPC = null;
    }

    private function _onKeyboardDown( e : KeyboardEvent ) : void {
//        if( e.keyCode == Keyboard.J && e.target is Stage ){
//            if(m_currentHeroMoveSelectNPC && m_currentHeroMoveSelectNPC.isRunning){
//                triggerNPC(m_currentHeroMoveSelectNPC);
//            }
//        }
    }

    private function triggerNPC(_npc:CGameObject):void{
        if(_npc){
            (_npc.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).triggerNPC();
        }
//        m_currentHeroMoveSelectNPC = null;
        m_currentMouseSelectNPC = null;
    }


    private function _onMouseMove(event:MouseEvent):void
    {
        if(!(event.target is Stage)) return;

        var m_pSceneFacade:ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        var NPCList : Vector.<Object> = m_pSceneFacade.NPCIterator as Vector.<Object>;

        if(NPCList.length <= 0){
            return;
        }

        for each (var obj:Object in NPCList)
        {
            var display:CCharacterDisplay = ((obj as CGameObject).getComponentByClass(CCharacterDisplay, true ) as CCharacterDisplay);
            if(isInNPC(display.modelDisplay.currentGlobalBound,event))
            {
                if(!(m_currentMouseSelectNPC == null) && m_currentMouseSelectNPC == obj){
                    return;
                }
                if(m_currentMouseSelectNPC && m_currentMouseSelectNPC != obj){
                    (m_currentMouseSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).showNPCOutline(false);
                }
                m_currentMouseSelectNPC = obj as CGameObject;
                (m_currentMouseSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).showNPCOutline(true);
                return;
            }
        }

        if(m_currentMouseSelectNPC)
        {
//            if(m_currentMouseSelectNPC != m_currentHeroMoveSelectNPC){
                var trigger:CNPCTriggerMediator = (m_currentMouseSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator);
                if(trigger)trigger.showNPCOutline(false);
//            }
            m_currentMouseSelectNPC = null;
        }
    }

    override public virtual function tickUpdate( delta : Number, obj : CGameObject ) : void {
        super.tickUpdate( delta, obj );

        if(!CCharacterDataDescriptor.isNPC( obj.data ) || !obj.isRunning){
            return
        }

        var m_pGameSystem:CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        var play:CPlayHandler = m_pGameSystem.getBean( CPlayHandler ) as CPlayHandler;
        if(play.hero && play.hero.isRunning && play.hero.transform.x != 0)
        {
            var _objNPC:CGameObject = obj;

            if(play.hero.transform.x <= _objNPC.transform.x + 700 && play.hero.transform.x >= _objNPC.transform.x - 700){
                (_objNPC.getComponentByClass( CNPCBubbleMediator, true ) as CNPCBubbleMediator).startBubble(isBubbleFun);
            }

//            if(play.hero.transform.x <= _objNPC.transform.x + 150 && play.hero.transform.x >= _objNPC.transform.x - 150 && play.hero.transform.y <= _objNPC.transform.y + 150 && play.hero.transform.y >= _objNPC.transform.y - 150)
//            {
//                if(m_currentHeroMoveSelectNPC != null){
//                    return;
//                }
//                m_currentHeroMoveSelectNPC = _objNPC;
//                (m_currentHeroMoveSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).showNPCOutline(true);
//                return;
//            }

//            if( m_currentHeroMoveSelectNPC == _objNPC )
//            {
//                (m_currentHeroMoveSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).showNPCOutline(false);
//
//                var npcTrigger:CNPCTriggerMediator = (m_currentHeroMoveSelectNPC.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator);
//                if(npcTrigger){
//                    npcTrigger.closeTriggerNPC();
//                }
//                m_currentHeroMoveSelectNPC = null;
//            }
        }
    }

    private function isBubbleFun(type:int = -1):Boolean{
        if(type != -1){
            m_isInBubble = type;
        }
        return m_isInBubble;
    }

    private function _onMouseClick( event : MouseEvent ) : void {
        if(!(event.target is Stage)) return;

        if(m_currentMouseSelectNPC){

            var display:CCharacterDisplay = ((m_currentMouseSelectNPC as CGameObject).getComponentByClass(CCharacterDisplay, true ) as CCharacterDisplay);
            if(display && !isInNPC(display.modelDisplay.currentGlobalBound,event)){
                return;
            }
            var m_pGameSystem:CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
            var play:CPlayHandler = m_pGameSystem.getBean( CPlayHandler ) as CPlayHandler;
            var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            if(m_currentMouseSelectNPC && m_currentMouseSelectNPC.transform){
                (play.hero.getComponentByClass(CNPCByPlayer,true) as CNPCByPlayer).moveToNPC(m_currentMouseSelectNPC,scene);
            }
        }
    }


    private function isInNPC(box:CAABBox2,event:MouseEvent):Boolean
    {
        if(box == null) {
            return false;
        }
        var pos:CVector2  = new CVector2(event.stageX, event.stageY);
        var m_pSceneFacade:ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        m_pSceneFacade.scenegraph.mainCamera.screenToWorld(pos);
        return box.isCollidedVertex(pos);
    }

    override protected virtual function onShutdown() : Boolean {
        system.stage.flashStage.removeEventListener( MouseEvent.CLICK, _onMouseClick );
        system.stage.flashStage.removeEventListener( MouseEvent.RIGHT_CLICK, _onMouseClick );
        system.stage.flashStage.removeEventListener( KeyboardEvent.KEY_DOWN, _onKeyboardDown );
        m_currentMouseSelectNPC = null;
//        m_currentHeroMoveSelectNPC = null;
        return true;
    }

    public function isClickNpc():Boolean{
        return m_currentMouseSelectNPC == null ? false : true;

    }
}
}
