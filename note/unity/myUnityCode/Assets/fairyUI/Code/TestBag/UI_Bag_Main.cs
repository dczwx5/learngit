/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_Main : GComponent
	{
		public UI_Bag_BagButton m_bagBtn;
		public GGroup m_n1;
		public GTextField m_n2;

		public const string URL = "ui://rbw1tv9tfvaib";

		public static UI_Bag_Main CreateInstance()
		{
			return (UI_Bag_Main)UIPackage.CreateObject("TestBag","Main");
		}

		public UI_Bag_Main()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_bagBtn = (UI_Bag_BagButton)this.GetChild("bagBtn");
			m_n1 = (GGroup)this.GetChild("n1");
			m_n2 = (GTextField)this.GetChild("n2");
		}
	}
}