/**
 * Created by auto on 2016/7/15.
 */
package kof.game.scenario.enum {
	public class EScenarioPartType {
		public static const ACTOR_APPEAR:int = 1; // 角色出现
		public static const ACTOR_MOVE:int = 2; // 角色移动
		public static const ACTOR_PLAY_ACTION:int = 3; // 角色播放动作
		public static const ACTOR_TURN_TO:int = 4; // 角色转身
		public static const ACTOR_HIDE:int = 5; // 角色隐藏
		public static const ACTOR_ACTION_SPEED:int = 6; // 角色动作速度
		public static const ACTOR_SCALE:int = 7; // 角色缩放
		public static const ACTOR_PLAY_SKILL:int = 8; // 角色播放技能
		public static const ACTOR_TELEPORT: int = 9; // 角色瞬移
		public static const ACTOR_TOP_FACE: int = 91; // 角色表情
		public static const ACTOR_NOVIECE_SKILL: int = 92; // 草薙京播放技能（序章副本专用）
		public static const ACTOR_NOVIECE_SPEED: int = 93; // 播放速度（序章副本专用）

		public static const CAMERA_MOVE:int = 10; // 移动
		public static const CAMERA_SHAKE:int = 11; // 震动
		public static const CAMERA_SCALE:int = 12; // 缩放
		public static const CAMERA_SPEED:int = 13; // 速度
		public static const CAMERA_ROTATION:int = 14; // 旋转
		public static const CAMERA_RESET:int = 15; // 还原摄像机
		public static const CAMERA_TO_TARGET:int = 16; // 摄像机绑定到人物身上, 如果是绑定到主角身上。则用reset

		public static const AUDIO_PLAY:int = 20; // 播放
		public static const AUDIO_STOP:int = 21; // 停止
		public static const AUDIO_LOCATION:int = 22; // 位置
		public static const AUDIO_APPEAR:int = 23; // 出现
		public static const AUDIO_SPEED:int = 24; // 速度
		public static const AUDIO_RESET:int = 25; // 还原背景音乐

		public static const EFFECT_MOVE:int = 30; // 特效移动
		public static const EFFECT_APPEAR:int = 31; // 特效出现
		public static const EFFECT_PLAY:int = 32; // 特效播放
		public static const EFFECT_HIDE:int = 33; // 特效隐藏
		public static const EFFECT_SPEED:int = 34; // 特效播放速度

		public static const VIDEO_PLAY:int = 40; // 视频出现

		public static const SCENE_ANIMATION_PLAY:int = 45; // 播放场景动画

		public static const DIALOG_PLAY:int = 50; // 对话
		public static const DIALOG_BUBBLES:int = 51; // 冒泡对话
		public static const SCREEN_WHITE:int = 52; // 白屏
		public static const BLACK_WHITE:int = 53; // 黑屏
		public static const BLACKSCREEN_DIALOG:int = 54; // 黑幕对话

		public static const CG_ANIMATION:int = 60; // CG图片
		public static const MASTER_COMING:int = 61; // 强敌来袭

		public static const SCENE_NAME:int = 62; // 场景名称
		public static const SCENE_ROLL:int = 63; // 场景滚动

		public static const SYSTEM_STOP_PART:int = 100; // 停止某个动作
		public static const SYSTEM_STOP_PART_ALL:int = 101; // 停止所有动作, 包括未启动的

		/**
		public static const DIALOG:int = 0; // "对话",
		public static const MOVE:int = 4; // "移动",
		public static const CAST_SPELL:int = 1; // "施法",
		public static const SCREEN_EFFECT:int = 2; // "屏幕特效",
		public static const TIME_SCALE:int = 3; // "时间缩放",
		public static const CAMERA_MOVE:int = 5; // "镜头移动",
		public static const HIDE_OBJ:int = 6; // "隐藏对象",
		public static const SCREEN_FADE_IN:int = 7; // "屏幕淡入",
		public static const SCREEN_FADE_OUT:int = 8; // "屏幕淡出",
		public static const SCREEN_FADE_IN_OUT:int = 9; // "屏幕淡入淡出",
		public static const SUBTITLE:int = 11; // "显示文字",
		public static const TRANSITION_SCENE:int = 12; // 切换关卡，与，跳回原剧情，的区别，切换是保留原数据信息，只是都visible掉，而跳回原剧情，是要清空当前剧情信息的
		public static const PLAY_AUDIO:int = 13; // "播放音频",
		public static const PLAY_ACTION:int = 14; // "执行动作",
		public static const PLAY_ANIMATION:int = 15; // "播放动画",
		public static const PLAY_EFFECT:int = 16; // "播放特效",
		public static const SHOW_NUM:int = 17; // "伤害飘字", // 应该是显示数字（有可能是减、加：血、魔）
		public static const WALK_OFF_ACTOR:int = 18; // "演员退场",
		public static const BACK_TO_SRC_SCENARIO:int = 19; // "跳回原剧情",
		public static const TURN_ORIENTATION:int = 20; // "转身",
		public static const PLAY_SCENE_ANIMATION:int = 21; // "播放场景动画",
		public static const PLAY_SPAWNER_EFFECT:int = 23; // "播放场景刷怪点特效",
		public static const ENTITY_AI_PHASE_CHANGE:int = 24; // "实体aiPhase调整",
		public static const PLAY_VIDEO:int = 25; // "播放视频"
		public static const COMMIT_QUEST:int = 26; // "提交任务"
 */
	}
}