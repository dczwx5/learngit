package a_core.character.builder
{
import laya.resource.IDispose;
import a_core.game.ecsLoop.CGameObject;
import a_core.character.builder.ICharacterBuilder;
import a_core.character.CCharacterDataDescriptor;
import a_core.CBaseData;
import a_core.character.builder.CPlayerBuilder;
import a_core.framework.CBean;
import a_core.scene.ISceneFacade;

/**
	* ...
	* @author
	*/
public class CCharacterBuilder extends CBean implements IDispose {
	public function CCharacterBuilder(){
		m_pPlayerBuilder = new CPlayerBuilder();
	}

	public function dispose() : void {

	}

	public function build(obj:CGameObject, data:Object) : void {
		obj.system = system;
		obj.sceneFacade = system.stage.getSystem(ISceneFacade) as ISceneFacade;
		
		var type:int = data[CBaseData._TYPE];

		if (CCharacterDataDescriptor.isPlayer(type)) {
			m_pPlayerBuilder.build(obj, data);
		}
	}

	public function set playerBuilder(v:ICharacterBuilder) : void {
		m_pPlayerBuilder = v;
	}

	private var m_pPlayerBuilder:ICharacterBuilder;
}

}