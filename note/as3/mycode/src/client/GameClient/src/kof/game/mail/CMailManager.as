//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/15.
 */
package kof.game.mail {

import QFLib.Interface.IUpdatable;

import com.greensock.easing.BounceOut;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.mail.data.CMailData;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.message.Mail.MailListResponse;
import kof.message.Mail.MailUpdateResponse;
import kof.table.MailSystem;

public class CMailManager extends CAbstractHandler implements IUpdatable {

    private var _mailTable:IDataTable;
    private var _mailDataAry:Array;
    private var _sortFlg : Boolean;

    public var readTheFirstMailFlg : Boolean;

    public function CMailManager() {
        super();
        _mailDataAry = [];
        _sortFlg = true;
    }

    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        _mailTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.MAIL_SYSTEM);

        return ret;
    }

    // ====================================S2C==================================================
    public function initialMailData(response:MailListResponse) : void {
        for each (var data:Object in response.mailList){
            initToDic(data);
        }
    }
    public function updateMailData(response:MailUpdateResponse) : void {
        //变更类型：1增加 2删除 3更新
        var data:Object;
        if( response.updateType == 1 ){
            for each ( data in response.mailUpdateData ){
                initToDic(data);
            }
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;
            if ( pSystemBundleCtx ) {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ) );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.NOTICE_ARGS,[CSystemNoticeConst.SYSTEM_MAIL]);
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, true );
            }
        }else if( response.updateType == 2 ){
            for each ( data in response.mailUpdateData ){
                deleteMailDataByUid(data[CMailData._uid]);
            }
        }else if( response.updateType == 3 ){
            for each ( data in response.mailUpdateData ){
                updateToDic(data);
            }
        }

        if(  response.updateType != 2 )
            _sortFlg = true;
    }



    private function initToDic(data:Object):void{
        var pCMailData : CMailData = new CMailData();
        _mailDataAry.push( pCMailData );
        pCMailData.updateDataByData(data);

    }
    private function updateToDic(data:Object):void{
        if( !data )
                return;
        var pCMailData:CMailData = getMailDataByUid(data[CMailData._uid]);
        if( pCMailData )
            pCMailData.updateDataByData(data);
    }

    public function getMailList():Array{
        if( _sortFlg && readTheFirstMailFlg ){
            _sortFlg = false;
            _mailDataAry.sort( sortItem );
        }
        return  _mailDataAry;
    }
    public function getMailDataByUid( uid : Number ):CMailData{
        var curCMailData : CMailData;
        for each( var pCMailData : CMailData in _mailDataAry ){
            if( pCMailData.uid == uid ){
                curCMailData = pCMailData;
                break;
            }
        }
        return  curCMailData;
    }

    public function getMailDataIndex(pCMailData:CMailData):int{
        return  _mailDataAry.indexOf(pCMailData);
    }
    public function deleteMailDataByUid(uid:Number):void{
        for each( var pCMailData : CMailData in _mailDataAry ){
            if( pCMailData.uid == uid ){
                _mailDataAry.splice( _mailDataAry.indexOf( pCMailData ) , 1 );
                break;
            }
        }
    }


    // 邮件状态
    //1 邮件没有附件，且邮件未阅读状态
    //2 邮件没有附件，且邮件已阅读状态
    //3 邮件有附件，且邮件未阅读状态
    //4 邮件有附件，附件未领取，邮件已阅读状态
    //5 邮件有附件，附件已领取，邮件已阅读状态

    //未读置顶>未读未置顶邮件  > 已读有未领取附件邮件（含置顶） > 其他已读已领取邮件（含置顶）
    private function sortItem(a:CMailData,b:CMailData):int{
        if( !a || !b  )
            return 0;
        ///////// -1的排在前面
        if( ( a.state == 1 || a.state == 3 ) && ( b.state == 2 || b.state == 4 || b.state == 5 ) ){//未读
            return -1;
        }else if( ( a.state == 2 || a.state == 4 || a.state == 5 ) && ( b.state == 1 || b.state == 3 ) ){
            return 1;
        }else{
            if(  a.top > b.top ){
                return -1;
            }else if( a.top < b.top ){
                return 1;
            }else{
                if(  a.state == 3 && b.state == 1 ){
                    return -1;
                }else if( a.state == 1 && b.state == 3   ){
                    return 1;
                }else{
                    if(  a.state == 4 && b.state == 2){
                        return -1;
                    }else if(   a.state == 2 && b.state == 4 ){
                        return 1;
                    }else{
                        if(  a.state == 4 && b.state == 5 ){
                            return -1;
                        }else if( a.state == 5 && b.state == 4  ){
                            return 1;
                        }else{
                            if( a.createTime < b.createTime ){
                                return -1;
                            }else if( a.createTime > b.createTime ){
                                return 1;
                            }else{
                                return 0;
                            }
                        }
                    }
                }
            }
        }
    }


   //新邮件
    public function get hasNewMail():Boolean{
        var bool : Boolean;
        for each( var pCMailData : CMailData in _mailDataAry ){
            if( pCMailData.state == 1 || pCMailData.state == 3 ){
                bool = true;
                break;
            }
        }
        return bool;
    }
    //有附件没有领取
    public function get hasItemMail():Boolean{
        var bool : Boolean;
        var pCMailData : CMailData;
        for each(  pCMailData  in _mailDataAry ){
            if( pCMailData.state == 3 || pCMailData.state == 4 ){
                bool = true;
                break;
            }
        }
        return bool;
    }
   //所有邮件的附件
    public function getAllMainItem():Array{
        var ary : Array = [];
        var pCMailData : CMailData;
        var obj : Object;
        for each(  pCMailData  in _mailDataAry ){
            if( pCMailData.state == 3 || pCMailData.state == 4 ){
                for each ( obj in pCMailData.attachs ){
                    var tempObj : Object = isObjInAry( obj , ary );
                    if( tempObj )
                        tempObj.num += obj.num;
                    else
                        ary.push( obj );
                }
            }
        }

        return ary;
    }
    private function isObjInAry( obj : Object ,ary : Array ):Object{
        var object : Object;
        for each ( object in ary ){
            if( obj.ID == object.ID ){
                return object;
                break;
            }
        }
        return null;
    }
    // ======================================table================================================
    public function getMailTableByID(baseID:int) : MailSystem{
        return _mailTable.findByPrimaryKey(baseID);
    }

    public function update(delta:Number) : void {

    }
}
}
