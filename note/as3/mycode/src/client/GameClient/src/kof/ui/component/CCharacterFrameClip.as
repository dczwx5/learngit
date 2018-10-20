//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui.component {

import QFLib.Foundation.CPath;
import QFLib.Foundation.CTimer;
import QFLib.Foundation.free;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Framework.Util.CSnapshotUtil;
import QFLib.Graphics.Character.model.CEquipSkinsInfo;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Rectangle;

import morn.core.components.SpriteBlitFrameClip;

/**当前帧发生变化后触发*/
[Event(name="frameChanged", type="morn.core.events.UIEvent")]
/**当前动画准备完成后触发*/
[Event(name="complete", type="flash.events.Event")]
/**
 * Character的FrameClip控件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterFrameClip extends SpriteBlitFrameClip {

    static protected const RUNTIME_ASSETS_URI : String = "assets/character/";

    protected var m_pCharacterObject : CCharacter;
    protected var m_sAnimationName : String;
    protected var m_pBelongFramework : CFramework;

    protected var m_bLoopPlay : Boolean = true;//是否循环播放
    protected var m_bStageScale : Boolean = false;//是否跟随舞台大小缩放

    protected var m_bIsBust : Boolean = false;//是否是半身像资源

    // 非半身像支持
    private var m_sWeapon:String; // 换武器
    private var m_sOutSideName:String; // 换肤
    protected var m_pTimer : CTimer;

    public function CCharacterFrameClip( skin : String = null ) {
        super( skin );

        m_sAnimationName = "Idle_1";
    }

    public function get animationName() : String {
        return m_sAnimationName;
    }

    public function set animationName( value : String ) : void {
        if ( m_sAnimationName != value ) {
            m_sAnimationName = value;
            this.setFrame( this.frame );
        }
    }

    public function get framework() : CFramework {
        return m_pBelongFramework;
    }

    public function set framework( value : CFramework ) : void {
        if ( m_pBelongFramework != value ) {
            initCharacter( value );
            m_pBelongFramework = value;
        }
    }

    override protected function changeSkin( value : String ) : void {
        // load character from runtime assets.
        initCharacter( this.framework );
    }

    protected function initCharacter( pFramework : CFramework ) : void {
        if ( !pFramework ) {
            free( m_pCharacterObject );
            m_pCharacterObject = null;
            return;
        }

        if ( (!m_pCharacterObject ) || ( pFramework != this.framework ) ) {
            free( m_pCharacterObject );
            m_pCharacterObject = new CCharacter( pFramework );
        }

        if ( _skin ) {
            var pFilePath : String = "";
            var sFileName : String = new CPath( _skin ).name ;
            if ( m_bIsBust ) {
                pFilePath = RUNTIME_ASSETS_URI + "bust/" + _skin + "/" + sFileName;
                m_pCharacterObject.loadCharacterFile( pFilePath, null, null, ELoadingPriority.NORMAL,
                        _onCharacterObjectLoadFinished);
            } else {
                pFilePath = RUNTIME_ASSETS_URI + _skin + "/" + sFileName;
                var outsidePath:String = null;
                var weaponPath:String = null;
                var equipSkins:CEquipSkinsInfo = null;
                if (m_sOutSideName && m_sOutSideName.length > 0) {
                    outsidePath = RUNTIME_ASSETS_URI + _skin + "/" + new CPath( m_sOutSideName ).name
                }
                if (m_sWeapon && m_sWeapon.length > 0) {
                    weaponPath = RUNTIME_ASSETS_URI + _skin + "/" + new CPath( m_sWeapon ).name;
                    equipSkins = new CEquipSkinsInfo();
                    equipSkins.addEquip(0, weaponPath);
                }

                m_pCharacterObject.loadFile( pFilePath, outsidePath, equipSkins, ELoadingPriority.NORMAL, _onCharacterObjectLoadFinished,
                        null, null, null, false, false );
            }

        }

        if ( !_bitmap ) {
            _bitmap = new Bitmap();

            if ( !_bitmap.parent )
                addChild( _bitmap );
        }
    }

    private function _onCharacterObjectLoadFinished( theObject : CCharacter, iResult : int ) : void {
        m_pCharacterObject.enablePhysics = false;
        sendEvent( Event.COMPLETE );
    }

    public function get isLoopPlay():Boolean {
        return m_bLoopPlay;
    }

    public function set isLoopPlay(value:Boolean):void {
        m_bLoopPlay = value;
    }

    public function get isStageScale():Boolean {
        return m_bStageScale;
    }

    public function set isStageScale(value:Boolean):void {
        m_bStageScale = value;
    }

    public function set isBust(value:Boolean):void {
        m_bIsBust = value;
    }

    public function get isBust():Boolean {
        return m_bIsBust;
    }
    public function set weapon(value : String) : void {
        m_sWeapon = value;
    }
    public function set outSideName(value : String) : void {
        m_sOutSideName = value;
    }

    override public function set interval( value : int ) : void {
        super.interval = value;
        if ( m_pTimer )
            m_pTimer.interval = this._interval * 0.001;
    }

    override public function play() : void {
        super.play();
        m_pTimer = m_pTimer || new CTimer();
        m_pTimer.reset();
        m_pTimer.interval = this._interval * 0.001;
    }

    override protected function loop() : void {
        if ( m_pTimer && m_pTimer.isOnTime() )
            super.loop();
    }

    override protected function setFrame( value : int ) : void {
//        var time : Number = 1.0 * this._frame * ( this._interval / 1000 );
        App.render.callLater( lazyDraw );
    }

    protected function lazyDraw() : void {
        if ( m_pCharacterObject && _bitmap ) {
            if ( !m_pCharacterObject.currentAnimationClip || m_pCharacterObject.currentAnimationClip.m_sName != this.animationName ) {
                m_pCharacterObject.playAnimation( this.animationName, this.isLoopPlay/*, true*/ );
            }

            var pBitmapData : BitmapData = CSnapshotUtil.snapshot( m_pCharacterObject, new Rectangle( 0, 0, 0, 0 ), this._bitmap.bitmapData, false, false, this.isStageScale );

            var bReLayout : Boolean = false;
            if ( pBitmapData && (this._bitmap.width != pBitmapData.width || this._bitmap.height != pBitmapData.height ) ) {
                bReLayout = true;
            }
            this._bitmap.bitmapData = pBitmapData;

            if ( bReLayout ) {
                resetPosition();
            }
        }
    }

    public function get character():CCharacter{
        return m_pCharacterObject;
    }
}
}
