//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/7.
 */
package kof.game.character.scripts.appear {

import kof.game.character.display.IDisplay;
import kof.game.character.property.CMonsterProperty;
import kof.game.core.CGameObject;
import kof.table.Monster.EMonsterType;

public class CPlayAnimationAppearAction extends CAppearAction {

    private var m_playAction:String;

    private var loop:Boolean;

    private var loopTime:Number;

    public function CPlayAnimationAppearAction( pOwner : CGameObject, pAppearData : Object ) {
        super( pOwner );
        m_playAction = pAppearData.playAction;
        loop = Boolean(pAppearData.loop);
        loopTime  = pAppearData.loopTime;
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay )
        {
            if(monsterType != EMonsterType.WORLD_BOSS){
                setResult( false );
            }
            modelDisplay.modelDisplay.enabled = true;
            modelDisplay.modelDisplay.playAnimation(m_playAction,loop,false,false,0,false,loopTime,function():void{
                setResult( false );
            });
        }
    }

    public function get monsterType() : int {
        var pProperty : CMonsterProperty = owner.getComponentByClass( CMonsterProperty, false ) as CMonsterProperty;
        if ( pProperty ) {
            return pProperty.monsterType;
        }
        return 0;
    }
}
}
