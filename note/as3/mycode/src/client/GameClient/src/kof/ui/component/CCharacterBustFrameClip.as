//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui.component {

import QFLib.Foundation.CPath;
import QFLib.Foundation.CTimer;
import QFLib.Foundation.free;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Math.CAABBox2;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.display.Bitmap;
import flash.events.Event;

/**
 * Character的FrameClip控件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterBustFrameClip extends CCharacterFrameClip {

    private var m_ponitX:Number = 0.0;

    private var m_bIsLight:Boolean = false;
    private var m_bIsDark:Boolean = false;

    public function CCharacterBustFrameClip( skin : String = null ) {
        super( skin );
        m_sAnimationName = "Idle_1";
    }

    override public function get animationName() : String {
        return m_sAnimationName;
    }

    override public function set animationName( value : String ) : void {
        if ( m_sAnimationName != value ) {
            m_sAnimationName = value;
            this.setFrame( this.frame );
        }
    }

    override public function get framework() : CFramework {
        return m_pBelongFramework;
    }

    override public function set framework( value : CFramework ) : void {
        if ( m_pBelongFramework != value ) {
            initCharacter( value );
            m_pBelongFramework = value;
        }
    }

    override protected function changeSkin( value : String ) : void {
        initCharacter( this.framework );
    }

    override protected function initCharacter( pFramework : CFramework ) : void {
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
                        _onCharacterObjectLoadFinished );
            }
        }

        if ( !_bitmap ) {
            _bitmap = new Bitmap();
        }
    }

    private function _onCharacterObjectLoadFinished( theObject : CCharacter, iResult : int ) : void {
//        sendEvent( Event.COMPLETE );
        // 不知道为什么Complete事件不发
        dispatchEvent(new Event("EventCharacterLoadCompleted"));

        if(m_bIsDark){
            setColorDark();
        }
        if(m_bIsLight){
            setColorLight();
        }
    }

    override public function set scaleX( value:Number ):void{
        if(m_pCharacterObject){
            m_pCharacterObject.setScale(value,1.0,1.0);
        }
    }

    override public function get scaleX():Number{
        if(m_pCharacterObject){
            return m_pCharacterObject.scale.x;
        }
        return 1;
    }

    override public function set scaleY( value:Number ):void{
        if(m_pCharacterObject){
            m_pCharacterObject.setScale(1.0,value,1.0);
        }
    }

    override public function get scaleY():Number{
        if(m_pCharacterObject){
            return m_pCharacterObject.scale.y;
        }
        return 1;
    }

    public function set pointX(value:Number):void{
        m_ponitX = value;
        updatePosition();
    }

    public function get pointX():Number{
        return m_ponitX;
    }

    public function get cWidth():Number{
        if(m_pCharacterObject && m_pCharacterObject.characterObject){
            var aabb:CAABBox2 = m_pCharacterObject.characterObject.currentBound;
            if(aabb){
                return aabb.width;
            }
        }
        return 500;
    }

    public function get aabb() : CAABBox2 {
        if(m_pCharacterObject && m_pCharacterObject.characterObject){
            var aabb:CAABBox2 = m_pCharacterObject.characterObject.currentBound;
            if(aabb){
                return aabb;
            }
        }
        return null;
    }

    public function setColorDark():void{
        if(m_pCharacterObject && m_pCharacterObject.characterObject){
            m_pCharacterObject.isStatic = true;
            m_pCharacterObject.characterObject.setLightColorAndContrast( 0.45, 0.45, 0.45, 1.0, 0.0 );
        }
    }

    public function setColorLight():void{
        if(m_pCharacterObject && m_pCharacterObject.characterObject){
            m_pCharacterObject.isStatic = true;
            m_pCharacterObject.characterObject.setLightColorAndContrast( 1.0, 1.0, 1.0, 1.0, 0.0 );
        }
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

    override protected function lazyDraw() : void {
        if ( m_pCharacterObject ) {
            if ( !m_pCharacterObject.currentAnimationClip || m_pCharacterObject.currentAnimationClip.m_sName != this.animationName ) {
                m_pCharacterObject.playAnimation( this.animationName, this.isLoopPlay/*, true*/ );
            }

            updatePosition();
        }
    }

    private function updatePosition():void{
        if( m_pBelongFramework ){
            m_pBelongFramework.addObjectToUILayer(m_pCharacterObject,m_ponitX,0);
        }
    }

    public function get isLight() : Boolean {
        return m_bIsLight;
    }

    public function set isLight( value : Boolean ) : void {
        m_bIsLight = value;
    }

    public function get isDark() : Boolean {
        return m_bIsDark;
    }

    public function set isDark( value : Boolean ) : void {
        m_bIsDark = value;
    }
}
}
