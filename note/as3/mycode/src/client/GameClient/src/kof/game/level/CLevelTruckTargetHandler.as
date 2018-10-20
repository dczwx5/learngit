/**
 * Created by user on 2016/12/28.
 */
package kof.game.level {

    import kof.framework.CSystemHandler;
    import kof.framework.INetworking;
    import kof.game.levelCommon.Enum.ETrunkEventType;
    import kof.game.levelCommon.info.CLevelConfigInfo;
    import kof.message.CAbstractPackMessage;
    import kof.message.Level.TruckTargetPassResponse;

    public class CLevelTruckTargetHandler extends CSystemHandler {

    public function CLevelTruckTargetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
        networking.unbind(TruckTargetPassResponse);

    }
    override protected function onSetup():Boolean {
        networking.bind(TruckTargetPassResponse).toHandler(_onTruckTargetComplete);
        return true;
    }

    private final function _onTruckTargetComplete(net:INetworking, message:CAbstractPackMessage):void{
        var levelManager:CLevelManager = (system.getBean(CLevelManager) as CLevelManager);
        var levelConfigInfo:CLevelConfigInfo = levelManager.levelConfigInfo;
        var eventsList:Array = levelConfigInfo.getTrunkById(levelManager.curTrunkData.ID).passEvents;
        if(eventsList == null || eventsList.length <= 0){
            onStateChangedFun();
            return;
        }
        for each (var obj:Object in eventsList){
            switch (obj.name){
                case ETrunkEventType.PLAY_SCENE_ANIMATION:
                    levelManager._sceneEffect.playAnimation(obj.parameter,onStateChangedFun);
                    break;
                case ETrunkEventType.PLAY_ANIMATION:
                    levelManager._levelEffect.showAnimation(obj.parameter,onStateChangedFun);
                    break;
                case ETrunkEventType.PLAY_SCENE_EFFECT:
                    levelManager._sceneEffect.playEffect(obj.parameter,onStateChangedFun);
                    break;
                case ETrunkEventType.PLAY_EFFECT:
                    levelManager._levelEffect.showEffect(obj.parameter,onStateChangedFun);
                    break;
                case ETrunkEventType.SCENARIO:
                    onStateChangedFun( null );
                    break;
            }
        }
    }

    private function onStateChangedFun( object : Object = null ):void{
        (system.getBean(CLevelHandler) as CLevelHandler).sendTrunkPassedEvent();
    }
}
}
