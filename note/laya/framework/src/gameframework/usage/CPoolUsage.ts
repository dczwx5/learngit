namespace gameframework {
export namespace usage {

/**
 * ...
 * @author auto 示例
 */ 
class CPoolUsage{
	public CPoolUsage(stage:framework.CAppStage){
		let poolSystem:pool.CPoolSystem = stage.getSystem(pool.CPoolSystem) as pool.CPoolSystem;
		let poolBean:pool.CPoolBean = poolSystem.addPool("testPool", TestPoolObject);

		let obj1:TestPoolObject = poolBean.createObject();
		let obj2:TestPoolObject = poolBean.createObject();
		let obj3:TestPoolObject = poolBean.createObject();

		poolBean.recoverObject(obj1);
		poolBean.recoverObject(obj2);
		poolBean.recoverObject(obj3);
	}
}

}

class TestPoolObject {

}
}