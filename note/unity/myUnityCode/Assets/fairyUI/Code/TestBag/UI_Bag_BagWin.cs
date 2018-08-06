/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_BagWin : GComponent
	{
		public Controller m_page;
		public UI_Bag_WindowFrame m_frame;
		public GList m_list;
		public GImage m_n9;
		public GImage m_n10;
		public GLoader m_n11;
		public GTextField m_n12;
		public GTextField m_n13;
		public GList m_n25;

		public const string URL = "ui://rbw1tv9tkcy10";

		public static UI_Bag_BagWin CreateInstance()
		{
			return (UI_Bag_BagWin)UIPackage.CreateObject("TestBag","BagWin");
		}

		public UI_Bag_BagWin()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_page = this.GetController("page");
			m_frame = (UI_Bag_WindowFrame)this.GetChild("frame");
			m_list = (GList)this.GetChild("list");
			m_n9 = (GImage)this.GetChild("n9");
			m_n10 = (GImage)this.GetChild("n10");
			m_n11 = (GLoader)this.GetChild("n11");
			m_n12 = (GTextField)this.GetChild("n12");
			m_n13 = (GTextField)this.GetChild("n13");
			m_n25 = (GList)this.GetChild("n25");
		}
	}
}