//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/23.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline {

import kof.framework.INetworking;
import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.FightTimeLineResponse;

public class CFightTimeLineHandler extends CGameSystemHandler {
    public function CFightTimeLineHandler() {
        super( CFightTimeLineFacade );
    }

    protected override function onSetup() : Boolean {
        var networking : INetworking = system.stage.getSystem( INetworking ) as INetworking;
        if( networking ){
//            networking.bind( FightTimeLineResponse ).toHandler( _onFightTimeLineRespose );
        }

        return true;
    }

    override public function tickValidate( delta : Number , obj : CGameObject ) : Boolean{
        return this.enabled;
    }

    override public function tickUpdate( delta : Number, obj : CGameObject ) : void{

    }

    private function _onFightTimeLineRespose( net : INetworking , message : CAbstractPackMessage ) : void {
        var msg : FightTimeLineResponse = message as FightTimeLineResponse;
        if( msg ){

        }
    }


}
}
