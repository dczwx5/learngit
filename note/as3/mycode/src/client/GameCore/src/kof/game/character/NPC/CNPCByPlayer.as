//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/19.
 */
package kof.game.character.NPC {

import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Math.CVector3;

import kof.game.character.CFacadeMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;

public class CNPCByPlayer extends CSubscribeBehaviour {

    private var m_npcObj:CGameObject;
    public function CNPCByPlayer() {
        super( "npcByPlayer" );
    }

    private var _moveToCallback:Function;
    public function moveToNPC(npcObj:CGameObject,scene:CScene, moveToCallback:Function = null):void{
        _moveToCallback = moveToCallback;
        if (npcObj == null || npcObj.transform == null){
            return;
        }
        m_npcObj = npcObj;

        var pFacadeMediator:CFacadeMediator = (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator);
        var dis:Number = owner.transform.x - npcObj.transform.x;
        var yDis:int =  owner.transform.y - npcObj.transform.y;
        if ( Math.abs( dis ) >= 150 ||  Math.abs( yDis ) >= 150 ) {
            var offsetX:int = Math.abs( dis ) >= 100 ? dis > 0 ? 100 : -100 : 0;
            var offsetY:int = Math.abs( yDis ) > 100 ?  yDis > 0 ? 100 : -100 : 0;
            var vec3:CVector3 = new CVector3(npcObj.transform.x,npcObj.transform.y,npcObj.transform.z);
            var moveBool:Boolean = pFacadeMediator.moveTo( new CVector2( vec3.x + offsetX, vec3.y + offsetY ), moveToCallBackFun );
            if(!moveBool){
                var m_scene:CScene = (owner.getComponentByClass(CSceneMediator,false) as CSceneMediator).scene;
                vec3 = m_scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3,m_scene.collisionData.movableBoxID);
                pFacadeMediator.moveTo( new CVector2( vec3.x, vec3.z ), moveToCallBackFun );
            }
        }else{
            (m_npcObj.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).triggerNPC();
        }
    }
    //世界boss提的需求，界面点击打大蛇，要跑到NPC旁边后，自动进入战场，和原来逻辑正好相反，所以新增一个方法
    public function moveToWorldBossNPC(npcObj:CGameObject,scene:CScene,callBackFunc:Function):void{
        if (npcObj == null || npcObj.transform == null){
            return;
        }
        m_npcObj = npcObj;
        var pFacadeMediator:CFacadeMediator = (owner.getComponentByClass(CFacadeMediator,false) as CFacadeMediator);
        var dis:Number = owner.transform.x - npcObj.transform.x;
        var yDis:int =  owner.transform.y - npcObj.transform.y;
        if ( Math.abs( dis ) >= 150 ||  Math.abs( yDis ) >= 150 ) {
            var offsetX:int = Math.abs( dis ) >= 100 ? dis > 0 ? 100 : -100 : 0;
            var offsetY:int = Math.abs( yDis ) > 100 ?  yDis > 0 ? 100 : -100 : 0;
            var vec3:CVector3 = new CVector3(npcObj.transform.x,npcObj.transform.y,npcObj.transform.z);
            var moveBool:Boolean = pFacadeMediator.moveTo( new CVector2( vec3.x + offsetX, vec3.y + offsetY ), callBackFunc );
            if(!moveBool){
                vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.z, vec3.y, vec3);
                pFacadeMediator.moveTo( new CVector2( vec3.x, vec3.z ), callBackFunc );
            }
        }else{
            callBackFunc.apply();
        }
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onExit() : void {
        m_npcObj = null;
    }

    private function moveToCallBackFun():void{
        var dis:Number = owner.transform.x - m_npcObj.transform.x;
        var yDis:int =  owner.transform.y - m_npcObj.transform.y;
        if ( Math.abs( dis ) >= 150 ||  Math.abs( yDis ) >= 150 ) {
            if (null != _moveToCallback) {
                _moveToCallback();
            }
            return;
        }
        else{
            (m_npcObj.getComponentByClass(CNPCTriggerMediator, true) as CNPCTriggerMediator).triggerNPC();
            if (null != _moveToCallback) {
                _moveToCallback();
            }
        }
    }


}
}
