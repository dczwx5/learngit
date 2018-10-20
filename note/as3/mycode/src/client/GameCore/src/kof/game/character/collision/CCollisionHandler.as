//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/5/18.
//----------------------------------------------------------------------
package kof.game.character.collision {

import kof.game.character.animation.IAnimation;
import kof.game.character.collision.*;

import QFLib.Framework.CFramework;

import kof.game.character.display.IDisplay;

import kof.game.core.CGameObject;
import kof.game.core.CGameSystemHandler;
import kof.game.scene.CSceneSystem;

public class CCollisionHandler extends CGameSystemHandler {

    public function CCollisionHandler() {
        super( CCollisionComponent );
    }

    override protected function setStarted() : void {
        super.setStarted();
        m_pFramework = sceneSys.graphicsFramework;
    }

    public function get showDebug() : Boolean {
        return m_pFramework.collisionDisplaySys.enable;
    }

    public function set showDebug( value : Boolean ) : void {
        m_pFramework.collisionDisplaySys.enable = value;
    }

    override public function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        var bValidated : Boolean = super.tickValidate( delta, obj );
        if ( !bValidated )
            return false;

        return false;
    }

    override public function beforeTick( delta : Number ) : void {
        super.beforeTick( delta );

        if ( m_pFramework )
            m_pFramework.collisionMgr.update( delta );
    }

    override public function afterTick( delta : Number ) : void {
        super.afterTick( delta );
    }

    final private function get sceneSys() : CSceneSystem {
        return system.stage.getSystem( CSceneSystem ) as CSceneSystem;
    }

    private var m_pFramework : CFramework;


}
}

