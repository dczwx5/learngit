//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/22.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect.util {

import QFLib.Framework.CObject;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.TimerEvent;

import flash.utils.Timer;

import kof.game.character.CKOFTransform;
import kof.game.character.display.IDisplay;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;

import kof.game.core.CGameObject;
import kof.game.scene.ISceneFacade;
import kof.table.HitShake;
import kof.table.HitShake.EAliasCenter;
import kof.table.HitShake.EShakeType;

/**
 * 单例模式的频幕抖动
 */
public class CSkillScreenIns {

    public function CSkillScreenIns( cls : _privateClass ) {
        m_timer = new Timer(0);
        m_timer.addEventListener( TimerEvent.TIMER, onShakeTimer  );
        m_timer.addEventListener( TimerEvent.TIMER_COMPLETE,_removeTimer);
    }

    public static function getSkillScreenEffIns() : CSkillScreenIns
    {
        if( m_screenEff )
                return m_screenEff;
        else
            m_screenEff = new CSkillScreenIns( new _privateClass() )

        return m_screenEff;
    }

    public function dispose() : void
    {
        m_timer.removeEventListener( TimerEvent.TIMER, onShakeTimer  );
        m_timer.removeEventListener( TimerEvent.TIMER_COMPLETE,_removeTimer);
        m_timer.stop();
    }

    public function setUpSceneFacade( sceneFacade : ISceneFacade ) : void{
        m_sceneFacade = sceneFacade;
    }
    /**
     * @param shakeID  the shake effect ID
     * @param aliasPos cVector3 that contain the target transform or transform's position x, y ,z
     */
    public function playSceneShakeEffect(pTarget : CGameObject,  shakeID : int , aliasPos : CVector3 = null) : void
    {
        var hShake : HitShake
        if( shakeID != 0 ) {
           hShake  = CSkillCaster.skillDB.getHitShakeByID( shakeID );
        }

        if( null == hShake )
            return ;

        if( hShake.ShakeType == EShakeType.E_DISTANCE_SHAKE )
        {
            playDistanceSceneEffect( hShake , pTarget)
        }
        else if( hShake.ShakeType == EShakeType.E_SCALE_SHAKE )
        {
            /**
            if( m_timer )
            {
                m_timer.reset();
                m_timer.stop();
            }

//            m_pTarget = pTarget;
            m_pShakeInfo = hShake;//m_pCenter=null;
            playZoomSceneEffect( pTarget , hShake , aliasPos );*/
            playScaleShake( hShake  , pTarget );

        }
    }

    private function playScaleShake( hShake : HitShake , pTarget : CGameObject ) : void
    {
        if( !pTarget )
            return;

        var shakeExt : CVector2 = CVector2.ZERO.clone();
        var frequency : Number = 0.02;

        if( hShake.Frequency != 0)
            frequency = 1/hShake.Frequency ;
        var duration : Number = frequency * hShake.Count;

        shakeExt.x = CMath.cosDeg( hShake.Direction ) * hShake.Extent / 10;
        shakeExt.y = CMath.sinDeg( hShake.Direction ) * hShake.Extent / 10;

        var sceneMediator : CSceneMediator = pTarget.getComponentByClass(CSceneMediator, true) as CSceneMediator;
        if(sceneMediator)
            sceneMediator.zoomShake(10,0.25,0.05 );//shakeExt.x , duration , frequency ) ;//( shakeExt.x, shakeExt.y, duration, frequency );
    }

    private function playDistanceSceneEffect( hShake : HitShake , pTarget : CGameObject) : void
    {
        if( !pTarget )
                return;

        var shakeExt : CVector2 = CVector2.ZERO.clone();
        var frequency : Number = 0.02;

        if( hShake.Frequency != 0)
            frequency = 1/hShake.Frequency ;
        var duration : Number = frequency * hShake.Count;

        shakeExt.x = CMath.cosDeg( hShake.Direction ) * hShake.Extent / 10;
        shakeExt.y = CMath.sinDeg( hShake.Direction ) * hShake.Extent / 10;

        var sceneMediator : CSceneMediator = pTarget.getComponentByClass(CSceneMediator, true) as CSceneMediator;
        if(sceneMediator)
            sceneMediator.shakeXY( shakeExt.x, shakeExt.y, duration, frequency );

    }

    private function playZoomSceneEffect( pTarget : CGameObject , hShake : HitShake , aliasPos : CVector3 ) : void {
        var shakeExt : CVector2 = CVector2.ZERO.clone();
        var center2D : CVector3;
        var centerTransform : CKOFTransform;
        var aliasCenter : int = hShake.CenterAlias;
        var boundOffset : CVector2 = CVector2.ZERO.clone();

        if ( hShake.Frequency != 0 )
            m_frequency = 1 / hShake.Frequency;

        if ( aliasCenter == EAliasCenter.E_ALIAS_ATTACTER ) {
            centerTransform = pTarget.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            center2D = CObject.get2DPositionFrom3D( centerTransform.x, centerTransform.z, centerTransform.y );
            m_pCenter.setValueXY( center2D.x, center2D.y );
        }
        else if ( aliasCenter == EAliasCenter.E_ALIAS_DEFENCER ) {
            center2D = CObject.get2DPositionFrom3D( aliasPos.x, aliasPos.z, aliasPos.y );
            m_pCenter.setValueXY( center2D.x, center2D.y );
        }
        else
            m_pCenter = null;

        var mDisplay : IDisplay = pTarget.getComponentByClass( IDisplay , true ) as IDisplay;

        if ( m_pCenter != null && mDisplay && mDisplay.modelCurrentBound ) {
            boundOffset.setValueXY( 0, -mDisplay.modelCurrentBound.extY );
            m_pCenter.addOn( boundOffset );
        }

        onShakeTimer( null );

        m_timer.delay = 1.0/hShake.Frequency  * 1000;
        m_timer.repeatCount = hShake.Count * 2 - 1;
        m_timer.start();
    }

    private function onShakeTimer( e: TimerEvent ) : void
    {
        var shakeExt : CVector2 = CVector2.ZERO.clone();
        var damping : Number = int ( m_timer.currentCount  / 4 )  * m_pShakeInfo.Damping / 100;

//        var sceneMediator : CSceneMediator = m_pTarget.getComponentByClass(CSceneMediator, true) as CSceneMediator;

        if( m_sceneFacade == null ) return;

        if( m_timer.currentCount % 4 == 2 || m_timer.currentCount % 4 == 1 ) {
            //negative to scale larger
            shakeExt.x = -m_pShakeInfo.Extent *( 1 - damping ) / 1000;
            shakeExt.y = shakeExt.x;
            m_sceneFacade.zoomCenterExt( m_pCenter, shakeExt, 0.1 );
        }
        else
        {
            shakeExt.x = m_pShakeInfo.Extent * ( 1 - damping ) / 1000;
            shakeExt.y = shakeExt.x;
            m_sceneFacade.zoomCenterExt( m_pCenter, shakeExt, 0.1 );
        }

    }

    private function _removeTimer( e: TimerEvent ): void
    {
        m_timer.stop();
        m_timer.reset();
//        m_timer.removeEventListener( TimerEvent.TIMER, onShakeTimer  );
//        m_timer.removeEventListener( TimerEvent.TIMER_COMPLETE,_removeTimer);
    }

    private  var m_sceneFacade : ISceneFacade;
    private static var m_screenEff : CSkillScreenIns;

    //只是缩放的变量 抖动的别用
    private static var m_timer : Timer;
//    private  var m_pTarget : CGameObject;
    private  var m_pShakeInfo : HitShake;
    private  var m_pCenter : CVector2 = CVector2.ZERO.clone();
    private  var m_frequency : Number = 0.02;

    //下面是抖动的
}
}

class _privateClass
{

}
