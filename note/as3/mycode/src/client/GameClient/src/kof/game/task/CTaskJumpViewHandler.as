//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/18.
 */
package kof.game.task {

import QFLib.Framework.CScene;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.NPC.CNPCByPlayer;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

public class CTaskJumpViewHandler extends CViewHandler {
    public function CTaskJumpViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function onNpcJump( npcID:Number):void{
        var pCGameObject : CGameObject = _pSceneSystem.findNPCByPrototypeID( npcID );
        if (pCGameObject && pCGameObject.transform) {
            var hero:CGameObject = _playHandler.hero;

            var npc:CNPCByPlayer = hero.getComponentByClass(CNPCByPlayer, false) as CNPCByPlayer;
            var scene:CScene = (_pSceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
            npc.moveToNPC(pCGameObject,scene);
        }
    }
    public function onPanelJump( sysTag : String ,tab : int = 0 ):void{
        //有的面板需要打开指定页签
        if( sysTag == KOFSysTags.ROLE ){ //格斗家
            _playerSystem.tab = tab;
            _playerSystem.isActived = true;
        }else if( sysTag == KOFSysTags.INSTANCE  ){//剧情副本
            _instanceSystem.tab = tab;
            _instanceSystem.isActived = true;
        }else if( sysTag == KOFSysTags.ELITE ){ //精英副本
            _instanceSystem.setEliteTab( tab );
            _instanceSystem.setEliteActived( true );
        } else{
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(sysTag));
            bundleCtx.setUserData( bundle, "activated", true );
        }

    }

    private function get _instanceSystem() : CInstanceSystem {
        return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pSceneSystem() : CSceneSystem {
        return system.stage.getSystem( CSceneSystem ) as CSceneSystem;
    }
    private function get _playHandler() : CPlayHandler {
        return (system.stage.getSystem(CECSLoop).getBean(CPlayHandler)) as CPlayHandler;
    }
}
}
