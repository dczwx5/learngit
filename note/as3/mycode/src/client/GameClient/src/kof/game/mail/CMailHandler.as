//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/15.
 */
package kof.game.mail {

import kof.SYSTEM_ID;
import kof.framework.INetworking;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CNetHandlerImp;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.message.CAbstractPackMessage;
import kof.message.Mail.MailAttachRecvRequest;
import kof.message.Mail.MailDeleteRequest;
import kof.message.Mail.MailListRequest;
import kof.message.Mail.MailListResponse;
import kof.message.Mail.MailReadRequest;
import kof.message.Mail.MailUpdateResponse;

public class CMailHandler extends CNetHandlerImp {
    public function CMailHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(MailListResponse, _onMailListResponseHandler);
        this.bind(MailUpdateResponse, _onMailUpdateResponseHandler);

        this.onMailListRequest();
        return ret;
    }
    /**********************Request********************************/

    /*邮件列表请求*/
    public function onMailListRequest( ):void{
        var request:MailListRequest = new MailListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*邮件阅读请求*/
    public function onMailReadRequest( uid : Number ):void{
        var request:MailReadRequest = new MailReadRequest();
        request.decode([uid]);

        networking.post(request);
    }
    /*邮件附件提取请求*/
    public function onMailAttachRecvRequest( type : int , uid : Number = 0 ):void{
        var request:MailAttachRecvRequest = new MailAttachRecvRequest();
        request.decode([type,uid]);

        networking.post(request);
    }
    /*邮件一键删除请求*/
    public function onMailDeleteRequest( ):void{
        var request:MailDeleteRequest = new MailDeleteRequest();
        request.decode([1]);

        networking.post(request);
    }


    /**********************Response********************************/

    private final function _onMailListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:MailListResponse = message as MailListResponse;
        _mailManager.initialMailData(response);
        if( _mailManager.hasNewMail || _mailManager.hasItemMail ){
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_MAIL]);
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }
    }
    private final function _onMailUpdateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:MailUpdateResponse = message as MailUpdateResponse;
        _mailManager.updateMailData(response);

        system.dispatchEvent(new CMailEvent(CMailEvent.MAIL_UPDATE,response.updateType));
    }

    private function get _mailManager():CMailManager{
        return system.getBean( CMailManager ) as CMailManager;
    }
}
}
