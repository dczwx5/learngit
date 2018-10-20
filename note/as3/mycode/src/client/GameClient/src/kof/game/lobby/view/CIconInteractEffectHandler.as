//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.lobby.view {

import QFLib.Foundation.CWeakRef;

import com.greensock.TweenLite;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;

import morn.core.components.Component;
import morn.core.components.Image;

/**
 *
 * @author jeremy
 */
public class CIconInteractEffectHandler extends CViewHandler {

    private static var LEFT_TOP : Point = new Point( 0, 0 );

    /** Creates an new CIconInteractEffectHandler */
    public function CIconInteractEffectHandler() {
        super();
    }

//    private function onMouseOverInEffect( event : MouseEvent ) : void {
//        event.preventDefault();
//        event.stopImmediatePropagation();
//    }

    protected function getOriginPosX( comp : Component, pos : Point = null ) : Point {
        var posOrig : Point = pos || new Point();
        if ( comp.tag && 'originX' in comp.tag ) {
            posOrig.setTo( comp.tag.originX, comp.tag.originY );
        } else {
            posOrig.setTo( comp.x, comp.y );
            comp.tag = comp.tag || {};
            comp.tag.originX = posOrig.x;
            comp.tag.originY = posOrig.y;
        }
        return posOrig;
    }

    public function performScaleEffect( aIcon : Component, aBg : Component,
                                        aIconPos : Point = null, aBgPos : Point = null ) : void {
        if ( !aIcon || !aBg )
            return;

        TweenLite.killTweensOf( aIcon );
        TweenLite.killTweensOf( aBg );

//        function addPreventRecusiveHoverEvents() : void {
//            aIcon.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverInEffect, true, 100, true );
//            aBg.addEventListener( MouseEvent.MOUSE_OVER, onMouseOverInEffect, true, 100, true );
//        }
//
//        function removePreventRecusiveHoverEvents() : void {
//            aIcon.removeEventListener( MouseEvent.MOUSE_OVER, onMouseOverInEffect );
//            aBg.removeEventListener( MouseEvent.MOUSE_OVER, onMouseOverInEffect );
//        }

        var posIconOrig : Point = aIconPos || getOriginPosX( aIcon );
        var posBgOrig : Point = aBgPos || getOriginPosX( aBg );

        // function onMouseOutInEffect( event : MouseEvent ) : void {
        // aIcon.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect );
        // aBg.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect );
        // aIcon.removeEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect );
        // aBg.removeEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect );

        // if ( t3 ) {
        // t3.kill();
        // }

        // aIcon.scale = 1.0;
        // aIcon.scaleX = 1.0;
        // aIcon.scaleY = 1.0;
        // aIcon.x = posIconOrig.x;
        // aIcon.y = posIconOrig.y;

        // aBg.scaleX = 1.0;
        // aBg.scaleY = 1.0;
        // aBg.x = posBgOrig.x;
        // aBg.y = posBgOrig.y;
        // }

        // aIcon.addEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect, false, 100, true );
        // aBg.addEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect, false, 100, true );
        // aIcon.addEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect, false, 100, true );
        // aBg.addEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect, false, 100, true );

        var fScale : Number = 3.0;

        var t1 : TweenLite = TweenLite.fromTo( aIcon, 8.0 / 30.0, {
            scaleX : fScale,
            scaleY : fScale,
            x : posIconOrig.x + (1.0 - fScale) * aIcon.width * 0.5,
            y : posIconOrig.y + (1.0 - fScale) * aIcon.height * 0.5,
            alpha : 0
        }, {
            scaleX : 1,
            scaleY : 1,
            x : posIconOrig.x,
            y : posIconOrig.y,
            alpha : 1,
            onComplete : function ( aIcon : Component, origX : Number, origY : Number ) : void {
                aIcon.scaleX = aIcon.scaleY = 1;
                aIcon.alpha = 1;
                aIcon.x = origX;
                aIcon.y = origY;
                t1.kill();
            },
            onCompleteParams : [ aIcon, posIconOrig.x, posIconOrig.y ]
        } );

        var t2 : TweenLite = TweenLite.fromTo( aBg, 8.0 / 30.0, {
            scaleX : 1 / fScale,
            scaleY : 1 / fScale,
            alpha : 0,
            x : posBgOrig.x + ( 1.0 - 1.0 / fScale ) * aBg.width / 2,
            y : posBgOrig.y + ( 1.0 - 1.0 / fScale ) * aBg.height / 2
        }, {
            scaleX : 1,
            scaleY : 1,
            x : posBgOrig.x,
            y : posBgOrig.y,
            alpha : 1,
            onStart : function () : void {
                // start.
            },
            onComplete : function ( aBg : Component, origX : Number, origY : Number ) : void {
                aBg.scaleX = aBg.scaleY = 1;
                aBg.alpha = 1.0;
                aBg.x = origX;
                aBg.y = origY;
//                removePreventRecusiveHoverEvents();
                t2.kill();
            },
            onCompleteParams : [ aBg, posBgOrig.x, posBgOrig.y ]
        } );

        var t3 : TweenLite = TweenLite.fromTo( aIcon, 0.15, {
            scaleX : 1,
            scaleY : 1,
            alpha : 1,
            x : posIconOrig.x,
            y : posIconOrig.y
        }, {
            scaleX : 1.2,
            scaleY : 1.2,
            delay : 8.0 / 30.0,
            x : posIconOrig.x + -0.2 * aIcon.width * 0.5,
            y : posIconOrig.y + -0.2 * aIcon.height * 0.5,
            alpha : 1,
            onComplete : function () : void {
                t3.kill();
            }
        } );

        aIcon.tag[ 't3' ] = t3;
    }

    public function endScaleEffect( aIcon : Component, aBg : Component,
                                    aIconPos : Point = null, aBgPos : Point = null ) : void {

        if ( !aIcon || !aBg )
            return;

        var posIconOrig : Point = aIconPos || getOriginPosX( aIcon );
        var posBgOrig : Point = aBgPos || getOriginPosX( aBg );

        var t3 : TweenLite = aIcon.tag[ 't3' ] as TweenLite;

        if ( t3 ) {
            t3.kill();
        }

        aIcon.scale = 1.0;
        aIcon.scaleX = 1.0;
        aIcon.scaleY = 1.0;
        aIcon.x = posIconOrig.x;
        aIcon.y = posIconOrig.y;

        aBg.scaleX = 1.0;
        aBg.scaleY = 1.0;
        aBg.x = posBgOrig.x;
        aBg.y = posBgOrig.y;
    }

    public function performMouseDownEffect( comp : Component ) : void {
        if ( !comp )
            return;

//        TweenLite.killTweensOf( comp, true );

        var fTime : Number = 0.125;
        var posOrig : Point = getOriginPosX( comp );

        var fScale : Number = 0.75;

        var t1 : TweenLite = TweenLite.fromTo( comp, fTime, {
            scale : 1.0,
            x : posOrig.x,
            y : posOrig.y
        }, {
            scale : fScale,
            x : posOrig.x + (1.0 - fScale) * comp.width * 0.5,
            y : posOrig.y + (1.0 - fScale) * comp.height * 0.5,
            onComplete : function () : void {
                t1.kill();
            }
        } );

        var t2 : TweenLite = TweenLite.fromTo( comp, fTime, {
            scale : fScale,
            x : posOrig.x + (1.0 - fScale) * comp.width * 0.5,
            y : posOrig.y + (1.0 - fScale) * comp.height * 0.5
        }, {
            delay : fTime,
            scale : 1.0,
            x : posOrig.x,
            y : posOrig.y,
            onComplete : function () : void {
                t2.kill();
            }
        } );
    }

    private var m_pLastItemWeak : CWeakRef;

    public function endScaleEffect1( aItem : Component, aIcon : Component, aBg : Component, aText : Component,
                                     aIconPos : Point = null, aBgPos : Point = null, aTextPos : Point = null ) : void {

        if ( !aItem || !aIcon || !aBg || !aText )
            return;

        var posIconOrig : Point = aIconPos || getOriginPosX( aIcon );
        // var posBgOrig : Point = aBgPos || getOriginPosX( aBg );
        var posTextOrig : Point = aTextPos || getOriginPosX( aText );

        var t2 : TweenLite = aItem.tag[ 't2' ] as TweenLite;
        var t3 : TweenLite = aItem.tag[ 't3' ] as TweenLite;


        if ( t2 ) t2.kill();
        if ( t3 ) t3.kill();

        aIcon.scaleX = 1.0;
        aIcon.scaleY = 1.0;
        aIcon.alpha = 1.0;
        aIcon.x = posIconOrig.x;
        aIcon.y = posIconOrig.y;

        aText.scaleX = 1.0;
        aText.scaleY = 1.0;
        aText.alpha = 1.0;
        aText.x = posTextOrig.x;
        aText.y = posTextOrig.y;

        TweenLite.killTweensOf( aIcon );
        TweenLite.killTweensOf( aText );
    }

    public function performScaleEffect1( aItem : Component, aIcon : Component, aBg : Component, aText : Component,
                                         aIconPos : Point = null, aBgPos : Point = null, aTextPos : Point = null ) : void {
        if ( !aItem || !aIcon || !aBg || !aText )
            return;

        TweenLite.killTweensOf( aIcon );
        TweenLite.killTweensOf( aBg );
        TweenLite.killTweensOf( aText );

        if ( m_pLastItemWeak && m_pLastItemWeak.ptr && m_pLastItemWeak.ptr != aItem ) {
            IEventDispatcher( m_pLastItemWeak.ptr ).dispatchEvent( new MouseEvent( MouseEvent.MOUSE_OUT ) );
            m_pLastItemWeak.ptr = null;
        }

        var posIconOrig : Point = aIconPos || getOriginPosX( aIcon );
        var posBgOrig : Point = aBgPos || getOriginPosX( aBg );
        var posTextOrig : Point = aTextPos || getOriginPosX( aText );

        var fScale : Number = 1.2;

        function onMouseOutInEffect( event : MouseEvent ) : void {
            var rt : Rectangle = new Rectangle( aIcon.x, aIcon.y, aIcon.width, aText.y + aText.height - aIcon.y );
            var pt : Point = new Point( event.localX, event.localY );

            if ( rt.containsPoint( pt ) )
                return;

            aItem.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect );
            aItem.removeEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect );
//            aText.removeEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect );
//            aText.removeEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect );

            t2.kill();
            t3.kill();

            aIcon.scaleX = 1.0;
            aIcon.scaleY = 1.0;
            aIcon.alpha = 1.0;
            aIcon.x = posIconOrig.x;
            aIcon.y = posIconOrig.y;

            aText.scaleX = 1.0;
            aText.scaleY = 1.0;
            aText.alpha = 1.0;
            aText.x = posTextOrig.x;
            aText.y = posTextOrig.y;

            TweenLite.killTweensOf( aIcon );
            TweenLite.killTweensOf( aText );
        }

//        aItem.addEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect, false, 100, true );
//        aItem.addEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect, false, 100, true );
//        aText.addEventListener( MouseEvent.MOUSE_OUT, onMouseOutInEffect, false, 100, true );
//        aText.addEventListener( MouseEvent.ROLL_OUT, onMouseOutInEffect, false, 100, true );

        if ( aText is Image )
            ( aText as Image ).smoothing = true;

        if ( aIcon is Image )
            ( aIcon as Image ).smoothing = true;

        var t1 : TweenLite = TweenLite.fromTo( aBg, 0.5, {
            scaleX : 1.0,
            scaleY : 1.0,
            alpha : 1.0,
            x : posBgOrig.x,
            y : posBgOrig.y,
            onStart : function () : void {
                preventMouseEvents( aBg );
            }
        }, {
            scaleX : fScale,
            scaleY : fScale,
            alpha : 0.0,
            x : posBgOrig.x + (1.0 - fScale) * aBg.width * 0.5,
            y : posBgOrig.y + (1.0 - fScale) * aBg.height * 0.5,
            onComplete : function () : void {
                t1.kill();
                aBg.scaleX = 1.0;
                aBg.scaleY = 1.0;
                aBg.alpha = 1.0;
                aBg.x = posBgOrig.x;
                aBg.y = posBgOrig.y;

                recoverMouseEvents( aBg );
            }
        } );

        fScale = 1.1;
        var fOffsetYp : Number = 0.08;

        var t2 : TweenLite = TweenLite.fromTo( aIcon, 0.25, {
            scaleX : 1.0,
            scaleY : 1.0,
            alpha : 1.0,
            x : posIconOrig.x,
            y : posIconOrig.y
        }, {
            scaleX : fScale,
            scaleY : fScale,
            alpha : 1.0,
            x : posIconOrig.x + (1.0 - fScale) * aIcon.width * 0.5,
            y : posIconOrig.y + (1.0 - fScale) * aIcon.height * 0.5 - aIcon.height * fOffsetYp
        } );

        var t3 : TweenLite = TweenLite.fromTo( aText, 0.25, {
            scaleX : 1.0,
            scaleY : 1.0,
            alpha : 1.0,
            x : posTextOrig.x,
            y : posTextOrig.y
        }, {
            scaleX : fScale,
            scaleY : fScale,
            alpha : 1.0,
            x : posTextOrig.x + (1.0 - fScale) * aText.width * 0.5,
            y : posTextOrig.y + (1.0 - fScale) * aText.height * 0.5
        } );

        m_pLastItemWeak = m_pLastItemWeak || new CWeakRef();
        m_pLastItemWeak.ptr = aItem;

        aItem.tag[ 't2' ] = t2;
        aItem.tag[ 't3' ] = t3;
    }

    private function preventMouseEvents( aComp : Component ) : void {
        if ( !aComp )
            return;

        aComp.addEventListener( MouseEvent.MOUSE_OVER, _comp_preventEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
        aComp.addEventListener( MouseEvent.ROLL_OVER, _comp_preventEventHandler, false, CEventPriority.CURSOR_MANAGEMENT, true );
    }

    private function _comp_preventEventHandler( event : Event ) : void {
        event.preventDefault();
        event.stopImmediatePropagation();
    }

    private function recoverMouseEvents( aComp : Component ) : void {
        if ( !aComp )
            return;

        aComp.removeEventListener( MouseEvent.MOUSE_OVER, _comp_preventEventHandler );
        aComp.removeEventListener( MouseEvent.ROLL_OVER, _comp_preventEventHandler );
    }

}
}
