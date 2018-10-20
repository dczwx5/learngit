//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/2.
 */
package kof.game.character.scripts.appear {

import QFLib.Graphics.Character.CAnimationClip;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.utils.setTimeout;

import kof.game.character.CKOFTransform;

import kof.game.character.animation.CAnimationStateConstants;
import kof.game.character.display.IDisplay;
import kof.game.character.fx.CFXMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;

public class CFallAppearAction extends CAppearAction {

    private var _fallHeight:int;

    private var _sFX_URL:String;

    private var _shakeWhenFall:Boolean;

    private var _booleanFX:Boolean = true;

    private var m_pAppearData:Object;

    public function CFallAppearAction( pOwner : CGameObject, pAppearData : Object  ) {
        super( pOwner );
        _fallHeight = pAppearData.fallHeight;
        _sFX_URL = pAppearData.fallEffect;
        _shakeWhenFall = pAppearData.shakeWhenFall;
        m_pAppearData = pAppearData;
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );

        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay )
        {
            var vPos : CVector3 = modelDisplay.modelDisplay.position;
//            pTransform.from2DAxis( vPos.x, vPos.y, _fallHeight);
            modelDisplay.modelDisplay.setPositionTo( vPos.x, vPos.y+_fallHeight, vPos.z );
            //modelDisplay.modelDisplay.move(0,_fallHeight,0);
//            modelDisplay.modelDisplay.playState( CAnimationStateConstants.JUMP );
//            modelDisplay.modelDisplay.onAnimationFinished = _onAnimationFinished;
        }

    }

    private function _onAnimationFinished( theAnimationClip : CAnimationClip ):void{
        if(theAnimationClip.m_sName == "Jump_Land_1"){
//            var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
//            if ( modelDisplay ){
//                modelDisplay.modelDisplay.onAnimationFinished = null;
//            }
            this.setResult( m_pAppearData.isPlayAction );
        }
    }

    private function showShake():void{
        if(_shakeWhenFall){
            var scence:CSceneMediator = (owner.getComponentByClass(CSceneMediator,true) as CSceneMediator);
            if(scence){
                scence.shakeXY(10,10,1);
            }
        }
    }

    private function showJumpEffect():void{
        if(_sFX_URL == "") {
            return;
        }
        var _fx:CFXMediator = (owner.getComponentByClass(CFXMediator,true) as CFXMediator);
        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay ){
            _fx.autoPlayFXOnce(_sFX_URL,false,modelDisplay.modelDisplay.position.x,0,modelDisplay.modelDisplay.position.z);
        }
    }

    override public function dispose():void {
        super.dispose();
        _fallHeight = 0;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
        if(!_booleanFX)
                return;
        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay && !modelDisplay.modelDisplay.inAir )
        {
            showJumpEffect();
            showShake();
            _booleanFX = false;
            setTimeout(timeoutFun,1000);
        }
    }

    private function timeoutFun():void{
        this.setResult( m_pAppearData.isPlayAction );
    }
}
}
