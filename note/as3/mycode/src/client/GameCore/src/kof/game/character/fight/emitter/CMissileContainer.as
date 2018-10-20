//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/11.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Foundation;
import QFLib.Memory.CResourcePool;

import kof.framework.CAppSystem;
import kof.framework.CSystemHandler;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.property.CMissileProperty;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.CSpawnHandler;


/**
 * this missiles container handler is used for Emitter to  allocate or recycle missile
 */
public class CMissileContainer extends CSystemHandler implements IEmitter {

    public function CMissileContainer() {
        super();
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        m_missilePool = new CResourcePool( "MissilePool", CMissile );
        m_missileBuilder = new CMissileBuilder();
        m_missilesList = new <CGameObject>[];
        return ret;
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        m_missileBuilder.dispose();
        m_missileBuilder = null;

        m_missilePool.dispose();
        m_missilePool = null;

        return ret;
    }

    override protected function enterSystem( system : CAppSystem ) : void {
        super.enterSystem( system );

        m_pSpawner = system.getBean( CSpawnHandler ) as CSpawnHandler;

        m_missileBuilder.theFrameWork = (system as CSceneSystem).graphicsFramework;
        m_pSceneRendering = ( system as CSceneSystem ).getBean( CSceneRendering );
        m_missileBuilder.theEmitterFacade = this;
        m_missileBuilder.sceneHandler = system.getBean( CSceneHandler ) as CSceneHandler;
    }

    override protected function exitSystem( system : CAppSystem ) : void {
        this.clearAllMissile();
        super.exitSystem( system );
    }

    public function shotMissile( missileInfo : Object ) : CMissile {
        var missile : CMissile = m_missilePool.allocate() as CMissile;
        if ( null == missile ) {
            Foundation.Log.logErrorMsg( "Allocate Missile Error" );
            return null;
        }

        missile.data = missileInfo;
        /**

         var fatherId : Number = CCharacterDataDescriptor.getID( master.data );
         var fatherTyep : Number = CCharacterDataDescriptor.getType( master.data );
         var fatherPath : String = CCharacterDataDescriptor.getSkinName( master.data );

         var ret : Boolean = m_missileBuilder.build( missile , cloneProprety , master ,
         fatherId ,fatherTyep,  fatherPath );
         */
        var ret : Boolean = m_missileBuilder.build( missile );

        m_pSpawner.addCharacter( missile );
        m_missilesList.push( missile );

        CSkillDebugLog.logTraceMsg( "shot missile : " + CCharacterDataDescriptor.getID( missileInfo ) );
        if ( ret ) {
//            var pFightTrigger : CCharacterFightTriggle = missile.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
//            var pProperty:CMissileProperty = missile.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
//            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.MISSILE_ACTIVATE , null , [ pProperty.missileSeq ]));
            return missile;
        }
        else
            return null;
    }

    public function recycleMissile( missile : CGameObject ) : CGameObject {
        if ( missile ) {
            var display : IDisplay = missile.getComponentByClass( IDisplay, true ) as IDisplay;
            if ( display ) {
                m_pSceneRendering.removeDisplayObject( display.modelDisplay );
                CSkillDebugLog.logTraceMsg( "recycle missile : " );
            }

            var index : int = m_missilesList.indexOf( missile );

            if ( index >= 0 )
                m_missilesList.splice( index, 1 );

            m_missileBuilder.removeMissile( missile );
            m_pSpawner.removeCharacter( missile );
            m_missilePool.recycle( missile );
            return missile;
        }
        return null;
    }

    public function findMissile( missileID : int, missileSeq : int ) : CGameObject {
        var missile : CGameObject;
        var missileProperty : CMissileProperty;
        for ( var i : int = 0; i < m_missilesList.length; i++ ) {
            {
                missile = m_missilesList[ i ];
                if( !missile || !missile.isRunning )
                        continue;
                if ( missile ) {
                    missileProperty = missile.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
                    if ( missileProperty &&
                            missileProperty.missileId == missileID &&
                            missileProperty.missileSeq == missileSeq ) {
                        return missile;
                    }
                }
            }
        }

        return null;
    }

    public function findMissileByUniqID( missileSeq : Number ) : CGameObject{
        var missile : CGameObject;
        var missileProperty : CMissileProperty;
        for ( var i : int = 0; i < m_missilesList.length; i++ ) {
            {
                missile = m_missilesList[ i ];
                if( !missile || !missile.isRunning )
                        continue;
                if ( missile ) {
                    missileProperty = missile.getComponentByClass( CMissileProperty, true ) as CMissileProperty;
                    if ( missileProperty &&
                            missileProperty.missileSeq == missileSeq ) {
                        return missile;
                    }
                }
            }
        }
        return null;
    }

    public function get iterator() : Object{
        return m_missilesList;
    }

    public function removeMissile( id : Number ) : CGameObject {
        var missile : CGameObject;
        for ( var i : int = 0; i < m_missilesList.length; i++ ) {
            if ( CCharacterDataDescriptor.getID( m_missilesList[ i ].data ) == id ) {
                missile = m_missilesList[ i ];
                break;
            }
        }

        return recycleMissile( missile );
    }

    protected function clearAllMissile() : void {
        for each ( var missle : CGameObject in m_missilesList ) {
            recycleMissile( missle );
        }

        if ( m_missilesList )
            m_missilesList.splice( 0, m_missilesList.length );
    }

    private var m_missilesList : Vector.<CGameObject>;
    private var m_missilePool : CResourcePool;
    private var m_missileBuilder : CMissileBuilder;
    private var m_pSpawner : CSpawnHandler;
    private var m_pSceneRendering : CSceneRendering;
}
}
