//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/14.
 */
package kof.game.task.data {

import kof.game.KOFSysTags;

public class CTaskJumpConst {
    public function CTaskJumpConst() {
    }

    static public const SUB_CLUB_BAG : String = "sub_club_bag" ;

    static public function getJumpPare( condition : int ):String{
        var sysTag : String = "";

        switch ( condition ){
            case CTaskConditionType.Type_101:  sysTag = '';break;
            case CTaskConditionType.Type_102:  sysTag = '';break;
            case CTaskConditionType.Type_103:  sysTag = KOFSysTags.INSTANCE ; break;
            case CTaskConditionType.Type_104:  sysTag = KOFSysTags.ELITE ; break;
            case CTaskConditionType.Type_105:  sysTag = KOFSysTags.BUY_POWER ;break;
            case CTaskConditionType.Type_106:  sysTag = KOFSysTags.INSTANCE ;break;
            case CTaskConditionType.Type_107:  sysTag = KOFSysTags.ELITE ;break;
            case CTaskConditionType.Type_108:  sysTag = KOFSysTags.CARDPLAYER ;break;
            case CTaskConditionType.Type_109:  sysTag = '' ;break;
            case CTaskConditionType.Type_110:  sysTag = KOFSysTags.INSTANCE ;break;
            case CTaskConditionType.Type_111:  sysTag = KOFSysTags.BUY_WEEK_CARD ;break;
            case CTaskConditionType.Type_112:  sysTag = KOFSysTags.BUY_MONTH_CARD ;break;
            case CTaskConditionType.Type_113:  sysTag = KOFSysTags.ROLE ;break;
            case CTaskConditionType.Type_114:  sysTag = KOFSysTags.ROLE ;break;
            case CTaskConditionType.Type_115:  sysTag = KOFSysTags.ROLE ;break;
            case CTaskConditionType.Type_116:  sysTag = KOFSysTags.ARTIFACT ;break;
            case CTaskConditionType.Type_117:  sysTag = KOFSysTags.GUILD ;break;
            case CTaskConditionType.Type_118:  sysTag = KOFSysTags.CARDPLAYER ;break;
            case CTaskConditionType.Type_119:  sysTag = '';break;
            case CTaskConditionType.Type_120:  sysTag = KOFSysTags.ARENA;break;
            case CTaskConditionType.Type_121:  sysTag = KOFSysTags.PEAK_GAME;break;
            case CTaskConditionType.Type_122:  sysTag = KOFSysTags.TASKCALLUP;break;
            case CTaskConditionType.Type_123:  sysTag = '';break;
            case CTaskConditionType.Type_124:  sysTag = KOFSysTags.CULTIVATE;break;
            case CTaskConditionType.Type_125:  sysTag = KOFSysTags.PEAK_GAME_FAIR;break;
            case CTaskConditionType.Type_126:  sysTag = KOFSysTags.IMPRESSION;break;

            case CTaskConditionType.Type_127:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_128:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_129:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_130:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_131:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_132:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_133:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_134:  sysTag = KOFSysTags.PEAK_GAME_FAIR;break;
            case CTaskConditionType.Type_135:  sysTag = KOFSysTags.PEAK_GAME_FAIR;break;
            case CTaskConditionType.Type_136:  sysTag = KOFSysTags.BUY_MONEY;break;
            case CTaskConditionType.Type_137:  sysTag = KOFSysTags.ARTIFACT;break;
            case CTaskConditionType.Type_138:  sysTag = KOFSysTags.INSTANCE;break;
            case CTaskConditionType.Type_139:  sysTag = KOFSysTags.IMPRESSION;break;
            case CTaskConditionType.Type_140:  sysTag = KOFSysTags.TALENT;break;

            case CTaskConditionType.Type_141:  sysTag = KOFSysTags.PEAK_GAME_FAIR;break;
            case CTaskConditionType.Type_142:  sysTag = KOFSysTags.ENDLESS_TOWER;break;
            case CTaskConditionType.Type_143:  sysTag = CTaskJumpConst.SUB_CLUB_BAG;break;
            case CTaskConditionType.Type_144:  sysTag = KOFSysTags.EQUIP_CARD;break;
            case CTaskConditionType.Type_145:  sysTag = KOFSysTags.CARDPLAYER;break;

            case CTaskConditionType.Type_147:  sysTag = KOFSysTags.RANKING;break;


            case CTaskConditionType.Type_1001:  sysTag = KOFSysTags.ROLE ;break;
            case CTaskConditionType.Type_1002:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_1003:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_1004:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_1005:  sysTag = KOFSysTags.ROLE;break;
            case CTaskConditionType.Type_1006:  sysTag = KOFSysTags.TALENT;break;
        }

        return sysTag;

    }
}
}
