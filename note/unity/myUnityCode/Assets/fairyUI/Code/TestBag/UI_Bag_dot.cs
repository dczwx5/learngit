/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace TestBag
{
	public partial class UI_Bag_dot : GButton
	{
		public Controller m_button;
		public GGraph m_n23;
		public GGraph m_n22;

		public const string URL = "ui://rbw1tv9tosdok";

		public static UI_Bag_dot CreateInstance()
		{
			return (UI_Bag_dot)UIPackage.CreateObject("TestBag","dot");
		}

		public UI_Bag_dot()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_button = this.GetController("button");
			m_n23 = (GGraph)this.GetChild("n23");
			m_n22 = (GGraph)this.GetChild("n22");
		}
	}
}