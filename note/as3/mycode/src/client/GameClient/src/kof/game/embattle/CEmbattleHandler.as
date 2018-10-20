//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/14.
 */
package kof.game.embattle {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.message.CAbstractPackMessage;
import kof.message.Embattle.EmbattleMessageRequest;
import kof.message.Embattle.EmbattleMessageResponse;
import kof.table.InstanceType;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CEmbattleHandler extends CNetHandlerImp {

    private var _saveObj:Object;

    public var type:int;

//    public var limit:int;

    public function CEmbattleHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(EmbattleMessageResponse, networking_broadcastMessageHandler);

        return ret;
    }

    public function onEmbattleMessageRequest( embattleMessageList:Array ,handleType : int = 0):void{

        var instanceType : InstanceType = _pEmbattleManager.getInstanceByType( type );
        if( instanceType && embattleMessageList.length < instanceType.embattleNumMin ){
            _pCUISystem.showMsgAlert( instanceType.name + "至少要有" + instanceType.embattleNumMin + "位上阵格斗家" );
            return ;
        }
        if( embattleMessageList.length > instanceType.embattleNumLimit ){
            _pCUISystem.showMsgAlert("最大上阵格斗家人数为" + instanceType.embattleNumLimit);
            return ;
        }

        _saveObj = {};
        _saveObj.embattleList = embattleMessageList;
        _saveObj.type = type;

        var request:EmbattleMessageRequest = new EmbattleMessageRequest();
        request.decode([embattleMessageList,type,handleType]);

        networking.post(request);

    }

    private function networking_broadcastMessageHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:EmbattleMessageResponse = message as EmbattleMessageResponse;
        //布阵成功
        if(response.gamePromptID == 0){
            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var pCPlayerData : CPlayerData = (playerSystem.getBean(CPlayerManager) as CPlayerManager).playerData;
            var embattleListData:CEmbattleListData = pCPlayerData.embattleManager.getByType(type);
            embattleListData.updateDataByData(_saveObj);

            if( response.subType == CEmbattleConst.SAVE_EMBATTLE  )
                _pCUISystem.showMsgAlert("保存阵容成功",CMsgAlertHandler.NORMAL );

            system.dispatchEvent(new CEmbattleEvent(CEmbattleEvent.EMBATTLE_SUCC));
        }
        system.dispatchEvent(new CEmbattleEvent(CEmbattleEvent.EMBATTLE_DATA));
    }



    private function get _pEmbattleManager():CEmbattleManager{
        return system.getBean(CEmbattleManager ) as CEmbattleManager
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    override public function dispose() : void {
        super.dispose();
    }
}
}
