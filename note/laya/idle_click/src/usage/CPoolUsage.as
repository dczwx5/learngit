package usage
{
	import core.pool.CPoolSystem;
	import core.framework.CAppStage;
	import core.pool.CPoolBean;

	/**
	 * ...
	 * @author
	 */ 
	public class CPoolUsage{
		public function CPoolUsage(stage:CAppStage){
			var poolSystem:CPoolSystem = stage.getSystem(CPoolSystem) as CPoolSystem;
			var poolBean:CPoolBean = poolSystem.addPool("testPool", TestPoolObject);

			var obj1:TestPoolObject = poolBean.createObject();
			var obj2:TestPoolObject = poolBean.createObject();
			var obj3:TestPoolObject = poolBean.createObject();

			poolBean.recoverObject(obj1);
			poolBean.recoverObject(obj2);
			poolBean.recoverObject(obj3);
		}
	}

}

class TestPoolObject {

}