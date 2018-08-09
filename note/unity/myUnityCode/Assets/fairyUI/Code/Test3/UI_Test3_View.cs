/** This is an automatically generated class by FairyGUI. Please do not modify it. **/

using FairyGUI;
using FairyGUI.Utils;

namespace Test3
{
	public partial class UI_Test3_View : GComponent
	{
		public GButton m_btn;

		public const string URL = "ui://edbftjexn2d70";

		public static UI_Test3_View CreateInstance()
		{
			return (UI_Test3_View)UIPackage.CreateObject("Test3","Test3_View");
		}

		public UI_Test3_View()
		{
		}

		public override void ConstructFromXML(XML xml)
		{
			base.ConstructFromXML(xml);

			m_btn = (GButton)this.GetChild("btn");
		}
	}
}