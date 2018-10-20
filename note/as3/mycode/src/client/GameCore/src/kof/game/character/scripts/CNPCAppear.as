//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/14.
 */
package kof.game.character.scripts {

import QFLib.ResourceLoader.ELoadingPriority;

import kof.game.character.CCharacterInitializer;
import kof.game.character.animation.CCharacterDisplay;
import kof.game.character.display.IDisplay;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CNPCProperty;

public class CNPCAppear extends CCharacterInitializer {
    public function CNPCAppear() {
        super();
        moveToAvailablePosition = false;
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {

        var pLevelMediator : CLevelMediator = this.getComponent(CLevelMediator) as CLevelMediator;
        if (pLevelMediator) {
            var pAppearData : Object = pLevelMediator.getBornActionDataByEntityID( this.entityID );
            this.moveToAvailablePosition = pAppearData.moveToAvailablePosition;
        }

        super.onDataUpdated();

        var pDisplay : CCharacterDisplay = this.getComponent( CCharacterDisplay ) as CCharacterDisplay;
        if ( pDisplay ) {
            pDisplay.physicsEnabled = false;
        }

        var property:CNPCProperty = owner.getComponentByClass(CNPCProperty,true) as CNPCProperty;
        if(property && property.shadow == 0)
        {
            if ( pDisplay ) {
                pDisplay.modelDisplay.castShadow = false;
            }
        }

        if ( pDisplay ) {
            pDisplay.loadingPriority = ELoadingPriority.CRITICAL;
        }

        m_bInitialized = true;
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    final public function get entityID() : int {
        if ( owner && owner.data )
            return int( owner.data.entityID );
        return 0;
    }
}
}
