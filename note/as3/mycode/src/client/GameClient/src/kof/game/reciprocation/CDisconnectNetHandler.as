//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/7/3.
 */
package kof.game.reciprocation {

import QFLib.Utils.StringUtil;

import kof.data.KOFTableConstants;
import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.message.CAbstractPackMessage;
import kof.message.Common.DisconnectionReasonResponse;
import kof.table.GamePrompt;

public class CDisconnectNetHandler extends CSystemHandler {
    public function CDisconnectNetHandler() {
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _addNetListeners();
        return ret;
    }

    private function _addNetListeners() : void {
        networking.bind( DisconnectionReasonResponse ).toHandler( _disconnectionResponse );
    }

    private final function _disconnectionResponse( net : INetworking, message : CAbstractPackMessage ) : void {
        var response : DisconnectionReasonResponse = message as DisconnectionReasonResponse;
        if ( response ) {
            var pView : CDisconnectViewHandler = system.getBean( CDisconnectViewHandler ) as CDisconnectViewHandler;
            // 如果有自定义的提示，强制使用
            if ( response.customMsg && response.customMsg != 'undefined' ) {
                if ( pView ) {
                    pView.disconnectReason = response.customMsg;
                }
            } else { // 通过表格定义查找提示
                var gamePromptTable : IDataTable = (system.stage.getSystem( IDatabase ) as IDatabase).getTable( KOFTableConstants.GAME_PROMPT );
                var tableData : GamePrompt = gamePromptTable.findByPrimaryKey( response.reasonID ) as GamePrompt;
                if ( pView && tableData ) {
                    var strMessage : String = tableData.content;

                    if ( response.contents && response.contents.length ) {
                        for ( var s : int = 0, e : int = response.contents.length; s < e; s++ ) {
                            strMessage = strMessage.replace( '{' + s + '}', response.contents[ s ] );
                        }
                    }

                    var replaceTokens : Array = strMessage.match( /\{\d\}/g );
                    if ( replaceTokens && replaceTokens.length > 1 ) {
                        for ( s = 0, e = response.contents.length; s < e; s++ ) {
                            strMessage = strMessage.replace( replaceTokens[ s ], '' );
                        }
                    }

                    if ( !StringUtil.trimAll( strMessage ) ) {
                        strMessage = "Unknown reason, but socket closed!";
                    }

                    pView.disconnectReason = strMessage;
                }
            }

            networking.close();
        }
    }
}
}
