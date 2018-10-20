package laya.physics.joint {
	import laya.components.Component;
	import laya.physics.Physics;
	import laya.physics.RigidBody;
	
	/**
	 * 齿轮关节：用来模拟两个齿轮间的约束关系，齿轮旋转时，产生的动量有两种输出方式，一种是齿轮本身的角速度，另一种是齿轮表面的线速度
	 */
	public class GearJoint extends Component {
		/**[首次设置有效]要绑定的第1个关节，类型可以是RevoluteJoint或者PrismaticJoint*/
		public var joint1:*;
		/**[首次设置有效]要绑定的第2个关节，类型可以是RevoluteJoint或者PrismaticJoint*/
		public var joint2:*;
		/**[只读]原生关节对象*/
		public var joint:*;
		
		/**两个齿轮角速度比例，默认1*/
		private var _ratio:Number = 1;
		
		override protected function _onEnable():void {
			_createJoint();
		}
		
		override protected function _onAwake():void {
			_createJoint();
		}
		
		private function _createJoint():void {
			if (!joint) {
				if (!joint1) throw "Joint1 can not be empty";
				if (!joint2) throw "Joint2 can not be empty";
				
				var box2d:* = window.box2d;
				var def:* = new box2d.b2GearJointDef();
				def.bodyA = joint1.owner.getComponent(RigidBody).getBody();
				def.bodyB = joint2.owner.getComponent(RigidBody).getBody();
				def.joint1 = joint1.joint;
				def.joint2 = joint2.joint;
				def.ratio = _ratio;
				joint = Physics.I._createJoint(def);
			}
		}
		
		override protected function _onDisable():void {
			Physics.I._removeJoint(joint);
			joint = null;
		}
		
		/**两个齿轮角速度比例，默认1*/
		public function get ratio():Number {
			return _ratio;
		}
		
		public function set ratio(value:Number):void {
			_ratio = value;
			if (joint) joint.SetRatio(value);
		}
	}
}