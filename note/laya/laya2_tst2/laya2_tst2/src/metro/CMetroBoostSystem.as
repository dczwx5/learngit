package metro
{
	import a_core.framework.CAppSystem;
	import a_core.character.CCharacterSystem;
	import a_core.character.builder.CCharacterBuilder;
	import metro.role.CMetroRoleBuilder;

	/**
	 * ...
	 * @author
	 */
	public class CMetroBoostSystem extends CAppSystem {
		public function CMetroBoostSystem(){
			
		}

		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
		
			// 替换playerBuilder为CMetroRoleBuiler;
			var pCharacterSystem:CCharacterSystem = stage.getSystem(CCharacterSystem) as CCharacterSystem;
			var characterBuilder:CCharacterBuilder = pCharacterSystem.getBean(CCharacterBuilder) as CCharacterBuilder;
			characterBuilder.playerBuilder = new CMetroRoleBuilder();

			return ret;
		}
	}

}