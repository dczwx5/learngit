//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/16.
 */
package kof.game.gm {

public class CGMConfig {
    public function CGMConfig() {
    }

    public static const gmArr:Array = [
        {
            typeName : "增加类型命令 : 如增加货币,经验,道具以及功能系统积分等",
            gmCmd : [
                {
                    description : "增加战队经验，Usage：add_exp addValue",
                    label : "增加战队经验",
                    name : "add_exp"
                },
                {
                    description : "增加玩家背包道具，Usage：add_item itemID addValue",
                    label : "增加物品",
                    name : "add_item"
                },
                {
                    description : "加某种类型的所有道具，Usage：add_type_item type count",
                    label : "加某种类型的所有道具",
                    name : "add_type_item"
                },
                {
                    description : "增加体力，Usage：add_vit addValue",
                    label : "增加体力",
                    name : "add_vit"
                },
                {
                    description : "增加金币，Usage：add_gold addValue",
                    label :"增加金币",
                    name : "add_gold"
                },
                {
                    description : "增加钻石，Usage：add_blue_diamond addValue",
                    label :"增加钻石",
                    name : "add_blue_diamond"
                },
                {
                    description : "添加蓝钻但不加vip经验，Usage：add_not_vip_blue addValue",
                    label :"添加蓝钻但不加vip经验",
                    name : "add_not_vip_blue"
                },
                {
                    description : "增加绑定钻石，Usage：add_purple_diamond addValue",
                    label :"增加绑定钻石",
                    name : "add_purple_diamond"
                },
                {
                    description : "增加巅峰赛积分，Usage：add_peak_score addValue",
                    label :"增加巅峰赛积分",
                    name : "add_peak_score"
                },
                {
                    description : "添加斗魂，Usage：add_soul addValue",
                    label : "添加斗魂",
                    name : "add_soul"
                },
                {
                    description : "添加货币，Usage：add_currency type count",
                    label : "添加货币",
                    name : "add_currency"
                },
                {
                    description : "加公平巅峰赛积分，Usage：add_fair_peak_score addValue",
                    label : "加公平巅峰赛积分",
                    name : "add_fair_peak_score"
                },
                {
                    description : "通过道具模糊名加道具，Usage：add_item_by_name 道具模糊名 count",
                    label : "通过道具模糊名加道具",
                    name : "add_item_by_name"
                },
                {
                    description : "添加神器能量，Usage：add_artifact_energy addValue",
                    label : "添加神器能量",
                    name : "add_artifact_energy"
                },
                {
                    description : "充值，Usage：add_recharge addValue",
                    label : "充值",
                    name : "add_recharge"
                }
                    ]
        },
        /*{
            typeName : "副本相关",
            gmCmd : [
                {
                    description : "通过所有副本",
                    label : "通过所有副本",
                    name : "pass_all_instance"
                },
                {
                    description : "请求进入指定副本，Usage：enter_instance instanceID",
                    label :"进入副本",
                    name : "enter_instance"
                },
                {
                    description : "退出当前副本，Usage：exit_instance",
                    label :"退出副本",
                    name : "exit_instance"
                },
                {
                    description : "通过副本，Usage：pass_instance",
                    label :"通过副本",
                    name : "pass_instance"
                }
            ]
        },*/
        {
            typeName : "格斗家相关",
            gmCmd : [
                {
                    description : "一键招募所有格斗家，Usage：add_all_hero",
                    label : "一键招募所有格斗家",
                    name : "add_all_hero"
                },
                {
                    description : "招募单个格斗家，Usage：add_hero roleId",
                    label :"招募单个格斗家",
                    name : "add_hero"
                },
                {
                    description : "招募单个格斗家，Usage：set_all_hero 等级 品质 星级",
                    label :"设置所有格斗家等级品质星级",
                    name : "set_all_hero"
                }
            ]
        },
        {
            typeName : "新手引导",
            gmCmd : [
                {
                    description : "通过所有系统指引",
                    label : "通过所有系统指引",
                    name : "passAllGuideTutor"
                },
                {
                    description : "执行系统指引，Usage：startGuideTutor <tutor group id>",
                    label :"执行系统指引",
                    name : "startGuideTutor"
                },
                {
                    description : "停止系统指引，Usage：stopGuideTutor",
                    label :"停止系统指引",
                    name : "stopGuideTutor"
                },
                {
                    description : "执行战斗引导，Usage：startBattleTutor tutorId",
                    label :"执行战斗引导",
                    name : "startBattleTutor"
                },
                {
                    description : "启动ActionID系统指引，Usage：startGuideAction <ActionTutorID>",
                    label :"启动ActionID系统指引",
                    name : "startGuideAction"
                },
                {
                    description : "关闭引导组的开启限制，Usage：closeGuideGroupStartCondition",
                    label :"关闭引导开启限制",
                    name : "closeGuideGroupStartCondition"
                }
                    ]
        },
        {
            typeName : "系统功能相关：",
            gmCmd : [
                {
                    description : "添加邮件(附件参数为可选)，Usage：reset_new_Server baseID resourceID:count",
                    label : "添加邮件",
                    name : "add_mail"
                },
                {
                    description : "GM广播消息（走马灯），Usage：marquee_msg 要发送内容",
                    label : "GM广播消息（走马灯）",
                    name : "marquee_msg"
                },
                {
                    description : "设置为新服，Usage：reset_new_Server",
                    label : "设置为新服",
                    name : "reset_new_Server"
                },
                {
                    description : "关闭作弊检测，Usage：close_cheat",
                    label :"关闭作弊检测",
                    name : "close_cheat"
                },
                {
                    description : "刷新签到状态，Usage：refresh_sign_in",
                    label :"刷新签到状态",
                    name : "refresh_sign_in"
                },
                {
                    description : "刷新签到天数，Usage：refresh_sign_days",
                    label :"刷新签到天数",
                    name : "refresh_sign_days"
                },
                {
                    description : "刷新玩家的所有膜拜与被膜拜次数，Usage：arena_refresh_worship",
                    label :"刷新玩家的所有膜拜与被膜拜次数",
                    name : "arena_refresh_worship"
                },
                {
                    description : "刷新资源副本次数 : Usage：clear_resource_instance_challenge_num 副本类型ID",
                    label :"刷新资源副本次数",
                    name : "clear_resource_instance_challenge_num"
                },
                {
                    description : "通过主线任务 : Usage：plottask count",
                    label :"通过主线任务",
                    name : "plottask"
                },
                {
                    description : "停止焦点丢失提示 : Usage：close_focusLost_tip",
                    label :"关闭焦点丢失提示",
                    name : "close_focusLost_tip"
                },
                {
                    description : "打开焦点丢失提示 : Usage：open_focusLost_tip",
                    label :"打开焦点丢失提示",
                    name : "open_focusLost_tip"
                },
                {
                    description : "清空制定类型货币，Usage：clear_currency type",
                    label : "清空制定类型货币",
                    name : "clear_currency"
                },
                {
                    description : "清空道具，Usage：clear_item",
                    label : "清空道具",
                    name : "clear_item"
                },
                {
                    description : "一键开启所有系统，Usage：open_all_system",
                    label : "一键开启所有系统",
                    name : "open_all_system"

                },
                {
                    description : "修改神器等级，Usage：add_artifact_level ID addValue",
                    label : "修改神器等级",
                    name : "add_artifact_level"
                },
                {
                    description : "试炼之地每日重置，Usage：reset_climb_tower",
                    label : "试炼之地每日重置",
                    name : "reset_climb_tower"
                },
                {
                    description : "打开挂机面板，Usage：open_hangUpView",
                    label : "打开挂机面板",
                    name : "open_hangUpView"
                },
                {
                    description : "不再弹出机系统，Usage：close_hangUpSystem",
                    label : "取消挂机",
                    name : "close_hangUpSystem"
                }
            ]
        }
    ];
}
}
