//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/10/17.
 */
package kof.game.club.view.clubview {

import kof.framework.CViewHandler;
import kof.game.club.CClubEvent;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.ui.master.club.ClubLogViewUI;

public class CClubLogViewHandler extends CViewHandler {

    private var clubLogViewUI : ClubLogViewUI;

    public function CClubLogViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    public function updateView( clubLogViewUI : ClubLogViewUI ):void {
        if ( !_pClubManager.selfClubData )
            return;
        this.clubLogViewUI = clubLogViewUI;

        system.removeEventListener( CClubEvent.CLUB_LOG_RESPONSE,_logListHandler );
        system.addEventListener( CClubEvent.CLUB_LOG_RESPONSE,_logListHandler );
    }

    private function _logListHandler( evt : CClubEvent  ):void{
        var logList : Array;
        var logObj : Object;
        var str : String = '';
        var date : Date;
        var logDicAry : Array = evt.data as Array;
        for each( logList in logDicAry ){
            date = new Date( logList[0].createTime );
            str = str + "<font color='#f0ecec' size='16' bold='true'>" + (date.month + 1 ) + '月' + date.date + '日' +  "</font>" + '\n';
            for each( logObj in logList ){
                str = str + CClubConst.logStr( logObj.type , logObj.desc ,logObj.createTime ) + '\n';
            }
            str = str + '\n';
        }
        clubLogViewUI.txt_log.text = str;
        clubLogViewUI.txt_log.height = clubLogViewUI.txt_log.textField.textHeight ;

        callLater( function refresh():void{
            clubLogViewUI.kofpanel.scrollTo( 0,0 );
            clubLogViewUI.kofpanel.refresh();
        })
    }



    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
}
}
