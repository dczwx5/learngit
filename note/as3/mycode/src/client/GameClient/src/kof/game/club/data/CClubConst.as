//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/27.
 */
package kof.game.club.data {

import QFLib.Utils.CDateUtil;
import QFLib.Utils.StringUtil;

import kof.message.Club.PlayerLuckyBagRecordResponse;

public class CClubConst {
    public function CClubConst() {
    }

    static public const NOT_IN_CLUB : int = 0; //未加入俱乐部

    static public const IN_CLUB : int = 1; //已加入俱乐部

    static public const SINGLE_APPLY : int = 0; //单个申请

    static public const QUICK_APPLY : int = 1; //快速申请

    static public const DEFAUL_NAME : String = '请输入名称';

    static public const ANNOUNCEMENT_MAX_CHARS : int = 100;//100个字符，50个汉字

    static public const CLUB_NAME_MAX_CHARS : int = 16;//16个字符，8个汉字

    //俱乐部主界面
    static public const CLUB_VIEW : int = 0;
    static public const CLUB_RANK : int = 1;
    static public const MANAGE_WELFARE : int = 2;
    static public const WELFARE_BAG : int = 3;
    static public const CLUB_FUND : int = 4;
    static public const CLUB_SHOP : int = 5;
    static public const GUILD_WAR : int = 6;
    static public const BA_JIE_JI_LAI_XI : int = 7;
    static public const DIAN_FENG_DUI_JUE : int = 8;

    //俱乐部大厅页签

    static public const CLUB_MEMBER : int = 0;
    static public const CLUB_LOG : int = 1;
    static public const CLUB_APPLY : int = 2;


    //加入条件
    static public const ANYONE_IN : int = 1;//1 允许任何人加入
    static public const ANYONE_APPLY : int = 2;//2 允许任何人申请(1级可申请)
    static public const ANYONE_IN_AND_LV : int = 3;//3 允许任何人加入有等级限制
    static public const ANYONE_APPLY_AND_LV : int = 4;//4 允许任何人申请但有等级限制
    static public const NOONE : int = 5;//不允许任何人加入
    static public const JOINCONDITIONARY : Array = ['','允许任何人加入','1级可以申请','级可以加入','级可以申请','不允许任何人加入'];

    public static function joinConditionStr( joinCondition : int, levelCondition : int ):String{
        var str : String = '';
        if( joinCondition == ANYONE_IN_AND_LV || joinCondition == ANYONE_APPLY_AND_LV )
            str = levelCondition + JOINCONDITIONARY[joinCondition];
        else
            str = JOINCONDITIONARY[joinCondition];
        return str;
    }

    //修改信息类型
    static public const CHANGE_ANNOUNCEMENT : int = 1;// 公告
    static public const CHANGE_NAME : int = 2;// 名称
    static public const CHANGE_ICON : int = 3;//标志
    static public const CHANGETYPE : Array = ['','公告','名称','标志'];

    //俱乐部职位
    static public const CLUB_POSITION_1 : int = 1;// 成员
    static public const CLUB_POSITION_2 : int = 2;// 理事
    static public const CLUB_POSITION_3 : int = 3;//副会长
    static public const CLUB_POSITION_4 : int = 4;//会长
    static public const CLUB_POSITION_STR : Array = ['','成员','理事','副会长','会长'];


    //俱乐部日志
    public static function logStr( type : int , par: Array ,createTime : Number):String{
        var str : String = '';
        str =   '[' + StringUtil.timeFormat2( createTime ) + '] ' ;
        switch ( type ){
            case 1:{
                str += "<font color='#ffd940' size='14'>" + par[0]  +  "</font>" + '创建了俱乐部，新的故事展开了！';
                break;
            }
            case 2:{
                str += '欢迎' + "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '加入俱乐部，让我们一起玩耍！';
                break;
            }
            case 3:{
                str += "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '退出了俱乐部，他在人生的道路上迷失了方向……';
                break;
            }
            case 4:{
                str += "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '被' + "<font color='#ffd940' size='14'>" + par[1] +  "</font>"  + '升职为' + CLUB_POSITION_STR[int(par[2])] + '。';
                break;
            }
            case 5:{
                str += "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '被' + "<font color='#ffd940' size='14'>" + par[1] +  "</font>"  + '降职为' + CLUB_POSITION_STR[int(par[2])] + '。';
                break;
            }
            case 6:{
                str += '会长' + "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '7天未上线被自动弹劾，' + "<font color='#ffd940' size='14'>" + par[1] +  "</font>"  + '接任了会长职务。';
                break;
            }
            case 7:{
                var joinCondition : int = int(par[1]);
                var levelCondition : int = int(par[2]);
                var conditionStr : String = '';
                if( joinCondition == ANYONE_IN_AND_LV || joinCondition == ANYONE_APPLY_AND_LV )
                    conditionStr = levelCondition + JOINCONDITIONARY[joinCondition];
                else
                    conditionStr = JOINCONDITIONARY[joinCondition];
                str += "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '更改了俱乐部加入条件为' + conditionStr + '。';
                break;
            }
            case 8:{
                var fundType : Array = ['','金币','钻石','至尊'];
                str += "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '在俱乐部投资中进行了' + "<font color='#ffd940' size='14'>" +
                        fundType[int(par[1])] +  "</font>" + '投资，增加建设值' + "<font color='#ffd940' size='14'>" + par[2] +  "</font>" + '点。';
                break;
            }
            case 9:{
                str += '在成员们的不懈努力下，俱乐部提升到了' + "<font color='#ffd940' size='14'>" + par[0] +  "</font>"  + '级。';
                break;
            }
            case 10:{
                str +=  "<font color='#ffd940' size='14'>" + par[0] +  "</font>" + '福星高照，成功招募到' +
                        "<font color='#ffd940' size='14'>" + par[1] +  "</font>" + '级格斗家' +
                        "<font color='#ffd940' size='14'>" + par[2] +  "</font>" + '！格斗家队伍实力越发壮大！';
                break;
            }
            case 11:{
                str +=  "<font color='#ffd940' size='14'>" + par[0] +  "</font>" + '孜孜不倦，成功将格斗家' +
                        "<font color='#ffd940' size='14'>" + par[1] +  "</font>" + '提升到了' +
                        "<font color='#ffd940' size='14'>" + par[2] +  "</font>" + '星！实力再度觉醒！';
                break;
            }
            case 12:{
                str +=  "<font color='#ffd940' size='14'>" + par[0] +  "</font>" + '富甲天下，成功将vip等级提升到了' +
                        "<font color='#ffd940' size='14'>" + par[1] +  "</font>" + '级！获得大量特权！';
                break;
            }
            case 13:{
                str +=  "<font color='#ffd940' size='14'>" + par[0] +  "</font>" + '大手一挥，充值了' +
                        "<font color='#ffd940' size='14'>" + par[1] +  "</font>" + '钻石！获得大量福利！';
                break;
            }
        }

        return str;
    }

    //dealType
    static public const AGREE : int = 0;// 同意
    static public const REFUSE : int = 1;// 拒绝
    static public const SINGLE : int = 0;// 单个
    static public const ALL : int = 1;// 一键

    //club member menu
    static public const CHECK_INFO : String = '查看信息';
    static public const TRANSFER_CHAIRMEN : String = '转让会长';
    static public const CHANGE_POSITION: String = '调整职位';
    static public const CLUB_FIRE : String = '请离俱乐部';

    //信息变化
    static public const FIRE : int = 1;// 被踢
    static public const POSITION_UP : int = 2;// 职位提升
    static public const POSITION_DOWN : int = 3;// 职位下降
    static public const APPLY_OK : int = 4;// 申请公会通过审核

    //俱乐部基金
    static public const NO_GET_FUND_ACTIVE : int = 0;// 没有领取
    static public const GOT_FUND_ACTIVE : int = 1;// 已经领取


    //俱乐部福袋页签
    static public const BAG_BASE_INFO : int = 0;
    static public const CLUB_BAG_SEND : int = 1;
    static public const CLUB_BAG_GET : int = 2;
    static public const CLUB_BAG_RECHARGE : int = 3;

    //福袋列表信息请求
    static public const CLUB_BAG_LIST : int = 1;
    static public const USER_BAG_LIST: int = 2;
    static public const RECHARGE_BAG_LIST: int = 3;

    //福袋主类型
    static public const BAG_SYSTEM : int = 1;//系统福袋
    static public const BAG_PLAYER : int = 2;//玩家福袋
    static public const BAG_RECHARGE : int = 3;//充值福袋

    //福袋子类型
    static public const BAG_GOLD_TYPE : int = 1;//金币
    static public const BAG_DIAMONDS_TYPE : int = 2;//钻石
    static public const BAG_ITEM_TYPE : int = 3;//道具

    static public const BAG_RECHARGE_TYPE : int = 4;//充值福袋

    //充值福袋类型
    static public const BAG_RECHARGE_SMALL : int = 0;//小
    static public const BAG_RECHARGE_MID : int = 1;//中
    static public const BAG_RECHARGE_BIG : int = 2;//大

    //福袋状态
    static public const CLUB_BAG_CAN_GET : int = 0;//未领取
    static public const CLUB_BAG_GOT: int = 1;//已抢
    static public const CLUB_BAG_NO_LESS: int = 2;//福袋已抢完
    static public const CLUB_BAG_NOT_IN_TIME: int = 3;//没在时间范围

    //福袋状态文字
    static public const CLUB_BAG_CAN_GET_STR : String = '抢福袋';
    static public const CLUB_BAG_GOT_STR : String = '已 抢';
    static public const CLUB_BAG_NO_LESS_STR : String = '抢 光';
    static public const CLUB_BAG_NOT_IN_TIME_STR : String = '不在时间内';

    //俱乐部系统福袋日志页签
    static public const BAG_LOG_GOLD_TYPE : int = 0;
    static public const BAG_LOG_DIAMONDS_TYPE : int = 1;
    static public const BAG_LOG_ITEM_TYPE : int = 2;
    static public const BAG_LOG_RECHARGE_TYPE : int = 3;


    // 福袋日志
    public static function baglogStr( obj :Object ):String{
        var str : String = '';
        var date : Date = new Date( obj.time );
        str += '您抢到了' +  obj.name + '的福袋，获得';
        var reward :  Object;
        for each( reward in obj.rewardList ){
            str += reward.rewardName + '*' + reward.num + ' '
        }

        return str;
    }


    //消息更新 type
    static public const APPLY_LIST_UPDATE : int = 1;
    static public const CLUB_LEVEL_UPDATE : int = 4;
    static public const CLUB_REDBAG_UPDATE : int = 3;

}
}
