package core.character.builder
{
import laya.resource.IDispose;
import core.game.ecsLoop.CGameObject;
import core.character.builder.ICharacterBuilder;
import core.character.CCharacterDataDescriptor;
import core.CBaseData;
import core.character.builder.CPlayerBuilder;
import core.framework.CBean;
import core.scene.ISceneFacade;

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