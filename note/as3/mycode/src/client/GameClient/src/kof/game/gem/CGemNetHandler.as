//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.gem.event.CGemEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Gem.GemAKeyMosaicRequest;
import kof.message.Gem.GemInfoRequest;
import kof.message.Gem.GemInfoResponse;
import kof.message.Gem.GemInfoUpdateResponse;
import kof.message.Gem.GemMergeRequest;
import kof.message.Gem.GemMosaicReplaceRequest;
import kof.message.Gem.GemTakeOffRequest;
import kof.message.Gem.GemUpgradeRequest;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CGemNetHandler extends CNetHandlerImp {
    public function CGemNetHandler()
    {
        super();
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();

        bind( GemInfoResponse, _onGemInfoResponse );
        bind( GemInfoUpdateResponse, _onGemInfoUpdateResponse );

        return true;
    }

//====================================================================================================================>>
    /**
     * 宝石信息请求
     */
    public function gemInfoRequest():void
    {
        var request:GemInfoRequest = new GemInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    private final function _onGemInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GemInfoResponse = message as GemInfoResponse;

        if(response)
        {
            _manager.initGemData(response);

            system.dispatchEvent(new CGemEvent(CGemEvent.GemInfoInit, null));
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>
    /**
     * 宝石信息改变反馈
     */
    private final function _onGemInfoUpdateResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GemInfoUpdateResponse = message as GemInfoUpdateResponse;

        if(response)
        {
            if(_manager.gemData == null)// 宝石数据尚未初始化
            {
                return;
            }

            _manager.updateGemInfo(response);

            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var configInfo:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(configInfo)
            {
                if(configInfo.content.indexOf("{0}") != -1 && response.contents.length)
                {
                    configInfo.content.replace("{0}", response.contents[0]);
                }

                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(configInfo.content,CMsgAlertHandler.NORMAL);
            }
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>

    /**
     * 宝石槽开启请求
     * @param gemPointConfigID 宝石孔配置表ID(唯一ID)
     */
    /*
    public function gemPointOpenRequest(gemPointConfigID:int):void
    {
        var request:GemPointOpenRequest = new GemPointOpenRequest();
        request.gemPointConfigID = gemPointConfigID;

        networking.post(request);
    }
    */

    /**
     * 宝石镶嵌（替换）请求
     * @param gemPointConfigID 宝石孔配置表ID(唯一ID)
     * @param gemConfigID 宝石配置表ID(唯一ID)
     */
    public function gemEmbedReplaceRequest(gemPointConfigID:int, gemConfigID:int):void
    {
        var request:GemMosaicReplaceRequest = new GemMosaicReplaceRequest();
        request.gemPointConfigID = gemPointConfigID;
        request.gemConfigID = gemConfigID;

        networking.post(request);
    }

    /**
     * 宝石一键镶嵌请求
     * @param pageType 页号
     */
    public function gemOneKeyEmbedRequest(pageType:int):void
    {
        var request:GemAKeyMosaicRequest = new GemAKeyMosaicRequest();
        request.pageType = pageType;

        networking.post(request);
    }

    /**
     * 宝石卸下请求
     * @param gemPointConfigID 宝石孔配置表ID(唯一ID)
     */
    public function gemTakeOffRequest(gemPointConfigID:int):void
    {
        var request:GemTakeOffRequest = new GemTakeOffRequest();
        request.gemPointConfigID = gemPointConfigID;

        networking.post(request);
    }

    /**
     * 宝石升级请求
     * @param type 1 一键升级（参数为宝石页类型）; 2 从宝石槽升级（参数位宝石槽配置表ID）; 3 从升级界面升级（参数为宝石配置表ID）EGemUpgradeType
     * @param param 升级参数
     */
    public function gemUpgradeRequest(type:int, param:int):void
    {
        var request:GemUpgradeRequest = new GemUpgradeRequest();
        request.type = type;
        request.param = param;

        networking.post(request);
    }

    /**
     * 宝石合成请求
     * @param gemConfigID 宝石配置表ID
     * @param num 合成数量
     */
    public function gemMergeRequest(gemConfigID:int, num:int):void
    {
        var request:GemMergeRequest = new GemMergeRequest();
        request.gemConfigID = gemConfigID;
        request.num = num;

        networking.post(request);
    }
//====================================================================================================================>>

    private function get _manager():CGemManagerHandler
    {
        return system.getHandler(CGemManagerHandler) as CGemManagerHandler;
    }
}
}
