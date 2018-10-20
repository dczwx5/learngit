//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/20.
 */
package kof.game.character.NPC {

import kof.game.core.CGameComponent;

/**
 * NPC对话组件
 * Created by user on 2017/1/20.
 */
public class CNPCViewMediator extends CGameComponent {

    /** @private */
    private var m_pNPCView: INPCViewFacade;

    public function CNPCViewMediator( pNPCViewFacade:INPCViewFacade ) {
        super( "NPCView" );
        m_pNPCView = pNPCViewFacade;
    }
    override public function dispose() : void {
        super.dispose();
        this.m_pNPCView = null;
    }

    public function showNPCView(fun:Function):void{
        m_pNPCView.showNPCView(owner.data, transform.position, fun);
    }

    public function getViewIsOpen():Boolean{
        return m_pNPCView.isOpen();
    }

    public function closeNPCView():void{
        m_pNPCView.closeNPCView();
    }
}
}
