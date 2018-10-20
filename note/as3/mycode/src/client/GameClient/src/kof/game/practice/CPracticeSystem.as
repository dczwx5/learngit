//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/11/29.
 */
package kof.game.practice {

import QFLib.Framework.CScene;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CKOFTransform;
import kof.game.character.CTarget;
import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.common.loading.movie.CMatchLoadingSelectFinishMovieCompoent;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;

import morn.core.handlers.Handler;

public class CPracticeSystem extends CBundleSystem implements ISystemBundle {
    private var m_bInitialized : Boolean;
    private var bInitListener : Boolean;
    public function CPracticeSystem() {
        super();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.PRACTICE );
    }

    public override function dispose() : void {
        var pSceneFacade : ISceneFacade = this.stage.getSystem( ISceneFacade ) as ISceneFacade;
        if( pSceneFacade)
            pSceneFacade.removeEventListener( CSceneEvent.CHARACTER_READY, _onHeroChange );
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CPracticeViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CPracticeViewHandler();
            this.addBean( pView );
        }

        pView = pView || this.getHandler( CPracticeViewHandler ) as CPracticeViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        addBean( new CPracticeViewHandler() );
        addBean( new CPracticeHandler() );

        var pInstanceSystem : CInstanceSystem = this.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        pInstanceSystem.addEventListener( CInstanceEvent.LEVEL_PLAYER_READY, _onLevelPlayerReady );
        pInstanceSystem.addEventListener( CInstanceEvent.EXIT_INSTANCE , _onLevelExit);

        return m_bInitialized;
    }

    private function _onLevelPlayerReady( e : CInstanceEvent ) : void {
        setHeroTarget();
    }

    private function _onLevelExit( e : CInstanceEvent ) : void{

        var pSceneFacade : ISceneFacade = this.stage.getSystem( ISceneFacade ) as ISceneFacade;
        pSceneFacade.removeEventListener( CSceneEvent.CHARACTER_READY, _onHeroChange );
        bInitListener = false;
    }

    private function _onHeroChange( e : CSceneEvent ) : void{
        var target : CGameObject = e.value as CGameObject;
        if( !target || (CCharacterDataDescriptor.isMissile( target.data ) || CCharacterDataDescriptor.isBuff( target.data )))
                return;

        setHeroTarget();
        if( bInitListener ) {
            var pHero : CGameObject = (stage.getSystem( CECSLoop ).getBean( CPlayHandler ) as CPlayHandler).hero;
           if( pHero && pHero.isRunning )
           {
               var pStateMachine : CCharacterStateMachine = pHero.getComponentByClass( CCharacterStateMachine , true ) as CCharacterStateMachine;
               if( pStateMachine && pStateMachine.actionFSM)
                   pStateMachine.actionFSM.on( CCharacterActionStateConstants.EVENT_POP );

               var pDisplay : IDisplay= pHero.getComponentByClass( IDisplay, true ) as IDisplay;
               if( pDisplay ) {
                   pDisplay.modelDisplay.setPositionToFrom2D( 730, 978, 0 );
               }

               var pAnimation : IAnimation = pHero.getComponentByClass( IAnimation , true ) as IAnimation;
               if( pAnimation )
                       pAnimation.playAnimation( CAnimationStateConstants.IDLE , true );
           }
        }
    }

    public function setHeroTarget() : void {

        var pInstanceSystem : CInstanceSystem = stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        if ( !pInstanceSystem ) {
            return;
        }
        var isPractice : Boolean = EInstanceType.isPractice( pInstanceSystem.instanceType );
        if ( !isPractice ) return;

        if( !bInitListener ) {
            var pSceneFacade : ISceneFacade = this.stage.getSystem( ISceneFacade ) as ISceneFacade;
            pSceneFacade.addEventListener( CSceneEvent.CHARACTER_READY, _onHeroChange );
            bInitListener = true;
        }

        var pHero : CGameObject = (stage.getSystem( CECSLoop ).getBean( CPlayHandler ) as CPlayHandler).hero;
        var pSceneSystem : CSceneSystem = stage.getSystem( CSceneSystem ) as CSceneSystem;
        var sceneObjectList : Vector.<Object>;
        var pSceneObject : CGameObject;

        var targetList : Vector.<CGameObject> = new Vector.<CGameObject>();
        if ( pHero && pHero.isRunning ) {
            sceneObjectList = pSceneSystem.findAllPlayer();
            for each( pSceneObject in sceneObjectList ) {
                if ( !CCharacterDataDescriptor.isHero( pSceneObject.data ) ) {
                    targetList.push( pSceneObject );
                }
            }
        }

        if ( targetList && targetList.length > 0 ) {
            // 设置目标
            (pHero.getComponentByClass( CTarget, true ) as CTarget).setTargetObjects( targetList );

            // 设置镜头
            var enemyTarget : CGameObject = targetList[ 0 ] as CGameObject;
            if ( enemyTarget ) {
                if ( pSceneSystem.scenegraph && pSceneSystem.scenegraph.scene ) {
                    var scene : CScene = pSceneSystem.scenegraph.scene;
                    scene.setCameraFollowingMode( 1, 6.0, 3.0 ); // springFactor太小，人物移动到边界会超出去
                    var pHeroCharacterDisplay : IDisplay = pHero.getComponentByClass( IDisplay, true ) as IDisplay;
                    var pEnemyCharacterDisplay : IDisplay = enemyTarget.getComponentByClass( IDisplay, true ) as IDisplay;
                    scene.setCameraFollowingTarget( pHeroCharacterDisplay.modelDisplay, pEnemyCharacterDisplay.modelDisplay );
                }
            }
        }
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CPracticeViewHandler = this.getHandler( CPracticeViewHandler ) as CPracticeViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CPracticeViewHandler isn't instance." );
            return;
        }

        var typeArr : * = ctx.getUserData( this, "change_type", false );
        var type : int = 0;
        if ( typeArr ) {
            type = typeArr[ 0 ];
        }

        if ( value ) {
            pView.addDisplay( type );
            _levelManager.pauseLevel();
        } else {
            pView.removeDisplay();
            if(typeArr[ 1 ]){
                _levelManager.continueLevel();
            }
            else{
                (this.stage.getSystem(CLevelSystem) as CLevelSystem).setPlayEnable(true);
            }
        }
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    public function enterPractice() : void {
        (getHandler( CPracticeHandler ) as CPracticeHandler).enterPractice();
    }

    public function closeView() : void {
        onActivated( false );
    }

    private function get _levelManager():CLevelManager{
        return (this.stage.getSystem(CLevelSystem) as CLevelSystem).getBean(CLevelManager) as CLevelManager;
    }

    public var heroList:Array;
}
}
