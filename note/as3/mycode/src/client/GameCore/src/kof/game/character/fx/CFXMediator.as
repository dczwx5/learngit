//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fx {

import QFLib.Framework.CFX;
import QFLib.Framework.CFramework;
import QFLib.Framework.CharacterExtData.CCharacterFXKey;
import QFLib.Math.CVector3;
import QFLib.Memory.CResourcePool;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.FileType;

import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameComponent;
import kof.util.CAssertUtils;

/**
 * 特效相关调停组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CFXMediator extends CGameComponent {

    static public const DEFAULT_DURATION : Number = -1.0;

    public function CFXMediator( graphicsFramework : CFramework ) {
        super( "FXMediator" );

        this.m_pGraphicsFramework = graphicsFramework;
    }

    final private function _onExitOrDispose() : void {
        this.m_pGraphicsFramework = null;
        if ( m_loopFx ) {
            m_loopFx.stop();
            CFX.manuallyRecycle( m_loopFx );
            m_loopFx = null;
        }

        if ( m_DieFX ) {
            m_DieFX.stop();
            CFX.manuallyRecycle( m_DieFX );
            m_DieFX = null;
        }
    }

    public function setCombineEffectLock( value : Boolean ) : void {
        m_bCombineEffectLock = value;
    }

    override public function dispose() : void {
        super.dispose();
        this._onExitOrDispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
        this._onExitOrDispose();
    }

    final protected function get graphicsFramework() : CFramework {
        return this.m_pGraphicsFramework;
    }

    final protected function get sceneMediator() : CSceneMediator {
        return this.getComponent( CSceneMediator ) as CSceneMediator;
    }

   public function playDieFx() : void{
       if( m_DieFX == null )
            m_DieFX = _playDieFx("dead_effects/dead_effects_0001");
   }

    public function playDieFadeFX() : void{
        if( m_DieFadeFX == null )
           m_DieFadeFX = _playDieFx("dead_effects/dead_effects_0002");
    }

    public function _playDieFx( name : String ) : CFX{
        var dieFX : CFX;
            var pDisplay : IDisplay = this.getComponent( IDisplay ) as IDisplay;
            if ( !pDisplay ) {
                return null;
            }

            var sFxName : String = name; //"dead_effects/dead_effects_0001";
            var sFXURL : String = CFXMediator.getRequestURI( sFxName );
            var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
            if ( pool ) {
                dieFX = pool.allocate() as CFX;
            }

            if ( dieFX == null ) {
                dieFX = new CFX( this.graphicsFramework );
                dieFX.loadFile( sFXURL, ELoadingPriority.NORMAL, onDieFxLoaded );
            }
            dieFX.onStopedCallBack = _dieFXStoped;
            dieFX.attachToTarget( pDisplay.modelDisplay );
            dieFX.play();
        return dieFX;
    }

    private function onDieFxLoaded( pFx : CFX, iResult : int ) : void {
        if ( iResult != 0 ) {
            m_DieFX = null;
        }
    }

    /**
     * 自动播放一次指定文件名的特效
     *
     * @param sFxName 文件名（格式：子目录/文件名，不带文件类型后缀）
     * @param bFlip 是否翻转
     * @param x 坐标X
     * @param y 坐标Y
     * @param z 坐标Z，如果Z为NaN，默认是角色显示对象的Z值加0.1或是1
     */
    public function autoPlayFXOnce( sFxName : String, bFlip : Boolean, x : Number, y : Number, z : Number = NaN ) : void {
        CAssertUtils.assertNotNull( graphicsFramework && sceneMediator );

        if ( !sFxName || !sFxName.length )
            return;

        var sFXURL : String = CFXMediator.getRequestURI( sFxName );
        var pFX : CFX;
        var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
        if ( pool ) {
            pFX = pool.allocate() as CFX;
        }

        if ( pFX == null ) {
            pFX = new CFX( this.graphicsFramework );
            pFX.loadFile( sFXURL );
        }
        pFX.setAutoRecycle( true );

        sceneMediator.addDisplayObject( pFX );

        if ( isNaN( z ) ) {
            // 获取当前显示对象的Z值
            var pDisplay : IDisplay = this.getComponent( IDisplay, true ) as IDisplay;
            if ( pDisplay ) {
                z = pDisplay.modelDisplay.position.z + 0.1;
            }
        }

        z = z || 1;

        pFX.setPosition( x, y, z );
        pFX.flipX = bFlip;

        pFX.play( false, -1, 0, 0 );
    }

    public function autoPlayFXLoop( sFxName : String, x : Number, y : Number, z : Number ) : CFX {
        CAssertUtils.assertNotNull( graphicsFramework && sceneMediator );

        if ( !sFxName || !sFxName.length )
            return null;

        if ( null == m_loopFx ) {
            var sFXURL : String = CFXMediator.getRequestURI( sFxName );
            var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
            if ( pool ) {
                m_loopFx = pool.allocate() as CFX;
            }

            if ( m_loopFx == null ) {
                m_loopFx = new CFX( this.graphicsFramework );
                m_loopFx.loadFile( sFXURL, ELoadingPriority.NORMAL, onLoopFxLoaded );
            }
            m_loopFx.onStopedCallBack = _loopFXStoped;

            sceneMediator.addDisplayObject( m_loopFx );
        }

        m_loopFx.setPosition( x, y, z );
        m_loopFx.play( true, -1, 0, 0 );
        return m_loopFx;
    }

    public function createFXLoop( sFxName : String, x : Number , y : Number , z : Number, bFlip : Boolean = false ) : CFX {
        CAssertUtils.assertNotNull( graphicsFramework && sceneMediator );

        if ( !sFxName || !sFxName.length )
            return null;

        var sFXURL : String = CFXMediator.getRequestURI( sFxName );
        var pFX : CFX;
        var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
        if ( pool ) {
            pFX = pool.allocate() as CFX;
        }

        if ( pFX == null ) {
            pFX = new CFX( this.graphicsFramework );
            pFX.loadFile( sFXURL );
        }
        pFX.setAutoRecycle( true );

        sceneMediator.addDisplayObject( pFX );

        if ( isNaN( z ) ) {
            // 获取当前显示对象的Z值
            var pDisplay : IDisplay = this.getComponent( IDisplay, true ) as IDisplay;
            if ( pDisplay ) {
                z = pDisplay.modelDisplay.position.z + 0.1;
            }
        }

        z = z || 1;

        pFX.setPosition( x, y, z );
        pFX.flipX = bFlip;

        pFX.play( true, -1, 0, 0 );
        return pFX

    }

    private function onLoopFxLoaded( pFx : CFX, iResult : int ) : void {
        if ( iResult != 0 ) {
            m_loopFx = null;
        }
    }

    /**
     * 播放绑定的击打效果
     * @param effDef
     * @param position
     */
    public function playBindHitEffect( hitEffName : String, position : CVector3, depth : Number = 0.0 ) : void {
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( position == null ) return;
        if ( pAnimation && pAnimation.modelDisplay ) {
            pAnimation.modelDisplay.playHitEffects( hitEffName, position, depth );
        }
    }

    /**
     * 播放元素特效
     * @param comHitName
     */
    public function playComhitEffects( comHitName : String, boLoop : Boolean = false, type : String = 'combine' ) : void {
        if ( m_bCombineEffectLock )
            return;
        if ( comHitName == null || comHitName.length == 0 )
            return;
        var pAnimation : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation && pAnimation.modelDisplay ) {
            pAnimation.modelDisplay.playCombineOrBuffEffects( comHitName, type, boLoop );
        }
    }

    public function stopComHitEffects( comHitName : String, type : String = 'combine' ) : void {
        var pAnimatin : IAnimation = owner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimatin && pAnimatin.modelDisplay ) {
            pAnimatin.modelDisplay.stopCombineOrBuffEffect( comHitName, type );
        }
    }

    public function playAtBone( sFxName : String, fDurationTime : Number = -1.0, boneName : String = null, boLoop : Boolean = false ) : void {
        if ( m_bCombineEffectLock )
            return;
        CAssertUtils.assertNotNull( graphicsFramework && sceneMediator );

        if ( !sFxName || !sFxName.length )
            return;

        var sFXURL : String = CFXMediator.getRequestURI( sFxName );
        var pFX : CFX;
        var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
        if ( pool ) {
            pFX = pool.allocate() as CFX;
        }

        if ( pFX == null ) {
            pFX = new CFX( this.graphicsFramework );
            pFX.loadFile( sFXURL );
        }
        pFX.setAutoRecycle( true );

        var key : CCharacterFXKey = new CCharacterFXKey();
        if ( boneName == null ) {
            key.boneIndex = 0;
        }
        else
            key.boneName = boneName;

        key.playFollowAnimationLoop = true;
        key.playTime = fDurationTime;

        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay )
            pFX.attachToCharacter( modelDisplay.modelDisplay, key );
        pFX.play( boLoop, fDurationTime, 0, 0 );
    }

    public function setLoopFxPosition( x : Number, y : Number, z : Number ) : void {
        if ( m_loopFx )
            m_loopFx.setPosition( x, y, z );
    }

    public function playSceneEffect( sFxName : String, fDuration : Number = -1.0,
                                     boLoop : Boolean = false, type : int = -1, flip : Boolean = false,
                                     flipSelf : Boolean = true, position : CVector3 = null, scale : CVector3 = null,
                                     isTopDisplay : Boolean = false ) : CFX {
        CAssertUtils.assertNotNull( graphicsFramework && sceneMediator );

        if ( !sFxName || !sFxName.length ) return null;

        var sFxURL : String = CFXMediator.getRequestURI( sFxName );
        var pFX : CFX = _allocatedFX( sFxURL );
        sceneMediator.attachFXToScene( pFX, flip, flipSelf, type, position, scale, isTopDisplay );
        pFX.play( boLoop, fDuration, 0.0, 0.0 );
        return pFX;
    }

    private function _allocatedFX( sFXURL : String ) : CFX {
        var pFX : CFX;
        var pool : CResourcePool = this.graphicsFramework.fxResourcePools.getPool( sFXURL );
        if ( pool ) {
            pFX = pool.allocate() as CFX;
        }

        if ( pFX == null ) {
            pFX = new CFX( this.graphicsFramework );
            pFX.loadFile( sFXURL );
        }
        pFX.setAutoRecycle( true );
        return pFX;
    }

    private function _dieFXStoped( params : Array ) : void {
        if ( m_DieFX != null ) {
            CFX.manuallyRecycle( m_DieFX );
            m_DieFX = null;
        }
    }

    private function _loopFXStoped( params : Array ) : void {
        if ( m_loopFx != null ) {
            CFX.manuallyRecycle( m_loopFx );
            m_loopFx = null;
        }
    }

    [Inline]
    static public function getRequestURI( sFxName : String ) : String {
        if ( !sFxName || !sFxName.length )
            return null;

        return "assets/fx/" + sFxName + "." + FileType.JSON;
    }

    private var m_DieFX : CFX;
    private var m_DieFadeFX : CFX;
    private var m_loopFx : CFX;
    private var m_pGraphicsFramework : CFramework;
    private var m_bCombineEffectLock : Boolean;
}
}

// vim:ft=as3 sw=4 ts=4 tw=200
