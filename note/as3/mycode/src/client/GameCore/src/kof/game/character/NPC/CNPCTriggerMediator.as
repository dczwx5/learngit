//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/14.
 */
package kof.game.character.NPC {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.character.CDatabaseMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.animation.IAnimation;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CSubscribeBehaviour;
import kof.game.level.ILevelFacade;
import kof.game.npc.INpcFacade;
import kof.game.scenario.IScenarioSystem;
import kof.message.Task.NpcDialogueRequest;
import kof.table.NPC;
import kof.table.PlotTask;

public class CNPCTriggerMediator extends CSubscribeBehaviour {

    private var m_pNpcFacade : INpcFacade;
    private var m_pLevelFacade : ILevelFacade;
    private var m_pScenarioSystem : IScenarioSystem;
    private var m_pCPlayHandler : CPlayHandler;
    private var m_pNetworking : INetworking;

    private var m_pNPCTable:IDataTable;
    private var m_pTaskTable:IDataTable;

    public function CNPCTriggerMediator( pNpcFacade : INpcFacade, pLevelFacade : ILevelFacade, pScenarioSystem:IScenarioSystem, pCPlayHandler:CPlayHandler,network : INetworking ) {
        super( "npcTrigger" );
        m_pNpcFacade = pNpcFacade;
        m_pLevelFacade = pLevelFacade;
        m_pScenarioSystem = pScenarioSystem;
        m_pCPlayHandler = pCPlayHandler;
        m_pNetworking = network;
    }

    override public function dispose() : void {
        super.dispose();
        m_pNpcFacade = null;
        m_pLevelFacade = null;
        m_pScenarioSystem = null;
        m_pCPlayHandler = null;
        m_pNetworking = null;
        m_pNPCTable = null;
        m_pTaskTable = null;
    }

    public function triggerNPC():void{

        var npcTrigger : CNpcTriggerComponent = owner.getComponentByClass( CNpcTriggerComponent, true ) as CNpcTriggerComponent;
        npcTrigger.dispatchEvent(new CNPCEvent(CNPCEvent.NPC_OPEN));

        if ( m_pNpcFacade && m_pNpcFacade.eventDelegate )
            m_pNpcFacade.eventDelegate.dispatchEvent( new CNPCEvent( CNPCEvent.NPC_OPEN ) );

        if(m_pNPCTable == null){
            m_pNPCTable = (getComponent(CDatabaseMediator) as CDatabaseMediator).getTable(KOFTableConstants.NPC);
        }
        if(m_pTaskTable == null){
            m_pTaskTable = (getComponent(CDatabaseMediator) as CDatabaseMediator).getTable(KOFTableConstants.PLOT_TASK);
        }


        if(m_pLevelFacade.isPlayingScenario()){
            return;
        }
        (owner.getComponentByClass(CNPCMoveMediator, true) as CNPCMoveMediator).stopMove();


        var animation:IAnimation = (owner.getComponentByClass(IAnimation, false) as IAnimation);
        var npc:NPC = m_pNPCTable.findByPrimaryKey( owner.data.prototypeID ) as NPC;

        if(animation && npc.footflag){
            (owner.getComponentByClass(CNPCSprite, true) as CNPCSprite).showFootSprite();
        }

        if(animation && npc.clickingAction){
            animation.modelDisplay.playState( CAnimationStateConstants.CLICK_BEGIN );
        }

        if(owner.data.taskID){
            var task:PlotTask = m_pTaskTable.findByPrimaryKey( owner.data.taskID ) as PlotTask;
            m_pScenarioSystem.playScenario(task.plotID, 1, function(id:int):void{taskOverFun(owner.data.taskID)},false);
        }else{
            var npcView:CNPCViewMediator = (owner.getComponentByClass(CNPCViewMediator,false) as CNPCViewMediator);
            if(npcView){
                npcView.showNPCView(hideView);
            }
        }

        var facade:CFacadeMediator = (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator);
        if(facade && npc.clickingDirection){
            facade.directionTo(m_pCPlayHandler.hero);
        }

        showNPCOutline(false);
    }

    public function showNPCOutline(enable:Boolean):void{
        var character:CCharacterDisplay = owner.getComponentByClass(CCharacterDisplay, true ) as CCharacterDisplay;
        if(character){
            character.modelDisplay.rimLightOutline(enable,1.0,1.0,1.0,0.92,3);
        }
    }

    public function closeTriggerNPC():void{
        var npcView:CNPCViewMediator = (owner.getComponentByClass(CNPCViewMediator,false) as CNPCViewMediator);
        if(npcView && npcView.getViewIsOpen()){
            npcView.closeNPCView();
        }
    }


    private function hideView():void{
        if(owner == null) return;
        var animation:IAnimation = (owner.getComponentByClass(IAnimation, false) as IAnimation);
        var npc:NPC = m_pNPCTable.findByPrimaryKey( owner.data.prototypeID ) as NPC;
        if(animation && npc.clickingAction){
             animation.modelDisplay.playState(CAnimationStateConstants.CLICK_END);
        }

        (owner.getComponentByClass(CNPCSprite, true) as CNPCSprite).hideFootSprite();
        (owner.getComponentByClass(CNPCMoveMediator, true) as CNPCMoveMediator).cuntinueMove();
    }

    private function taskOverFun(taskID:int):void{
        var request:NpcDialogueRequest = new NpcDialogueRequest();
        request.taskID = taskID;
        m_pNetworking.post(request);
        hideView();

        var npcTrigger : CNpcTriggerComponent = owner.getComponentByClass( CNpcTriggerComponent, true ) as CNpcTriggerComponent;
        npcTrigger.dispatchEvent(new CNPCEvent(CNPCEvent.NPC_TASKOVER));

        if ( m_pNpcFacade && m_pNpcFacade.eventDelegate )
            m_pNpcFacade.eventDelegate.dispatchEvent( new CNPCEvent( CNPCEvent.NPC_TASKOVER ) );
    }
}
}
