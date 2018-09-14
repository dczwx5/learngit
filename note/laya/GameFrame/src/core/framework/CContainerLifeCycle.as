package core.framework
{
	/**
	 * ...
	 * @author auto
	 */
	public class CContainerLifeCycle extends  CLifeCycle {
		public function CContainerLifeCycle(){
			m_beanList = new Vector.<CLifeCycle>();
			m_unReadyBeanList = new Vector.<CLifeCycle>();
			m_unStartBeanList = new Vector.<CLifeCycle>();
		}

		// =================================================

		public override function destroy() : void {
			super.destroy();

			for (var i:int = m_beanList.length - 1; i >= 0; i--) {
				var o:CLifeCycle = m_beanList[i];
				o.destroy();
			}
		}

		public override function awake() : void {
			super.awake();
			
			if (m_unReadyBeanList.length > 0) {
				for (var i:int = 0; i < m_unReadyBeanList.length; i++) {
					var o:CLifeCycle = m_unReadyBeanList[i];
					o.awake();

					if (o.isAwaked) {
						m_unReadyBeanList.splice(i, 1);
						i--;
						m_unStartBeanList.push(o);
					}
					
				}

			}
		}

		// 
		public override function start() : Boolean {
			var ret:Boolean = super.start();
			if (!ret) {
				return ret;
			}

			if (m_unStartBeanList.length > 0) {
				for (var i:int = 0; i < m_unStartBeanList.length; i++) {
					var o:CLifeCycle = m_unStartBeanList[i];
					ret = o.start();
					if (!ret) {
						return ret;
					}

					if (o.isStarted) {
						m_unStartBeanList.splice(i, 1);
						i--;
					}
				}
			}
			return true;
		}

		// =================================================


		protected override function onAwake() : void {
			super.onAwake();
		}
		// onStart如果return false, 则会多次调用直到为true
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}


		// =================================================

		public function getBean(clz:Class) : CLifeCycle {
			if (m_beanList) {
				for each (var o:CLifeCycle in m_beanList) {
					if (o is clz) {
						return o;
					}
				}
			}
			return null;
		}
		public function getBeans() : Vector.<CLifeCycle> {
			return m_beanList;
		}

		public function removeBean(b:CLifeCycle) : Boolean {
			if (!b) {
				return false;
			}

			var index:int = m_beanList.indexOf(b);
			if (-1 == index) {
				return false;
			}

			m_beanList.splice(index, 1);

			index = m_unReadyBeanList.indexOf(b);
			if (-1 != index) {
				m_unReadyBeanList.splice(index, 1);
			}

			index = m_unStartBeanList.indexOf(b);
			if (-1 != index) {
				m_unStartBeanList.splice(index, 1);
			}
			return true;
		}

		public function addBean(o:CLifeCycle) : Boolean {
			if (!o) {
				return false;
			}

			if (contains(o)) {
				return false;
			}

			m_beanList.push(o);
			m_unReadyBeanList.push(o);

			return true;
		}

		public function contains(o:CLifeCycle) : Boolean {
			for each (var b:CLifeCycle in m_beanList) {
				if (b == o) {
					return true;
				}
			}
			return false;
		}

		private var m_beanList:Vector.<CLifeCycle>;
		private var m_unReadyBeanList:Vector.<CLifeCycle>;
		private var m_unStartBeanList:Vector.<CLifeCycle>;
	}

}