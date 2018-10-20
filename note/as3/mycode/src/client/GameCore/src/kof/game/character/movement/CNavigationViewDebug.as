//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/16.
 * Time: 11:27
 */
package kof.game.character.movement {

import QFLib.Graphics.Sprite.CSprite;
import QFLib.Math.CVector2;

import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/16
     */
    public class CNavigationViewDebug extends CNavigation {
        private var _quadVec : Vector.<CSprite> = null;
        private var _sceneMediator : CSceneMediator = null;

        public function CNavigationViewDebug() {
            _quadVec = new <CSprite>[];
        }

        override protected virtual function onExit() : void {
            super.onExit();
            clearVec();
        }

        override public function clearPath( bNotifyAll : Boolean = false ) : void {
            clearVec();
        }

        private function clearVec() : void {
            for each ( var obj : CSprite in _quadVec ) {
                _sceneMediator.scene.sceneObject.removeObjectFromEntityLayer( obj );
                obj.dispose();
            }
            _quadVec.splice( 0, _quadVec.length );
        }

        public function addQuad( pathList : Array, sceneMediator : CSceneMediator, owner : CGameObject ) : void {
            clearVec();
            this._sceneMediator = sceneMediator;
            var len : int = pathList.length;
            for ( var i : int = 0; i < len; i++ ) {
                var quad : CSprite = new CSprite( sceneMediator.graphicFramework.spriteSystem );
                quad.createEmpty( 20, 20 );
                quad.setColor( 1, 0, 1 );
//                quad.loadFile( "assets/ui/icon/talent/fangyu1_1.png" );
                var vec2 : CVector2 = pathList[ i ];
                var f3DHeight : Number = sceneMediator.getTerrainHeight( vec2.x, vec2.y );
                quad.setPosition3D( vec2.x, f3DHeight, vec2.y );
//                quad.setPosition3D( owner.transform.position.x, owner.transform.position.z, owner.transform.position.y );
                _quadVec.push( quad );
            }
            for each ( var obj : CSprite in _quadVec ) {
                sceneMediator.scene.sceneObject.addObjectToEntityLayer( obj );
            }
        }
    }
}

import QFLib.Interface.IDisposable;

import flash.events.EventDispatcher;

import kof.game.character.movement.CNavigation;
import kof.game.character.movement.CNavigationViewDebug;
import kof.game.character.movement.INavigationListener;

class CDefaultListener extends EventDispatcher implements INavigationListener, IDisposable {

    private var m_pContainer : CNavigation;

    public function CDefaultListener( pContainer : CNavigationViewDebug ) {
        super();

        this.m_pContainer = pContainer;
    }

    public function dispose() : void {
        // NOOP.
        m_pContainer.removeListener( this );
        m_pContainer = null;
    }

}
