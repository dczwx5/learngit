//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/21.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.display.CBaseDisplay;
import kof.game.character.level.CLevelMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.scene.ISceneFacade;

public class CBelongToComponent extends CGameComponent{
    public function CBelongToComponent( ) {
    }

    override protected function onDataUpdated() : void
    {
        super.onDataUpdated();
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onExit() : void {
        super.onExit();
        m_fFatherID = -1;
        m_nFatherType = -1;
    }

    public function setFather( id : Number , type : int ) : void{
        m_fFatherID = id;
        m_nFatherType = type;
    }

    public function get sFatherFilePath() : String
    {
        return m_sFileString;
    }

    public final function get sFatheSkin() : String {
        if ( pFather ) {
            var pBaseDisplay : CBaseDisplay = pFather.getComponentByClass( CBaseDisplay , true ) as CBaseDisplay;
            return pBaseDisplay.skin;
        }
        return "";
    }

    public final function get pFather() : CGameObject
    {
        return pSceneMediator.findGameObj( m_nFatherType , m_fFatherID );
    }

    private final function get pSceneMediator() : CSceneMediator
    {
        return owner.getComponentByClass( CSceneMediator , true ) as CSceneMediator;
    }

    private var m_fFatherID : Number;
    private var m_nFatherType : int;
    private var m_sFileString : String;
}
}
