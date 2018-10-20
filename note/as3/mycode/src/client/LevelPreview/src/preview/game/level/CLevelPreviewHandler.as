/**
 * Created by auto on 2016/6/28.
 */
package preview.game.level {
import kof.framework.IApplication;
import kof.framework.INetworking;
import kof.game.CGameStage;
import kof.game.level.CLevelManager;
import kof.game.levelCommon.CLevelConfig;
import kof.game.levelCommon.CLevelLog;
import preview.game.levelServer.protocol.CEnterLevelResponse;
import kof.login.CLoginHandler;
import kof.message.Account.RoleLoginResponse;
import kof.message.Account.RoleMessageResponse;
import kof.message.CAbstractPackMessage;
import kof.message.GM.GMCommandRequest;
import kof.util.CAssertUtils;
import kof.util.CObjectUtils;

// 关卡通信, 接收服务器发来的信息 , 在levelStage中添加到levelSystem
public class CLevelPreviewHandler extends CLoginHandler {
    public function CLevelPreviewHandler() {
        super();
    }

    override protected function onSetup():Boolean {

        networking.bind( CEnterLevelResponse ).toHandler(onEnterLevelMessageHandlerB);
        networking.bind( RoleMessageResponse ).toHandler( roleInfoUpdateHandler );
        networking.bind( RoleLoginResponse ).toHandler( enterGameMessageHandler );
        return true;
    }

    /**
     * @处理进入关卡消息, 用在preview, 需要统一
     */
    public final function onEnterLevelMessageHandlerB(net:INetworking, message:CAbstractPackMessage):void {
        var response:CEnterLevelResponse = message as CEnterLevelResponse;
        CLevelLog.addDebugLog("client : receive enter level : " + response.fileName);
        (system.getBean(CLevelManager) as CLevelManager).enterLevelForPreview(response);
    }

    /**
     * 进入游戏，未进入到场景前的初始准备
     */
    private function enterGameMessageHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        // Next to GameStage.
        var app : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( app ) {
            app.replaceStage(  CLevelConfig.stage );
        }
    }

    /**
     * 收到玩家登陆的角色数据，缓存到App作用域，传递给GameStage使用
     */
    private function roleInfoUpdateHandler( net : INetworking, message : CAbstractPackMessage ) : void {
        var msg : RoleMessageResponse = message as RoleMessageResponse;
        if ( msg ) {
            // clone msg's data as object.
            var data : Object = CObjectUtils.cloneObject( msg );
            system.stage.configuration.setConfig( "role.data", data );
        }
        var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
        CAssertUtils.assertNotNull( request );

        request.command = "refresh_resources";
        request.args = [""];

        this.networking.send( request );
    }

    public function killOneMonster():void{
        var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
        CAssertUtils.assertNotNull( request );

        request.command = "removeOneDiffCampObject";
        request.args = [""];

        this.networking.send( request );
    }
    public function killAllEnemy():void{
        var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
        CAssertUtils.assertNotNull( request );

        request.command = "removeAllDiffCampObject";
        request.args = [""];

        this.networking.send( request );
    }
    public function killAllTeammates():void{
        var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
        CAssertUtils.assertNotNull( request );

        request.command = "removeOneCampObject";
        request.args = [""];

        this.networking.send( request );
    }
    public function killOneTeammates():void{
        var request : GMCommandRequest = this.networking.getMessage( GMCommandRequest ) as GMCommandRequest;
        CAssertUtils.assertNotNull( request );

        request.command = "removeAllCampObject";
        request.args = [""];

        this.networking.send( request );
    }

}
}
