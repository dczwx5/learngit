package core.framework
{

	/**
	 * ...
	 1.update/fixUpdate : 继承IUpdate/IFixUpdate的system, 会自动调用update与fixUpdate, 并不会往下自动调用(避免调用太多无用的update)
	 2.在OnAwake中addBean的节点, 会自动启动, 其他的需要自行调用awake与start:
	 	如 : (在awake之外添加)
			addBean(b);
			b.awake();
			b.start();
	 * @author auto
	 */
	public class CAppStage extends CContainerLifeCycle implements IUpdate, IFixUpdate {
		public function CAppStage(){
			
		}

		public function update(deltaTime:Number) : void {
			var b:CLifeCycle;
			var beans:Vector.<CLifeCycle> = getBeans();
			var iCount:int = beans.length;
			for (var i:int = 0; i < iCount; i++) {
				b = beans[i];
				if (b.isStarted) {
					if (b is IUpdate) {
						(b as IUpdate).update(deltaTime);
					}
				}
			}
		}
		public function fixUpdate(fixTime:Number) : void {
			var b:CLifeCycle;
			var beans:Vector.<CLifeCycle> = getBeans();
			var iCount:int = beans.length;
			for (var i:int = 0; i < iCount; i++) {
				b = beans[i];
				if (b.isStarted) {
					if (b is IFixUpdate) {
						(b as IFixUpdate).fixUpdate(fixTime);
					}
				}
			}
		}
		
		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : void {
			super.onStart();
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function getSystem(clazz:Class) : CAppSystem {
			return this.getBean(clazz) as CAppSystem;
		}
		public function addSystem(sys:CAppSystem) : Boolean {
			if (this.addBean(sys)) {
				sys.stage = this;
			}
			return false;
		}
		public function removeSystem(sys:CAppSystem) : Boolean {
			return this.removeBean(sys);
		}
	}

}