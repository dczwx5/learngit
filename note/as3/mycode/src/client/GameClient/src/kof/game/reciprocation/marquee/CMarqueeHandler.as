//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/4/10.
 */
package kof.game.reciprocation.marquee {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.chat.CChatSystem;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatLinkConst;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.message.CAbstractPackMessage;
import kof.message.Player.MarqueeResponse;
import kof.table.ArtifactQuality;
import kof.table.EquipQuality;
import kof.table.MarqueeInfo;
import kof.table.PlayerQuality;
import kof.util.CQualityColor;

public class CMarqueeHandler extends CNetHandlerImp {

    /**2俱乐部*/
    public static const CHANNEL_TYPE_2:int = 2;
    /**4系统*/
    public static const CHANNEL_TYPE_4:int = 4;


    public function CMarqueeHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        super.onSetup();
        bind( MarqueeResponse, _onMarqueeMsgHandler );//141
        return true;
    }

    private function getMarqueeTable( marqueeId:int ):MarqueeInfo
    {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MARQUEE_MSG);
        var info:MarqueeInfo = pTable.findByPrimaryKey( marqueeId );
        return info;
    }

    private function getQualityTable( quality:int ):PlayerQuality
    {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
        var info:PlayerQuality = pTable.findByPrimaryKey( quality );
        return info;
    }

    //====================S2C====================
    private function _onMarqueeMsgHandler( net:INetworking, message:CAbstractPackMessage, isError:Boolean ):void{
        var response:MarqueeResponse = message as MarqueeResponse;
        var marqueeId:int = response.marqueeID;

        var msg:String = "";
        var showTime:int = 5;
        //=====记录公告中携带的数据参数及获取时间====by Lune 2018.05.31============
        var responseData:Dictionary = new Dictionary();
        responseData["time"] = CTime.getCurrServerTimestamp();//获取当前时间

        if( marqueeId == 0 ){
            //如果id是0，直接显示内容
            msg = response.contents[0];

            if (response.channelType == 8) {
                var mqData : CMarqueeData = system.getBean( CMarqueeData ) as CMarqueeData;
                if ( mqData ) {
                    mqData.push( msg, showTime);
                }

                var mqViewHandler:CMarqueeViewHandler = system.getBean( CMarqueeViewHandler ) as CMarqueeViewHandler;
                if( mqViewHandler ){
                    system.stage.callLater( mqViewHandler.startMarquee );
                }
            } else {
                if( chatSystem && response.channelType != 8 )
                    chatSystem.addSystemMsg( msg , response.channelType );
            }
        } else {
            var record:MarqueeInfo = getMarqueeTable( marqueeId );
            if (record) {
                // show by record.type : 0 is info, 1 is error
                var content : String = record.content;
                if ( response.contents && response.contents.length ) {
                    var replaceKey : String;
                    var qualityName : String = '';
                    var qualityLevel : PlayerQuality;
                    var qualityLevelValue : int
                    for ( var i : int = 0; i < response.contents.length; i++ ) {
                        replaceKey = "{" + i + "}";
                        if( i == 1 ){
                            if( marqueeId == 201 || marqueeId == 301 ) {//201:格斗家 301:装备
//                                var playerHeroData : CPlayerHeroData = new CPlayerHeroData();
//                                playerHeroData.databaseSystem = system.stage.getSystem( IDatabase ) as IDatabase;
//                                qualityLevel  = playerHeroData.heroQualityLevelTable.findByPrimaryKey( response.contents[ 3 ] );
//                                qualityLevelValue  = int( qualityLevel.qualityColour );
                                if (marqueeId == 201) {
                                    var playerQuality : PlayerQuality = getPlayerQuality( response.contents[ 3 ] );
                                    qualityName = playerQuality.qualityName;
                                    qualityLevelValue  = int( playerQuality.qualityColour );

                                    response.contents[ 2 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>【" + response.contents[ 2 ] + "</font>";
                                    response.contents[ 3 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>" + qualityName + "】</font>";
                                } else {
                                    var equipQuality : EquipQuality = getEquipQuality( response.contents[ 4 ] );
                                    qualityName = equipQuality.qualityName;
                                    qualityLevelValue  = int( equipQuality.qualityColour );
                                    response.contents[ 3 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>【" + response.contents[ 3 ] + "</font>";
                                    response.contents[ 4 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>" + qualityName + "】</font>";
                                }
                            } else if( marqueeId == 501 ){//神器
                                var artifactQuality : ArtifactQuality = getArtifactQuality( response.contents[ 3 ] );
                                qualityName = artifactQuality.qualityName;
                                qualityLevelValue  = int( artifactQuality.qualityColour );
                                response.contents[ 2 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>【" + response.contents[ 2 ] + "</font>";
                                response.contents[ 3 ] = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[ qualityLevelValue ] + "'>" + qualityName + "】</font>";
                            }
                        }
                        responseData[i] = response.contents[ i ];
                        content = content.replace( replaceKey, response.contents[ i ] );
                    }
                }
                msg = content;
                showTime = record.showTime;

                var ownerUID:Number = 0;
                if (response.contents && response.contents.length > 0) {
                    var tempLastParamData:Object = response.contents[response.contents.length-1];
                    ownerUID = (Number)(tempLastParamData);
                }

                //添加到聊天窗口显示
                var chatMsg : String = msg;
                var guideType : Array = record.guideType.split('/');
                for each ( var channelType : int in guideType ){
                    if( channelType > CChatChannel.ALL && channelType <= CChatChannel.GETITEM ){
                        if( record.linkWord.length > 0 ){
                            if( chatMsg.indexOf( record.linkWord ) != - 1 ) {
                                var taskTargetStr : String = HtmlUtil.hrefAndU( record.linkWord, CChatLinkConst.MARQUEE_TARGET, "#8bef3a" );
                                chatMsg = chatMsg.replace( record.linkWord, taskTargetStr );
                            }
                        }
                        if( ownerUID != _playerData.ID && record.roleNameLink && record.roleNameLink.length > 0 ){
                            var roleNameLinkAry : Array = record.roleNameLink.split(',');
                            var roleIDAry : Array = String( response.contents[ response.contents.length - 1 ] ).split(',');
                            var roleIdIndex : int ;
                            var roleNameLinkStr : String = '';
                            for( roleIdIndex = 0 ; roleIdIndex < roleNameLinkAry.length ; roleIdIndex++ ){
                                roleNameLinkStr = HtmlUtil.hrefAndU( response.contents[ int(roleNameLinkAry[roleIdIndex]) ], CChatLinkConst.MARQUEE_ROLE_TARGET + roleIDAry[roleIdIndex], "#8bef3a" );
                                chatMsg = chatMsg.replace( response.contents[ int(roleNameLinkAry[roleIdIndex]) ], roleNameLinkStr );
                                responseData[CChatLinkConst.MARQUEE_ROLE_TARGET + roleIDAry[roleIdIndex]] = roleIDAry[roleIdIndex];
                                responseData['marqueeRoleName'] = response.contents[ int(roleNameLinkAry[roleIdIndex]) ];
                            }
                        }
                        if( chatSystem )
                            chatSystem.addSystemMsg( chatMsg , channelType , record ,responseData);
//                              chatSystem.addSystemMsg(msg,response.channelType);
                    }else if( channelType == 8 ){
                        var pData : CMarqueeData = system.getBean( CMarqueeData ) as CMarqueeData;
                        if ( pData ) {
                            pData.push( msg, showTime);
                        }

                        var viewHandler:CMarqueeViewHandler = system.getBean( CMarqueeViewHandler ) as CMarqueeViewHandler;
                        if( viewHandler ){
                            system.stage.callLater( viewHandler.startMarquee );
                        }
                    }
                }
            }
        }

//        if( marqueeId == 0 && response.channelType == CHANNEL_TYPE_4 ){
//            var mqData : CMarqueeData = system.getBean( CMarqueeData ) as CMarqueeData;
//            if ( mqData ) {
//                mqData.push( msg, showTime);
//            }
//
//            var mqViewHandler:CMarqueeViewHandler = system.getBean( CMarqueeViewHandler ) as CMarqueeViewHandler;
//            if( mqViewHandler ){
//                system.stage.callLater( mqViewHandler.startMarquee );
//            }
//        }


    }

    private function getPlayerQuality( id : int ):PlayerQuality{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL );
        return pTable.findByPrimaryKey( id );

    }
    private function getEquipQuality( id : int ):EquipQuality{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.EQUIP_QUALITY_LEVEL );
        return pTable.findByPrimaryKey( id );

    }
    private function getArtifactQuality( id : int ):ArtifactQuality{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.ARTIFACTQUALITY );
        return pTable.findByPrimaryKey( id );

    }


    private function get chatSystem():CChatSystem{
        return (system.stage.getSystem( CChatSystem ) as CChatSystem );
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem
    }


}
}
