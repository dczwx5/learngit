package script {
	import laya.events.Event;
	import laya.events.MouseManager;
	import laya.display.Scene;
	import ui.test.GameSceneUI;
	/**
	 * 本示例采用非脚本的方式实现，而使用继承页面基类，实现页面逻辑。在IDE里面设置场景的Runtime属性即可和场景进行关联
	 * 相比脚本方式，继承式页面类，可以直接使用页面定义的属性（通过IDE内var属性定义），比如this.tipLbll，this.scoreLbl，具有代码提示效果
	 * 建议：如果是页面级的逻辑，需要频繁访问页面内多个元素，使用继承式写法，如果是独立小模块，功能单一，建议用脚本方
	 */
	public class MyScene extends GameSceneUI {
		
		/**设置单例的引用方式，方便其他类引用 */
		public static var instance:MyScene;
		/**当前游戏积分字段 */
		private var _score:Number;
		/**游戏控制脚本引用，避免每次获取组件带来不必要的性能开销 */
		private var _control:MyControl;
		
		public function MyScene():void {
			super();
			MyScene.instance = this;
			//关闭多点触控，否则就无敌了
			MouseManager.multiTouchEnabled = false;
		}
		
		override public function onEnable():void {
			this._control = this.getComponent(MyControl);
		}
	}
}