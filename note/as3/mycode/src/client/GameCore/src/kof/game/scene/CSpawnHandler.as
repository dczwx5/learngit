//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;
import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.character.display.IDisplay;
import kof.game.core.CGameObject;
import kof.game.core.CECSLoop;
import kof.util.CAssertUtils;

/**
 * 场景物体生成逻辑，场景角色等，例如怪物，NPC，玩家
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSpawnHandler extends CAbstractHandler implements IUpdatable {

    /** @private */
    private var m_pGameSystem : CECSLoop;
    /** @private */
    private var m_pSceneRendering : CSceneRendering;
    /** @private */
    private var m_pSceneObjectList : CSceneObjectLists;
    /** @private */
    private var m_listSpawnQueue : Vector.<CGameObject>;
    /** @private */
    private var m_nMaxSpawnCountPerFrame : int;

    /** Creates a new CSpawnHandler.  */
    public function CSpawnHandler( maxSpawnCountPerFrame : int = 15 ) {
        super();
        this.m_nMaxSpawnCountPerFrame = maxSpawnCountPerFrame;
    }

    public final function get networking() : INetworking {
        return system.handler.networking;
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        // Retrieves CECSLoop reference first.
        var ret : Boolean = true;
        this.m_pGameSystem = system.stage.getSystem( CECSLoop ) as CECSLoop;

        ret = ret && this.m_pGameSystem;
        CAssertUtils.assertNotNull( this.m_pGameSystem, "CECSLoop required in CSpawnHandler 'onSetup' phase." );

        return ret;
    }

    override protected function onShutdown() : Boolean {
        m_pGameSystem = null;
        m_pSceneRendering = null;
        return true;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        this.m_pSceneRendering = system.getBean( CSceneRendering ) as CSceneRendering;
        this.m_pSceneObjectList = system.getBean( CSceneObjectLists ) as CSceneObjectLists;
        this.m_listSpawnQueue = new <CGameObject>[];
    }

    /**
     * 添加角色
     */
    public function addCharacter( character : CGameObject ) : void {
        if ( !character )
            return;

        this.m_listSpawnQueue.push( character ); // Queue in spawn list.
    }

    /**
     * 移除角色
     */
    public function removeCharacter( character : CGameObject ) : void {
        if ( !character )
            return;
        var idx : int = m_listSpawnQueue.indexOf( character );
        if ( idx != -1 ) {
            m_listSpawnQueue.splice( idx, 1 );
        }

        if ( m_pGameSystem )
            m_pGameSystem.removeObject( character );
    }

    public function update( delta : Number ) : void {
        if ( !m_pSceneRendering || !m_pGameSystem )
            return;

        if ( m_pSceneRendering.isReady ) {
            if ( this.m_listSpawnQueue.length ) {
                var counter : int = 0;
                for each ( var obj : CGameObject in m_listSpawnQueue ) {
                    if ( obj ) {
                        spawnObject( obj );
                    }

                    ++counter;

                    if ( counter >= m_nMaxSpawnCountPerFrame )
                        break;
                }

                if ( counter > 0 )
                    this.m_listSpawnQueue.splice( 0, counter );
            }
        }
    }

    protected function spawnObject( character : CGameObject ) : void {
        var display : IDisplay = character.findComponentByClass( IDisplay ) as IDisplay;
        if ( display ) {
            this.m_pSceneRendering.addDisplayObject( display.modelDisplay );
        }

        this.m_pGameSystem.addObject( character ); // 添加到游戏系统，开始ECS Loop
    }

} // class CSpawnHandler
}
