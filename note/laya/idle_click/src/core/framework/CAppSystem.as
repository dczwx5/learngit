package core.framework
{
	import core.framework.CViewBean;
	import core.framework.IUpdate;

	/**
	 * ...
	 * @author auto
	 */
	public class CAppSystem extends CContainerLifeCycle implements IUpdate {
		public function CAppSystem() {
			
		}
		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
			return ret;		
		}
		
		protected override function onDestroy() : void {
			m_stage = null;

			super.onDestroy();

			m_viewList = null;
		}

		// view
		public function getAllViewBean() : Vector.<CViewBean> {
			return m_viewList;
		}
		public function update(delta:Number) : void {
			if (m_viewList) {
				for each (var view:CViewBean in m_viewList) {
					if (view && view.isStarted) {
						if (view.isDirty) {
							view.updateData();
						}
					}
				}
			}
		}

		public override function addBean(o:CLifeCycle) : Boolean {
			var ret:Boolean = super.addBean(o);
			if (ret) {
				(o as CBean).system = this;
			}

			if (o is CViewBean) {
				if (!m_viewList) {
					m_viewList = new Vector.<CViewBean>();
				}
				m_viewList.push(o);
			}
			
			return ret;
		}
		public override function removeBean(b:CLifeCycle) : Boolean {
			var ret:Boolean = super.removeBean(b);
			if (b is CViewBean) {
				var idx:int = m_viewList.indexOf(b as CViewBean);
				m_viewList.splice(idx, 1);
			}
			return ret;
		}
		
		public function get stage() : CAppStage {
			return m_stage;
		}
		public function set stage(v:CAppStage) : void {
			m_stage = v;
		}

		private var m_stage:CAppStage;

		private var m_viewList:Vector.<CViewBean>;

	}

}