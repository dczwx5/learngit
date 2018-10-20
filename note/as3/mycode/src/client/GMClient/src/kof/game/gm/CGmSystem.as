//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm {

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.Framework.CFramework;
import QFLib.Graphics.RenderCore.utils.CGraphicsPage;
import QFLib.Interface.IUpdatable;

import kof.framework.INetworking;
import kof.game.common.system.CAppSystemImp;
import kof.game.gm.command.boots.CBootstrapCommandHandler;
import kof.game.gm.command.focusLost.CFocusLostCommandHandler;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;
import kof.game.gm.command.hangUp.CHangUpCommandHandler;
import kof.game.gm.command.instance.CInstanceCommandHandler;
import kof.game.gm.command.lobby.CLobbyCommandHandler;
import kof.game.gm.command.message.CKOFDynamicPackCommandHandler;
import kof.game.gm.command.switching.CSwitchingCommandHandler;
import kof.game.gm.command.tutor.CTutorCommandHandler;
import kof.game.gm.data.CGmData;
import kof.game.gm.view.cmdPage.CCharacterResourcePage;
import kof.game.gm.view.cmdPage.CGMenuPage;
import kof.game.gm.view.cmdPage.CGmPage;
import kof.game.gm.view.perf.CGamePerfPage;
import kof.game.scene.ISceneFacade;

public class CGmSystem extends CAppSystemImp implements IUpdatable {

    public function CGmSystem() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }

    // ====================================================================
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        if (ret) {
            this.addBean(_netHandler = new CGmNetHandler());
            this.addBean(_uiHandler = new CGmUIHandler());
            this.addBean(_gmData = new CGmData());

//            this.addBean( new CTalentCommandHanlder() );
//            this.addBean( new CTaskCommandHandler() );
            this.addBean( new CSwitchingCommandHandler() );
//            this.addBean( new CSignCommandHandler() );
//            this.addBean( new CMarqueeCommandHandler() );
//            this.addBean(new CCurrencyCommandHandler());
//            this.addBean(new CPlayerCommandHandler());
            this.addBean( new CLobbyCommandHandler() );
//            this.addBean( new CMailCommandHandler());
            this.addBean( new CBootstrapCommandHandler() );
            this.addBean( new CKOFDynamicPackCommandHandler() );
//            ret = ret && addBean(new CBagCommandHandler());
//            ret = ret && this.addBean( new CKOFConfigCommandHandler );
            ret = ret && this.addBean( new CInstanceCommandHandler() );
            addBean(new CTutorCommandHandler());
//            addBean(new CCheatCommandHandler());
//            addBean(new CPeakCommandHandler());
//            addBean(new CVipCommandHandler());
//            addBean(new CArenaCommandHandler());

            addBean(new CFocusLostCommandHandler());
            addBean(new CHangUpCommandHandler());

            _addCommand();
            var pDashBoard:CDashBoard = stage.getBean(CDashBoard) as CDashBoard;
            if (pDashBoard) {
                if (null == pDashBoard.findPageByClass(CGmPage)) {
                    pDashBoard.addPage(new CGmPage(this, pDashBoard));
                }
                if (null == pDashBoard.findPageByClass(CGMenuPage)) {
                    pDashBoard.addPage(new CGMenuPage(this, pDashBoard));
                }
                if (null == pDashBoard.findPageByClass(CGraphicsPage)) {
                    pDashBoard.addPage(new CGraphicsPage(pDashBoard));
                }
                var theFrameWork : CFramework = (stage.getSystem(ISceneFacade) as ISceneFacade).scenegraph.graphicsFramework;
                if (null == pDashBoard.findPageByClass(CCharacterResourcePage)) {
                    pDashBoard.addPage(new CCharacterResourcePage(pDashBoard, theFrameWork));
                }

                if (null == pDashBoard.findPageByClass( CGamePerfPage )) {
                    pDashBoard.addPage( new CGamePerfPage( pDashBoard, this ));
                }
            }
        }
        return ret;
    }

    public function update(delta : Number) : void {

    }

    private function _addCommand():void{
        var cmdList:Array = CGMConfig.gmArr;//_data as Array;

        var pBoard : CDashBoard = this.stage.getBean( CDashBoard ) as CDashBoard;
        var pConsolePage : CConsolePage = pBoard.findPage( "ConsolePage" ) as CConsolePage;

        for each (var itemType:Object in cmdList){
            for each (var item:Object in itemType.gmCmd){
                if(pConsolePage.commandHandler.commandMap.find(item.name) == null){
                    var cmd:CAbstractConsoleCommand = new CAbstractConsoleCommand(item.name,item.description,item.label);
                    cmd.syncToServer = true;
                    cmd.networking = this.stage.getBean( INetworking ) as INetworking;
                    if ( pConsolePage ) {
                        pConsolePage.commandHandler.registerCommand(cmd);
                    }
                }
            }
        }
    }

    // ============================interface========================================
    public function get netHandler() : CGmNetHandler { return _netHandler; }
    public function get uiHandler() : CGmUIHandler { return _uiHandler; }
    public function get gmData() : CGmData { return _gmData; }

    private var _netHandler : CGmNetHandler;
    private var _uiHandler : CGmUIHandler;
    private var _gmData:CGmData;

}
}