/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_BagGridSub : GButton
	{
		public Controller m_button;
		public GImage m_n13;
		public GLoader m_icon;
		public GImage m_n12;
		public GTextField m_title;

		public const string URL = "ui://rbw1tv9tjlmg7";

		public static UI_Bag_BagGridSub CreateInstance()
		{
			return (UI_Bag_BagGridSub)UIPackage.CreateObject("TestBag","BagGridSub");
		}

		public UI_Bag_BagGridSub()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_button = this.GetController("button");
			m_n13 = (GImage)this.GetChild("n13");
			m_icon = (GLoader)this.GetChild("icon");
			m_n12 = (GImage)this.GetChild("n12");
			m_title = (GTextField)this.GetChild("title");
		}
	}
}