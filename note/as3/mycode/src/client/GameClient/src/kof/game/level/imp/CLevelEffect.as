//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/10.
 */
package kof.game.level.imp
{

    import QFLib.Foundation.CMap;
    import QFLib.Framework.CAnimationController;
    import QFLib.Framework.CAnimationState;
    import QFLib.Framework.CCharacter;
    import QFLib.Framework.CFX;
    import QFLib.Framework.CFramework;
    import QFLib.Framework.CScene;
    import QFLib.Interface.IDisposable;
    import QFLib.Memory.CResourcePool;
    import QFLib.ResourceLoader.ELoadingPriority;

    import kof.game.character.fx.CFXMediator;
import kof.game.core.CGameObject;
import kof.game.level.CLevelManager;
    import kof.game.levelCommon.info.entity.CTrunkEffectInfo;
    import kof.game.scene.CSceneRendering;
    import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;

public class CLevelEffect implements IDisposable
    {
        private var _levelManager : CLevelManager;
        private var _fxMap : CMap; // 关卡创建的fx列表, 原本关卡创建的特效，应该在场景退出的时候就删除,
        private var _animationMap : CMap;
        private var _clickFX : CFX;

        public function CLevelEffect ( levelManager : CLevelManager )
        {
            _levelManager = levelManager;
            _fxMap = new CMap ();
            _animationMap = new CMap ();
        }

        public function dispose () : void
        {
            clear ();
            _levelManager = null;
            _animationMap = null;
            _fxMap = null;
            if ( _clickFX )
            {
                _clickFX.stop ();
                CFX.manuallyRecycle ( _clickFX );
                _clickFX = null;
            }
        }

        public function clear () : void
        {
            var sceneSystem : CSceneSystem = _levelManager.system.stage.getSystem ( CSceneSystem ) as CSceneSystem;
            if ( sceneSystem )
            {
                for each ( var pFX : CFX in _fxMap )
                {
                    pFX.stop ();
                    CFX.manuallyRecycle ( pFX );
                    pFX = null;
                }
                _fxMap.clear ();

                for each ( var animation : CCharacter in _animationMap )
                {
                    animation.dispose ();
                    animation = null;
                }
                _animationMap.clear ();
            }
        }

        public function showAnimation ( params : String, onStateChangedFun : Function = null ) : void
        {
            var paramList : Array = params.split ( "," );
            var animName : String = paramList[ 0 ];
            var animAction : String = paramList[ 1 ];
            var loop : int = paramList[ 2 ];
            var playTime : int = paramList[ 3 ];
            var info : CTrunkEffectInfo = _levelManager.levelConfigInfo.getEffectInfoByName ( animName );

            if ( _animationMap == null )
            {
                _animationMap = new CMap ();
            }

            var character : CCharacter = _animationMap.find ( info.name );
            if ( character == null )
            {
                var sceneSystem : CSceneSystem = _levelManager.system.stage.getSystem ( CSceneSystem ) as CSceneSystem;
                var graphicsFramework : CFramework = sceneSystem.graphicsFramework;
                character = new CCharacter ( graphicsFramework );
                var theDefaultState : CAnimationState = new CAnimationState ( info.animation, info.animation, info.loop, false, false );
                var theController : CAnimationController = new CAnimationController ( theDefaultState );
                character.animationController = theController;

                character.loadFile ( "assets/character/" + info.fileName + ".json", null, null, ELoadingPriority.NORMAL, onSceneCharacterLoadFinished );

                character.setPositionToFrom2D ( info.location.x, info.location.y, 0.0, -info.location.z );
                character.setScale ( info.scale.x, info.scale.y, info.scale.z );
                sceneSystem.scenegraph.addDisplayObject ( character, info.layerId );

                _animationMap.add ( info.name, character );
            }
            character.enablePhysics = false;
            character.enabled = true;
            if ( loop )
            {
                character.playAnimation ( animAction, true, true, true, 0, false, playTime, onStateChangedFun );
            }
            else
            {
                character.playAnimation ( animAction, false, false, false, 0, false, 0.0, onStateChangedFun );
            }
        }

        private function onSceneCharacterLoadFinished ( theCharacter : CCharacter, iResult : int ) : void
        {
            if ( iResult == 0 )
            {
                var vAnimationNames : Vector.<String> = new Vector.<String> ();
                theCharacter.retrieveAllAnimationClipNames ( vAnimationNames );

                for each( var sAnimationName : String in vAnimationNames )
                {
                    if ( theCharacter.animationController.findState ( sAnimationName ) == null )
                    {
                        theCharacter.animationController.addState ( new CAnimationState ( sAnimationName, sAnimationName, false ) );
                    }
                }
            }
        }

        public function stopAnimation ( params : String, onStateChangedFun : Function = null ) : void
        {
            var paramList : Array = params.split ( "," );
            var animName : String = paramList[ 0 ];

            var info : CTrunkEffectInfo = _levelManager.levelConfigInfo.getEffectInfoByName ( animName );
            var character : CCharacter = _animationMap.find ( info.name );
            if ( character )
            {
                character.animationSpeed = 0;
            }
        }

        public function showEffect ( params : String, onStateChangedFun : Function = null ) : void
        {
            var paramList : Array = params.split ( "," );
            var animName : String = paramList[ 0 ];
            var loop : Boolean = int(paramList[ 1 ]);
            var playTime : int = int(paramList[ 2 ]);
            var pTrunkInfo : CTrunkEffectInfo = _levelManager.levelConfigInfo.getEffectInfoByName ( animName );
            var pEffectInfo : Array = _levelManager.levelConfigInfo.levelEffectInfo;
            if ( pEffectInfo != null && pEffectInfo.length > 0 )
            {
                var sFX_URL : String = CFXMediator.getRequestURI ( pTrunkInfo.fileName );
                var pFX : CFX = _fxMap.find ( sFX_URL );
                if ( pFX == null )
                {
                    pFX = addEffect ( pTrunkInfo.fileName );
                    pFX.onStopedCallBack = _fxStopedCallBack;
                    _fxMap.add ( pFX.filename, pFX );
                }

                _setEffectPosition ( pFX, pTrunkInfo.location.x, pTrunkInfo.location.y, 0, pTrunkInfo.scale.x, pTrunkInfo.scale.y );
                _setEffectLayer ( pFX, pTrunkInfo.layerId );
                _playEffect ( pFX, loop, playTime, onStateChangedFun );
            }
        }

        public function addClickEffect ( x : Number, y : Number, z : Number ) : void
        {
            var sceneSystem : CSceneSystem = _levelManager.system.stage.getSystem ( CSceneSystem ) as CSceneSystem;
            var scene : CScene = (sceneSystem.getBean ( CSceneRendering ) as CSceneRendering).scene;
            var layer : int = scene.numSceneLayers () - 1;
            if ( _clickFX == null )
            {
                var fileName:String = "ui_point/ui_point";
                _clickFX = addEffect ( fileName );
            }

            _setEffectPosition ( _clickFX, x, y, z, 0.8, 0.8, false );
            _setEffectLayer ( _clickFX, layer );
            _playEffect ( _clickFX, true, 0 );
            _clickFX.enabled = true;
        }

        public function hideClickEffect () : void
        {
            if ( _clickFX )
            {
                _clickFX.pause ();
                _clickFX.enabled = false;
            }
        }

        public function stopEffect ( params : String, onStateChangedFun : Function = null ) : void
        {
            var paramList : Array = params.split ( "," );
            var animName : String = paramList[ 0 ];
            var info : CTrunkEffectInfo = _levelManager.levelConfigInfo.getEffectInfoByName ( animName );
            var sFX_URL : String = CFXMediator.getRequestURI ( info.fileName );
            var pEffectInfo : Array = _levelManager.levelConfigInfo.levelEffectInfo;
            if ( pEffectInfo && pEffectInfo.length > 0 )
            {
                var pFX : CFX = _fxMap.find ( sFX_URL );
                pFX.stop ();
                CFX.manuallyRecycle ( pFX );
                _fxMap.remove ( sFX_URL );
            }
        }

        final private function addEffect ( fileName : String ) : CFX
        {
            var sceneSystem : CSceneSystem = _levelManager.system.stage.getSystem ( CSceneSystem ) as CSceneSystem;
            var graphicsFramework : CFramework = sceneSystem.graphicsFramework;
            var sFX_URL : String = CFXMediator.getRequestURI ( fileName );

            var pFX : CFX;
            var pool : CResourcePool = graphicsFramework.fxResourcePools.getPool ( sFX_URL );
            if ( pool )
                pFX = pool.allocate () as CFX;

            if ( pFX == null )
            {
                pFX = new CFX ( graphicsFramework );
                pFX.loadFile ( sFX_URL, ELoadingPriority.NORMAL, onEffectLoaded );
            }
            pFX.name = fileName;
            return pFX;
        }

        final private function onEffectLoaded(pFx:CFX, iResult:int):void
        {
            if(iResult != 0)
            {
                _fxMap.remove(pFx.name);
                _clickFX = null;
            }
        }

        final private function _setEffectPosition ( pFX : CFX, x : Number, y : Number, z : Number, scaleX : Number, scaleY : Number, from2D : Boolean = true ) : void
        {
            pFX.setScale ( scaleX, scaleY, 1 );
            from2D ? pFX.setPositionToFrom2D ( x, y ) : pFX.setPositionTo ( x, y, z );
        }

        final private function _setEffectLayer ( pFX : CFX, layerId : int ) : void
        {
            var sceneSystem : CSceneSystem = _levelManager.system.stage.getSystem ( CSceneSystem ) as CSceneSystem;
            sceneSystem.scenegraph.addDisplayObject ( pFX, layerId );
        }

        final private function _playEffect ( pFX : CFX, loop : Boolean, playTime : int, _onStateChangedFun : Function = null ) : void
        {
            if ( _onStateChangedFun ) {
                pFX.onStopedCallBack = _onStateChangedFun;
            }
            pFX.play ( loop, playTime );
        }

        final private function _fxStopedCallBack ( params : Array ) : void
        {
            var pFX : CFX = params[ 0 ] as CFX;
            if ( pFX != null )
            {
                CFX.manuallyRecycle ( pFX );
                _fxMap.remove ( pFX.filename );
            }
        }
    }
}
