//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/23.
 */
package kof.game.character.NPC {

import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.framework.events.CEventPriority;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.CFacadeMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.level.CLevelMediator;
import kof.game.core.CGameComponent;
/**
 * NPC巡路
 * Created by user on 2017/1/20.
 */
public class CNPCMoveMediator extends CGameComponent {

    private var m_index:int = 0;
    private var isStop:Boolean;
    public function CNPCMoveMediator( name : String = null, branchData : Boolean = false ) {
        super( name, branchData );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
        }
    }

    private function _onCharacterDisplayReady( event : CCharacterEvent ) : void {
        moveFun();
    }

    private function moveFun():void{
        var levelMediator:CLevelMediator = owner.getComponentByClass(CLevelMediator,false) as CLevelMediator;
        var npc:Object = levelMediator.getNPC(owner.data.prototypeID);
        if(npc == null)return;
        if(npc.appearType != 1 || isStop){
            return;
        }
        m_index++;
        if(m_index >= 2){//(npc.appearPosition as Array).length){
            m_index = 0;
        }
        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;

        var pixelPos3D:CVector3 = CObject.get3DPositionFrom2D(pDisplay.modelDisplay, npc.appearPosition[m_index].x, npc.appearPosition[m_index].y, 0);
        (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator).moveTo(new CVector2(pixelPos3D.x,pixelPos3D.z),moveFun);
    }

    public function stopMove():void{
        (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator).makeRunStop();
        isStop = true;
    }

    public function cuntinueMove():void{
        isStop = false;
        var levelMediator:CLevelMediator = owner.getComponentByClass(CLevelMediator,false) as CLevelMediator;
        var npc:Object = levelMediator.getNPC(owner.data.prototypeID);
        if(npc == null)return;
        if(npc.appearType != 1 || isStop){
            return;
        }
        var pDisplay : IDisplay = getComponent( IDisplay ) as IDisplay;
        var pixelPos3D:CVector3 = CObject.get3DPositionFrom2D(pDisplay.modelDisplay, npc.appearPosition[m_index].x, npc.appearPosition[m_index].y, 0);
        (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator).moveTo(new CVector2(pixelPos3D.x,pixelPos3D.z),moveFun);
    }
}
}
