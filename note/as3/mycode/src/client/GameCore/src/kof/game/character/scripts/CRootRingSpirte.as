//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/11/19.
//----------------------------------------------------------------------
package kof.game.character.scripts {

import QFLib.Framework.CCharacter;
import QFLib.Framework.CFX;
import QFLib.Framework.CFramework;
import QFLib.Interface.IUpdatable;
import QFLib.Memory.CResourcePool;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.FileType;

import flash.events.Event;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.table.Monster.EMonsterType;
import kof.util.CAssertUtils;

public class CRootRingSpirte extends CGameComponent implements IUpdatable {
    public static const RING_BOSS : String = "rootflag/rootflag_boss";
    public static const RING_FRIEND : String = "rootflag/rootflag_friend";
    public static const RING_ENEMY : String = "rootflag/rootflag_enemey";
    public static const RING_SELF : String = "rootflag/rootflag_self";
    public static const RING_SELF_2 : String = "rootflag/rootflag_self2";
    public static const RING_ROBOT : String = "rootflag/rootflag_robot";
    public static const RING_ROBOT_B : String = "rootflag/rootflag_robotb";
    public static const RING_ELITE : String = "rootflag/rootflag_elite";
    public static const RING_BOSS_N : String = "rootflag/rootflag_bossn"

    public function CRootRingSpirte( gf : CFramework, playHld : CPlayHandler ) {
        super();
        m_pGraphicFrameWork = gf;
        m_pPlayHandle = playHld;
    }

    override public function dispose() : void {
        super.dispose();
        m_pGraphicFrameWork = null;
        if ( m_pLastFX ) {
            m_pLastFX.stop();
            CFX.manuallyRecycle( m_pLastFX );
            m_pLastFX = null;
        }
        m_boInit = false;
    }

    public function update( delta : Number ) : void {
        if ( m_pLastFX ) {
            if ( pDisplay && pDisplay.modelDisplay ) {
                var zIdx : Number;

                zIdx = pDisplay.modelDisplay.position.z - 10;

                var onGround : Boolean = pStateBoard.getValue( CCharacterStateBoard.IN_GUARD );
                if ( onGround )
                    m_pLastFX.setPositionTo( pDisplay.modelDisplay.position.x, pDisplay.modelDisplay.position.y, zIdx );
                else {
                    m_pLastFX.setPositionTo( pDisplay.modelDisplay.position.x, 0, zIdx );
                }
            }
        }
    }

    override public function set enabled( value : Boolean ) : void {
        if ( enabled == value )
            return;
        super.enabled = value;
        if ( m_pLastFX ) {
            if ( value ) {
                m_pLastFX.play();
                m_pLastFX.visible = true;
            }

            else {
                m_pLastFX.pause();
                m_pLastFX.visible = false;
            }

        }
    }

    final private function get pHero() : CGameObject {
        return m_pPlayHandle.hero;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        var pLevelMediator : CLevelMediator = owner.getComponentByClass( CLevelMediator , false) as CLevelMediator;
        if ( pEventMediator ) {
            if( !pLevelMediator.isPVE)
                pEventMediator.addEventListener( CCharacterEvent.INSTANCE_STARTED, instanceReady );
            else
                pEventMediator.addEventListener( CCharacterEvent.READY , instanceReady );
        }
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
        var boChange : Boolean;
        if ( owner.data && owner.data.hasOwnProperty( 'operateIndex' ) ) {
            if ( objOprIndex != m_iPreOperatorIndex ) {
                m_iPreOperatorIndex = objOprIndex;
                boChange = true;
            }
        }
        if ( owner.data && owner.data.hasOwnProperty( 'operate' ) ) {
            if ( objOprSize != m_iSide ) {
                m_iSide = objOprSize;
                boChange = true;
            }
        }

        if ( owner.data && owner.data.hasOwnProperty( 'campID' ) ) {
            if ( objCamp != m_iCamp ) {
                m_iCamp = objCamp;
                boChange = true;
            }
        }

        if ( boChange )
            updateDisplayRing();
    }

    private function instanceReady( event : Event ) : void {
        m_bInstanceReady = true;
        updateDisplayRing( event );
    }

    override protected virtual function onExit() : void {
        super.onExit();
        var pEventMediator : CEventMediator = owner.getComponentByClass( CEventMediator, false ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.INSTANCE_STARTED, instanceReady );
            pEventMediator.removeEventListener( CCharacterEvent.READY , instanceReady );
        }

        this.m_bInstanceReady = false;
        dispose();
    }

    final private function get pDisplay() : IDisplay {
        return owner.getComponentByClass( IDisplay, true ) as IDisplay;
    }

    final private function get objType() : int {
        return CCharacterDataDescriptor.getType( owner.data );
    }

    final private function get objOprIndex() : int {
        return CCharacterDataDescriptor.getOperateIndex( owner.data );
    }

    final private function get objOprSize() : int {
        return CCharacterDataDescriptor.getOperateSide( owner.data );
    }

    final private function get objCamp() : int {
        return CCharacterDataDescriptor.getCampID( owner.data );
    }

    private function get pLevelMediator() : CLevelMediator {
        return owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
    }

    private function updateDisplayRing( event : Event = null ) : void {
        var levelMediator : CLevelMediator = pLevelMediator;

        if ( !m_bInstanceReady ) return ; // && levelMediator.instanceFacade && !levelMediator.instanceFacade.isStart ) return;

        var hideEffect : Boolean;

        if ( levelMediator ) {
            if ( levelMediator.isMainCity ) {
                return;
            }

            if ( !CCharacterDataDescriptor.isPlayer( owner.data ) ) {
                hideEffect = levelMediator.getHideFootEffect( CCharacterDataDescriptor.getEntityID( owner.data ) );
                if ( hideEffect )
                    return;
            }
        }

        if ( objType == CCharacterDataDescriptor.TYPE_PLAYER ) {
            if ( objOprSize == 1 ) {
                if ( objOprIndex == 1 )
                    displayRingByType( CRootRingSpirte.RING_SELF );
                else
                    displayRingByType( CRootRingSpirte.RING_SELF_2 );
            } else {
                if ( pLevelMediator.isAttackable( pHero ) ) {
                    if ( objOprIndex == 1 )
                        displayRingByType( CRootRingSpirte.RING_BOSS );
                    else
                        displayRingByType( CRootRingSpirte.RING_ELITE )
                } else {
                    displayRingByType( CRootRingSpirte.RING_FRIEND );
                }
            }
        }
        else if ( objType == CCharacterDataDescriptor.TYPE_MONSTER ) {
            var monsterProperty : CMonsterProperty = owner.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
            if ( monsterProperty ) {
                if ( !pLevelMediator.isAttackable( pHero ) ) {
                    displayRingByType( CRootRingSpirte.RING_ROBOT_B );
                } else {
                    var monsterType : int = monsterProperty.monsterType;
                    if ( monsterType == EMonsterType.WORLD_BOSS )
                        displayRingByType( CRootRingSpirte.RING_BOSS_N );
                    else if ( monsterType == EMonsterType.BOSS || monsterType == EMonsterType.EXTRAME_BOSS )
                        displayRingByType( CRootRingSpirte.RING_BOSS );
                    else if ( monsterType == EMonsterType.UNIQUE )
                        displayRingByType( CRootRingSpirte.RING_ELITE );
                }
            }
        }
    }

    public function displayRingByType( sFxName : String ) : void {
        CAssertUtils.assertNotNull( m_pGraphicFrameWork );

        if ( !sFxName || !sFxName.length ) {
            if ( m_pLastFX ) {
                m_pLastFX.stop();
                CFX.manuallyRecycle( m_pLastFX );
                m_pLastFX = null;
            }
            return;
        }

        var sFXURL : String = _getRootURL( sFxName );
        if ( m_pLastFX ) {
            if ( m_pLastFX.filename == sFXURL ) {
                if ( !m_pLastFX.isPlaying ) {
                    m_pLastFX.play( true );
                }
                return;
            }
            else {
                m_pLastFX.stop();
                CFX.manuallyRecycle( m_pLastFX );
                m_pLastFX = null;
            }
        }

        var pool : CResourcePool = this.m_pGraphicFrameWork.fxResourcePools.getPool( sFXURL );
        if ( pool ) {
            m_pLastFX = pool.allocate() as CFX;
        }

        if ( m_pLastFX == null ) {
            m_pLastFX = new CFX( this.m_pGraphicFrameWork );
            m_pLastFX.loadFile( sFXURL, ELoadingPriority.NORMAL, onEffectLoaded );
        }

        pSceneMediator.addDisplayObject( m_pLastFX );
        m_pLastFX.play( true );
        m_boInit = true;
    }

    private function onEffectLoaded( pFx : CFX, iResult : int ) : void {
        if ( iResult != 0 ) {
            m_pLastFX = null;
        }
    }

    private function _getRootURL( sName : String ) : String {
        if ( !sName || !sName.length )
            return null;

        return "assets/fx/" + sName + "." + FileType.JSON;
    }

    private function get pSceneMediator() : CSceneMediator {
        return owner.getComponentByClass( CSceneMediator, true ) as CSceneMediator;
    }

    private function get pStateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    final public function get boInit() : Boolean {
        return m_boInit;
    }

    private var m_pGraphicFrameWork : CFramework;
    private var m_pLastFX : CFX;
    private var m_boInit : Boolean;
    private var m_pPlayHandle : CPlayHandler;
    private var m_iPreOperatorIndex : int = -1;
    private var m_iType : int = -1;
    private var m_iSide : int = -1;
    private var m_iCamp : int = -1;
    private var m_bInstanceReady : Boolean;
}
}

