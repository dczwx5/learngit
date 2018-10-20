/**
 * Created by user on 2017/7/21.
 */
package kof.game.level {

import QFLib.Framework.CObject;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import kof.framework.CAbstractHandler;
import kof.game.character.CFacadeMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;

public class CLevelPortalHandler extends CAbstractHandler{

    private var _portalType:int;
    public function CLevelPortalHandler() {
        super();
    }

    public function startPortal(type:int):void{
        _portalType = type;
        _startFun();
    }

    private function _startFun():void{
        (system.getBean(CLevelManager) as CLevelManager).pauseLevel();
        switch (_portalType){
            case -1 ://不自动传送
                break;
            case  0://倒计时自动传送
                (system.getBean(CLevelHandler) as CLevelHandler).sendEndPortalRequest();
                break;
            case 1 ://跑动传送
                runPortal();
                break;
            case 2://特效传送
                break;
            case 3://播放胜利动作传送
                (system.getBean(CLevelManager) as CLevelManager).waitAllGameObjectFinishWinAnimation(1,winAnimationCallbackFun);
                break;
        }
    }

    private function runPortal():void{
        var gameSystem : CECSLoop = system.stage.getSystem( CECSLoop ) as CECSLoop;
        var playHandler : CPlayHandler = gameSystem.getBean( CPlayHandler ) as CPlayHandler;
        var pDisplay : IDisplay = playHandler.hero.getComponentByClass( IDisplay, true ) as IDisplay;
        var array:Array = (system as CLevelSystem).getPortal();
        var location:Object = array[0].location;
        var targetPoint:CVector2  = new CVector2(location.x, location.y);
        var vec3:CVector3 = CObject.get3DPositionFrom2D(pDisplay.modelDisplay,targetPoint.x,targetPoint.y);
        targetPoint.x = vec3.x;
        targetPoint.y = vec3.z;
        var pFacadeMediator : CFacadeMediator = playHandler.hero.getComponentByClass( CFacadeMediator, true ) as CFacadeMediator;
        pFacadeMediator.moveTo(targetPoint);
    }

    private function winAnimationCallbackFun(obj:*):void{
        (system.getBean(CLevelHandler) as CLevelHandler).sendEndPortalRequest();
    }
}
}
